# Raid data - abilities/stats still needing real numbers

Snapshot as of 2026-08-12. Each item below has an `X` placeholder (or a
guessed description with no matching entry in `Spell.xlsx`) - fill in
from in-game testing, don't guess numbers (see [CLAUDE.md](CLAUDE.md)).

**Consistency pass 2026-08-29** - reconciled this file against the current
raid files. State now: **Molten Core trash** is fully filled except the four
"still unsure" items below (Firelord Fireball, Lava Annihilator Double
Attack interval, Flame Imp Fire Nova, and the Incinerate wording). **Scarlet
Monastery bosses** are down to two `X`s: Loksey → Power Shot and Doan →
Frozen Solid. **Scarlet Monastery trash** has no `X` left in any ability
line - only the `stats` blocks (all 20 mobs, untested). Remaining boss `X`s
elsewhere: Molten Core has 10 (all on bosses/adds - Golemagg's Core Rager,
Garr's Firesworn, Baron Geddon, Shazzrah, Majordomo's healer adds,
Sulfuron, and Ragnaros), BWL still has its 6 placeholder abilities (Known
Issues in AGENTS.md), and ZG/UBRS/LBRS trash `stats` are still `"X"`
wholesale.

**Spell.csv pass 2026-09-29** - used the external Spell.csv reader
(`C:\Users\Leon_\Documents\WoW Website Project\projects\Spell.csv reader`, `python sp.py <id>`),
which reads the raw client spell table directly instead of `Spell.xlsx`.
Beyond the columns in its README, three more were verified against known
spells: col 1 = school (0 Physical, 2 Fire, 3 Nature, 4 Frost, 5 Shadow,
6 Arcane), cols 61-63 = effect type (2 School Damage, 6 Apply Aura, 98 Knock
Back, ...), cols 91-93 = aura type (3 periodic damage, 12 stun, 33 slow, 61
scale, 74 reflect school, 79 damage done %, 87 damage taken %, 89 % health
per tick, 138 melee haste). Columns 91+ need the same row shift as 70+.
Resolved:
- MC: Baron Geddon Spreading Flames = 32000 Fire split within 10 yd (spell
  34472); Ragnaros Intense Heat = 2000 Fire within 20 yd + knockback (spell
  21155, logged under "Flame of Ragnaros"; timing still unknown).
- BWL: Broodlord Frost Reflection 100% / 20s; Krixix Shrink Ray (-75% damage
  done, -50% size, -25% move speed, 30s) and Death Ray (12000-17000 Physical
  + 30s stun - verify, unusually long); Spellbinder Greatest Polymorph 20s
  (ID assumed 35168, Spellbinder not in the log); Brood Power: Red ticks
  every 1s; Brood Power: Blue's attack-speed sign confirmed as a slow.
- Onyxia: Warder Cleave hits up to 10 targets.
- ZG: 42 trash `X` lines filled (durations, tick intervals, radii, target
  counts) - each marked with a `-- CHANGED 2026-09-29` comment + spell ID.
- **Bug fixed:** the earlier `Spell.xlsx` pass turned negative values into
  `abs(bp) + 1` instead of `abs(bp + 1)`, so every negative percentage/stat
  was 2 too high (77% instead of 75%, Sunder 1002 instead of 1000, ...).
  Fixed 19 such numbers in ZG (5 while filling `X`s, 14 from a sweep of
  every raid file against Spell.csv); no other raid had a hit.

