"""Find table fields with no separator between them in Lua files (the 'x' '}' expected near 'y' load error).
Usage: python tools/check_fields.py Raids/*.lua
No Lua is installed on the PC or the server; this catches the "'}' expected near ..." load error.
"""
import re, sys

TOK = re.compile(r"""
    (?P<ws>\s+)
  | (?P<lcomment>--\[(?P<eq>=*)\[.*?\](?P=eq)\])
  | (?P<comment>--[^\n]*)
  | (?P<lstr>\[(?P<eq2>=*)\[.*?\](?P=eq2)\])
  | (?P<str>"(?:[^"\\\n]|\\.)*"|'(?:[^'\\\n]|\\.)*')
  | (?P<num>0[xX][0-9a-fA-F]+|\d+\.?\d*(?:[eE][+-]?\d+)?|\.\d+)
  | (?P<name>[A-Za-z_]\w*)
  | (?P<op>\.\.\.|\.\.|==|~=|<=|>=|[-+*/%^#<>=(){}\[\];:,.])
""", re.S | re.X)
KEYWORDS = {"and", "or", "not", "then", "do", "end", "else", "elseif", "in", "if", "for", "while",
            "repeat", "until", "function", "local", "return", "break"}
ENDS_VALUE = {"str", "num", "lstr"}

bad = 0
for path in sys.argv[1:]:
    src = open(path, encoding="utf-8").read()
    toks, pos = [], 0
    while pos < len(src):
        m = TOK.match(src, pos)
        if not m:
            print(f"{path}: cannot tokenize at line {src.count(chr(10), 0, pos) + 1}"); bad += 1; break
        kind = m.lastgroup if m.lastgroup not in ("eq", "eq2") else None
        kind = next(k for k in ("ws", "lcomment", "comment", "lstr", "str", "num", "name", "op") if m.group(k) is not None)
        if kind not in ("ws", "lcomment", "comment"):
            toks.append((kind, m.group(0), src.count("\n", 0, pos) + 1))
        pos = m.end()
    stack = []  # '{' / '(' / '['
    for i, (k, v, ln) in enumerate(toks):
        if v in "{([" and k == "op":
            stack.append(v)
            continue
        if v in "})]" and k == "op":
            if stack:
                stack.pop()
        if not stack or stack[-1] != "{" or i + 1 >= len(toks):
            continue
        # value just ended and the next token starts a new field without ',' or ';'
        ends = k in ENDS_VALUE or (k == "name" and v in ("true", "false", "nil")) or (k == "op" and v in ")}]")
        nk, nv, nln = toks[i + 1]
        starts = (nk == "name" and nv not in KEYWORDS and i + 2 < len(toks) and toks[i + 2][1] == "=") or (nk == "op" and nv == "{") or nk in ("str", "lstr")
        if ends and starts:
            print(f"{path}:{nln}: missing ',' before '{nv}' (after '{v[:30]}' on line {ln})"); bad += 1
    if stack:
        print(f"{path}: {len(stack)} unclosed {stack[-3:]}"); bad += 1
print("problems:", bad)
sys.exit(1 if bad else 0)
