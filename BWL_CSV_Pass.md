# BWL data pass from "BWL stuff.csv" (2026-08-29)

Source: `BWL stuff.csv` (uploaded by the user) - a real Blackwing Lair combat
log, ~103k rows, 17 columns (`Source`, `Source GUID`, `Action / Ability`,
`Spell ID`, `Target`, ...). Same methodology as the SM / ZG / UBRS / LBRS
passes: filter to creature GUIDs (`Source GUID` starting `0xF13`), drop totems
/ pet summons / the generic `Dazed` (1604) and `Shield Toss Return` (34308)
noise, group by `Source` name, keep distinct `Action / Ability` + `Spell ID`.

## Spell.xlsx column note (important)

The first pass at this mistakenly concluded Spell.xlsx had **no** description
text for BWL spells. It does - the earlier extract was reading the wrong
columns. In this workbook the usable English text sits in the columns whose
headers read **`Description_koKR`** (real English `Description`) and
**`AuraDescription_koKR`** (real English aura text); the `_enUS` columns are
mostly blank. `$s1` / `$s2` tokens were resolved as `EffectBasePoints_n + 1`
and `$d` via `SpellDuration.csv` (DurationIndex), exactly like the other
passes. Each filled line records the spell ID and how the number was derived
in its `-- CHANGED:` comment. Tick intervals (`$t1`) are still unresolved.

## Abilities added to existing bosses / adds (with resolved numbers)

| Boss / add | Ability | Spell ID | Filled as |
|---|---|---|---|
| Razorgore | Untamed Fury | 35177 | +20% attack speed per stack, up to 5 |
| Razorgore | Summon Livingflame | 35176 | summons a Livingflame add (no text - behaviour untested) |
| Razorgore | Warming Flames | 23040 | no text - retail = self-heal near orb, unconfirmed |
| Grethok | Greatest Polymorph | 35168 | sheep for up to 20s, one target at a time |
| Grethok | Slow | 13747 | movement + attack-speed slow |
| Grethok | Arcane Missiles (reworded) | 35169 | ~1900 Arcane damage + interrupt |
| Blackwing Guardsman | Thunder Clap | 35166 | +50% time-between-attacks & -50% move speed, 12s |
| Blackwing Mage | Counterspell | 35174 | interrupt + 10s school lock |
| Blackwing Mage | Ice Mirror | 35171 | reflects spells cast at it for 5s |
| Elementium Decapitator | Sticky Oil Tar | 35135 | +25% Fire damage taken, 16s, stacks |
| Elementium Decapitator | Ice Sprinkler (+ slow) | 35147 / 35148 | Frost spray + movement slow (amounts untested) |
| Broodlord | Frost Reflection | 35187 | reflects Frost spells cast at him (duration untested) |
| Firemaw | Thrash | 3391 | passive extra attacks |
| Krixix | Disrupting Ray | 35272 | strips defences, +100% damage taken, 30s |
| Krixix | Gravity Defied | 35488 | hooks / pulls the target to Krixix |
| Krixix | Shrink Ray | 35273 | shrink debuff ("So tiny!") - values untested |
| Krixix | Death Ray | 35274 | heavy single-target shock - damage untested |
| Ebonroc & Flamegor | Thrash | 3391 | passive extra attacks, both dragons |
| Chromaggus | Time Lapse | 35276 | 5th breath - raid stun + -50% max health, 15s |
| Chromaggus | Elemental Shield | 22278/22279/22281 | passive resist matching current breath pair |
| Nefarian P1 - Vaelastrasz | Flame Breath | 23461 | ~3500 Fire damage frontal cone |
| Nefarian P1 - Vaelastrasz | Flame Aura | 35301 | ~275 Fire damage/sec to nearby players |
| Nefarian P1 - Lord Victor Nefarius | Shadow Bolt Volley | 22665 | Shadow damage to nearby enemies |
| Nefarian P1 - Lord Victor Nefarius | Silence | 22666 | prevents casting |
| Nefarian P1 - Lord Victor Nefarius | Shadow Command | 22667 | charm ("Charmed!") |
| Nefarian P2 | Veil of Shadow | 22687 | -75% healing received, 6s |
| Nefarian P2 | Dragon sickness | 35324 | debuff ("You become arrogant...") - effect untested |
| Nefarian P2 | Hover | 17131 | untargetable between phases |

