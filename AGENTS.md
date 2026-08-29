You are an experienced, pragmatic software engineering AI agent. Do not over-engineer a solution when a simple one is possible. Keep edits minimal. If you want an exception to ANY rule, you MUST stop and get permission first.

# DungeonJournal

## Project Overview

DungeonJournal is a **World of Warcraft 1.12.1 (Vanilla) addon** that provides an
"Adventure Guide"-style window for raid/dungeon encounters, driven by a top nav bar
with three views:

1. **Bosses** — a collapsible raid → boss tree on the left, and a boss header plus
   a tabbed accordion list of abilities and adds on the right.
2. **Trash** — a *separate* collapsible raid → trash-pack tree and its own right
   panel. Deliberately mirrors the Bosses panel's rendering (portrait, flag row,
   armor/resistance line, accordion ability list with separators) rather than a
   bespoke layout — see "Data model" below.
3. **Icon Guide** ("Explaination") — a full-width icon legend.

- **Language:** Lua 5.0 as embedded in the 1.12.1 client (no external runtime, no
  package manager, no build step).
- **UI:** Blizzard FrameXML API only (`CreateFrame`, `UIPanelScrollFrameTemplate`,
  `SetBackdrop`, ...). No Ace/LibStub or other third-party libraries.
- **Assets:** boss portraits as `.blp` textures in `Icons/`, with source PNGs kept in
  `Icons/PNG Files/` for reference.

## Reference

```
DungeonJournal.toc     Addon manifest: interface version, metadata, file/asset load list
DungeonJournal.lua     Config, BOSS_FLAGS, UI, rebuild functions, slash command
raids/*.lua            One file per raid; each appends its raid table to the
                        shared DungeonJournal_Raids global (== RAIDS)
Icons/*.blp            Boss portrait textures actually loaded by the client
Icons/PNG Files/*.png  Source art (not loaded in-game; keep in sync when adding icons)
```

See "External reference files" below for spreadsheets/logs/notes kept in the repo for
research purposes only — none of them are loaded by the addon or listed in the `.toc`.

`DungeonJournal.lua` is organized top-to-bottom in labeled comment banners; keep new
code in the matching section:

1. **Config** — window/row dimensions, `CLASS_ICON_TEXTURE` + `CLASS_ICON_COORDS`,
   `UTILITY_ICONS`, `ApplyUtilityIcon()`.
2. **`BOSS_FLAGS`** — per-encounter/per-trash-pack quick-glance flags (tauntable,
   damage school, mob "type" tags like Caster/Melee/Immune to X). Shared by both the
   Bosses view and the Trash view via the same `flags` field and the same
   icon-slot mechanism.
3. **`ICON_ExplainationS`** — icon legend rows for the Explaination view.
4. **`RAIDS`** — the content database: `raids -> { bosses, trash } -> abilities / adds -> abilities`.
   Lives in `raids/*.lua`, one file per raid (loaded via the `.toc` before
   `DungeonJournal.lua`, each `table.insert`-ing into the shared
   `DungeonJournal_Raids` global); `DungeonJournal.lua` just does
   `local RAIDS = DungeonJournal_Raids`.
5. **UI construction** — main frame, boss tree/panel, trash tree/panel (own scroll
   frames, own row/separator/flag-slot pools, but reuses `CreateAbilityRow` /
   `ConfigureAbilityRow` / `CreateSeparatorRow` / `ConfigureSeparatorRow` /
   `FormatBossStats`), tabs, nav bar, Explaination panel.
6. **Rebuild functions** — `RebuildTree()`, `RebuildAbilityList()`, `RebuildBossFlags()`,
   `RebuildTrashTree()`, `RebuildTrashAbilityList()`, `RebuildTrashFlags()`,
   `RebuildExplainationList()`, `ShowBossInfo()`, `ShowTrashPack()`, `SelectTab()`,
   `SelectView()`.
7. **Slash command** — `/clicky` toggles the window.

### Data model

Add content by editing the relevant raid's file under `raids/` only; the UI is
fully data-driven. Each file is a `table.insert(DungeonJournal_Raids, { ... })`
call — edit the `{ ... }` raid table, same shape as before the split:

