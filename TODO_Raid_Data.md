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

## Upper Blackrock Spire ([raids/UBRS.lua](raids/UBRS.lua))

Added 2026-08-13 from a real combat log (`UBRS.csv`, 46k rows), filtered
to `Source GUID` starting `0xF130` (real creatures) and totems excluded,
cross-matched against `Spell.xlsx` by exact Spell ID - same methodology
as the SM trash pass above.

- **7 of 8 bosses with combat data got real abilities**: Pyroguard
  Emberseer, Solakar Flamewreath, Goraluk Anvilcrack, Warchief Rend
  Blackhand, Gyth, The Beast, General Drakkisath, Lord Valthalak.
  **Jed Runewatcher has no combat data in `UBRS.csv`** and was left as
  the original single-ability placeholder untouched.
- **25 trash mobs added** (`UBRS_TRASH_ORDER`/`UBRS_TRASH_MOBS`), one
  entry per distinct non-totem NPC name that logged an ability.
- **Summoned-variant merge decision**: "Summoned Blackhand Dreadweaver"
  and "Summoned Blackhand Veteran" (necromancer-summoned versions) were
  merged into the base `blackhand_dreadweaver`/`blackhand_veteran`
  entries rather than listed as separate trash pulls - each summoned
  variant's logged ability set is a strict subset of the base mob's kit
  (3 spells each, all also present on the base mob), which reads as the
  same unit type rather than a mechanically distinct pack. See the
  `-- CHANGED:` comment on each entry in `UBRS_TRASH_MOBS`.
- **Pull order/grouping is completely unknown**, same caveat as SM
  trash: the CSV is a flat event list with no pull boundaries, so
  `UBRS_TRASH_ORDER` is all 25 mobs in no particular order, no
  separators. Needs an actual walkthrough (Rookery/Furnace/Summoner's
  Tomb/Hall of Assassins wings, mixed packs, etc.) to group properly.
- **`stats` (armor/resistances) is `"X"` across all 25 trash mobs** -
  the log has no stat data at all, 100% untested.
- **Abilities left as `X`** (raw sheet value looked implausible, or no
  `Description_enUS` at all) - see the `-- CHANGED:` comment on each:
  - Blackhand Elite / Goraluk Anvilcrack / Rage Talon Captain -> **Head
    Crack**: raw Stamina-reduction value (1) looks too small to be real.
  - Rookery Guardian / Rookery Hatcher -> **Sunder Armor** (spell
    15572): raw per-stack armor value (0) looks implausible; compare
    against the 1000-per-stack values on the two other Sunder Armor
    ranks (15572's sibling ranks 24317/16145) used elsewhere in this
    file, which look far more plausible.
  - Rage Talon Dragon Guard -> **Sunder Armor** (spell 16145): no
    per-stack amount could be pulled for this specific rank; text left
    generic rather than borrowing a different rank's number.
  - Rage Talon Dragonspawn -> **Charge**: raw bonus-damage value (1)
    looks implausibly small next to the near-identical Shield Charge/
    Berserker Charge abilities elsewhere in this file (150-300).
  - Warchief Rend Blackhand -> **Whirlwind**: raw sheet value for the
    bonus-damage effect is an implausible -9900 (likely a sentinel);
    the real bonus damage lives on a separate linked spell not captured
    in this pass.
  - Scarshield Spellbinder -> **Resist Fire**: raw value (2) looks
    implausibly small for a resistance buff.
  - Multiple mobs' **Mana Burn** (Burning Felhound, Scarshield
    Spellbinder): the drained-mana amount is real, but the
    damage-per-point-of-mana value lives on a separate linked effect
    not captured in this pass.
  - Blackhand Dreadweaver -> **Curse of Thorns**: proc chance and
    per-attack damage both live on linked spells/effects not captured.
  - General Drakkisath -> **Conflagration**: the periodic splash damage
    to nearby allies lives on a separate linked spell (16806) not
    captured in this pass.
  - Blackhand Iron Guard -> **Defensive Stance**: real percentages live
    on a separate linked spell (7376), not captured in this pass.
  - General Drakkisath -> **True Fulfillment**: raw sheet value
    (100000) looks like an "unlimited"-style sentinel, not a real
    number.
  - Every ability with **zero `Description_enUS`** (Eviscerate, Shield
    Toss Return, Fireball/Frost Nova on Blackhand Summoner, Sap Visual,
    "Hate to 50%", Disturb Rookery Egg, Defile, Frenzy, Chromatic Chaos,
    Dominance, Emberseer Growing) was left as a generic "no ability
    description available" placeholder, several with a short note on
    what the name/effect type suggests (e.g. "Hate to 50%" and "Sap
    Visual" both read as internal mechanic/visual effects rather than
    real player-facing abilities, but were still listed per the sourcing
    rule of not filtering beyond totems).
