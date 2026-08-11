# DungeonJournal

WoW 1.12.1 (Vanilla) addon, plain Lua 5.0 + Blizzard FrameXML, no build step.
See [AGENTS.md](AGENTS.md) for the full architecture reference (data model,
patterns, known issues) — this file is just quick orientation.

## Key files

- `DungeonJournal.lua` — config, `BOSS_FLAGS`, UI construction, rebuild functions.
  `RAIDS` is `DungeonJournal_Raids`, built up by the files in `raids/`.
- `raids/*.lua` — one file per raid (`MC.lua`, `BWL.lua`, `ZG.lua`, `SM.lua`,
  `LBRS.lua`, `UBRS.lua`, plus `Onyxia.lua`, `WorldBosses.lua`,
  `EmeraldDragons.lua`),
  each `table.insert`-ing its raid table into the shared `DungeonJournal_Raids`
  global. Loaded via the `.toc` before `DungeonJournal.lua`.
- `DungeonJournal.toc` — addon manifest (interface version, file/asset list).
- `Icons/*.blp` — portrait textures actually loaded in-game.
- `Spell.xlsx`, `mob_abilities_summary.txt`, `V+ Lists.xlsx`, `WoWCombatLog.txt`,
  `Tips_Tricks*.docx` — research-only reference files, not loaded by the addon.

## Build / test

No build, lint, or test tooling. Validate by:

```bash
luac -p DungeonJournal.lua   # syntax check, if a Lua 5.1-ish binary is available
```

Otherwise: copy into a client's `Interface\AddOns\`, `/reload`, run `/clicky`,
and manually exercise the tree, both nav tabs, and scrolling.

**Always verify brace balance after editing a raid file** (each `raids/*.lua`
is one big table literal, so a missing `}` breaks the addon silently at load):

```bash
grep -o '{' raids/MC.lua | wc -l
grep -o '}' raids/MC.lua | wc -l
```

## Conventions from this project

- Trash packs mirror the boss data shape exactly (icon/flags/stats/abilities)
  so the Trash view reuses the boss panel's rendering code.
- Trash separators group packs that always spawn/pull together; click to
  collapse/expand. Packs under a separator get `grouped = true` for extra
  tree indent. See AGENTS.md's "Data model" section for the full syntax.
- Ability `lines` use `X damage` / `X seconds` / `X%` placeholders where the
  real numbers aren't known yet — fill in from testing, don't guess numbers.
- New icon/flag types go in `BOSS_FLAGS` + `ICON_ExplainationS` (the legend);
  no other code changes needed.
- Always state at the end of a task which data is real (from the reference
  files) vs. guessed/placeholder.
- Never prepend `cd "<this repo>" &&` to git commands — the working directory
  is already this repo, and the prefix breaks the `Bash(git commit:*)` /
  `Bash(git add:*)` auto-allow rules in `.claude/settings.json` (they match
  on the start of the command string).

