# DungeonJournal

DungeonJournal is a World of Warcraft 1.12.1 (Vanilla) addon that provides an
"Adventure Guide"-style reference window for raid and dungeon encounters.

It shows a collapsible raid → boss tree on the left, and on the right a boss
header with a tabbed list of that boss's abilities and adds — including
role/dispel/class icons and quick-glance encounter flags (e.g. "not
tauntable", "bring Fire Protection Potions"). A second "Explaination" view
lists a legend explaining every icon used in the tool.

Currently included: **Molten Core** and **Scarlet Monastery**.

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
