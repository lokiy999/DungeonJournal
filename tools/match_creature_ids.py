"""Propose creature (NPC) IDs for every boss, add and trash mob in Raids/*.lua.

Sources, in order of trust:
  1. Vanilla+ combat logs: the creature ID is in the unit GUID (0xF130 + 6 hex digits of ID + ...).
     The repo's *.csv logs (Source / Target GUID) and the client's Chronicle logs (UNIT_INFO, with
     the zone from the last ZONE_INFO line).
  2. pfQuest's classic NPC database (hub data\\pfquest: enUS names, zones from map coords).
A name with one ID in the logs takes that ID. Same-named NPCs are told apart by the raid's zone;
what stays ambiguous or is in neither source is listed, never guessed.

Usage: python tools/match_creature_ids.py [--write]   (report only without --write)
Writes creature_ids.json (proposals) next to this script's repo root; --write adds `npcId = N,`
after each matched mob's name line in Raids/*.lua.
"""
import csv, glob, json, os, re, sys
from collections import Counter, defaultdict

sys.path.insert(0, os.path.dirname(__file__))
import lua_data  # noqa: E402

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HUB = os.path.dirname(os.path.dirname(REPO))
PFQ = os.path.join(HUB, "data", "pfquest")
CHRONICLE = r"C:\Programs\WoW_VPlus_Client\World of Warcraft Vanilla+\CustomData"

# pfQuest zone ids per raid (map ids used in units.lua coords) and the zone names the
# Chronicle logs write in ZONE_INFO.
RAID_ZONES = {
    "MC": ({2717}, {"Molten Core"}),
    "BWL": ({2677}, {"Blackwing Lair"}),
    "ZG": ({1977}, {"Zul'Gurub"}),
    "ONY": ({2159}, {"Onyxia's Lair"}),
    "SM": ({796}, {"Scarlet Monastery"}),
    "LBRS": ({1583}, {"Blackrock Spire"}),
    "UBRS": ({1583}, {"Blackrock Spire"}),
    "GREEN": ({10, 331, 357, 47}, {"Duskwood", "Ashenvale", "Feralas", "The Hinterlands"}),
    "WORLD": ({16, 4, 1377, 46, 51, 3}, {"Azshara", "Blasted Lands", "Silithus", "Burning Steppes",
                                          "Searing Gorge", "Badlands"}),
}


def guid_id(g):
    g = (g or "").strip()
    if not g.upper().startswith("0XF130") or len(g) < 18:
        return None
    return int(g[6:12], 16)


CAST = defaultdict(lambda: defaultdict(set))  # name -> {id: abilities that creature cast (CSV logs)}
# Journal names that differ from the game's
ALIASES = {"Neferian": "Nefarian", "Majordomo": "Majordomo Executus"}
# Decided by hand (2026-10-25), with the reason. A list = one journal entry for several creatures.
OVERRIDES = {
    "Ebonroc & Flamegor": ([14601, 11981], "one encounter, two dragons: Ebonroc 14601, Flamegor 11981 (logs + pfquest)"),
    "Sawblade": ([25103, 25104, 25105, 25109], "four Vanilla+ creatures named Sawblade, all cast the same spell (logs)"),
    "Gri'lek": (15082, "pfquest: 15082 is the level-63 boss; 15081 is a level 45-46 elite"),
}


def log_index():
    """name -> Counter{(id, zone or ''): hits}"""
    idx = defaultdict(Counter)
    for f in glob.glob(os.path.join(REPO, "*.csv")):
        with open(f, encoding="utf-8", errors="replace") as fh:
            r = csv.DictReader(fh)
            if not r.fieldnames or "Source GUID" not in r.fieldnames:
                continue
            for row in r:
                for n, g in ((row["Source"], row["Source GUID"]), (row.get("Target"), row.get("Target GUID"))):
                    i = guid_id(g)
                    if i and n:
                        idx[n][(i, "")] += 1
                i = guid_id(row["Source GUID"])
                if i:
                    CAST[row["Source"]][i].add(row["Action / Ability"])
    for f in glob.glob(os.path.join(CHRONICLE, "*.txt")):
        zone = ""
        with open(f, encoding="utf-8", errors="replace") as fh:
            for ln in fh:
                if "|ZONE_INFO|" in ln:
                    zone = ln.split("|")[2]
                elif "|UNIT_INFO|0xF130" in ln:
                    p = ln.split("|")
                    i = guid_id(p[2])
                    if i and p[4]:
                        idx[p[4]][(i, zone)] += 1
    return idx


def pfquest_index():
    names = {}
    for m in re.finditer(r'^\s*\[(\d+)\] = "((?:[^"\\]|\\.)*)",', open(os.path.join(PFQ, "enUS", "units.lua"), encoding="utf-8").read(), re.M):
        names[int(m.group(1))] = re.sub(r"\\(.)", r"\1", m.group(2))
    zones = defaultdict(set)
    cur = None
    for ln in open(os.path.join(PFQ, "units.lua"), encoding="utf-8"):
        m = re.match(r"\s*\[(\d+)\] = \{$", ln)
        if m and ln.startswith("  [") and not ln.startswith("   "):
            cur = int(m.group(1))
            continue
        m = re.match(r"\s*\[\d+\] = \{ [\d.]+, [\d.]+, (\d+),", ln)
        if m and cur:
            zones[cur].add(int(m.group(1)))
    by_name = defaultdict(list)
    for i, n in names.items():
        by_name[n].append(i)
    return by_name, zones


