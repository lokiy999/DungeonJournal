# DungeonJournal

DungeonJournal is a World of Warcraft 1.12.1 (Vanilla) addon that provides an
"Adventure Guide"-style reference window for raid and dungeon encounters.

It shows a collapsible raid → boss tree on the left, and on the right a boss
header with a tabbed list of that boss's abilities and adds — including
role/dispel/class icons and quick-glance encounter flags (e.g. "not
tauntable", "bring Fire Protection Potions"). A second "Explaination" view
lists a legend explaining every icon used in the tool.

Currently included: **Molten Core**, **Blackwing Lair**, and **Scarlet Monastery**.

## Installing

Copy this repository into your WoW 1.12.1 `Interface\AddOns\` folder as
`DungeonJournal`, then enable it from the in-game AddOns list.

## Usage

Type `/clicky` in chat to toggle the window. Expand a raid in the tree,
click a boss to load its abilities/adds, and switch between the Abilities
and Adds tabs. Both the tree and ability panels scroll with the mouse wheel
or scrollbar.

## Contributing

See [AGENTS.md](AGENTS.md) for the codebase layout, data model, and
conventions to follow when adding content or making changes.

### Abilities vs. passives

Each mob's ability list can carry a `Passives` heading
(`{ separator = true, passive = true, name = "Passives" }`) for its always-on
traits. A cooldown or a trigger condition does **not** make something a
passive — decide by what it *is*, not when it fires:

- **Passive** — a permanent property: a stat/behaviour modifier (block chance,
  crit, a stance, an aura, a seal) or a no-cooldown reactive proc that is just
  "how the mob fights". The raid does nothing differently when it procs; you
  would never mark it `warning = true`.
- **Ability** — a discrete event the raid reacts to (times, interrupts,
  dispels, dodges, stops DPS for), *even if it is on a fixed timer or only
  fires under a condition*. E.g. an every-15s reflect window, or a cast that
  only happens at 20% HP.

Rule of thumb: if removing it would change the mob's tooltip stats it is a
passive; if removing it would change what the raid has to *do*, it is an
ability. Full reasoning and more examples are in
[AGENTS.md](AGENTS.md) under "What counts as a passive".