```lua
{ key = "MC", name = "Molten Core", expanded = false, bosses = {{
    key = "lucifron",
    name = "Lucifron",
    icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Lucifron", -- no .blp extension
    color = "ffffd100",                                          -- optional, tints the tree row (gold here)
    flags = { "nottauntable", "potion_fire" },                   -- keys of BOSS_FLAGS
    abilities = {{
        name = "Lucifron's Curse",
        icon = "Interface\\Icons\\Spell_Shadow_BlackPlague",
        roles = { "decurse" },       -- keys of UTILITY_ICONS (roles, dispels, classes)
        color = "ffa335ee",          -- optional ARGB hex for the name text
        warning = true,              -- optional, shows the yellow "!" icon
        lines = { "Description line one.", "Line two." },
    }},
    adds = {{ name = "...", lines = {...}, abilities = {...} }}, -- adds may nest abilities
}}, trash = {{
    key = "core_hound",
    name = "Core Hound",
    icon = "Interface\\Icons\\Ability_Hunter_Pet_Wolf",
    flags = { "melee", "immune_fire" },   -- same BOSS_FLAGS keys as bosses; also
                                           -- doubles as the "mob type" tag row
    stats = { armor = 3400, fire = "immune", nature = 50, frost = 50, shadow = 50, arcane = 50 },
    abilities = {{ name = "Fast Melee", icon = "...", roles = {"tank"}, lines = {"..."} }},
    -- adds/tabs are NOT supported on trash packs (single flat abilities list only)
}} }
```

A trash pack is **intentionally the same shape as a boss** (`icon`/`flags`/`stats`/
`abilities`, including `separator = true` phase bars) so the Trash view's rendering
can reuse the boss panel's functions wholesale instead of a bespoke layout. There is
currently no dedicated field for CC priority / patrol path / pull order — add that
content as separator-grouped abilities (e.g. `{ separator = true, name = "Pull Order" }`
followed by plain entries) rather than inventing new pack fields, unless a real need
for structured fields comes up.

**Trash tree separators.** A raid's `trash` list also supports `separator = true`
entries, rendered as a non-clickable grouping label in the Trash tab's left tree -
`RebuildTrashTree()` / `BuildTrashEntries()` in `DungeonJournal.lua` - the same pattern
as `RAIDS[].bosses`'s boss-list separators. Use this to mark packs that always spawn/
pull together (e.g. a mixed hallway group), purely by inserting a separator entry
before the run of packs it labels:

```lua
trash = {
    { separator = true, name = "Always pulled together" }, -- optional color = "ffRRGGBB"
    { key = "...", name = "Mob A", ... },
    { key = "...", name = "Mob B", ... },
    { key = "...", name = "Mob C", ... },
}
```

**Boss stats line.** A boss may carry an optional `stats` table, rendered as a
single armor/resistance line above its ability list (Abilities tab only). Omitted
keys default to `0`, and Holy is deliberately unsupported — 1.12 has no
meaningful Holy resistance. Add new schools to `RESISTANCE_SCHOOLS`.

```lua
stats = { armor = 0, fire = 0, nature = 0, frost = 0, shadow = 0, arcane = 0 },
```

**Phase separators.** An entry in a boss's top-level `abilities` list with
`separator = true` renders as a clickable bar instead of an ability row. Every
ability after it belongs to that phase until the next separator, so grouping is
driven purely by position in the table. Clicking the bar collapses/expands that
phase. Separators default to expanded and are ignored inside an add's nested
`abilities`.

```lua
abilities = {
    { separator = true, name = "Phase 1" },            -- optional color = "ffRRGGBB"
    { name = "Command Gesture", lines = {"..."} },
    { separator = true, name = "Phase 2" },
    { name = "Lay on Hands", lines = {"..."} },
}
```

