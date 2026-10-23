# DungeonJournal – development history

Written 2026-10-22, after the repo moved from the Addon Tickering client's `Interface\AddOns\` to
`C:\Users\Leon_\Documents\WoW Website Project\projects\DungeonJournal` (git state unchanged, all pushed).
The next goal is to show DungeonJournal's abilities on **db.lokiy.dev**, linked by spell ID and NPC
(creature) ID — see `..\..\MAP.md` and `..\..\docs\PLAN.md`.

Detailed per-item notes live in `TODO_Raid_Data.md` (it grew into a log of every data pass, not just open
items), `BWL_CSV_Pass.md` and `SPELL_DATA_WORKFLOW.md`. `AGENTS.md` is the architecture reference.

---

## 1. The addon — Jul 29 – Aug 1

**Request:** an in-game Dungeon Journal for Vanilla+ (1.12.1): per raid, each boss's abilities, flags and
resistances, mechanics only — no strategy text.

Built:
- `DungeonJournal.lua`: one window with a raid/boss tree on the left and the boss panel on the right
  (portrait, flag icons, resistances coloured by school, ability list with role/dispel icons, the yellow
  "!" warning icon, optional colours). `/clicky` opens it.
- `BOSS_FLAGS` + `ICON_ExplainationS` (the legend): new flag types are data only. "Not Always Tauntable"
  added for Herod.
- Clickable **phase separators** in ability lists (`separator = true`), nested abilities
  (`abilities = {...}` inside an ability, e.g. Recidivism under Shared Sentence), adds with their own
  abilities.
- Raids: Molten Core, Blackwing Lair, Scarlet Monastery, Onyxia, Zul'Gurub (15 bosses; Edge of Madness
  later split into its four real bosses), LBRS, UBRS, World Bosses (incl. Teremus and King Mosh in gold),
  Emerald Dragons. Ebonroc + Flamegor are one encounter.
- Resistances for 35 bosses from `V+ Lists.xlsx`.

## 2. Trash tab and file split — Aug 11–13

- **Trash tab** with its own tree and panel. Trash packs have exactly the boss shape
  (icon/flags/stats/abilities) so the boss panel code is reused.
- Collapsible trash separators (gold, collapsed by default, per-raid colour) for packs that pull together;
  grouped packs get `grouped = true` for extra indent.
- `RAIDS` split into `raids/*.lua`, each `table.insert`-ing into `DungeonJournal_Raids`; a mob registry +
  `*_BOSS_ORDER` / pull-order lists so packs can be reordered without copying data.
- Trash rosters from combat logs for SM, UBRS, ZG, LBRS; real MC/BWL trash.
- Trash tab hides raids without trash.

## 3. Tactics companion addon — Aug 12–23

- A separate optional addon, **DungeonJournalTactics** (its own repo, now `projects\DungeonJournalTactics`),
  hooks an inline Tactics panel into the boss and trash panels. Strategy text lives there, never in
  DungeonJournal.
- Labeled sections, a **Broadcast** button with a curated preview, `rw()` raid-warning lines, a confirm
  popup before sending to raid/party chat.
- The hook side was merged into DungeonJournal via PR #3 (branch `Tactics`, fully merged).

## 4. Filling in real numbers — Aug 12 – Sep 30

Rule from the start: lines use `X damage` / `X seconds` / `X%` placeholders until a real number is known —
never guess.

- **Sources, in order of trust:** the client's `Spell.csv` (read with the external
  `projects\Spell.csv reader`), then `Spell.xlsx` / DBC CSVs (`SpellDuration.csv`, `SpellRadius.csv`,
  `SpellRange.csv`), then combat logs (`MC FULL.csv`, `BWL stuff.csv`, `SM 6 bosses.csv`, `ZG 2.csv`,
  `ZG Spell GO.csv`, `UBRS.csv`, `LBRS.csv`, `Onyxia.csv`), then in-game testing.
- Per-raid passes (MC bosses/trash, BWL's six placeholder abilities replaced with real spells, SM bosses
  cross-checked against logs, SM trash + the Scarlet Diviner Prophecies, ZG/UBRS/LBRS rosters).
- **Passives** heading (`passive = true` separator) for always-on traits (Thrash, Double Attack, Melt
  Weapon, stances…).
- Emerald Dragons and World Bosses filled from the Classic 1.12 wiki pages (Lokiy confirmed they are
  unchanged on V+); Hederine is still empty.
- **2026-09-30 – Spell.csv pass** (`tools/propose.py`, `dump.py`, `scaling.py`, `apply_lines.py`; steps in
  `SPELL_DATA_WORKFLOW.md`): placeholders filled from Spell.csv, level-scaled spells written as
  "base plus N per caster level above L (about X at level 60)".

