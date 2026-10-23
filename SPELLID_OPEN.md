# Abilities still without a spellId

Generated 2026-10-23 by matching ability names against lokiy.dev/spells (`db/index.json`)
and the combat-log CSVs. These have several spells of the same name and no log line from
their own mob, so the right one can't be picked from the data. "other mob" = only another
mob's cast of that name is in the logs (a hint, not proof).

Second pass (2026-10-23): each ability's numbers and effect text were compared with every
candidate's tooltip and effect values on lokiy.dev/spells; the 34 with one clear match were filled
and removed from this list. What is left either has no numbers to compare, ties between
candidates (e.g. 18173 / 23620 Burning Adrenaline), or numbers that match no candidate
(e.g. Tail Sweep 925-1075 vs 1600-2100 in the data).


## BWL

| Mob | Ability | Candidates | Source |
|---|---|---|---|
| Grethok the Controller | Dominate Mind | 20604, 36013 | log (other mob) |
| Blackwing Mage | Arcane Intellect | 1459, 1460, 1461, 1472, 1473, 1474, 1475, 3065 (+6) | site name |
| Ebonroc & Flamegor | Shadow Flame | 22539, 22682, 22985, 22992 | log (other mob) |
| Ebonroc & Flamegor | Wing Buffet | 18500, 23339 | log (other mob) |
| Ebonroc & Flamegor | Shadow Nova | 34873, 34874, 35239 | log (other mob) |
| Ebonroc & Flamegor | Shadows of Ebonroc | 35361 | log (other mob) |
| Ebonroc & Flamegor | Flames of Flamegor | 35360 | log (other mob) |
| Neferian | Essence of the Red | 23513 | log (other mob) |
| Neferian | Burning Adrenaline | 18173, 23478, 23619, 23620, 23644, 24701, 35300 | site name |
| Neferian | Tail Lash | 23364 | log (other mob) |
| Neferian | Shadow Flame | 22539, 22682, 22985, 22992 | log (other mob) |
| Neferian | Bellowing Roar | 18431, 22686 | log (other mob) |
| Neferian | Dropped Weapon | 6608, 23365, 25057, 25655 | site name |
| Neferian | Cleave | 15284, 15496, 19632, 19983, 20605, 20691, 22540 | log (other mob) |
| Death Talon Wyrmkin | Fireball Volley | 15285, 16250, 22425, 34483, 35208 | log (other mob) |
| Blackwing Warlock | Shadow Bolt | 686, 695, 12471, 12739, 15232, 19728, 21077, 22677 (+3) | log (other mob) |
| Blackwing Warlock | Rain of Fire | 19717, 24669 | log (other mob) |
| Blackwing Warlock | Howl of Terror | 5484, 17928 | log (other mob) |
| Blackwing Technician | Bomb | 8858, 9143, 22334 | site name |
| Blackwing Technician | Bottle of Poison | 7365, 22335 | site name |
| Death Talon Overseer | Mortal Strike | 13737, 15708, 16856, 17547, 19643, 24573 | log (other mob) |
| Death Talon Overseer | Fire Blast | 16144, 20623 | log (other mob) |
| Death Talon Overseer | Retaliation | 22857, 22858 | log (other mob) |
| Death Talon Overseer | Cleave | 15284, 15496, 19632, 19983, 20605, 20691, 22540 | log (other mob) |
| Blackwing Spellbinder | Arcane Blast | 24857 | log (other mob) |
| Blackwing Spellbinder | Flamestrike | 12468, 16102, 16419, 22275, 24612, 35976, 36091 | log (other mob) |

## EmeraldDragons

| Mob | Ability | Candidates | Source |
|---|---|---|---|
| Emeriss | Volatile Infection | 3584, 3585, 3586, 3587, 12094, 18149, 18150, 24928 (+1) | site name |
| Emeriss | Tail Sweep | 15847, 34416 | log (other mob) |
| Emeriss | Seeping Fog | 24813, 24814 | site name |
| Lethon | Shadow Bolt Whirl | 24820, 24821, 24822, 24823, 24834, 24835, 24836, 24837 (+1) | site name |
| Lethon | Tail Sweep | 15847, 34416 | log (other mob) |
| Lethon | Seeping Fog | 24813, 24814 | site name |
| Taerar | Tail Sweep | 15847, 34416 | log (other mob) |
| Taerar | Seeping Fog | 24813, 24814 | site name |
| Ysondre | Tail Sweep | 15847, 34416 | log (other mob) |
| Ysondre | Seeping Fog | 24813, 24814 | site name |

## MC