**Passive heading.** A separator entry may carry `passive = true`. Instead of a
collapsible phase bar it renders as a plain section heading (same font as the
"Abilities" header, no background bar, no `[+]/[-]` toggle, not clickable); the
rows beneath it, up to the next separator, are always shown. Use it to label a
mob's always-on passive traits. Add it only to bosses/trash that actually have a
passive worth calling out — mobs without one just omit it, so it never appears
in the UI and adds no per-mob data. Example: Scarlet Soldier lists its active
`Sunder Armor` first, then a `Passives` heading, then `Improved Blocking`.

```lua
abilities = {
    { name = "Sunder Armor", lines = {"..."} },
    { separator = true, passive = true, name = "Passives" },
    { name = "Improved Blocking", lines = {"Increases block chance by 55%."} },
}
```

**What counts as a passive.** The `Passives` heading means "a permanent
property of the mob", not "something it does". A cooldown or a trigger
condition does *not* make an ability passive — almost every active ability is
gated by an internal cooldown and/or an AI condition ("at 20% HP", "when a
beast is in the raid", "every 15s"); that is just *when* the mob uses it, it is
still a discrete action. Decide by asking: is this a permanent trait, or an
event the raid reacts to?

Put it under `Passives` when it is:

- always on from the moment the mob engages, with no cast;
- only a stat/behaviour modifier — block chance, crit, a stance, an aura, a
  seal, a no-cooldown reactive proc that is just "how it fights" (e.g. Scarlet
  Guardsman's Riposte, Scarlet Centurion's Retaliation);
- something you would never mark `warning = true` or give a `roles` icon;
- something the raid does nothing differently about when it "procs".

Keep it as a normal ability (optionally with its own phase separator) when it:

- has a cast, activation, or telegraph;
- produces a distinct effect the raid times, interrupts, dispels, dodges, or
  stops DPS for — even on a fixed timer. Scarlet Champion's Vengeance (every
  15s: 3s grow, then reflect all damage — raid stops attacking) is a *periodic
  ability*, not a passive; the timer does not make it passive.
- is a condition-gated cast (Brigitte's Lay on Hands at 20%, Loksey's Scare
  Beast when a beast is present) — the condition is just the AI trigger.

Rule of thumb: if removing it would change the mob's tooltip stats, it is a
passive; if removing it would change what the raid has to *do*, it is an
ability.

## Essential Commands

There is no build, lint, format, test, or dev-server tooling in this repo. Validation is
manual in-game.

```bash
# Syntax check — optional, requires a locally installed Lua 5.1-compatible binary
# (none is installed in this repo/environment by default; the client has no CLI)
luac -p DungeonJournal.lua

# Deploy for testing (adjust the client path)
cp -r . "/c/Program Files/World of Warcraft 1.12.1/Interface/AddOns/DungeonJournal"
```

In-game validation loop: `/console reloadui` (or `/reload`), then `/clicky` to toggle the
window; expand a raid, click a boss, switch the Abilities/Adds tabs, and exercise both
scroll frames with the mouse wheel and the scrollbar.

## Patterns

- **Vanilla API only.** 1.12.1 predates most modern conventions: event/script handlers
  receive arguments via the globals `this`, `arg1`, ...; use `getglobal("Name")` instead
  of `_G["Name"]`; there is no `self`, no varargs `...` in handlers, and no
  `C_*` namespaces. Do not copy patterns from Retail/Classic-era addons.
- **Scrollbars must be recomputed manually.** `UIPanelScrollFrameTemplate` does not
  update its scrollbar range when the scroll child's height changes. Call
  `UpdateScrollBarRange(scrollFrame)` after every rebuild that changes child height,
  and use `EnableMouseWheelScroll(scrollFrame)` for wheel support.
- **Row pooling.** Tree rows, ability rows, flag slots, and Explaination rows are
  created lazily into pools (`abilityRowPool`, `CreateBossFlagSlot`, ...) and reused.
  Reuse the existing pool + `Configure*Row()` pattern instead of creating frames per
  rebuild, and always reset every field a row can set (textures, tex coords, colors) so
  stale state from a previous entry does not leak — see `ApplyUtilityIcon()`, which
  resets `SetTexCoord(0, 1, 0, 1)` for non-class icons.