def mobs():
    """(raid key, kind, key, name) for every boss, add and trash pack."""
    out = []
    for f in sorted(glob.glob(os.path.join(REPO, "Raids", "*.lua"))):
        r = lua_data.load_raid(f)
        for b in r["bosses"]:
            if b.get("separator"):
                continue
            out.append((r["key"], "boss", b["key"], b["name"], os.path.basename(f)))
            for a in b.get("adds", []):
                out.append((r["key"], "add", b["key"], a["name"], os.path.basename(f)))
        for t in r["trash"]:
            if not t.get("separator"):
                out.append((r["key"], "trash", t["key"], t["name"], os.path.basename(f)))
    return out


def decide(raid, name, logs, pfq, pfzones):
    if name in OVERRIDES:
        cid, why = OVERRIDES[name]
        return cid, "by hand: " + why, cid if isinstance(cid, list) else [cid]
    name = ALIASES.get(name, name)
    pz, lz = RAID_ZONES.get(raid, (set(), set()))
    seen = logs.get(name, Counter())
    ids = Counter()
    for (i, z), n in seen.items():
        ids[i] += n
    if len(ids) == 1:
        return next(iter(ids)), "log", sorted(ids)
    if len(ids) > 1:
        pf_in = [i for i in pfq.get(name, []) if i in ids]
        if len(pf_in) == 1:  # the logs mix up same-kind names (whelps, Firelord / Lava Annihilator)
            return pf_in[0], "log + pfquest", sorted(ids)
        # the boss casts its whole kit; a same-named helper casts one ground effect
        kit = Counter({i: len(a) for i, a in CAST.get(name, {}).items()})
        top = kit.most_common(2)
        if top and top[0][1] >= 3 and (len(top) == 1 or top[0][1] >= 3 * top[1][1]):
            return top[0][0], "log (main caster)", sorted(ids)
        inzone = {i for (i, z), _ in seen.items() if z in lz}
        if len(inzone) == 1:
            return inzone.pop(), "log (zone)", sorted(ids)
        return None, "log: several IDs", sorted(ids)
    cands = pfq.get(name, [])
    if len(cands) == 1:
        return cands[0], "pfquest", cands
    if len(cands) > 1:
        inzone = [i for i in cands if pfzones.get(i, set()) & pz]
        if len(inzone) == 1:
            return inzone[0], "pfquest (zone)", cands
        return None, "pfquest: several IDs", cands
    return None, "not found", []


def main():
    logs = log_index()
    pfq, pfzones = pfquest_index()
    rows = []
    for raid, kind, key, name, fname in mobs():
        cid, how, cands = decide(raid, name, logs, pfq, pfzones)
        pf = pfq.get(ALIASES.get(name, name), [])
        rows.append({"raid": raid, "kind": kind, "key": key, "name": name, "file": fname,
                     "id": cid, "how": how, "candidates": cands,
                     "pfquest": pf, "differs": bool(isinstance(cid, int) and pf and cid not in pf)})
    json.dump(rows, open(os.path.join(REPO, "creature_ids.json"), "w"), indent=1)
    c = Counter(r["how"] for r in rows)
    print(len(rows), "mobs:", dict(c))
    for r in rows:
        if not r["id"] or r["differs"]:
            print(f'  {r["raid"]:5} {r["kind"]:5} {r["name"]:34} {r["how"]:22} {r["candidates"][:6]} pfq={r["pfquest"][:4]}')


def write(rows):
    """Add `npcId = N,` (or `npcIds = {a, b},`) after each matched mob's name line."""
    by_file = defaultdict(list)
    for r in rows:
        if r["id"]:
            by_file[r["file"]].append(r)
    done = 0
    for fname, rs in by_file.items():
        path = os.path.join(REPO, "Raids", fname)
        L = open(path, encoding="utf-8", newline="").read().split("\n")
        reg = {k: next(i for i, l in enumerate(L) if re.match(rf"local \w+_{k} = \{{", l))
               for k in ("BOSSES", "TRASH_MOBS") if any(re.match(rf"local \w+_{k} = \{{", l) for l in L)}
        inserts = []
        for r in rs:
            start = reg["TRASH_MOBS" if r["kind"] == "trash" else "BOSSES"]
            k = next(i for i in range(start, len(L)) if L[i] == f"    {r['key']} = {{")
            end = next(i for i in range(k + 1, len(L)) if L[i] in ("    },", "    }"))
            if r["kind"] == "add":
                a = next(i for i in range(k, end) if L[i].strip().startswith("adds = {"))
                n = next(i for i in range(a, end) if L[i].strip() == f'name = "{r["name"]}",')
            else:
                n = next(i for i in range(k, end) if L[i].startswith('        name = "'))
            if any("npcId" in L[j] for j in range(n + 1, min(n + 3, end))):
                continue
            ind = re.match(r"\s*", L[n]).group(0)
            v = r["id"]
            line = f"{ind}npcIds = {{{', '.join(map(str, v))}}}," if isinstance(v, list) else f"{ind}npcId = {v},"
            inserts.append((n, line))
        for n, line in sorted(inserts, reverse=True):
            L.insert(n + 1, line)
            done += 1
        open(path, "w", encoding="utf-8", newline="").write("\n".join(L))
    print("written:", done)


if __name__ == "__main__":
    main()
    if "--write" in sys.argv:
        write(json.load(open(os.path.join(REPO, "creature_ids.json"))))
