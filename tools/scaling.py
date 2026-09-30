"""scaling.py <spell id> [more ids...]

Show whether a spell's values scale with the caster's level. Prints max level (col 27),
spell level (col 29), the raw EffectRealPointsPerLevel fields (cols 73-75) and the base
points. Real value = (base points + 1) + perLevel * (casterLevel - spellLevel), with
casterLevel capped at max level when max level > 0.

The per-level fields are floats, and the export split any decimal into two fields
("-0.2" -> "-0", "200000002980232"), so a row with a split decimal shows 4+ fields here
and shifts everything after it. Read them by eye: a field that follows an integer part
and looks like a long digit string (or a lone digit like "5" in "1","5") is its decimals.
"""
import csv, os, re, sys

READER = os.environ.get("SPELL_READER", r"C:\Users\Leon_\Desktop\Wow stuff\Spell.csv reader")
NUM = re.compile(r"^-?(0x[0-9A-Fa-f]+|\d+(\.\d+)?)$")
want = set(sys.argv[1:])
for r in csv.reader(open(os.path.join(READER, "CSV's", "Spell.csv"), encoding="utf-8")):
    if not r or r[0] not in want:
        continue
    s = 0  # row shift: the name should sit at col 120
    for k in range(120, 126):
        if r[k] and not NUM.match(r[k]):
            s = k - 120
            break
    per = r[73:76 + s]
    scaled = any(p not in ("0", "", "-0") for p in per)
    print(f"{r[0]:>6} {r[120 + s][:28]:28} max={r[27]} spellLevel={r[29]} "
          f"perLevel(raw)={per} basePoints={r[76 + s:79 + s]}" + ("  <- SCALES" if scaled else ""))