- Every ability whose tooltip includes a duration (`$d`), radius
  (`$a1`), or tick interval (`$t1`/`$t2`) is rendered as `X seconds` -
  `Spell.xlsx` only has index references into `Duration.dbc`/`Range.dbc`
  (not included) for duration/radius, and tick intervals aren't
  resolvable from this sheet at all; needs in-game testing.
- Icons were picked from each mob's own real abilities (trash) or kept
  as the existing `Interface\Icons\temp` placeholder (bosses - portrait
  work is out of scope for this pass, see the "Known Issues" section in
  AGENTS.md).
- `flags` (melee/caster/ranged) are informed guesses from each mob's
  ability set (e.g. mobs with only Shadow Bolt/Fireball-type abilities
  marked `caster`), not verified in-game.

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

## Zul'Gurub trash ([raids/ZG.lua](raids/ZG.lua))

Added 2026-08-13 from a real combat log ("ZG Spell GO.csv" - 81k rows),
filtered to `0xF130`-prefixed creature GUIDs and cross-matched against
`Spell.xlsx` by exact Spell ID, same methodology as SM trash above. 39
distinct trash mobs kept (6 more moved out afterward - see below);
everything below is either an `X` placeholder or a mob/ability
deliberately left out.

- **Moved out of trash into boss `adds`/sub-boss entries** (per user
  correction, 2026-08-13): Ohgan is Mandokir's mount, now an add on
  `mandokir`. Jungle Toad is Hakkari Witch Doctor's summon, now nested
  under that trash mob's "Release Toads" ability instead of its own
  entry. Shade of Jin'do is now an add on `jindo`. Spawn of Mar'li is now
  an add on `marli`. Zealot Lor'Khan and Zealot Zath are fought together
  with Thekal as one three-boss encounter, now wrapped as sub-boss
  entries under `thekal` (same pattern as `edge_of_madness`'s four
  sub-bosses) instead of separate trash pulls.

- **Pull order/grouping is completely unknown**, same caveat as SM -
  the CSV has no pull boundaries, so `ZG_TRASH_ORDER` is a flat list of
  all 45 mobs with no separators.
- **`stats` (armor/resistances) is `"X"` across all 45 mobs** - the log
  has no stat data at all, 100% untested.
- **Mobs/sources excluded from the roster:**
  - All named totems (Magma Totem IV, Searing Totem/VI, Mana Spring
    Totem IV, Strength of Earth Totem IV/V, Healing Stream Totem V,
    Fire Nova Totem V, Greater Fire Nova Totem, Earthbind Totem, Brain
    Wash Totem, Venomous Totem) - these are player shaman totems logged
    with `0xF130` creature GUIDs, not real ZG mobs.
  - "Infernal" and "Mad Voidwalker" - warlock pet summons, not ZG trash.
  - Literal `Source` name "Unknown" (one Fire Nova cast, unresolvable).
  - "Poison Cloud" - its only logged spell IDs (28241/28158) don't match
    the "Poison Cloud" already on the Venoxis boss entry, but the name
    collision plus zero other abilities made it too ambiguous to treat
    as a distinct trash mob; skipped rather than guessed.
  - "Corrupted Blood Globe" and "Fresh Blood Globe" - both logged only
    the generic "Dazed" flee-effect, no real ability; read as summoned
    zone objects near Hakkar's sacrifice altar, not pullable trash.
  - "Powerful Healing Ward" - single self-named spell cast (24311), reads
    like a summoned ward object rather than a pullable mob; skipped.
  - "Hazza'rah" - already documented as a sub-boss inside the
    `edge_of_madness` boss entry (its Earth Shock/Chain Burn kit is
    already there); its trash-log entries were skipped as a duplicate.
- **Generic non-ability events dropped from every mob's ability list:**
  `Dazed` (spell 1604, universal "hit while fleeing" effect, not a real
  mob ability) and `Sap Visual` (spell 35762, appears to be a
  misattributed player Rogue Sap landing on the mob, not something the
  mob casts).
