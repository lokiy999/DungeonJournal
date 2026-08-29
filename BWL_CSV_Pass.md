# BWL data pass from "BWL stuff.csv" (2026-08-29)

Source: `BWL stuff.csv` (uploaded by the user) - a real Blackwing Lair combat
log, ~103k rows, 17 columns (`Source`, `Source GUID`, `Action / Ability`,
`Spell ID`, `Target`, ...). Same methodology as the SM / ZG / UBRS / LBRS
passes: filter to creature GUIDs (`Source GUID` starting `0xF13`), drop totems
/ pet summons / the generic `Dazed` (1604) and `Shield Toss Return` (34308)
noise, group by `Source` name, keep distinct `Action / Ability` + `Spell ID`.

## Big caveat - no descriptions available

`Spell.xlsx` has **zero** `Description_enUS` / `AuraDescription_enUS` text for
every BWL NPC spell ID checked in this pass (including plain ones like Cleave,
Thrash, Silence). So this pass could only add:

- the real **ability name** and **spell ID** (from the log), and
- a short **mechanical description** where the ability is a standard, unchanged
  Vanilla ability (retail spell ID, well-known effect - Thrash, Silence, Fear,
  Counterspell, Slow, Veil of Shadow, Flame Breath, ...), OR
- a `"No confirmed effect - needs testing"` line for **custom Vanilla+ spells**
  (IDs in the 35xxx range with no tooltip text), each tagged with its spell ID
  so it can be looked up / tested later.

Every line added this way carries a `-- CHANGED:` comment naming the spell ID
and this CSV.

## Abilities added to existing bosses

| Boss / add | Ability added | Spell ID | Note |
|---|---|---|---|
| Razorgore | Untamed Fury | 35177 | custom, untested |
| Razorgore | Summon Livingflame | 35176 | custom; may overlap existing "Eternal Livingflame" |
| Razorgore | Warming Flames | 23040 | retail = self-heal near orb; unconfirmed here |
| Razorgore add - Grethok | Greatest Polymorph | 35168 | logged this run instead of Dominate Mind |
| Razorgore add - Grethok | Slow | 13747 | standard |
| Razorgore add - Blackwing Guardsman | Thunder Clap | 35166 | custom rank |
| Razorgore add - Blackwing Mage | Counterspell | 35174 | standard interrupt |
| Razorgore add - Blackwing Mage | Ice Mirror | 35171 | custom, untested |
| Elementium Decapitator | Sticky Oil Tar | 35135 | custom, untested |
| Elementium Decapitator | Ice Sprinkler (+ slow) | 35147 / 35148 | custom, untested |
| Broodlord Lashlayer | Frost Reflection | 35187 | custom, untested - possible Frost reflect |
| Firemaw | Thrash | 3391 | standard passive |
| Krixix | Disrupting Ray | 35272 | custom, untested |
| Krixix | Gravity Defied | 35488 | custom, untested |
| Krixix | Shrink Ray | 35273 | custom, untested |
| Krixix | Death Ray | 35274 | custom, untested |
| Ebonroc & Flamegor | Thrash | 3391 | standard passive, both dragons |
| Chromaggus | Time Lapse | 35276 | the 5th breath - was missing from the Breaths list |
| Chromaggus | Elemental Shield | 22278 / 22279 / 22281 | passive per-school resist matching current breaths |
| Nefarian P1 - Vaelastrasz | Flame Breath | 23461 | frontal Fire cone |
| Nefarian P1 - Vaelastrasz | Flame Aura | 35301 | custom passive aura, untested |
| Nefarian P1 - Lord Victor Nefarius | Shadow Bolt Volley | 22665 | balcony caster |
| Nefarian P1 - Lord Victor Nefarius | Silence | 22666 | balcony caster |
| Nefarian P1 - Lord Victor Nefarius | Shadow Command | 22667 | balcony caster (fear / MC) |
| Nefarian P2 | Veil of Shadow | 22687 | healing-reduction debuff |
| Nefarian P2 | Dragon sickness | 35324 | custom debuff, untested |
| Nefarian P2 | Hover | 17131 | untargetable between phases |

## New mob / add entries created

| New entry | Placed as | Ability | Spell ID |
|---|---|---|---|
| Orb of Domination | Razorgore add | Mental Strike | 35165 |
| Sawblade | Elementium Decapitator add | Saw Blade | 35138 |
| Bone Construct | Nefarian add | Exploit Weakness | 8355 |
| Corrupted Bronze Whelp | trash (Supression Room group) | - (none logged, like the other three whelps) | - |

`Corrupted Bronze Whelp` was also added to `BWL_TRASH_ORDER` after the blue whelp.

## The 6 old placeholders (done in the prior commit `ca5fa6c`)

| Mob | Ability | Spell ID |
|---|---|---|
| Death Talon Captain | Mark of Flames | 25050 |
| Death Talon Wyrmguard | Brood Power: Black / Blue / Bronze / Green / Red | 22560 / 22559 / 22291 / 22561 / 22558 |

Renamed from "X Brood Power" to "Brood Power: X" to match the combat log, and
each is cross-referenced to Chromaggus's matching `Brood Affliction: <colour>`.

## Deliberately NOT added

- **`Dragonbane` (23967)**, **`Assault Blessing` (35175)**, **`Dragonslayer`
  (35173)** - recur identically across many unrelated mobs; player trinket /
  buff effects, per the pre-existing filter note in `BWL.lua`.
- **`Saw Sound` (35141)**, **`Saw Launch Animation` (35154)**, **`Stun 5s`
  (35162)** under the Decapitator - launch visual + the Sawblade's own stun,
  folded into the Sawblade add's description rather than listed as boss casts.
- **Black Drakonid / Chromatic Drakonid** - Nefarian tunnel adds; only logged
  a single mis-attributed "Brood Power: Black" each, not enough for an entry.
  The existing "Tunnel adds" ability on Nefarian already covers them.
- **Reflected player spells under Krixix** (Siphon Life, Fireball, Corruption,
  Earth Shock, ...) - these are the raid's own spells bounced back by Mirrors
  System, not Krixix abilities.
- **Mobs already in `BWL.lua` that this particular log didn't cover**
  (Blackwing Warlock / Technician / Spellbinder, Death Talon Overseer, Death
  Talon Seether's Aura of Flames, Death Talon Wyrmkin's Fireball Volley) -
  left untouched; their data came from `mob_abilities_summary.txt`.

## Still open for BWL

- **Every custom 35xxx ability above needs in-game testing** for its actual
  effect / numbers - `Spell.xlsx` cannot supply them.
- **All BWL trash `stats`** (armor/resistances) remain best-guess, and trash
  `flags`/`roles` are general knowledge - unchanged by this pass.
- The `X`-placeholder abilities on Grethok (Arcane Missiles / Dominate Mind
  numbers) are still `X`.