- Same day, continued: ZG's 32 "no ability description" entries written
  from their effect/aura columns; UBRS 55 lines and LBRS 80 lines filled
  the same way. Real errors found and fixed along the way: Gyth's Freeze
  had its direct/periodic numbers swapped, Drakkisath's Conflagration said
  700 total (it's 700 per second = 7000 over 10s), Rend's Whirlwind is
  +280-390 every 0.3s (not "+50"), and LBRS's two Bloodlust entries had
  30%/60% swapped.

**Spell.csv pass 2026-09-30** (uncommitted until tested in-game):
- **Scripted/internal entries removed** (new CLAUDE.md rule): Hate to 50% /
  Hate to Zero / Sap Visual from UBRS (7), LBRS (7) and Onyxia (1); ZG's
  Intoxicating Venom (Dummy) and both Poisonous Blood entries (Script Effect).
  Kept: UBRS Disturb Rookery Egg and ZG "Hate to Zero(Reset)" (described
  effects) - say if they should go too.
- **Level-scaling sweep** of every spell ID cited in a `-- CHANGED` comment.
  Fixed lines that quoted the level-1 base: Sulfuron's Sunder Armor
  (27991: 48/level, not 1000), UBRS Sunder Armor 16145 (24/level), Enrage
  8269/8599, Rage 16789, Cleave 19983, Knockdown 16790, War Stomp
  11876/16727, Lightning Shield 34881, Ravage 24333, Devour 34938, Improved
  Blocking 3248, Exploit Weakness 8355, Blast Wave 13021, Earth Shock
  10414, Infected Bite 16128 (per-slot reading from a 3-field row - verify),
  and filled Stun Bomb 16497, Snap Kick 15618 and Eviscerate 15691 from
  their per-level values. Only IDs cited in comments were swept.
- **Mana Burn** damage per mana: 0.5 (15785, 15980), 1 (15800).
- **Charge** 24023 is 75 bonus damage + triggers Fixate (no stun in the
  data); Charge 25821 is +1300; Greater Polymorph 22274 is 20s; Soul Tap
  burns 500 mana/s (aura 162).
- Dropped unresolvable target counts ("up to X enemies") from Howl of
  Terror, Psychic Scream, Whirlwind, Sweeping Strikes rather than keep an `X`.
- **Still `X` (not in the data):** Flamecrack stun duration, Defile /
  Touch of Death pulse effect, Recklessness's immunity type, True
  Fulfillment, Cleanse Nova (ZG line's spell match looks wrong), ZG
  Whirlwind (34930 line), BWL Dominate Mind, Loksey Power Shot, Doan Frozen
  Solid, and every trash/boss `stats` block.

**Same day, later:**
- **Strategy wording removed** (CLAUDE.md scope rule) from BWL, ZG,
  Onyxia and World Bosses: priority/CC/interrupt calls, dispel/decurse
  assignments, tank/healer instructions, class tips. The Onyxia
  "Preparation" and "Landing" abilities were pure strategy and were deleted
  (with the "Pre-pull & positioning" separator). Short factual notes such as
  "move out of it" were kept. BWL's Chromaggus Tail Sweep line is now the
  real effect (spell 15847: 1600-2100 in a 15 yd cone behind, knockback).
- **Second level-scaling sweep, by (mob, ability) from the combat logs** -
  now states the per-level scaling on Cleave (15284/15496/19632/19983),
  Strike (19730, 11976, 13446, 18368, 15580, 14516, 19644), Sinister Strike,
  Kick, Mighty Blow, Backstab, Arcing Smash, Shield Slam, Thunderclap,
  Demoralizing Shout (16244/23511/13730), Stormbolt, Dragon Breath, Power
  Word: Requital, Crusader Strike, Spit and Slowing Poison. "Increased melee
  damage" lines on Strike got real numbers. Thunderclap 15588 and Slowing
  Poison 7992 read their per-level value from a split-decimal row - verify.
  Mobs' levels aren't known, so the "about N at level 60" figures are
  illustrative.
- Other known scaled spells left alone: Death Coil 28412 (+3/level, capped
  at 64), Flame Shock 29228 and Chain Burn 24684 (odd per-level layout).
- Resist Fire now says "about 90 at level 60" instead of an `X`.

**Full audit pass (2026-09-30, uncommitted):** every mob's logged abilities
were compared against its entry, and every number in a line was compared
against the spell data.
- **Chromaggus** rewritten from the data: Double Bite (100% weapon damage to
  a second enemy), Enrage/Frenzy numbers, the Brood Affliction durations,
  Caustic Breath (armor -8000, 15s), Ignite Flesh (160s, stacks to 10),
  Incinerate (4800-6000 Fire) and Frost Burn (2500-3000 Frost, attack time
  +400%, 20s). Strategy notes removed.
- **Wrong numbers fixed:** Venoxis Venom Spit (2000-2500 + 325-375 every 2s,
  not 850 + 200 every 5s), Razorgore Conflagration (500/s, not 100/s), Coke
  Ejection (3000-4000 + 200-250, not 3000-6000), Shadow Nova's heal.
- **~40 missing abilities added** from the logs: MC (Magmadar Conflagration,
  Gehennas Shadow Shock, Garr Enrage, Shazzrah Replenish Mana, Sulfuron
  Demoralizing Shout / Recklessness, Ancient Hysteria, Annihilator Flurry),
  Onyxia Heated Ground, SM (Monk Knockout, Doan Great Polymorph), LBRS
  (Shield Bash, Counterspell, Scarshield Portal), UBRS Acolyte Psychic
  Scream, and ZG (Jeklik Mind Flay/Mind Blast/SW:Pain, Venoxis Renew /
  Parasitic Serpent / snake form, Mar'li Drain Life / spider form, Mandokir
  Guillotine, Gahz'ranka Acidic Ink, Thekal Killing Frenzy / tiger form,
  Arlokk Hamstring / SW:Pain / Curse of Tongues / Chainlink Lasso / Mark of
  Arlokk / panther form, Jin'do's healing ward). Icons for these were
  picked by name and are not verified in-game.
- **Data vs. existing lines disagreed - changed to the data** (user rule:
  Spell.csv wins): Gehennas Shadow Bolt 3350-4250 (was 2250-2750),
  Lucifron Shadow Shock 419-485 (was 2000-3000(?)), Venoxis Poison Cloud
  500/s for 20s with no slow (was 575/s + slow), Hakkar Blood Siphon is an
  8s stun + script effect (was a 700/s drain).
- Not added on purpose: visual/animation spells, transform sound effects,
  totem summons with no effect data (Charged / Brain Wash Totem), Kill
  Command (unclear aura effect), and names that only differ by spelling from
  an existing entry.

**Level-scaled spells (important).** Spell.csv stores a *points per level*
value next to the base points (raw cols 73-75, before the row shift - a
decimal like 0.2 is split into two fields there, same as elsewhere). The
real value is `base + perLevel x (casterLevel - spellLevel)`, capped at
the max level (col 27; spell level is col 29). Every "raw sheet value looks
implausibly small" note in this file was this: e.g. Head Crack 16172 is
-1 Stamina per level, Sunder Armor 15572 is -12 armor per level per stack,
**Flamewaker Sunder Armor 15502 is -8 armor per level per stack** (resolves
the MC item below - now filled into `MC.lua`), Forked Lightning 8435 is +5
per level, Lightning Shield 13585 is +2 per level. Lines touched today
state the scaling instead of the base value. Not yet done: many older
lines still quote the level-1 base of a scaled spell without saying so
(Enrage 8269's "+50 damage" is +2 per level from 26; Cleave 19983's "plus
50" is +5 per level from 10; Improved Blocking, Earth Shock, Blast Wave,
Knockdown, Infected Bite, War Stomp, ...) - needs a sweep, and the mob
levels to turn formulas into single numbers. Snap Kick 15618's per-level
split is ambiguous in the export and was left as X.

Still not resolvable from Spell.csv (numbers are 0 / computed server-side
/ spell not in any log): Flamewaker Sunder Armor per stack (0), Firesworn
Separation Anxiety distance (no radius - scripted), Lava Spawn Fireball
(data says 192-258 with no DoT effect at all - conflicts with the ~980-1300
observed), Loksey Power Shot damage (0), Grethok's Dominate Mind (not in
any log, 9 candidate IDs), Onyxian Warder Hate to 50% (a scripted Dummy
effect), and every ZG "no ability description" entry (these need a
description written from their effect/aura columns - not done yet).

## Molten Core trash ([raids/MC.lua](raids/MC.lua))

Status update 2026-08-23, from in-game testing:

- ~~**Flameguard** - `stats` block~~ - **RESOLVED.** Real armor/resistance
  numbers (armor 4441, fire immune, nature 35, frost 0, shadow 51, arcane
  51) in `raids/MC.lua` as of 2026-08-29 - an earlier note here marked this
  resolved before the values actually landed; the committed file still had
  `"X"` until this pass.
- ~~**Firelord -> Incinerate** - damage amount~~ - **RESOLVED** (still no
  matching `Spell.xlsx` entry, so the description text stays a guess).
  Note: the line in `raids/MC.lua` still literally reads "increased by
  25(%)?" - user confirmed this wording is **still unsure**, don't clean
  up the `(%)?` yet.
- ~~**Lava Reaver -> Lava Grasp**~~ - **RESOLVED, 2026-08-29 (user):** root
  duration is 10 seconds and the ability deals **no damage** - the current
  line in `raids/MC.lua` is correct as written. (Earlier notes here about
  "damage still unknown" / "X Nature damage" were wrong - there is no
  damage component.)

**Combat-log pass 2026-08-30** - `MC FULL.csv` (160k rows, all 10 bosses +
their adds + trash) cross-matched against `MC.lua` + Spell.xlsx. Every
existing boss number checked out. The remaining ability `X` placeholders
were resolved or reworded: Firesworn Eruption (~2350 Fire), Shazzrah Arcane
Volley (~275/bolt), Flame Imp Fire Nova (~148), the Sulfuron
"Flamewaker Priest" add's shield is actually **Shadow Shield** (50000
absorb + 475 to melee, 30s) and its heal is **Dark Mending** (127750);
Baron Geddon Spreading Flames confirmed 6s (damage still unknown - not in
sheet); Lava Annihilator Double Attack reworded (it's a passive proc, not
timed); Ragnaros Melt Weapon reworded (proc on hit). Flamewaker Sunder
Armor and Firesworn's Separation Anxiety distance are still the only real
unknowns.