- **Class icons are one atlas.** 1.12.1 has no `ClassIcon_X` files; class entries in
  `UTILITY_ICONS` all point at `CLASS_ICON_TEXTURE` and are cropped via
  `CLASS_ICON_COORDS`. Do not rely on Blizzard's `CLASS_ICON_TCOORDS` global.
- **New icons/flags are additive.** To add an icon type, add an entry to
  `UTILITY_ICONS` (plus `ICON_ExplainationS` for the legend) or `BOSS_FLAGS`; no other
  code changes should be needed.
- **New boss portraits** must be added as `.blp` in `Icons/`, listed in
  `DungeonJournal.toc`, and referenced without the file extension.
- **Shared row widgets branch on `currentView`.** `CreateAbilityRow` and
  `CreateSeparatorRow` are generic (parent passed in) and reused by both the boss
  panel (`abilityScrollChild`, `abilityRowPool`) and the trash panel
  (`trashAbilityScrollChild`, `trashAbilityRowPool`). Their `OnClick` handlers must
  check `currentView == "trash"` and call `RebuildTrashAbilityList(currentTrashPack)`
  instead of `RebuildAbilityList(currentBoss)` — forgetting this makes rows in
  whichever panel didn't get the branch silently unclickable (toggles `expanded` but
  rebuilds the wrong list). Apply the same check to any *new* shared row type.
- **`SelectView()` must run only after every widget it touches exists.** It's a
  `local function` that references trash-panel globals (`trashPortrait`,
  `RebuildTrashFlags`, `trashAbilityScrollFrame`, ...) defined later in the file, near
  `ShowBossInfo()`. Do not call `SelectView(...)` for the initial view until the very
  end of the file (after `RebuildTree()`), or those globals will still be `nil`.

## Anti-patterns

- Don't rename or renumber the `-- CHANGED:` comment banners; they document non-obvious
  1.12 workarounds and the rationale for existing hacks.
