# Raid data - abilities/stats still needing real numbers

Snapshot as of 2026-08-12. Each item below has an `X` placeholder (or a
guessed description with no matching entry in `Spell.xlsx`) - fill in
from in-game testing, don't guess numbers (see [CLAUDE.md](CLAUDE.md)).

## Molten Core trash ([raids/MC.lua](raids/MC.lua))

- **Flameguard** - `stats` block: armor + all 5 resistances are `"X"`,
  never tested.
- **Firelord -> Incinerate** - damage amount unknown; description itself
  is a guess (no matching spell in `Spell.xlsx`).
- **Firelord -> Spawn Lava Spawn -> Fireball** - both the direct hit and
  the DoT damage are unknown.
- **Lava Elemental -> Lava Explosion** - damage unknown; description is a
  guess (no `Spell.xlsx` match).
- **Lava Reaver -> Lava Grasp** - damage + root duration unknown; text and
  icon are both guesses (no `Spell.xlsx` match).
- **Lava Annihilator -> Double Attack** - we've confirmed it hits twice
  per swing, but not the interval ("every X seconds").
- **Flame Imp -> Fire Nova** - damage unknown; description is a guess (no
  `Spell.xlsx` match).

Everything else in MC trash (Molten Giant, Molten Destroyer, Flameguard's
other two abilities, Core Hound, Ancient Core Hound, Lava Surger, Lava
Reaver's Strike, Lava Annihilator's Annihilate, Firewalker) has confirmed
numbers as of this pass.

## Blackwing Lair ([raids/BWL.lua](raids/BWL.lua))

- **Razorgore -> Grethok the Controller (add) -> Arcane Missiles** -
  channel duration and per-missile damage both unknown.
- **Razorgore -> Grethok the Controller (add) -> Dominate Mind** - max
  level it can control, and the control duration, both unknown.
- **Blackwing Spellbinder -> Greatest Polymorph** - duration unknown.
- **All 14 BWL trash mobs** (`death_talon_captain` through
  `death_talon_wyrmguard`) - the file's own header comment says their
  flags/roles/stats are "general knowledge / best-guess," i.e. none of
  it has actually been tested. Worth a full pass, not just filling
  individual `X`s.

Everything else checked in BWL (Razorgore's own kit, and every other
boss/trash ability scanned) had real numbers, no `X` placeholders found.

### BWL wording pass not done yet - acceptable for now

BWL hasn't been through a scope/wording pass the way MC has (see the
`CLAUDE.md` scope rule: mechanics only, no raid-lead strategy/priority
calls). This is fine to leave as-is for now - just flagging it as
not-yet-done rather than "wrong":

- Razorgore add "Grethok the Controller": *"Kill or interrupt it
  quickly."*
- Razorgore add "Blackwing Mage": *"priority CC or interrupt"*, and its
  Fireball ability: *"priority CC or interrupt target"*; its Arcane
  Intellect: *"kill or CC quickly to limit its casting."*
- Chromaggus separator literally named *"Brood Afflictions - dispel
  assignments."*
- Chromaggus "Tail Swipe": *"Tanks position front and back, away from
  the raid during phase 1."*
- Chromaggus "Tunnel adds": *"are the number one priority - they
  overwhelm the raid quickly."*
- Nefarian "Curse of Nefarius": *"Decurse it as a priority."*
- Blackwing Warlock's Healing Circle: *"kill or interrupt to limit its
  support."*
- Blackwing Spellbinder's Arcane Blast: *"priority CC or interrupt
  target."*

## Scarlet Monastery bosses ([raids/SM.lua](raids/SM.lua))

- **Loksey -> Paralyzing Poison** - per-stack Nature damage unknown.
- **Loksey -> Power Shot** - damage unknown (line literally reads
  "(Loksey weapon damage?)X damage" - unresolved question mark left in
  from testing).
- **Brigitte Abbendis -> (Scarlet Sharpshooter add) -> Explosive Shot** -
  Fire damage amount unknown.