Still unsure / hard to find - needs more digging later:

- **Firelord -> Spawn Lava Spawn -> Fireball** - both the direct hit and
  the DoT damage are unknown. A tentative observed range (~980-1300, vs.
  192-258 in the spell DB) came up in testing but the user is **not
  confident** in it - left as `X` in `raids/MC.lua`.
- ~~**Lava Elemental -> Lava Explosion** - damage unknown~~ - **RESOLVED,
  2026-08-29:** 902 to 1202 Fire damage plus a knockback, confirmed via
  testing (still no `Spell.xlsx` match). Filled into `raids/MC.lua`.
- ~~**Lava Annihilator -> Double Attack**~~ / ~~**Flame Imp -> Fire
  Nova**~~ - handled in the 2026-08-30 pass above.
- **Flamewaker (Gehennas add) -> Sunder Armor** - per-stack armor value is
  0 in Spell.xlsx (same gap as UBRS/LBRS Sunder Armor); needs testing.
- **Firesworn -> Separation Anxiety** - the distance that triggers the
  +300% damage is not in the sheet.

Everything else in MC trash (Molten Giant, Molten Destroyer, Flameguard's
other two abilities, Core Hound, Ancient Core Hound, Lava Surger, Lava
Reaver's Strike, Lava Annihilator's Annihilate, Firewalker) has confirmed
numbers as of this pass.

## Blackwing Lair ([raids/BWL.lua](raids/BWL.lua))