Also reworded from real Spell.xlsx text: **Death Talon Captain -> Mark of
Flames** (25050 -> +1000 Fire damage taken, 2 min), **Blackwing Taskmaster ->
Shadow Shock** (35183 -> Shadow damage + -30% healing, 5s).

## Brood Powers (Death Talon Wyrmguard), resolved

Renamed "X Brood Power" -> "Brood Power: X" to match the log. All cast on raid
members, DurationIndex 32 = 6s (Bronze = index 28 = 5s):

| Ability | Spell ID | AuraDescription -> filled as |
|---|---|---|
| Brood Power: Black | 22560 | "Damage taken increased by $s1%" -> +10% damage taken |
| Brood Power: Blue | 22559 | "Increases the time between attacks by $s1%" ($s1 = -100) + mana drain - sign not confirmed in-game |
| Brood Power: Bronze | 22291 | "Caught in a sandstorm!" -> periodic time-stop, 5s |
| Brood Power: Green | 22561 | "Stunned." -> periodic stun, 6s |
| Brood Power: Red | 22558 | "Deals $s1% health damage every $t1 sec" -> 5% health / few sec |

## New mob / add entries created

| New entry | Placed as | Ability | Spell ID |
|---|---|---|---|
| Orb of Domination | Razorgore add | Mental Strike | 35165 (no text) |
| Sawblade | Elementium Decapitator add | Saw Blade -> 1350 damage on contact | 35138 |
| Bone Construct | Nefarian add | Exploit Weakness -> bonus damage from behind | 8355 |
| Corrupted Bronze Whelp | trash (Supression Room group) | none logged (like the other three whelps) | - |

`Corrupted Bronze Whelp` was also added to `BWL_TRASH_ORDER` after the blue whelp.

## Deliberately NOT added

- **`Dragonbane` (23967)**, **`Assault Blessing` (35175)**, **`Dragonslayer`
  (35173)** - recur identically across many unrelated mobs; player trinket /
  buff effects, per the pre-existing filter note in `BWL.lua`.
- **`Saw Sound` (35141)**, **`Saw Launch Animation` (35154)**, **`Stun 5s`
  (35162)** under the Decapitator - launch visual + the Sawblade's own stun,
  folded into the Sawblade add's description.
- **Black Drakonid / Chromatic Drakonid** - Nefarian tunnel adds; only logged
  a single mis-attributed "Brood Power: Black" each. The existing "Tunnel adds"
  ability on Nefarian already covers them.
- **Reflected player spells under Krixix** (Siphon Life, Fireball, Corruption,
  Earth Shock, ...) - the raid's own spells bounced back by Mirrors System.
- **Mobs already in `BWL.lua` that this log didn't cover** (Blackwing Warlock /
  Technician / Spellbinder, Death Talon Overseer, Death Talon Seether's Aura of
  Flames, Death Talon Wyrmkin's Fireball Volley) - left untouched; their data
  came from `mob_abilities_summary.txt`.

## Still open for BWL

- **Numbers marked "untested" above** need in-game confirmation - Shrink Ray,
  Death Ray, Ice Sprinkler amounts, Dragon sickness / Mental Strike / Summon
  Livingflame / Warming Flames effects, and the Brood Power: Blue attack-speed
  sign.
- Tick intervals (`$t1`) on Brood Power: Red and similar are still `X`.
- The `X`-placeholder on Grethok's **Dominate Mind** (max level, duration).
- **All BWL trash `stats`** (armor/resistances) remain best-guess; trash
  `flags`/`roles` are general knowledge - unchanged by this pass.