Decisions recorded in `CLAUDE.md`:
- Spell.csv wins over every other source; a changed line keeps a `-- CHANGED` comment with the spell ID and
  the old value.
- "weapon damage", never "normal damage".
- Never add Dazed (1604) or Shield Toss Return — stripped everywhere on 2026-08-23 as noise.
- Script-only effects (Hate to 50%, Sap Visual…) are deleted, not left as `X`.
- No strategy wording; strategy belongs in DungeonJournalTactics.
- Don't commit UI/behaviour changes before Lokiy has tested them in-game.

## 5. Audit and move — Oct 22

- **Spell.csv audit pass** (`006feac`): level scaling, missing abilities from the logs, data fixes across
  all raid files.
- Tool paths now point at `projects\Spell.csv reader` (`SPELL_READER` env var overrides).
- Repo moved into `WoW Website Project\projects\`; the 4.2 GB `WoWCombatLog.txt` moved to
  `logs\WoWCombatLog 2026-08-09.txt`.
- **`spellId` field** added to 458 of 1,121 ability entries (this commit) — every ability whose spell ID
  was already named in its own comments or lines, checked against Spell.csv by name. It is not read by the
  addon; it is the key for db.lokiy.dev. Per file: BWL 56, LBRS 122, MC 24, Onyxia 3, SM 41, UBRS 88,
  ZG 124, Emerald Dragons 0, World Bosses 0 (those two were filled from the wiki, with no IDs).
  - Picked one of several IDs (noted with a `-- spellId:` comment): BWL Frenzy (35238 Ebonroc, 23342
    Flamegor), BWL Elemental Shield (22278 / 22279 / 22281), UBRS Whirlwind (26083 cast, 26084 damage),
    ZG Whirlwind (13736 cast, 15589 damage). Also chose the main spell over linked ones without a note:
    Berserker Stance 2458 (not the passive auras 7381 / 35490), Stormstrike 17364 (not off-hand 34592),
    Arcane Missiles 15791 (not tick rank 15790), Spreading Flames 34471 (not damage 34472), Arcane Volley
    34469 (not Detonation 34470), Seal of Command 36133, Power Shot 35841, Duel 36269, Fire Shield 36092,
    Charge 24023 (not Fixate 12021), UBRS Conflagration 16805 (not splash 16806), UBRS Sunder Armor 16145.
  - Matched by name rather than an exact ID in the comment: SM Prophecy: Doppelganger = 36199 (comment
    only gave the 36175–36204 range), ZG "Jungle Toad - Disease Cloud" = 24063 "Disease Cloud",
    BWL Tail Swipe = 15847 "Tail Sweep" (the log name).
  - **Left without a spellId (uncertain, `-- spellId: uncertain` comment):** BWL Sawblade (only the
    'Stun 5s' effect 35162 is known), SM Vengeance (36127 or 36129), UBRS Defensive Stance (only the
    passive 7376 is known; 71 / 7164 / 34477?), ZG Infected Bite on the mob that cites both 24339 and
    16128.

## In the middle of

Getting DungeonJournal's data onto db.lokiy.dev. The spell IDs are the first half; nothing has been
exported yet.

## Still open

- **spellId for the last ~100 abilities** — 2026-10-23 passes filled 490 more (948 in total) from the
  mob's own combat-log line, a unique name on lokiy.dev/spells, or numbers matching one candidate's data.
  19 have a `-- spellId: uncertain` note (two IDs in the mob's own log); 82 are listed in
  `SPELLID_OPEN.md` (several same-named spells, nothing in the line to tell them apart).
- **NPC (creature) IDs** — no boss, add or trash pack has one yet. Needed to link to the site's NPC pages
  (combat logs carry the creature GUIDs; the server DB has `creature_template`).
- **Export script** (one per data flow, listed in MAP.md): read `raids/*.lua` → JSON for the site. Not
  written yet.
- **Merge `raid-data-todo` into `main`** (36+ commits ahead) once Lokiy has checked the Sep 30 / Oct 22
  data passes in-game. The `Tactics` branch is fully merged and can be deleted too.
- **Project docs:** the shared convention is `docs/CHANGES.md`, `docs/TODO.md`, `docs/TODO_DONE.md`; this
  repo still uses `TODO_Raid_Data.md` (mixed log + open items). Splitting it is open.
- **Data still missing** (details in `TODO_Raid_Data.md`): 124 lines still hold an `X` placeholder (ability lines and stats);
  most of those are trash `stats` blocks (ZG/UBRS/LBRS/SM); Emerald Dragons' own resistances and portraits,
  Hederine, BWL wording pass, a few MC trash items (Firelord Fireball, Lava Annihilator Double Attack
  interval, Flame Imp Fire Nova).
- Big research files in the repo folder (`Spell.xlsx`, combat-log CSVs, `.docx`) could move to `data\` /
  `logs\` per the shared layout.