- **Three mobs have zero real logged abilities** - "Hooktooth Frenzy",
  "Nightmare Illusion", and "Razzashi Skitterer" only ever logged the
  generic Dazed effect. Given a placeholder entry (mirroring the
  `nameless_hermit` boss's own pattern in this file) rather than dropped,
  since they're clearly real, named, pullable mobs.
- **Every ability with no `Description_enUS` at all in `Spell.xlsx`**
  was left as a generic "no ability description available" placeholder
  rather than guessed from raw effect codes - see the `-- CHANGED:`
  comments throughout `ZG_TRASH_MOBS`. That's a large fraction of the
  abilities pulled (Throw Axe, Summon Flames, Toad Explode, Web Spin,
  Touch of Death, Level Up, and many more).
- Every ability whose tooltip includes a duration (`$d`) or radius (`$a1`)
  is rendered as `X seconds`/`X yards`, same `Spell.xlsx` limitation as
  documented for SM trash (no `Duration.dbc`/`Range.dbc` in this sheet).
  Some tooltips also reference a linked spell's own effect via a
  spell-ID-prefixed token (e.g. `$24336d`, `$22703s1`) - those can't be
  resolved from this pass either and were rendered as `X`.
- **`flags` (melee/caster/ranged) and `roles` (`kick`/`dispel` tags) are
  heuristic**, inferred from each mob's ability descriptions rather than
  tested in-game - worth a pass to verify against actual pulls.
- Icons were picked from each mob's own real logged abilities, not
  verified in-game.

### Second pass from "ZG 2.csv" (2026-08-13)

Added real data for Hakkar/Azus/Nameless Hermit from a second combat log
("ZG 2.csv" - 25k rows), same methodology (exact Spell ID match against
`Spell.xlsx`).

- **Nameless Hermit** now has real abilities (Devour, Silence, Whirlwind,
  Wild Charge) replacing its old full-placeholder entry.
- **Hakkar** gained two new abilities not in the first pass: Cause
  Insanity (real numbers - speeds attacks 100%, movement 200%, causes it
  to attack its own allies) and Aspect of Thekal (`X` - no
  `Description_enUS`).
- **Azus the Bloodseeker** gained three new abilities: Rupture, Wound
  (both `X` - no `Description_enUS`), and Thirst (`X` - raw base points
  of 39999-70000 look like a sentinel/formula value, not a real number,
  same judgment call as SM's Greater Light).
- **Caverngloom Crocolisk** (new mob, not in the original ZG log) is now
  an `add` on `nameless_hermit` per user correction, not a standalone
  trash pull. Its only real ability, Infected Bite, has
  `Description_enUS` set to the literal word `"Trash"` in `Spell.xlsx` -
  clearly a Blizzard dev placeholder, not real flavor text - so it's `X`
  rather than used verbatim.
- **Nightmare Illusion** moved out of trash per user correction - it's an
  add Hazza'rah summons (fits his sleep/nightmare theme). ~~Nested inside
  Hazza'rah's own ability list~~ - superseded below: Hazza'rah is now a
  real top-level boss, so this is a proper `adds` entry.

### Edge of Madness split into four real bosses (2026-08-13)

Per user request: `edge_of_madness` (previously one boss entry with four
sub-bosses nested as ability-shaped tables) is now four real top-level
bosses - `renataki`, `grilek`, `hazzarah`, `wushoolay` - grouped under a
non-clickable `{ separator = true, name = "Edge of Madness" }` label in
`ZG_BOSS_ORDER` (only one of the four ever spawns per reset, so the
separator keeps the tree reading as one encounter). `BuildZGBosses()` was
updated to pass separator entries through, mirroring how `BuildZGTrash()`
already handles trash separators.

Reasoning: `BuildAbilityLines()` (used by Broadcast/the auto-summary)
only reads a boss's top-level `abilities` array - it doesn't recurse into
a nested sub-boss's own abilities, so none of the four's real
warning-flagged abilities were ever reachable by Broadcast under the old
nested shape. Splitting also means whichever of the four actually spawns
is just `currentBoss` like any other boss - no new "which one is live"
selection logic needed, and each one now gets real `adds` support
(Hazza'rah's Nightmare Illusion is a proper `adds` entry again, with a
new "Summon Nightmare Illusion" ability replacing the old
inline-summary line). None of the four have confirmed `stats` - worth
testing in-game.
- Existing Hakkar/Azus abilities (Corrupted Blood, Blood Siphon, Curse of
  Nemesis, Hysteria, Blood Leech, Lacerate, Blood Cloud, Blood Tide,
  Charge) were left untouched - their `Spell.xlsx` `Description_enUS` is
  empty for several of them (Hysteria, Blood Siphon, Corrupted Blood), so
  that wording predates this CSV pass and wasn't re-verified against it.