- **Doan (Frost stance) -> Chilled to the Bone -> Frozen Solid** - both
  the stun duration and the per-tick Frost damage are unknown (nested
  three deep under Doan's Frost-stance "Numbing Cold").

Everything else checked in SM bosses (Vishas, Herod, Brother Michael,
Renault Mograine, Fairbanks, and the rest of Loksey/Brigitte/Doan) had
real numbers, no `X` placeholders found.

## Scarlet Monastery trash ([raids/SM.lua](raids/SM.lua))

Added 2026-08-12 from a real combat log ("Scarlet Monestary Trash (most
of it).csv" - 23 distinct mobs), cross-matched against `Spell.xlsx` by
exact Spell ID rather than name-guessing. The CSV's own damage numbers
were ignored per instruction (random every pull, not real spell values);
everything below comes from `Spell.xlsx`'s effect fields instead. This
first pass is functional but has real gaps - to make it solid:

- **Pull order/grouping is completely unknown.** The CSV is a flat event
  list with no pull boundaries, so `SM_TRASH_ORDER` is just all 23 mobs
  in no particular order, no separators. Needs an actual walkthrough to
  group mobs the way they really pull (Library/Armory/Cathedral/Graveyard
  wings, mixed packs, etc.) - see AGENTS.md's trash tree separator syntax.
- **Trash packs have no "adds" UI, unlike bosses.** Scarlet Tracking Hound
  is really an add Scarlet Beastmaster summons (see Beastmaster's own
  "Summon Scarlet Tracking Hound" ability), but the Trash panel only has
  Abilities/Tactics tabs - no `tabAdds`/adds-rendering path the way
  `ShowTactics`/the boss panel has (see `DungeonJournal.lua` around
  `tabAdds`/`currentBoss.adds`). They're listed as two independent trash
  pulls for now. Building a real trash Adds tab (mirroring the boss
  panel's) would let this - and similar cases elsewhere - be modeled
  properly; needs in-game UI testing before it ships.
- **`stats` (armor/resistances) is `"X"` across all 23 mobs** - the log
  has no stat data at all, 100% untested.
- **Scarlet Diviner's 23 "Prophecy: ..." cards are all `X`-only.** Every
  one of them ships with zero tooltip text in `Spell.xlsx` (no
  `Description_enUS`), so there's nothing to derive from - this mob
  needs dedicated external research (wiki/testing), not just filling
  gaps from the sheet.
- **Every ability with no `Description_enUS` at all** (not just missing
  numbers, but zero tooltip text) was left as a generic "no ability
  description available" placeholder rather than guessed from raw effect
  codes. That's roughly a third of the abilities pulled from the log -
  see any `-- CHANGED:` comment reading "no ability description
  available" in `SM_TRASH_MOBS`. Worth a pass to see if a build-uploaded
  or newer `Spell.xlsx` fills these in.
- **Scarlet Tracking Hound -> Infected Wound** - the raw sheet value (+3
  damage taken) looked implausibly small for what should be a meaningful
  debuff, so it was left `X` rather than presented as real - re-check
  against Spell.xlsx directly.
- **Scarlet Sorcerer -> Mana Shield** - sheet lists an absorb amount of
  999,999,999, almost certainly an "unlimited" sentinel value rather than
  a real number - confirm intended behavior.
- **Scarlet Protector -> Judgement of Light** - actual heal amount lives
  on a separate linked spell (36071) that wasn't pulled in this pass.
- Every ability whose tooltip includes a duration (`$d`) or radius (`$a1`)
  is `X seconds`/`X yards` - `Spell.xlsx` only has index references
  (`DurationIndex`/`RangeIndex`) into `Duration.dbc`/`Range.dbc`, which
  aren't in this workbook, so those can't be resolved from the sheet at
  all and need in-game testing.
- Icons and mob-level (portrait) icons were picked reasonably from each
  mob's own real abilities, not verified in-game.