**Combat-log pass 2026-08-29** - `BWL stuff.csv` was cross-matched against
`BWL.lua`; see [BWL_CSV_Pass.md](BWL_CSV_Pass.md) for the full list. The 6 old
"Placeholder" abilities are gone and ~25 more abilities were added/reworded
with real numbers from Spell.xlsx (its header row is shifted ~2 columns from
the text data in this export - see the note in AGENTS.md). A handful of custom V+
effects still say "needs testing" - Shrink Ray, Death Ray, Ice Sprinkler
amounts, Dragon sickness / Mental Strike / Summon Livingflame / Warming Flames
effects, Brood Power: Blue's attack-speed sign, and `$t1` tick intervals.

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

**Combat-log pass 2026-08-30** - all 8 SM bosses cross-matched against
`SM.lua` + Spell.xlsx, from `SM 6 bosses.csv` (Loksey, Brigitte, Vishas,
Herod, Brother Michael, Doan) and `SM mograine fairbanks.csv` (Renault
Mograine, Sally Whitemane, Fairbanks). Every existing damage/percent
checked out. Added:
- Brigitte -> Improved Blocking (passive, 55%)
- Brother Michael -> Inner Fire (passive, +/-20%)
- Doan -> Mana Shield + per-phase Elemental Wards (Arcane/Frost/Fire,
  reflect that school for 60s)
- Mograine -> Blinding Light (6s blind), Divine Shield (10s), Lay on Hands
- Whitemane -> Deep Sleep (30s), Dominate Mind duration (15s)
- Fairbanks -> Claustrophobia corrected (it buffs Stomp, does not resize
  players); the log only caught the pull so nothing else new there.
Herod's Demoralized was already present and correct.

- ~~**Loksey -> Paralyzing Poison** - per-stack Nature damage unknown.~~ -
  **RESOLVED, 2026-08-29 (user):** 125 to 145 Nature damage per stack
  every 2 sec, lasts 20 seconds. Filled into `raids/SM.lua`.
- **Loksey -> Power Shot** - damage still unknown. Spell.xlsx confirms the
  description (spell 35841, pierces + ignores armor) but the damage spell
  (35844 "Power Shot DMG") has base points 0 - needs testing.
- ~~**Brigitte Abbendis -> (Scarlet Sharpshooter add) -> Explosive Shot**~~ -
  **RESOLVED, 2026-08-29 (user):** 1550 to 2100 Fire damage, knocks back,
  silences for 6 seconds, slows movement speed 50% for 6 seconds. Filled
  into `raids/SM.lua` (dropped the vague "Concussed, Dazed" wording now
  that the real slow value is known).
- **Doan (Frost stance) -> Chilled to the Bone -> Frozen Solid** - stun
  duration and per-tick Frost damage still unknown; nested three deep
  under Doan's Frost-stance "Numbing Cold". (A 2026-08-29 fill was
  reverted at the user's request - not confirmed.)

Everything else checked in SM bosses (Vishas, Herod, Brother Michael,
Renault Mograine, Fairbanks, and the rest of Loksey/Brigitte/Doan) had
real numbers, no `X` placeholders found. Remaining SM-boss `X`s: Loksey's
Power Shot and Doan's Frozen Solid.

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
  - ~~Rage Talon Dragon Guard -> **Sunder Armor** (spell 16145): no
    per-stack amount could be pulled for this specific rank~~ - **STALE,
    RESOLVED 2026-08-23.** A per-stack amount does exist
    (`EffectBasePoints_1` -25, +1 = 24 armor per stack) - it was just
    small relative to the 1000-per-stack rank (24317) used elsewhere;
    filled in as-is in `raids/UBRS.lua`.
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
  - General Drakkisath -> **Conflagration**: RESOLVED - splash damage
    (500) pulled from linked spell 16806 in Spell.xlsx.
  - Blackhand Iron Guard -> **Defensive Stance**: RESOLVED - percentages
    (-10% damage taken, -10% damage caused, +30% threat) pulled from
    linked spell 7376 in Spell.xlsx.
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
  **Update 2026-08-22:** `SpellDuration.csv`/`SpellRadius.csv` (exports of
  those two DBCs) are now available, and 28 of the `X seconds`/`X yards`
  placeholders in this file were resolved to real numbers by matching
  each ability's existing description text back to its exact
  `Spell.xlsx` row (or, where the ability name has several ranks with
  identical wording, confirming every matching rank resolves to the same
  number before applying it) - see the `-- CHANGED:` comments added
  above each one. Tick intervals (`$t1`/`$t2`) are still unresolved (not
  in these CSVs), and a handful of `X seconds`/`X yards` were left alone
  either because `DurationIndex`/`EffectRadiusIndex` was 0/blank for that
  spell (e.g. Tremor Totem's radius, Flamecrack's stun, Cleanse Nova's
  duration) or because multiple same-named ranks resolved to different
  numbers (genuinely ambiguous without a confirmed spell ID).
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
everything below comes from `Spell.xlsx`'s effect fields instead.

