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

## Scarlet Monastery ([raids/SM.lua](raids/SM.lua))

No trash data exists for SM at all currently (bosses only).

- **Loksey -> Paralyzing Poison** - per-stack Nature damage unknown.
- **Loksey -> Power Shot** - damage unknown (line literally reads
  "(Loksey weapon damage?)X damage" - unresolved question mark left in
  from testing).
- **Brigitte Abbendis -> (Scarlet Sharpshooter add) -> Explosive Shot** -
  Fire damage amount unknown.
- **Doan (Frost stance) -> Chilled to the Bone -> Frozen Solid** - both
  the stun duration and the per-tick Frost damage are unknown (nested
  three deep under Doan's Frost-stance "Numbing Cold").

Everything else checked in SM (Vishas, Herod, Brother Michael, Renault
Mograine, Fairbanks, and the rest of Loksey/Brigitte/Doan) had real
numbers, no `X` placeholders found.
