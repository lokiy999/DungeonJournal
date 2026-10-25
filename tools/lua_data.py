"""Read DungeonJournal's raid files (and DungeonJournalTactics) as plain Python data.

There is no Lua on the PC or the server, so this evaluates the small subset the data files use:
`local NAME = <table>` declarations, string / number / boolean literals, `..` string joins,
references to earlier locals, and calls to helper functions given in `calls`
(e.g. Tactics' sep / bsep / rw). Function bodies (BuildXBosses etc.) are skipped; the raid
layout is rebuilt by `load_raid` the same way those functions do it.
"""
import re

_TOK = re.compile(r"""
    (?P<ws>\s+)
  | (?P<lcomment>--\[(?P<eq>=*)\[.*?\](?P=eq)\])
  | (?P<comment>--[^\n]*)
  | (?P<lstr>\[(?P<eq2>=*)\[.*?\](?P=eq2)\])
  | (?P<str>"(?:[^"\\\n]|\\.)*"|'(?:[^'\\\n]|\\.)*')
  | (?P<num>0[xX][0-9a-fA-F]+|\d+\.?\d*(?:[eE][+-]?\d+)?|\.\d+)
  | (?P<name>[A-Za-z_]\w*)
  | (?P<op>\.\.\.|\.\.|==|~=|<=|>=|[-+*/%^#<>=(){}\[\];:,.])
""", re.S | re.X)
_ESC = {"n": "\n", "t": "\t", "\\": "\\", '"': '"', "'": "'", "\n": "\n"}


def _unquote(s):
    body = s[1:-1]
    return re.sub(r"\\(.)", lambda m: _ESC.get(m.group(1), m.group(1)), body, flags=re.S)


def tokenize(src):
    toks, pos = [], 0
    while pos < len(src):
        m = _TOK.match(src, pos)
        if not m:
            raise SyntaxError(f"cannot read line {src.count(chr(10), 0, pos) + 1}")
        kind = next(k for k in ("ws", "lcomment", "comment", "lstr", "str", "num", "name", "op") if m.group(k) is not None)
        if kind not in ("ws", "lcomment", "comment"):
            toks.append((kind, m.group(0), src.count("\n", 0, pos) + 1))
        pos = m.end()
    toks.append(("eof", "", -1))
    return toks


class _Parser:
    def __init__(self, toks, env, calls):
        self.t, self.i, self.env, self.calls = toks, 0, env, calls

    def peek(self, k=0):
        return self.t[self.i + k]

    def take(self, value=None):
        tok = self.t[self.i]
        if value is not None and tok[1] != value:
            raise SyntaxError(f"line {tok[2]}: expected {value!r}, got {tok[1]!r}")
        self.i += 1
        return tok

    def expr(self):
        v = self.atom()
        while self.peek()[1] == "..":
            self.take()
            v = f"{v}{self.atom()}"
        return v

    def atom(self):
        kind, v, ln = self.take()
        if kind == "str":
            return _unquote(v)
        if kind == "lstr":
            return re.sub(r"^\[=*\[\n?|\]=*\]$", "", v)
        if kind == "num":
            return int(v, 16) if v.lower().startswith("0x") else (float(v) if "." in v or "e" in v.lower() else int(v))
        if v == "-" and self.peek()[0] == "num":
            return -self.atom()
        if v == "{":
            return self.table()
        if v in ("true", "false"):
            return v == "true"
        if v == "nil":
            return None
        if kind == "name":
            if self.peek()[1] == "(":
                self.take("(")
                args = []
                while self.peek()[1] != ")":
                    args.append(self.expr())
                    if self.peek()[1] == ",":
                        self.take()
                self.take(")")
                if v not in self.calls:
                    raise SyntaxError(f"line {ln}: unknown call {v}()")
                return self.calls[v](*args)
            if v not in self.env:
                raise SyntaxError(f"line {ln}: unknown name {v}")
            return self.env[v]
        raise SyntaxError(f"line {ln}: unexpected {v!r}")

    def table(self):
        arr, keyed = [], {}
        while self.peek()[1] != "}":
            k0, k1 = self.peek(), self.peek(1)
            if k0[0] == "name" and k1[1] == "=":
                self.take(); self.take("=")
                keyed[k0[1]] = self.expr()
            elif k0[1] == "[":
                self.take(); key = self.expr(); self.take("]"); self.take("=")
                keyed[key] = self.expr()
            else:
                arr.append(self.expr())
            if self.peek()[1] in (",", ";"):
                self.take()
            elif self.peek()[1] != "}":
                raise SyntaxError(f"line {self.peek()[2]}: expected ',' or '}}' before {self.peek()[1]!r}")
        self.take("}")
        if keyed and arr:
            keyed["_list"] = arr
            return keyed
        return keyed if keyed else arr


def load_locals(src, calls=None, stop_after=None):
    """Every top-level `local NAME = <expr>` in the file, in order (function bodies skipped).
    `stop_after`: return once that local is read (the code after it is not data)."""
    toks = tokenize(src)
    env, p = {}, _Parser(toks, {}, calls or {})
    p.env = env
    depth = 0  # inside function ... end
    while p.peek()[0] != "eof":
        kind, v, ln = p.peek()
        if v == "function":
            depth += 1
        elif v == "end" and depth:
            depth -= 1
        elif depth == 0 and v == "local" and p.peek(1)[0] == "name" and p.peek(2)[1] == "=":
            p.take(); name = p.take()[1]; p.take("=")
            env[name] = p.expr()
            if name == stop_after:
                break
            continue
        elif depth and v in ("if", "for", "while", "do") and v != "do":
            # `for ... do` / `while ... do` / `if ... then` open a block closed by `end`
            depth += 1
        p.take()
    return env


def raid_header(src):
    """key / name of the table.insert(DungeonJournal_Raids, {...}) call."""
    block = src[src.index("table.insert(DungeonJournal_Raids"):]
    return {k: re.search(rf'\b{k}\s*=\s*"([^"]*)"', block).group(1) for k in ("key", "name")}


def load_raid(path):
    """One raid as {key, name, bosses: [...], trash: [...]}, rebuilt like the file's Build* functions."""
    src = open(path, encoding="utf-8").read()
    env = load_locals(src)
    head = raid_header(src)

    def find(suffix):
        hits = [k for k in env if k.endswith(suffix)]
        return env[hits[0]] if hits else None

    bosses = [dict(k) if isinstance(k, dict) else dict(key=k, **find("_BOSSES")[k])
              for k in (find("_BOSS_ORDER") or [])]  # a table entry is a boss-list separator
    trash = []
    for entry in find("_TRASH_ORDER") or []:
        if isinstance(entry, dict) and entry.get("separator"):
            trash.append(dict(entry))
            continue
        key, count = (entry.get("key"), entry.get("count")) if isinstance(entry, dict) else (entry, None)
        pack = dict(key=key, **find("_TRASH_MOBS")[key])
        if count is not None:
            pack["count"] = count
        trash.append(pack)
    return {**head, "bosses": bosses, "trash": trash}


def load_tactics(path):
    """DungeonJournalTactics' TACTICS table, keyed by boss / pack key."""
    calls = {
        "sep": lambda name: {"separator": True, "name": name},
        "bsep": lambda name: {"separator": True, "name": name, "broadcast": True},
        "rw": lambda text: {"warning": True, "text": text},
    }
    return load_locals(open(path, encoding="utf-8").read(), calls, stop_after="TACTICS")["TACTICS"]
