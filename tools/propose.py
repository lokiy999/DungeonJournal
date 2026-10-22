"""propose.py <raid> <combat log csv> [more csvs...]

Find X-placeholder ability lines in Raids/<raid>.lua, map each one to spell IDs via the
combat-log CSVs (source mob + ability name) and any spell ID in a comment just above it,
and print the Spell.csv-resolved tooltip text for review. Read-only - apply the changes
you accept with apply_lines.py. Example: python tools/propose.py ZG "ZG Spell GO.csv" "ZG 2.csv"
"""
import csv, os, re, sys

READER = os.environ.get("SPELL_READER", r"C:\Users\Leon_\Documents\WoW Website Project\projects\Spell.csv reader")
sys.path.insert(0, READER)
import gen_custom_spell_tooltips as g

ADDON = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
raid, logs = sys.argv[1], sys.argv[2:]
CSVD = os.path.join(READER, "CSV's")

names, icons, descs, data = g.load_spell_csv(os.path.join(CSVD, "Spell.csv"))
durs = g.load_durations(os.path.join(CSVD, "SpellDuration.csv"))
radii = g.load_radii(os.path.join(CSVD, "SpellRadius.csv"))

# (source, ability) -> {spell id: count}
pairs = {}
for lp in logs:
    for r in csv.reader(open(os.path.join(ADDON, lp), encoding="utf-8", errors="replace")):
        if len(r) > 7 and r[6].isdigit() and r[4].startswith("0xF1"):
            pairs.setdefault((r[3], r[5]), {}).setdefault(int(r[6]), 0)
            pairs[(r[3], r[5])][int(r[6])] += 1

lines = open(os.path.join(ADDON, "Raids", raid + ".lua"), encoding="utf-8").read().split("\n")
NAME = re.compile(r'^(\s*)name = "(.*)",')
stack = []  # (indent, name)
out = []
for n, line in enumerate(lines, 1):
    m = NAME.match(line)
    if m:
        ind = len(m.group(1))
        stack = [s for s in stack if s[0] < ind] + [(ind, m.group(2))]
        continue
    if "lines = {" in line and re.search(r'\bX\b', line):
        ability = stack[-1][1] if stack else "?"
        mobs = [s[1] for s in stack[:-1]][::-1]
        ids = {}
        for mob in mobs:
            ids = pairs.get((mob, ability), {})
            if ids:
                break
        how = "mob"
        if not ids:  # any NPC source with that ability name
            how = "any"
            for (src, ab), v in pairs.items():
                if ab == ability:
                    for k, c in v.items():
                        ids[k] = ids.get(k, 0) + c
        # also any spell ids mentioned in a comment just above
        cmt = " ".join(lines[max(0, n - 8):n])
        cids = [int(x) for x in re.findall(r"spell(?: ID)? (\d{3,6})", cmt)]
        res = []
        for sid in sorted(set(ids) | set(cids)):
            raw = descs.get(sid, "")
            if not raw or raw == "0" or re.fullmatch(r"0x[0-9A-Fa-f]+", raw):
                txt = ""
            else:
                try:
                    txt = g.resolve_desc(raw, sid, data, durs, radii)
                except Exception as e:
                    txt = "ERR " + str(e)
            d = data.get(sid, {})
            res.append({"id": sid, "n": ids.get(sid, 0), "name": names.get(sid), "text": txt,
                        "dur": durs.get(d.get("dur_idx"), (None,))[0], "bp": [b + 1 for b in d.get("bp", [])],
                        "amp": d.get("amp"), "chain": d.get("chain")})
        out.append({"line": n, "mob": mobs[0] if mobs else "?", "ability": ability, "how": how,
                    "current": line.strip(), "cands": res})

for o in out:
    print(f"L{o['line']} {o['mob']} -> {o['ability']} [{o['how']}]")
    print("   now:", o["current"][:200])
    for c in o["cands"]:
        print(f"   {c['id']} x{c['n']} {c['name']}: {c['text'][:220]}  |dur={c['dur']} bp={c['bp']} amp={c['amp']}")