- Don't add third-party libraries or a build pipeline — the addon must load as plain
  files dropped into `Interface\AddOns\`.
- Don't reference textures with a `.blp`/`.png` extension; the client resolves
  extensionless paths.

## Known Issues

Fix these deliberately, not incidentally, and mention them in the commit message:

- **Blackwing Lair boss portraits are missing.** The eight BWL bosses reference
  `Icons/` portrait paths (Razorgore, ElementiumDecapitator, Broodlord, Firemaw,
  Krixix, Ebonroc, Chromaggus, Neferian) whose `.blp` files don't exist, so they
  fall back to the missing-texture placeholder in-game. The Molten Core and Scarlet
  Monastery bosses all have real `.blp` portraits in `Icons/` (and are listed in the
  TOC). ZG / UBRS / LBRS / Onyxia bosses use Blizzard `Interface\Icons\...` art or the
  `Interface\Icons\temp` placeholder, not custom portraits. (`Icons/Whitemane.blp`
  exists but is unused — Sally Whitemane is a phase separator, not a mob entry.)
- **Blackwing Lair has no placeholder abilities left** (the last 6 were filled from
  a combat log on 2026-08-29, and a further ~25 abilities added / reworded from the
  same log - see `BWL_CSV_Pass.md`). A handful of custom Vanilla+ effects
  (Shrink/Death Ray, Ice Sprinkler, Dragon sickness, ...) still say "needs
  testing". Scarlet Monastery is fully documented. Per-raid gaps: `TODO_Raid_Data.md`.
- **Spell.xlsx column quirk:** the usable English spell text is in the columns
  headed `Description_koKR` / `AuraDescription_koKR` (the `_enUS` ones are mostly
  blank in this export). Resolve `$s1`/`$s2` as `EffectBasePoints_n + 1` and `$d`
  via `SpellDuration.csv`, same as prior passes.
- **Trash coverage** now exists for Molten Core, Blackwing Lair, Scarlet Monastery,
  Zul'Gurub, UBRS, LBRS, and Onyxia (only World Bosses and the Emerald Dragons have
  no `trash` table). Ability *names* are sourced from real combat logs (per-raid CSVs
  or `mob_abilities_summary.txt`), *icons/descriptions* from `Spell.xlsx` matched by
  spell ID (strip the `$s1`/`$o1`/`$d` formula tokens in `Description_enUS`). Most
  trash `stats` (armor/resistances) are still estimates or `"X"` — the resistance
  sheets only cover bosses and their in-encounter adds, not hallway trash — and
  `flags` (mob type tags) are general-knowledge guesses throughout. `TODO_Raid_Data.md`
  has the per-raid sourcing notes and the list of what's still unverified.
- Resistance-school immunity is shown once, on the `stats` line (e.g. `fire = "immune"`) -
  do not also add a `BOSS_FLAGS` entry like `immune_fire` for it; that flag type was
  removed as redundant. `immune_poly` is the one exception (Polymorph immunity isn't a
  resistance school, so `stats` can't express it).

The slash command remains `/clicky` (unchanged, not currently considered an issue).

## External reference files (not loaded by the addon)

These live alongside `DungeonJournal.lua` for research/content purposes only — none are
referenced by the `.toc` or read at runtime. Use them to source real ability
names/icons, resistance values, and trash/patrol notes when filling in `RAIDS`, then
throw the derived Lua data into the normal `RAIDS` table; don't have the addon read
these files itself.

- **`Spell.xlsx`** — spell names, icons, and descriptions. Single "Spell" sheet, ~12MB.
  Good for looking up an ability's real icon path/tooltip text by name.
- **`mob_abilities_summary.txt`** — a pre-generated, human-readable summary of every
  spell/ability name seen in `WoWCombatLog.txt`, grouped by source mob (~8.7MB text).
  **Prefer this over the raw combat log** for "what abilities does mob X use" —
  it's already the distilled answer.
- **`WoWCombatLog.txt`** — the raw combat log the summary above was generated from.
  **~4.2GB — do not read or grep this without explicitly confirming with the user
  first**, even for a narrow search; it can burn an enormous number of tokens or time
  out. If `mob_abilities_summary.txt` doesn't answer the question, ask before touching
  this file, and even then scope the search as tightly as possible (e.g. `grep` for one
  exact mob/spell name, never a broad scan).
- **`V+ Lists.xlsx`** — multi-sheet raid-organizer workbook. Sheets include `Resistances
  Data` / `Resistances Testing` (source for boss/trash `stats` armor+resistance values),
  `Threat Data`, `Debuff List`, `Class BuffsDebuffs`, `Group Comp`, and a WIP MC tanking
  assignments sheet. `.xlsx` is a zip of XML — either use the `xlsx` skill or
  `unzip -o "V+ Lists.xlsx" -d <dir>` and read `xl/worksheets/sheetN.xml` +
  `xl/sharedStrings.xml` directly for a quick peek without loading the whole workbook.
- **`Tips_Tricks about 40-man content for RL.docx`** — raid-lead strategy notes: pre-pull
  checklists, mechanics, and (for at least Molten Core) a "Patrols" section with
  trash-pack-specific notes (e.g. Lava Surger, Ancient Core Hound) — a good direct
  source for the CC-priority/patrol-path/pull-order content the Trash view is designed
  to hold via separator-grouped abilities (see "Data model" above). `.docx` is also a
  zip of XML; `unzip` + strip tags from `word/document.xml` for a quick peek, or use the
  `docx` skill for a full clean read.

## Commit and Pull Request Guidelines

Before committing:

1. Confirm the file parses — `luac -p DungeonJournal.lua` if a Lua binary is available,
   otherwise verify the addon loads without a Lua error on-screen in-game.
2. Load the addon in a 1.12.1 client and verify `/clicky`, tree expansion, boss
   selection, both tabs, the Explaination view, and scrolling in both panels.
3. If assets changed, confirm every new `.blp` is listed in `DungeonJournal.toc`.

Commit messages: history is minimal (`Github Upload to save data`), so use
`type: message` going forward — e.g. `feat: add Onyxia's Lair encounters`,
`fix: reset tex coords when reusing ability rows`, `docs: document RAIDS schema`.

Pull request descriptions must state:

- What changed and why (content addition vs. UI/behavior change).
- Which client build/version it was tested on, and the manual steps exercised.
- Screenshots for any visual/UI change.