**Roster confirmed complete 2026-08-30:** re-checked against the two
full-run logs (`SM 6 bosses.csv`, `SM mograine fairbanks.csv`) - every
Scarlet trash mob they contain is in `SM_TRASH_MOBS`. The only extras in
those logs (Sharpshooter, Trainee, Recruit) are already accounted for as
boss adds / non-pulls. Remaining gaps:

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
- ~~Scarlet Diviner's 23 "Prophecy: ..." cards are all `X`-only~~ -
  **STALE, RESOLVED 2026-08-23.** They do have empty `Description_enUS`,
  but real tooltip text exists in `Spell.xlsx`'s `AuraDescription_enUS`
  column instead (missed in the original pass). All 24 cards actually
  present in `SM_TRASH_MOBS` (spell IDs 36175-36204 minus the 6 never
  logged) already had correct numbers filled in from a prior,
  undocumented pass - cross-checked against `EffectBasePoints_n+1` and
  confirmed matching, and a `-- CHANGED:` comment was added above the
  ability list in `raids/SM.lua` documenting the `AuraDescription_enUS`
  source. **Doppelganger** and **Instability** have no numbers in
  `Spell.xlsx` at all (their `AuraDescription_enUS` is literally just
  "Mirrored Presence." / "Fate remains unknown.") - filled in with that
  literal vague text rather than left as `X`, but the actual mechanic
  behind either is still unknown and would need external research to
  pin down.
- **Every ability with no `Description_enUS` at all** (not just missing
  numbers, but zero tooltip text) was left as a generic "no ability
  description available" placeholder rather than guessed from raw effect
  codes. That's roughly a third of the abilities pulled from the log -
  see any `-- CHANGED:` comment reading "no ability description
  available" in `SM_TRASH_MOBS`. Worth a pass to see if a build-uploaded
  or newer `Spell.xlsx` fills these in.
- ~~**Scarlet Tracking Hound -> Infected Wound** - the raw sheet value (+3
  damage taken) looked implausibly small...~~ - **STALE, 2026-08-29.** The
  line in `raids/SM.lua` already reads "increases physical damage taken by
  3 per stack up to 99 stacks" (matches the Loksey-add copy), i.e. the +3
  value is in use, not `X`. Still not in-game confirmed, but no longer a
  placeholder. (The blue name tint was also removed this pass.)
- ~~**Scarlet Sorcerer -> Mana Shield** - sheet absorb amount is a
  999,999,999 sentinel~~ - **RESOLVED, 2026-08-29 (user).** There is no
  real absorb number to find: Mana Shield is mana-bound, not absorb-capped
  (the billion is a Blizzard "effectively unlimited" placeholder). User
  confirmed the Sorcerer casts it once at the pull and it holds until his
  mana runs out - effectively the whole fight. `raids/SM.lua` now says
  exactly that, with no number. Nothing left to do here.
- **Scarlet Protector -> Judgement of Light** - RESOLVED - heal amount
  (875 to 1095) pulled from linked spell 36071 in Spell.xlsx.
