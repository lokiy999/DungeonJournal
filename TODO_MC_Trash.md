# MC Trash - abilities still needing real numbers

Snapshot as of 2026-08-12. Each of these has an `X` placeholder (or a
guessed description with no matching entry in `Spell.xlsx`) in
[raids/MC.lua](raids/MC.lua) - fill in from in-game testing, don't guess
numbers (see [CLAUDE.md](CLAUDE.md)).

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
