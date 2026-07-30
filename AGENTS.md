You are an experienced, pragmatic software engineering AI agent. Do not over-engineer a solution when a simple one is possible. Keep edits minimal. If you want an exception to ANY rule, you MUST stop and get permission first.

# DungeonJournal

## Project Overview

DungeonJournal is a **World of Warcraft 1.12.1 (Vanilla) addon** that provides an
"Adventure Guide"-style window for raid/dungeon encounters: a collapsible
raid → boss tree on the left, and a boss header plus a tabbed accordion list of
abilities and adds on the right. A second top-level view ("Explaination") lists an
icon legend.

- **Language:** Lua 5.0 as embedded in the 1.12.1 client (no external runtime, no
  package manager, no build step).
- **UI:** Blizzard FrameXML API only (`CreateFrame`, `UIPanelScrollFrameTemplate`,
  `SetBackdrop`, ...). No Ace/LibStub or other third-party libraries.
- **Assets:** boss portraits as `.blp` textures in `Icons/`, with source PNGs kept in
  `Icons/PNG Files/` for reference.

## Reference

```
DungeonJournal.toc     Addon manifest: interface version, metadata, file/asset load list
DungeonJournal.lua     Entire addon (~1.8k lines): config, data, UI, slash command
Icons/*.blp            Boss portrait textures actually loaded by the client
Icons/PNG Files/*.png  Source art (not loaded in-game; keep in sync when adding icons)
```

`DungeonJournal.lua` is organized top-to-bottom in labeled comment banners; keep new
code in the matching section:

1. **Config** — window/row dimensions, `CLASS_ICON_TEXTURE` + `CLASS_ICON_COORDS`,
   `UTILITY_ICONS`, `ApplyUtilityIcon()`.
2. **`BOSS_FLAGS`** — per-encounter quick-glance flags (tauntable, protection potions).
3. **`ICON_ExplainationS`** — icon legend rows for the Explaination view.
4. **`RAIDS`** (line ~261) — the content database: `raids -> bosses -> abilities / adds -> abilities`.
5. **UI construction** — main frame, tree scroll frame, boss header, ability scroll
   frame, tabs, nav bar, Explaination panel.
6. **Rebuild functions** — `RebuildTree()`, `RebuildAbilityList()`, `RebuildBossFlags()`,
   `RebuildExplainationList()`, `ShowBossInfo()`, `SelectTab()`, `SelectView()`.
7. **Slash command** — `/clicky` toggles the window.

### Data model

Add content by editing the `RAIDS` table only; the UI is fully data-driven.

```lua
{ key = "MC", name = "Molten Core", expanded = false, bosses = {{
    key = "lucifron",
    name = "Lucifron",
    icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Lucifron", -- no .blp extension
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
}} }
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

## Anti-patterns

- Don't rename or renumber the `-- CHANGED:` comment banners; they document non-obvious
  1.12 workarounds and the rationale for existing hacks.
- Don't add third-party libraries or a build pipeline — the addon must load as plain
  files dropped into `Interface\AddOns\`.
- Don't reference textures with a `.blp`/`.png` extension; the client resolves
  extensionless paths.

## Known Issues

Fix these deliberately, not incidentally, and mention them in the commit message:

- Several bosses reference portrait icons that are not present in `Icons/` nor listed
  in the TOC (they fall back to the default question-mark icon in-game): the Scarlet
  Monastery bosses Loksey, Brigitte Abbendis, Vishas, Herod, Brother Michael, Doan,
  Renault Mograine & Sally Whitemane, and Fairbanks, plus every Blackwing Lair boss.
  Only the original Molten Core bosses have real `.blp` portraits.
- Blackwing Lair and the newer Scarlet Monastery bosses currently have only a single
  placeholder ability each ("Placeholder. Abilities not yet documented.") — real
  ability data still needs to be filled in.

The slash command remains `/clicky` (unchanged, not currently considered an issue).

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