- Every ability whose tooltip includes a duration (`$d`) or radius (`$a1`)
  is `X seconds`/`X yards` - `Spell.xlsx` only has index references
  (`DurationIndex`/`RangeIndex`) into `Duration.dbc`/`Range.dbc`, which
  aren't in this workbook, so those can't be resolved from the sheet at
  all and need in-game testing.
  **Update 2026-08-22:** with `SpellDuration.csv`/`SpellRadius.csv` now
  available, 4 of these were confidently resolved (see `-- CHANGED:`
  comments); the rest were left as `X seconds`/`X yards` because the
  ability's description text either didn't match a `Spell.xlsx` row
  closely enough to trust, or matched several same-named ranks that
  resolve to different numbers.
  **Update 2026-08-29:** re-scanned `SM_TRASH_MOBS` - **no `X seconds` /
  `X yards` / `X damage` remain in any trash ability line.** The only `X`
  placeholders left in SM trash are the `stats = {...}` armor/resistance
  blocks (all 20 mobs). The 4 remaining ability-text `X`s in `raids/SM.lua`
  are all on bosses/boss-adds: Loksey -> Paralyzing Poison ("X Nature
  damage"), Loksey -> Power Shot ("X damage"), Brigitte's Scarlet
  Sharpshooter add -> Explosive Shot, and Doan (Frost) -> Chilled to the
  Bone -> Frozen Solid ("X Frost Damage every X seconds"). (Explosive Shot
  was resolved 2026-08-29 - see the SM bosses section.)
- Icons and mob-level (portrait) icons were picked reasonably from each
  mob's own real abilities, not verified in-game.

### Scarlet Diviner Prophecy trigger lines (2026-10-23)

Lokiy's list of spoken lines covers 29 of the 30 Prophecies in Spell.csv
(36175-36204). Added the 11 lines the cards were missing (Alacrity,
Cinderborn, Execution, Exposure, Helpless, Momentum, Sanctified, Shared
Fate, Undying, Unfettered, Untouchable) and confirmed Weakness's line
(was marked as a guess). **Spellward** had Untouchable's line ("You walk
between the rain."); now "All Magic will fail against you."

Doomed's line ("Your shroud is already woven!") followed the same day, so
all 30 cards now have their trigger line.

Still open:
- **Doppelganger** - seems to summon a copy (Lokiy, in-game, 2026-10-23);
  how it works is unknown. Spell.csv 36199 is a lone apply-aura effect, no
  summon, so it's server-scripted - only in-game testing will tell.
- **Instability** - effect unknown; Spell.csv 36201 gives nothing beyond
  "Fate remains unknown." Needs in-game testing.

### Passive-trait classification pass (2026-08-29)

New `passive = true` separator support (see AGENTS.md "Passive heading" /
"What counts as a passive" and the README's "Abilities vs. passives") -
renders a plain, non-clickable `Passives` heading; rows under it are always
shown. Applied to SM trash, mob classifications confirmed with the user:

- **Passives grouped under the heading:** Scarlet Soldier / Scarlet
  Defender / Scarlet Protector -> Improved Blocking; Scarlet Guardsman /
  Scarlet Defender -> Defensive Stance; Scarlet Centurion -> Battle Stance
  + Retaliation; Scarlet Myrmidon -> Berserker Stance; Scarlet Guardsman ->
  Riposte; Scarlet Tracking Hound -> Infected Wound; Scarlet Sorcerer ->
  Mana Shield; Scarlet Protector -> Protection Aura; Scarlet Gallant ->
  Sanctity Aura + Seal of Command.
- **Explicitly kept as normal abilities** (user calls): Scarlet Champion ->
  Vengeance (every-15s reflect window with a stun-cancellable telegraph -
  a periodic ability, not a passive); Scarlet Monk -> Inner Fire; Scarlet
  Wizard / Scarlet Evoker -> Fire Shield; Scarlet Chaplain -> Prayer of
  Fortitude; Scarlet Guardsman -> Impale; Scarlet Protector -> Judgement
  of Light.
- **Scarlet Monk -> Kick** given the `Ability_Kick` icon and its `kick`
  role marker dropped (it's the mob's own attack, not an interrupt call).
- Other SM trash mobs (Torturer, Beastmaster, Wizard's/Evoker's/Conjuror's
  nuke kits, the healer casters, Diviner) have no always-on passive worth
  a heading and were left without one.

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
  **Update 2026-08-22:** with `SpellDuration.csv`/`SpellRadius.csv` now
  available, 37 of the `X seconds`/`X yards` placeholders were resolved
  (see `-- CHANGED:` comments above each). The rest, including the
  spell-ID-prefixed-token cases above, were left alone - either no
  confident text match to a `Spell.xlsx` row, or same-named ranks
  resolving to different numbers.
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

## Lower Blackrock Spire ([raids/LBRS.lua](raids/LBRS.lua))

Added 2026-08-13 from a real combat log (`LBRS.csv`, 27k rows), filtered
to `Source GUID` starting `0xF130` (real creatures), shaman totems
(Magma/Mana Spring/Searing/Stoneclaw/Strength of Earth/Fire Nova Totem)
and raw unresolved GUID sources excluded, cross-matched against
`Spell.xlsx` by exact Spell ID - same methodology as the UBRS/ZG passes
above.

- **8 of 9 bosses with combat data got real abilities**: Highlord Omokk,
  Shadow Hunter Vosh'gajin, War Master Voone, Mother Smolderweb,
  Quartermaster Zigris, Halycon, Gizrul the Slavener, Overlord
  Wyrmthalak. **Urok Doomhowl has no combat data in `LBRS.csv`** (no
  "Urok Doomhowl" `Source` with a `0xF130`-prefixed `Source GUID`
  anywhere in the log) and was left as the original single-ability
  placeholder untouched.
- **34 trash mobs added** (`LBRS_TRASH_ORDER`/`LBRS_TRASH_MOBS`,
  `BuildLBRSTrash()`), one entry per distinct non-totem NPC name that
  logged an ability: the Bloodaxe, Firebrand, Scarshield, Smolderthorn,
  and Spirestone/Spire mob families.
- **Merge decisions** (same-named ability logged under two spell IDs,
  treated as one ability entry per the UBRS precedent):
  - Highlord Omokk's **Stormstrike** merges the off-hand companion cast
    (spell ID 34592, `Description_enUS` is literally `"OH"`) with the
    main-hand cast (17364, real text).
  - Bloodaxe Summoner's **Arcane Missiles** merges the channel-tick rank
    (15790, empty `Description_enUS`) with the cast rank (15791, real
    text).
  - Firebrand Grunt's **Retaliation** merges the companion trigger (spell
    ID 22858, empty `Description_enUS`) into the main entry (22857, real
    text), same pattern as UBRS's Blackhand Elite.
- **Pull order/grouping is completely unknown**, same caveat as every
  other raid's trash so far: the CSV is a flat event list with no pull
  boundaries, so `LBRS_TRASH_ORDER` is all 34 mobs in alphabetical order,
  no separators. Needs an actual walkthrough (Bloodaxe hall, Firebrand
  hall, Scarshield camp, Smolderthorn area, Spire/Spirestone ogre area)
  to group properly.
- **`stats` (armor/resistances) is `"X"` across all 34 trash mobs** - the
  log has no stat data at all, 100% untested.
- **Abilities left as `X`** (raw sheet value looked implausible, or no
  `Description_enUS` at all) - see the `-- CHANGED:` comment on each:
  - Bloodaxe Raider -> **Sunder Armor** (spell 15572): raw per-stack
    armor value (0) looks implausible; compare against the 1000-per-
    stack values on the 24317 Sunder Armor rank used elsewhere in this
    file, which looks far more plausible.
  - Bloodaxe Veteran -> **Snap Kick** (spell 15618): raw stun-damage
    value (2) looks implausibly small next to the 875-1125 range on the
    other Snap Kick rank (24671) used elsewhere in this file.
  - Firebrand Dreadweaver -> **Plague Cloud**: raw Strength/Agility/
    Intellect reduction values (-2 each) look implausibly small for a
    stat-debuff AoE.
  - Firebrand Grunt -> **Charge**: raw bonus-damage value (0) looks
    implausibly small next to the near-identical Berserker Charge/Shield
    Charge abilities elsewhere in this file (150-1300); a larger value
    (1300) exists on a different effect slot not referenced by the
    description's token.
  - Firebrand Grunt / Spirestone Enforcer -> **Berserker Stance**:
    PARTIALLY RESOLVED - Firebrand Grunt's crit chance (+3%) and damage
    taken (+10%) pulled from linked spell 7381; Spirestone Enforcer's
    chance of being critically hit (+10%) pulled from linked spell
    35490. Each spell only documents some of its effect slots in
    Spell.xlsx's description text, so the remaining X placeholders
    (Firebrand Grunt's "chance of being critically hit"; Spirestone
    Enforcer's crit chance and damage taken) are left as X rather than
    guessed.
  - Quartermaster Zigris -> **Stun Bomb**: raw bonus-damage value (0)
    looks implausibly small.
  - Scarshield Spellbinder -> **Resist Fire**: raw value (2) looks
    implausibly small for a resistance buff (same gap noted in the UBRS
    TODO entry for the same mob/spell).
  - Smolderthorn Seer -> **Lightning Shield**: raw per-strike damage
    value (2) looks implausibly small.
  - Spirestone Mystic -> **Forked Lightning**: raw damage value (5)
    looks implausibly small for a boss-tier mob's Nature nuke.
  - Multiple mobs' **Mana Burn** (Scarshield Spellbinder, Smolderthorn
    Shadow Priest): the drained-mana amount is real, but the
    damage-per-point-of-mana value lives on a separate linked effect not
    captured in this pass.
  - Every ability with **zero `Description_enUS`** (Throw Axe, Gas Bomb,
    Hex on Shadow Hunter Vosh'gajin, Intoxication, Summon Spire
    Spiderling, Recklessness, Eviscerate, Sap Visual, "Hate to 50%",
    "Hate to Zero", Frenzy, Shield Toss Return, Summon Scarshield/
    Bloodaxe Worg) was left as a generic "no ability description
    available" placeholder, several with a short note on what the name/
    effect type suggests (internal threat-reset mechanics, cosmetic sap
    visuals, summon triggers), per the same sourcing rule used in the
    other raids' trash passes.
- Every ability whose tooltip includes a duration (`$d`), radius (`$a1`),
  or tick interval (`$t1`/`$t2`) is rendered as `X seconds` -
  `Spell.xlsx` only has index references into `Duration.dbc`/`Range.dbc`
  (not included) for duration/radius, and tick intervals aren't
  resolvable from this sheet at all; needs in-game testing.
  **Update 2026-08-22:** `SpellDuration.csv`/`SpellRadius.csv` are now
  available and 51 of these placeholders were resolved (see `-- CHANGED:`
  comments above each). Tick intervals are still unresolved, and a few
  `X seconds`/`X yards` were left as-is where the text match to
  `Spell.xlsx` wasn't confident or same-named ranks disagreed on the
  number.
- Icons were picked from each mob's own real abilities (trash) or kept as
  the existing `Interface\Icons\temp` placeholder (bosses - portrait work
  is out of scope for this pass, see the "Known Issues" section in
  AGENTS.md).
- `flags` (melee/caster/ranged) are informed guesses from each mob's
  ability set (e.g. mobs with only Shadow Bolt/Fireball-type abilities
  marked `caster`), not verified in-game.

## Onyxia's Lair ([raids/Onyxia.lua](raids/Onyxia.lua))

Added 2026-08-13 from a real combat log (`Onyxia.csv`, 13k rows), same
methodology as the other passes above. Onyxia herself already had a full
hand-written kit before this pass and was left untouched - only her adds
were new.

- **Onyxian Warder** added with 5 abilities (Pierce Armor, Flame Lash,
  Fire Nova, Cleave, Hate to 50%).
  - **Update 2026-08-23:** per user correction (confirmed in-game), the
    Warder is real pre-fight trash - pullable outside the encounter -
    not a boss add. Moved from `onyxia.adds` into a proper
    `ONY_TRASH_ORDER`/`ONY_TRASH_MOBS` roster, mirroring every other
    raid's trash shape. Onyxia now has a real `trash` field/Trash tab
    entry (1 mob) - the "World boss, no trash" assumption below no
    longer holds for her, only for World Bosses.
  - **Hate to 50%** has no `Description_enUS` in `Spell.xlsx` - left as
    `X`, no ability text available.
  - **Cleave**'s target-count token (`$x1`) can't be resolved from this
    sheet - rendered as `X` in "affecting up to X targets."
  - **Pierce Armor**/**Flame Lash**/**Fire Nova** have real numbers, but
    their `$d` duration tokens are unresolvable the same way as every
    other raid's trash - rendered as `X seconds`.
    **Update 2026-08-22:** Pierce Armor's and Flame Lash's durations were
    resolved via `SpellDuration.csv` (see `-- CHANGED:` comments); Fire
    Nova's duration text didn't have a confident enough `Spell.xlsx` text
    match and was left as `X seconds`.
  - `stats` (armor/resistances) is `"X"` - not present in the log, 100%
    untested.
- **Onyxian Whelp** remains a real `adds` entry (confirmed as an actual
  encounter add, not trash) with no abilities - the log only shows the
  generic Dazed effect for this mob, no real cast logged.
  - No `stats` added - not present in the log, 100% untested.

## Emerald Dragons ([raids/EmeraldDragons.lua](raids/EmeraldDragons.lua))

**2026-08-29:** user confirmed the V+ Dragons of Nightmare are still
identical to Classic, so the whole file was refilled with real numbers from
`warcraft.wiki.gg`'s "<dragon> (Classic)" pages (cross-checked against the
Warcraft Tavern guide) - shared abilities (Noxious Breath 3000 + 350-450/3s
DoT stacking 6x, Tail Sweep 925-1075, Seeping Fog 4s sleep, Mark/Aura of
Nature), the 75/50/25% signature summons, and each dragon's adds
(Ysondre's Demented Druid Spirits, Lethon's Spirit Shades, Taerar's Shades)
with their own abilities.

Still open:
- Boss `stats` - V+ Lists "Resistances Data" only has Ysondre's row filled
  (armor 4691, 126 all schools); the other three now copy those values
  (they're the same level-63 dragon) but their own rows were never tested.
- All four still use the `Interface\Icons\temp` portrait placeholder.
- `$t1`-style tick intervals for a couple of DoTs are given as "every N
  seconds" from the wiki text, not independently confirmed on this server.

## Trash tab showed empty entries for raids with no trash (fixed)

`BuildTrashEntries()` in `DungeonJournal.lua` previously added a
clickable header row to the Trash tab's tree for every raid in `RAIDS`,
even ones with no `trash` field at all (Onyxia, World Bosses) - clicking
it just expanded to nothing. Fixed to only show a raid's header when
`raid.trash` exists and has at least one entry. This is a UI/behavior
change, not just data - needs in-game verification that the Trash tab
now correctly omits World Bosses, correctly shows Onyxia's real 1-mob
trash roster (Onyxian Warder - see the Onyxia's Lair section above,
updated 2026-08-23 once she turned out to have real pre-fight trash
after all), and that every raid that *does* have trash
(MC/BWL/SM/ZG/UBRS/LBRS) is unaffected.

## spellId pass from lokiy.dev/spells + combat logs (2026-10-23)

456 more abilities got a `spellId` (914 in total), across every raid file:
- 416 from a combat-log line where **their own mob** cast a spell of that exact name (one ID only).
- 40 from a name that exists **only once** in lokiy.dev/spells (`db/index.json`) - incl. all 29
  remaining Scarlet Diviner Prophecies.

Not filled:
- 19 where the mob's own log has two or three IDs under the same name (cast + effect, or ranks;
  the log only has cast events, so it can't tell which) - each has a `-- spellId: uncertain` note.
- 116 with several same-named spells and no log line from their own mob - listed in
  `SPELLID_OPEN.md` with the candidates. "other mob" there means only another mob's cast is in the
  logs; it's a hint, not proof, so none were filled from it.

The addon still doesn't read `spellId`; it's the key for db.lokiy.dev.

### Second spellId pass: numbers vs. candidates (2026-10-23)

Went through `SPELLID_OPEN.md`: each ability's numbers and effect wording compared with every
candidate's tooltip and effect values on lokiy.dev/spells. 34 had one clear match and were filled
(948 spellIds in total), e.g. Majordomo Blast Wave 20229 (994-1406, 50%, 12 sec), Whitemane Holy
Fire 36019, Vishas Pummel 35900, Kazzak Mark of Kazzak 21056 (250 mana/sec; 21058 is the 4000
explosion), Azuregos Frost Breath 21099 (the only one that stuns 4 sec).

Left open on purpose (82, still in `SPELLID_OPEN.md`):
- Ties: Burning Adrenaline 18173 / 23620, Magnetize 34461 / 34462, Rend 21949 / 36080, Wing Buffet,
  Shadow Nova, Twisted Reflection, Mortal Wound, Lava Spawn Fireball.
- Doan's Chilled to the Bone: the line (root + 50% slow) reads like 35984, but 35985 is the
  periodic-trigger half - needs a log.
- Lines whose numbers match no candidate: Tail Sweep (925-1075 in the line, 1600-2100 in both
  spells), Emeriss Volatile Infection (875-1125 vs 24928's 1130-1530), Kazzak Void Bolt, Azuregos
  Chill. Per the Spell.csv-wins rule these lines may need fixing once the right spell is known.
- Generic abilities with no numbers in the line (Cleave, Shadow Bolt, Fire Blast, ...).
