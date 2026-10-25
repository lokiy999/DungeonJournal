"""Export DungeonJournal (+ DungeonJournalTactics) to one JSON file for db.lokiy.dev's NPC / boss pages.

Reads:  Raids/*.lua, DungeonJournal.lua (flag / role legend), ../DungeonJournalTactics/DungeonJournalTactics.lua,
        the hub's data/dbc/Spell.dbc (spell school by spellId).
Writes: dungeonjournal.json (repo root, git-ignored); `--upload` also copies it to the server path below.
Run after every change to the raid files or the tactics (DungeonJournal stays the hand-edited source).

Shape (plain data, field names as in the Lua files):
  { generated, source: {repo, branch, commit, dirty, tactics_commit},
    flags: {key: {name, desc}}, roles: [key, ...] (keys used in ability `roles`),
    raids: [ { key, name,
               bosses: [ {key, name, npcId | npcIds, flags, stats, color, abilities, adds, tactics} | {separator, name} ],
               trash:  [ {key, name, npcId | npcIds, flags, stats, count, grouped, abilities, tactics} | {separator, name} ] } ] }
  ability: {name, spellId, school, icon, roles, warning, color, lines, separator, passive, abilities (nested)}
  tactics (when DungeonJournalTactics has an entry for that key): {title, lines, resistances};
  a line is text or {separator, name, broadcast} / {warning, text}.
`icon` values are WoW texture paths (Interface\\Icons\\...); the site maps them to its own icons.
"""
import datetime, glob, json, os, struct, subprocess, sys

sys.path.insert(0, os.path.dirname(__file__))
import lua_data  # noqa: E402

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HUB = os.path.dirname(os.path.dirname(REPO))
TACTICS = os.path.join(os.path.dirname(REPO), "DungeonJournalTactics")
SPELL_DBC = os.path.join(HUB, "data", "dbc", "Spell.dbc")
OUT = os.path.join(REPO, "dungeonjournal.json")
SERVER = "lokiy:/opt/wowsims-classic/tools/itemdb/dungeonjournal.json"
SCHOOLS = ["Physical", "Holy", "Fire", "Nature", "Frost", "Shadow", "Arcane"]


def spell_schools():
    """spell id -> school name, from Spell.dbc (WDBC: id = field 0, school = field 1)."""
    data = open(SPELL_DBC, "rb").read()
    magic, n, fields, size, _ = struct.unpack_from("<4s4I", data)
    assert magic == b"WDBC", magic
    out = {}
    for r in range(n):
        sid, school = struct.unpack_from("<2I", data, 20 + r * size)
        out[sid] = SCHOOLS[school] if school < len(SCHOOLS) else str(school)
    return out


def git(path, *args):
    return subprocess.run(["git", "-C", path, *args], capture_output=True, text=True).stdout.strip()


def legend():
    src = open(os.path.join(REPO, "DungeonJournal.lua"), encoding="utf-8").read()
    part = src[src.index("local CLASS_ICON_TEXTURE"):src.index("local ICON_ExplainationS")]
    env = lua_data.load_locals(part)
    flags = {k: {f: v[f] for f in ("name", "desc") if f in v} for k, v in env["BOSS_FLAGS"].items()}
    return flags, sorted(env["UTILITY_ICONS"])  # roles are icon-only in the addon: just the keys


def clean_ability(a, schools):
    a = dict(a)
    if a.get("spellId") in schools:
        a["school"] = schools[a["spellId"]]
    if "abilities" in a:
        a["abilities"] = [clean_ability(x, schools) for x in a["abilities"]]
    return a


def clean_mob(m, schools, tactics):
    m = dict(m)
    if m.get("separator"):
        return m
    m["abilities"] = [clean_ability(a, schools) for a in m.get("abilities", [])]
    if "adds" in m:
        m["adds"] = [clean_mob(x, schools, {}) for x in m["adds"]]
    if m.get("key") in tactics:
        m["tactics"] = tactics[m["key"]]
    return m


def main():
    schools = spell_schools()
    tactics = lua_data.load_tactics(os.path.join(TACTICS, "DungeonJournalTactics.lua"))
    flags, roles = legend()
    raids, used = [], set()
    for f in sorted(glob.glob(os.path.join(REPO, "Raids", "*.lua"))):
        r = lua_data.load_raid(f)
        r["bosses"] = [clean_mob(b, schools, tactics) for b in r["bosses"]]
        r["trash"] = [clean_mob(t, schools, tactics) for t in r["trash"]]
        used |= {m["key"] for m in r["bosses"] + r["trash"] if "tactics" in m}
        raids.append(r)
    doc = {
        "generated": datetime.datetime.now().isoformat(timespec="seconds"),
        "source": {
            "repo": "lokiy999/DungeonJournal",
            "branch": git(REPO, "rev-parse", "--abbrev-ref", "HEAD"),
            "commit": git(REPO, "rev-parse", "--short", "HEAD"),
            "dirty": bool(git(REPO, "status", "--porcelain", "Raids")),
            "tactics_commit": git(TACTICS, "rev-parse", "--short", "HEAD"),
        },
        "flags": flags,
        "roles": roles,
        "raids": raids,
    }
    json.dump(doc, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    mobs = [m for r in raids for m in r["bosses"] + r["trash"] if not m.get("separator")]
    adds = [a for m in mobs for a in m.get("adds", [])]
    print(f"{OUT}: {len(raids)} raids, {len(mobs)} bosses / trash + {len(adds)} adds, "
          f"{sum(1 for m in mobs + adds if 'npcId' in m or 'npcIds' in m)} with a creature id, "
          f"tactics for {len(used)} of {len(tactics)} entries; {os.path.getsize(OUT) // 1024} KB")
    unused = sorted(set(tactics) - used)
    if unused:
        print("tactics with no matching boss / pack key:", unused)
    if "--upload" in sys.argv:
        subprocess.run(["scp", "-q", OUT, SERVER], check=True)
        print("uploaded to", SERVER)


if __name__ == "__main__":
    main()
