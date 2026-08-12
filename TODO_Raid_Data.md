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
