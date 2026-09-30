"""apply_lines.py <raid> <fixes.py> [--any]

Replace the single-line `lines = {...}` on the given line numbers of Raids/<raid>.lua and
add a `-- CHANGED <date>: from Spell.csv (spell <id>).` comment above each one.
fixes.py defines FIX = {line number: (spell id, new text)} using the line numbers printed
by propose.py. Lines are processed bottom-up, so the numbers stay valid while comments
are inserted. By default a target line must still contain an `X` placeholder (a guard
against stale line numbers); pass --any to allow rewriting a line without one.
"""
import datetime, os, re, runpy, sys

A = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "Raids")
raid, fx = sys.argv[1], sys.argv[2]
allow_any = "--any" in sys.argv[3:]
FIX = runpy.run_path(fx)["FIX"]
P = os.path.join(A, raid + ".lua")
today = datetime.date.today().isoformat()
lines = open(P, encoding="utf-8", newline="").read().split("\n")
for n in sorted(FIX, reverse=True):
    sid, text = FIX[n]
    i = n - 1
    old = lines[i]
    assert "lines = {" in old, (n, "not a lines = {...} line", old)
    assert allow_any or re.search(r"\bX\b", old), (n, "no X placeholder - stale line number?", old)
    assert '"' not in text, (n, "text must not contain double quotes")
    indent = old[:len(old) - len(old.lstrip())]
    body = old.rstrip("\r")
    tail = body[body.rindex('"}') + 2:]  # keeps a trailing "," if there is one
    cr = "\r" if old.endswith("\r") else ""
    lines[i] = f'{indent}lines = {{"{text}"}}{tail}{cr}'
    lines.insert(i, f"{indent}-- CHANGED {today}: from Spell.csv (spell {sid}).{cr}")
open(P, "w", encoding="utf-8", newline="").write("\n".join(lines))
print("applied", len(FIX))
