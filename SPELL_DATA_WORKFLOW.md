# Spell data workflow

How ability numbers (damage, durations, tick intervals, radii, target counts) get
filled into `Raids/*.lua` from the client's own spell table instead of guesswork.
First used 2026-09-29 for MC, BWL, Onyxia, ZG, UBRS and LBRS - see
[TODO_Raid_Data.md](TODO_Raid_Data.md) for what was filled and what is still open.

## Files and paths

| What | Where |
|---|---|
| Raid data being edited | `Raids/<RAID>.lua` in this repo |
| Combat logs (spell IDs per mob) | `*.csv` in this repo root: `MC FULL.csv`, `BWL stuff.csv`, `Onyxia.csv`, `ZG Spell GO.csv`, `ZG 2.csv`, `UBRS.csv`, `LBRS.csv`, `SM 6 bosses.csv`, `SM mograine fairbanks.csv`, `Scarlet Monestary Trash (most of it).csv` |
| Spell.csv reader (external, not in this repo) | `C:\Users\Leon_\Documents\WoW Website Project\projects\Spell.csv reader\` - `sp.py`, `gen_custom_spell_tooltips.py`, `README.md` |
| Client spell tables | `...\Spell.csv reader\CSV's\` - `Spell.csv`, `SpellDuration.csv`, `SpellRadius.csv`, `SpellIcon.csv` |
| Helper scripts (this repo) | `tools/propose.py`, `tools/dump.py`, `tools/scaling.py`, `tools/apply_lines.py` |
| Notes on what's done / open | `TODO_Raid_Data.md` |

The `tools/` scripts find the reader through the `SPELL_READER` environment variable,
defaulting to the Desktop path above. They find this repo relative to themselves, so run
them from the repo root. None of this is loaded by the addon (the `.toc` only lists Lua
and art), so the `.py` files are safe to keep here.

To let Claude read the reader folder without asking each time, it's listed under
`permissions.additionalDirectories` in `.claude/settings.local.json` (git-ignored).

## Step by step

1. **Find the gaps.** Placeholders are the letter `X` in a `lines` string:
   `grep -nE '\bX\b' Raids/ZG.lua | grep -v stats`.
2. **Get proposals.** `python tools/propose.py ZG "ZG Spell GO.csv" "ZG 2.csv"` - for every
   single-line `lines = {...}` with an `X`, it looks up the spell ID in the combat logs by
   (source mob, ability name), also takes any `spell <id>` from the comment just above,
   and prints the Spell.csv tooltip with the tokens (`$d`, `$t1`, `$x1`, `$a1`, ...)
   resolved. It's read-only.
   - It skips **multi-line** `lines = {` blocks - grep for those and handle them by hand.
   - If one mob has two IDs for the same ability name, both are shown - pick deliberately.
3. **No tooltip text?** `python tools/dump.py <id>` prints the effect types, aura types,
   values, radius and tick interval, and follows triggered spells. Write the description
   from that. Where the effect is scripted (Dummy / Script Effect, or a periodic trigger
   with no target spell), there's nothing more in the data - keep an `X` and say so.
4. **Check level scaling.** `python tools/scaling.py <id>` - if it prints `<- SCALES`, the
   stored value is only the level-1 base. Real value:
   `(base + 1) + perLevel x (casterLevel - spellLevel)`, capped at max level when that's
   above 0. Mob levels aren't known yet, so write the per-level amount, optionally with
   an "about N at level 60" example. Durations never scale.
5. **Apply.** Put the accepted changes in a small fixes file
   `FIX = {line: ("spell id", "new text")}` (line numbers from step 2) and run
   `python tools/apply_lines.py ZG fixes.py`. It rewrites those lines bottom-up and adds
   a `-- CHANGED <date>: from Spell.csv (spell <id>).` comment above each one. It refuses a
   line that no longer has an `X` (stale line numbers); pass `--any` to override.
   One-off edits are fine to do by hand instead - keep the same comment style.
6. **Verify.** Brace balance for every edited file:
   `grep -o '{' Raids/ZG.lua | wc -l` and the same for `}` - the counts must match.
7. **Record it** in `TODO_Raid_Data.md`: what was filled, what's still `X`, and why.
8. **Don't commit yet.** The user tests in-game with `/reload` first (see CLAUDE.md).

## Reading Spell.csv - what the reader's README doesn't cover

Column numbers are 0-based. Columns 70 and up are shifted right by one for every decimal
split into two fields in that row. The reader works out the shift from where the name
lands (should be col 120); the tools apply it.

| Col | Meaning | Checked against |
|---|---|---|
| 1 | School: 0 Physical, 1 Holy, 2 Fire, 3 Nature, 4 Frost, 5 Shadow, 6 Arcane | Fireball, Shadow Word: Pain, Frost Shock |
| 27 / 29 | Max level / spell level (used for level scaling) | Fireball Rank 1 (0.6 per level) |
| 61-63 | Effect type per effect: 2 School Damage, 3 Dummy, 6 Apply Aura, 27 Persistent Area Aura, 41 Summon, 77 Script Effect, 98 Knock Back, ... (never shifted) | Fireball, Frost Shock |
| 73-75 | Points per level per effect (floats - may be split) | Fireball Rank 1 |
| 91-93 | Aura type per effect: 3 periodic damage, 8 periodic heal, 12 stun, 22 resistance/armor, 23 periodic trigger, 33 slow, 61 scale, 74 reflect school, 79 damage done %, 87 damage taken %, 89 % of max health per tick, 138 melee haste | SW:P, Renew, Mark of the Wild, Polymorph |

The full effect/aura name tables are in `tools/dump.py`.

## Mistakes already made - don't repeat them

- **Negative values:** the real value is `abs(base + 1)`, not `abs(base) + 1`. The old
  `Spell.xlsx` pass did the latter, making every negative percentage 2 too high (77%
  instead of 75%, Sunder 1002 instead of 1000). 19 of those were fixed in ZG.
- **`$o1` is a total:** it's `per-tick value x (duration / tick interval)`. Quoting the
  per-tick value as the total gave "700 over 10 sec" instead of 7000.
- **Tiny values usually mean level scaling**, not bad data - run `scaling.py` before
  writing a "looks implausibly small" note.
- **Check the tooltip against the effects.** Gyth's Freeze text had its up-front and
  over-time numbers swapped relative to what the effects actually do.
- **A resolved tooltip can mislead** when the real numbers are in a triggered spell (Rend's
  Whirlwind: the tooltip resolves to "+50", the triggered spell does +280 to 390 every
  0.3 sec). Follow the triggers with `dump.py`.
- The combat log CSVs' `Value` column is a hit count, not damage - don't read amounts
  from it.