| Mob | Ability | Candidates | Source |
|---|---|---|---|
| Flamewaker Protector | Mind Control | 605, 627, 1293, 10911, 10912, 10913, 10914, 11446 (+1) | site name |
| Garr | Magnetize | 34461, 34462 | site name |
| Enrage | Earthquake | 1348, 33616, 33617, 34400, 35089 | site name |
| Sulfuron Harbinger | Battle Stance | 34475 | log (other mob) |
| Sulfuron Harbinger | Rend | 18200, 36080 | log (other mob) |
| Spawn Lava Spawn | Fireball | 133, 12466, 15242, 16788, 17290, 18392, 19391, 20420 (+2) | log (other mob) |
| Lava Annihilator | Double Attack | 18941, 18943, 19194, 19817, 19818 | site name |

## SM

| Mob | Ability | Candidates | Source |
|---|---|---|---|
| Loksey | Freezing Trap | 35873 | log (other mob) |
| Doan | Numbing Cold | 35978, 35980, 35981, 35982, 35983 | site name |
| Numbing Cold | Chilled to the Bone | 35984, 35985 | site name |
| Dragon Breath | Searing Heat | 35989, 35999, 36000 | site name |
| Renault Mograine | Dispel Magic | 15090, 17201, 23859, 36023 | log (other mob) |
| Fairbanks | Stomp | 4282, 4283, 4767, 6019, 12612, 25056, 27993, 36028 | site name |
| Panic | Fear | 6215, 22678 | log (other mob) |

## WorldBosses

| Mob | Ability | Candidates | Source |
|---|---|---|---|
| Azuregos | Chill | 21098, 28534, 28547 | site name |
| Azuregos | Aura of Frost | 23185, 23186 | site name |
| Azuregos | Teleport | 4801, 7791, 7794, 8195, 20449, 20534, 20682, 29216 (+1) | site name |
| Lady Hederine | Tears of the Hederine | 34811, 34819 | site name |
| Lady Hederine | Curse of Weakness | 702, 729, 1031, 1108, 1109, 1393, 1394, 6205 (+15) | site name |
| Lady Hederine | Lash of Pain | 7814, 7815, 7816, 7876, 7877, 7878, 11778, 11779 (+13) | site name |
| Lady Hederine | Mind Control | 605, 627, 1293, 10911, 10912, 10913, 10914, 11446 (+1) | site name |
| Lord Kazzak | Shadow Bolt Volley | 14887, 20741, 22665, 27383 | log (other mob) |
| Lord Kazzak | Void Bolt | 7588, 21066, 22709 | site name |
| Lord Kazzak | Twisted Reflection | 21063, 21064 | site name |
| Lord Kazzak | Thunder Clap | 11581, 35166, 36045 | log (other mob) |
| Lord Kazzak | Cleave | 15284, 15496, 19632, 19983, 20605, 20691, 22540 | log (other mob) |
| Lord Kazzak | Enrage | 8269, 8599, 19516, 19953, 28131, 28747, 35928 | log (other mob) |
| Kurinnaxx | Mortal Wound | 25646, 28467, 34046, 34235 | site name |
| Kurinnaxx | Tail Sweep | 15847, 34416 | log (other mob) |
| Kurinnaxx | Sand Trap | 25648, 25656, 26524 | site name |
| Kurinnaxx | Enrage | 8269, 8599, 19516, 19953, 28131, 28747, 35928 | log (other mob) |
| Teremus the Devourer | Shadow Flame | 22539, 22682, 22985, 22992 | log (other mob) |
| Teremus the Devourer | Knock Away | 10101, 11130, 18945, 19633, 20686 | log (other mob) |
| Teremus the Devourer | Cleave | 15284, 15496, 19632, 19983, 20605, 20691, 22540 | log (other mob) |
| King Mosh | Trample | 5568, 15550 | site name |
| King Mosh | Terrifying Roar | 14100 | log (other mob) |
| King Mosh | Vicious Rend | 14331 | log (other mob) |
| King Mosh | Primal Vitality | 34371, 34965 | site name |

## ZG

| Mob | Ability | Candidates | Source |
|---|---|---|---|
| Renataki | Thousand Blades | 24649, 24767 | site name |
| Renataki | Gouge | 12540, 24698, 28456 | log (other mob) |
| Renataki | Ambush | 34431 | log (other mob) |
| Gri'lek | Sweeping Strikes | 12723 | log (other mob) |
| Gri'lek | Entangling Roots | 339, 790, 1062, 1063, 1435, 1436, 2919, 2920 (+24) | site name |
| Wushoolay | Lightning Cloud | 6535, 8293, 19513, 22946, 23105, 24683, 25033, 26550 | site name |
| Wushoolay | Forked Lightning | 8435 | log (other mob) |
| Wushoolay | Chain Lightning | 15305, 15659 | log (other mob) |
