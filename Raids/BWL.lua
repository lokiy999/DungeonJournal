-- Part of the DungeonJournal RAIDS database (see AGENTS.md "Data model").
-- Loaded via DungeonJournal.toc before DungeonJournal.lua; appends this
-- raid's table to the shared DungeonJournal_Raids list in load order.

DungeonJournal_Raids = DungeonJournal_Raids or {}

------------------------------------------------------------
-- BWL order lists - START HERE to reorder/regroup content.
--
-- BWL_BOSS_ORDER and BWL_TRASH_ORDER are the only two things you should
-- need to touch to change what order bosses/trash appear in their tabs,
-- or which packs are grouped under which separator. Each is just a flat
-- list of keys (+ separator markers for trash) - actual boss/mob data
-- (icon/flags/stats/abilities) lives further down in BWL_BOSSES and
-- BWL_TRASH_MOBS, defined once per key and looked up from here.
------------------------------------------------------------

-- Boss encounter order (Bosses tab tree, top to bottom).
local BWL_BOSS_ORDER = {
    "razorgore",
    "elementium_decapitator",
    "broodlord",
    "firemaw",
    "krixix",
    "ebonroc_flamegor",
    "chromaggus",
    "nefarian",
}

-- Trash pull order (Trash tab tree): separators + mob keys, in tree
-- order. A plain string is a mob key with no count shown; a table
-- { key = ..., count = ... } shows a count for that occurrence. There is
-- deliberately no separate counts table - every count lives right here,
-- next to the pack it belongs to, even when the same mob's count repeats
-- across several occurrences (e.g. Blackwing Warlock/Technician below).
local BWL_TRASH_ORDER = {
    { separator = true, name = "Death Talon Pack", color = "ffcc6600" },
    { key = "death_talon_seether", count = 2 },
    { key = "death_talon_wyrmkin", count = 2 },
    { key = "death_talon_flamescale", count = 2 },
    "death_talon_captain",

    { separator = true, name = "Supression Room", color = "ff999999" },
    "corrupted_red_whelp",
    "corrupted_green_whelp",
    "corrupted_blue_whelp",
    "corrupted_bronze_whelp",
    "death_talon_hatcher",
    "blackwing_taskmaster",

    { separator = true, name = "Lab Pack", color = "ffcc6600" },
    { key = "blackwing_warlock", count = 2 },
    { key = "blackwing_technician", count = 8 },

    { separator = true, name = "Lab Pack 2", color = "ff999999" },
    { key = "blackwing_warlock", count = 2 },
    { key = "blackwing_technician", count = 8 },
    "death_talon_overseer",
    "blackwing_spellbinder",

    { separator = true, name = "Firemaw Pack", color = "ffcc6600" },
    "death_talon_wyrmguard",
    { key = "death_talon_overseer", count = 3 },

    { separator = true, name = "Double Spellbinder Pack", color = "ff999999" },
    { key = "blackwing_warlock", count = 2 },
    { key = "blackwing_technician", count = 8 },
    "death_talon_overseer",
    { key = "blackwing_spellbinder", count = 2 },

    { separator = true, name = "Wyrmguard Pack", color = "ffcc6600" },
    { key = "death_talon_wyrmguard", count = "3/4" },
}

------------------------------------------------------------
-- Boss registry - one entry per boss (icon/flags/stats/abilities/adds),
-- referenced by key from BWL_BOSS_ORDER above. Defined once each; add a
-- new boss here and add its key to BWL_BOSS_ORDER to place it.
------------------------------------------------------------
local BWL_BOSSES = {
    razorgore = {
        name = "Razorgore the Untamed",
        npcId = 12435,
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Razorgore",
        flags = {"nottauntable"},
        stats = {armor = 5675, fire = 243, nature = 71, frost = 71, shadow = 71, arcane = 108},
        abilities = {{
            name = "Conflagration",
            spellId = 23023,
            icon = "Interface\\Icons\\Spell_Fire_Incinerate",
            warning = true,
            roles = {"healer"},
            -- CHANGED 2026-09-30: spell 23023 in Spell.csv - 500 Fire/s for 10s (30 yd range), confuse, and a 500 Fire pulse to nearby allies each second (old line said 100/s).
            lines = {"Razorgore's most frequent ability by far - sets the target aflame for 500 Fire damage every second for 10 seconds and sends it into a state of panic. While affected, the flames scorch nearby allies for 500 Fire damage every second."}
        }, {
            -- spellId: uncertain - the combat log has 22425 / 35208 for this mob under this name.
            name = "Fireball Volley",
            icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
            warning = true,
            lines = {"Inflicts 455 Fire damage to nearby enemies and slows their movement speed by 50%."}
        }, {
            name = "Untamed Strike",
            spellId = 35178,
            icon = "Interface\\Icons\\temp",
            roles = {"tank"},
            lines = {"A heavy strike on his current target."}
        }, {
            name = "Eternal Livingflame",
            spellId = 35179,
            icon = "Interface\\Icons\\Spell_Fire_Fire",
            lines = {"Heals his allies but burns enemies, ticking every second."}
        }, {
            name = "Cleave",
            spellId = 19632,
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            roles = {"tank", "melee"},
            -- CHANGED 2026-09-30: spell 19632 in Spell.csv is level-scaled - bonus 50, +5 per caster level above 10, chain 10.
            lines = {"Strikes his target and its nearest allies for weapon damage plus 50, plus 5 per caster level above 10 (about 300 at level 60), affecting up to 10 targets."}
        }, {
            -- CHANGED: spell 35177, from BWL combat log "BWL stuff.csv". Text
            -- from Spell.xlsx AuraDescription; "$s1" = EffectBasePoints_1 (19)
            -- + 1 = 20; StackAmount 5.
            name = "Untamed Fury",
            spellId = 35177,
            icon = "Interface\\Icons\\Spell_Nature_BloodLust",
            warning = true,
            lines = {"Increases Razorgore's attack speed by 20% per stack, up to 5 stacks."}
        }, {
            -- CHANGED: spell 35176, from BWL combat log. No Spell.xlsx text
            -- (icon is the Temp placeholder). May be the same mechanic as the
            -- existing Eternal Livingflame entry above.
            name = "Summon Livingflame",
            spellId = 35176,
            icon = "Interface\\Icons\\Spell_Fire_Fire",
            warning = true,
            lines = {"Summons a Livingflame add (spell 35176). Behaviour needs in-game testing."}
        }, {
            -- CHANGED: spell 23040, from BWL combat log. No Spell.xlsx text.
            name = "Warming Flames",
            spellId = 23040,
            icon = "Interface\\Icons\\Spell_Fire_Fire",
            lines = {"No ability description available (spell 23040) - retail Razorgore uses this to regenerate health while near the orb; not confirmed for this server."}
        }},
        -- CHANGED: orc handlers that guard Razorgore's eggs during the egg
        -- phase - moved here from the Trash view since they're specific to
        -- this encounter rather than hallway trash.
        adds = {{
            key = "blackwing_guardsman",
            name = "Blackwing Guardsman",
            npcId = 14456,
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            roles = {"tank"},
            color = "ffcc6600",
            lines = {"Guards the eggs during the egg-destruction phase alongside Grethok the Controller."},
            abilities = {{
                name = "Cleave",
                spellId = 19632,
                icon = "Interface\\Icons\\Ability_Warrior_Cleave",
                roles = {"tank"},
                -- CHANGED 2026-09-30: spell 19632 in Spell.csv is level-scaled - bonus 50, +5 per caster level above 10, chain 10.
                lines = {"A sweeping attack that strikes its target and nearest ally for weapon damage plus 50, plus 5 per caster level above 10 (about 300 at level 60), affecting up to 10 targets."}
            }, {
                name = "Concussion Blow",
                spellId = 22427,
                icon = "Interface\\Icons\\Ability_ThunderBolt",
                warning = true,
                roles = {"tank"},
                lines = {"A brutal strike that stuns its target."}
            }, {
                -- CHANGED: spell 35166, from BWL combat log. Text from
                -- Spell.xlsx Description; "$s2" = EffectBasePoints_2 (-51)
                -- + 1 = -50; DurationIndex 29 = 12s.
                name = "Thunder Clap",
                spellId = 35166,
                icon = "Interface\\Icons\\Spell_Nature_ThunderClap",
                warning = true,
                lines = {"Blasts nearby enemies with thunder, increasing the time between their melee attacks by 50% and reducing movement speed by 50% for 12 seconds."}
            }}
        }, {
            -- CHANGED: real ability names (Arcane Missiles, Dominate Mind)
            -- sourced from mob_abilities_summary.txt; descriptions from
            -- Spell.xlsx with numeric tokens replaced by X placeholders.
            -- "Retribution Aura"/"Sanctity Aura" also logged under this mob
            -- were dropped as nearby-Paladin buff noise, same as elsewhere.
            key = "grethok",
            name = "Grethok the Controller",
            npcId = 12557,
            icon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
            roles = {"kick", "dispel"},
            color = "ffcc6600",
            lines = {"Guards the eggs during the egg-destruction phase - if left alive too long it can Dominate Mind a raid member."},
            abilities = {{
                -- CHANGED: spell 35169 in the BWL combat log. Spell.xlsx
                -- Description: "inflicting $s1 Arcane damage and interrupting
                -- spellcasting"; "$s1" = EffectBasePoints_1 (1899) + 1 = 1900.
                name = "Arcane Missiles",
                spellId = 35169,
                icon = "Interface\\Icons\\Spell_Nature_StarFall",
                warning = true,
                roles = {"kick"},
                lines = {"Launches magical missiles for around 1900 Arcane damage and interrupts spellcasting."}
            }, {
                name = "Dominate Mind",
                icon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
                warning = true,
                roles = {"dispel"},
                lines = {"Takes control of a humanoid enemy up to level X for X seconds."}
            }, {
                -- CHANGED: spell 35168, from BWL combat log "BWL stuff.csv" -
                -- logged this run in place of Dominate Mind. Text from
                -- Spell.xlsx Description; DurationIndex 18 = 20s.
                name = "Greatest Polymorph",
                spellId = 35168,
                icon = "Interface\\Icons\\Spell_Nature_Brilliance",
                warning = true,
                roles = {"dispel"},
                lines = {"Polymorphs a raid member into a sheep for up to 20 seconds - they cannot act but regenerate quickly. Only one target at a time."}
            }, {
                -- CHANGED: spell 13747, from BWL combat log.
                name = "Slow",
                spellId = 13747,
                icon = "Interface\\Icons\\Spell_Nature_Slow",
                warning = true,
                lines = {"Reduces the target's movement speed and increases the time between its attacks."}
            }}
        }, {
            key = "death_talon_dragonspawn",
            name = "Death Talon Dragonspawn",
            npcId = 12422,
            icon = "Interface\\Icons\\Ability_Whirlwind",
            roles = {"tank"},
            color = "ffcc6600",
            lines = {"Melee dragonkin add during the Razorgore encounter."},
            abilities = {{
                name = "Ring Cleave",
                spellId = 35170,
                icon = "Interface\\Icons\\Ability_Whirlwind",
                roles = {"tank"},
                lines = {"Attacks all nearby enemies in a whirlwind, causing weapon damage to each."}
            }}
        }, {
            key = "blackwing_legionnaire",
            name = "Blackwing Legionnaire",
            npcId = 12416,
            icon = "Interface\\Icons\\Ability_Rogue_Ambush",
            roles = {"tank"},
            color = "ffcc6600",
            lines = {"Melee orc add during the Razorgore encounter."},
            abilities = {{
                name = "Cleave",
                spellId = 19632,
                icon = "Interface\\Icons\\Ability_Warrior_Cleave",
                roles = {"tank"},
                -- CHANGED 2026-09-30: spell 19632 in Spell.csv is level-scaled - bonus 50, +5 per caster level above 10, chain 10.
                lines = {"A sweeping attack that strikes its target and nearest ally for weapon damage plus 50, plus 5 per caster level above 10 (about 300 at level 60), affecting up to 10 targets."}
            }, {
                name = "Strike",
                spellId = 15580,
                icon = "Interface\\Icons\\Ability_Rogue_Ambush",
                roles = {"tank"},
                lines = {"Strikes at an enemy, inflicting increased melee damage."}
            }}
        }, {
            key = "blackwing_mage",
            name = "Blackwing Mage",
            npcId = 12420,
            icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
            roles = {"kick"},
            color = "ffcc6600",
            lines = {"Caster add during the Razorgore encounter."},
            abilities = {{
                name = "Fireball",
                spellId = 17290,
                icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
                warning = true,
                roles = {"kick"},
                lines = {"Hurls a fiery ball that causes Fire damage plus a burn over time."}
            }, {
                name = "Arcane Intellect",
                icon = "Interface\\Icons\\Spell_Holy_MagicalSentry",
                lines = {"Buffs its own Intellect."}
            }, {
                -- CHANGED: spell 35174, from BWL combat log. Text from
                -- Spell.xlsx Description; DurationIndex 1 = 10s.
                name = "Counterspell",
                spellId = 35174,
                icon = "Interface\\Icons\\Spell_Frost_IceShock",
                warning = true,
                roles = {"kick"},
                lines = {"Interrupts the current cast and locks that school of magic for 10 seconds."}
            }, {
                -- CHANGED: spell 35171, from BWL combat log. Text from
                -- Spell.xlsx; DurationIndex 7 = 5s.
                name = "Ice Mirror",
                spellId = 35171,
                icon = "Interface\\Icons\\Spell_Frost_FrostArmor02",
                warning = true,
                roles = {"caster"},
                lines = {"Shields the Mage with a mirror of ice that reflects spells cast at it for 5 seconds - stop casting while it is up."}
            }}
        }, {
            -- CHANGED: new entry from BWL combat log "BWL stuff.csv" - the
            -- mind-control orb the raid uses to command Razorgore during the
            -- egg phase. Only ability it logged as a source is Mental Strike.
            key = "orb_of_domination",
            name = "Orb of Domination",
            npcId = 25119,
            spellId = 35200,
            icon = "Interface\\Icons\\Spell_Shadow_Metamorphosis",
            color = "ffcc6600",
            lines = {"The controllable orb used to take command of Razorgore and destroy the eggs. Stops working (and pulses damage) if the controller is knocked off."},
            abilities = {{
                -- CHANGED: spell 35165, from BWL combat log. Custom V+, no
                -- Spell.xlsx text.
                name = "Mental Strike",
                spellId = 35165,
                icon = "Interface\\Icons\\Spell_Shadow_MindTwisting",
                warning = true,
                lines = {"No ability description available (spell 35165) - reads as the backlash on whoever is controlling the orb. Needs in-game testing."}
            }}
        }}
    },

    elementium_decapitator = {
        name = "Elementium Decapitator Mk III",
        npcId = 25100,
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\ElementiumDecapitator",
        flags = {"nottauntable"},
        stats = {armor = 6600, fire = 322, nature = 58, frost = 98, shadow = 78, arcane = 58},
        abilities = {{
            name = "Heavy Thorium Grenade",
            spellId = 35155,
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            warning = true,
            lines = {"Lobs grenades at the raid - by far its most frequent ability (26000+ log entries)."}
        }, {
            name = "Coke Ejection",
            spellId = 35146,
            icon = "Interface\\Icons\\Spell_Fire_MeteorStorm",
            warning = true,
            roles = {"tank"},
            -- CHANGED 2026-09-30: spell 35146 in Spell.csv - 3000-4000 Fire plus a second 200-250 Fire effect (old line said 3000-6000).
            lines = {"Inflicts 3000 to 4000 Fire damage, plus an additional 200 to 250 Fire damage, to enemies in a cone in front of it."}
        }, {
            -- CHANGED: spell 35135, from BWL combat log. Text from Spell.xlsx
            -- AuraDescription; "$s1" = EffectBasePoints_1 (24) + 1 = 25;
            -- DurationIndex 387 = 16s. (Same debuff wording as MC Firelord's
            -- Incinerate.)
            name = "Sticky Oil Tar",
            spellId = 35135,
            icon = "Interface\\Icons\\INV_Misc_Slime_02",
            warning = true,
            lines = {"Coats the target in tar, increasing the Fire damage it takes by 25% for 16 seconds. Stacks."}
        }, {
            -- CHANGED: spells 35147 (Ice Sprinkler) + 35148 (its slow), from
            -- BWL combat log. Neither has Spell.xlsx description text.
            name = "Ice Sprinkler",
            spellId = 35147,
            icon = "Interface\\Icons\\Spell_Frost_FrostNova",
            warning = true,
            lines = {"A Frost spray (spell 35147) that applies a movement slow (spell 35148). Damage / slow amount need testing."}
        }},
        -- CHANGED: the spinning saw-blade hazards the Decapitator launches -
        -- logged as their own source "Sawblade" (spell "Saw Blade" 35138) in
        -- "BWL stuff.csv". "Saw Sound" / "Saw Launch Animation" / "Stun 5s"
        -- under the boss itself are the launch visual + the blade's stun.
        adds = {{
            key = "sawblade",
            -- spellId: uncertain - only the 'Stun 5s' effect (35162) is known, not the blade's own spell.
            name = "Sawblade",
            npcIds = {25103, 25104, 25105, 25109},
            icon = "Interface\\Icons\\Ability_Whirlwind",
            color = "ffcc6600",
            lines = {"Spinning blades launched across the room. Being hit deals damage and (per the boss's 'Stun 5s' cast, spell 35162) stuns for about 5 seconds - do not stand in their path."},
            abilities = {{
                -- CHANGED: spell 35138. "$s1" = EffectBasePoints_1 (1349) + 1.
                name = "Saw Blade",
                spellId = 35138,
                icon = "Interface\\Icons\\INV_Misc_SawBlade_01",
                warning = true,
                lines = {"Inflicts 1350 damage to anyone the blade passes through."}
            }}
        }}
    },

    broodlord = {
        name = "Broodlord Lashlayer",
        npcId = 12017,
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Broodlord",
        flags = {"nottauntable"},
        stats = {armor = 5675, fire = 94, nature = 94, frost = 94, shadow = 94, arcane = 94},
        abilities = {{
            name = "Blast Wave",
            spellId = 23331,
            icon = "Interface\\Icons\\Spell_Holy_Excorcism_02",
            warning = true,
            lines = {"A wave of flame radiates outward, inflicting heavy Fire damage to everyone within roughly 10 yards, knocking them back and slowing them.",
                     "His signature ability - by far his most common log entry."}
        }, {
            name = "Knock Back",
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_14",
            warning = true,
            roles = {"tank"},
            lines = {"Resets or reduces threat. The tanks are slowed and cannot chase."}
        }, {
            name = "Mortal Strike",
            spellId = 24573,
            icon = "Interface\\Icons\\Ability_Warrior_SavageBlow",
            warning = true,
            roles = {"tank", "healer"},
            lines = {"A brutal strike that also reduces healing received on the target."}
        }, {
            name = "Cleave",
            spellId = 15284,
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            roles = {"tank", "melee"},
            -- CHANGED 2026-09-30: spell 15284 in Spell.csv is level-scaled - bonus 10, +1 per caster level above 10, chain 3.
            lines = {"Strikes his target and its nearest allies for weapon damage plus 10, plus 1 per caster level above 10 (about 60 at level 60), affecting up to 3 targets."}
        }, {
            -- CHANGED: spell 35187, from BWL combat log. AuraDescription is
            -- "Reflecting Frost spells." CHANGED 2026-09-29: Spell.csv has
            -- aura 74 (reflect spells of a school) at 99 + 1 = 100% chance,
            -- school Frost, duration 20s.
            name = "Frost Reflection",
            spellId = 35187,
            icon = "Interface\\Icons\\Spell_Frost_FrostArmor02",
            warning = true,
            roles = {"caster"},
            lines = {"Reflects 100% of Frost spells cast at him back at the caster for 20 seconds - stop casting Frost while it is up."}
        }}
    },

    firemaw = {
        name = "Firemaw",
        npcId = 11983,
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Firemaw",
        flags = {"tauntable"},
        stats = {armor = 5280, fire = 384, nature = 76, frost = 31, shadow = 76, arcane = 31},
        abilities = {{
            name = "Flame Buffet",
            spellId = 23341,
            icon = "Interface\\Icons\\Spell_Fire_Fireball",
            warning = true,
            roles = {"tank"},
            lines = {"Firemaw's defining mechanic and his most frequent ability by an enormous margin (37000+ log entries).",
                     "Increases Fire damage taken and stacks indefinitely. It CANNOT be removed with Vial of Elune's Light."}
        }, {
            -- spellId: uncertain - the combat log has 22539 / 22682 for this mob under this name.
            name = "Shadow Flame",
            icon = "Interface\\Icons\\Spell_Fire_Incinerate",
            warning = true,
            lines = {"Inflicts heavy Shadow damage to enemies in a cone in front of him. Do not stand in front."}
        }, {
            name = "Wing Buffet",
            spellId = 23339,
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_14",
            warning = true,
            roles = {"tank"},
            lines = {"Knocks nearby enemies back for around 1500 damage, shedding threat."}
        }, {
            -- CHANGED 2026-09-30: per the devs, the orbs Firemaw spawns are called Flame Rifts. Not in the combat log; damage and behavior unknown.
            name = "Flame Rifts",
            icon = "Interface\\Icons\\Spell_Fire_Fire",
            lines = {"The orbs Firemaw spawns are Flame Rifts (per the devs). X - their effect is not yet documented."}
        }, {
            separator = true,
            passive = true,
            name = "Passives"
        }, {
            -- CHANGED: spell 3391, from BWL combat log "BWL stuff.csv".
            name = "Thrash",
            spellId = 3391,
            icon = "Interface\\Icons\\Ability_Warrior_DecisiveStrike",
            roles = {"tank"},
            lines = {"Passive - occasionally grants an extra melee attack or two on the same swing."}
        }}
    },

    krixix = {
        name = "Master Elemental Shaper Krixix",
        npcId = 14401,
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Krixix",
        flags = {"tauntable"},
        stats = {armor = 5240, fire = 102, nature = 102, frost = 102, shadow = 84, arcane = 31},
        abilities = {{
            name = "Mirrors System",
            spellId = 35271,
            icon = "Interface\\Icons\\Spell_Nature_AstralRecalGroup",
            warning = true,
            roles = {"caster"},
            lines = {"Reflects the next several direct damage spells back at everyone around him.",
                     "This is why the combat log shows him 'casting' the raid's own spells - stop casting while it is up."}
        }, {
            -- spellId: uncertain - the combat log has 35268 / 35269 / 35270 for this mob under this name.
            name = "Elemental Blast",
            icon = "Interface\\Icons\\Spell_Nature_EarthShock",
            warning = true,
            lines = {"Inflicts around 1100 damage of a rotating school (Nature, Fire or Frost). The cast cannot be interrupted by damage."}
        }, {
            -- CHANGED: the four below are from the BWL combat log (spells 35272
            -- / 35488 / 35273 / 35274). Text from Spell.xlsx where present;
            -- "$s2" on Disrupting Ray = EffectBasePoints_2 (99) + 1 = 100,
            -- DurationIndex 2 = 30s. CHANGED 2026-09-29: Shrink Ray / Death
            -- Ray only have flavour aura text, so their numbers come from the
            -- effect/aura columns in Spell.csv instead - Shrink Ray: aura 79
            -- (damage done %) -75, aura 61 (scale) -50, aura 33 (slow) -25,
            -- 30s. Death Ray: School Damage 11999 + 1 to + 5001 = 12000 to
            -- 17000 Physical, plus aura 12 (stun) with the spell's 30s
            -- duration - a 30s stun is unusually long, check in-game.
            name = "Disrupting Ray",
            spellId = 35272,
            icon = "Interface\\Icons\\INV_Misc_EngGizmos_03",
            warning = true,
            roles = {"tank"},
            lines = {"Completely strips the target's defences and increases the damage it takes by 100% for 30 seconds."}
        }, {
            name = "Gravity Defied",
            spellId = 35488,
            icon = "Interface\\Icons\\Spell_Nature_Levitate",
            warning = true,
            lines = {"Hooks the targeted player and pulls them back to Krixix (spell 35488)."}
        }, {
            name = "Shrink Ray",
            spellId = 35273,
            icon = "Interface\\Icons\\INV_Misc_EngGizmos_06",
            warning = true,
            lines = {"Shrinks the target for 30 seconds: 75% less damage dealt, 50% smaller and 25% slower movement (spell 35273)."}
        }, {
            name = "Death Ray",
            spellId = 35274,
            icon = "Interface\\Icons\\INV_Misc_EngGizmos_01",
            warning = true,
            lines = {"Inflicts 12000 to 17000 Physical damage and stuns the target for 30 seconds (spell 35274)."}
        }}
    },

    ebonroc_flamegor = {
        name = "Ebonroc & Flamegor",
        npcIds = {14601, 11981},
        flags = {"nottauntable"},
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Ebonroc",
        stats = {armor = 5680, fire = 0, nature = 21, frost = 37, shadow = 188, arcane = 98},
        abilities = {{
            separator = true,
            name = "Shared - both dragons"
        }, {
            name = "Positioning",
            icon = "Interface\\Icons\\Ability_Hunter_Pet_Dragonhawk",
            warning = true,
            roles = {"tank"},
            lines = {"Both dragons are active at once, each with its own aura."}
        }, {
            name = "Shadow Flame",
            icon = "Interface\\Icons\\Spell_Fire_Incinerate",
            warning = true,
            lines = {"Inflicts heavy Shadow damage to enemies in a cone in front of the dragon. Both use it."}
        }, {
            name = "Wing Buffet",
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_14",
            roles = {"tank"},
            lines = {"Knocks nearby enemies back for around 1500 damage, shedding threat.",
                     "High threat players drop threat with a timed Wing Buffet - Shadow Flame follows 2 seconds after."}
        }, {
            -- spellId: 35238 is Ebonroc's Frenzy; Flamegor's is 23342 (same ability, two spells).
            name = "Frenzy",
            spellId = 35238,
            icon = "Interface\\Icons\\Ability_GhoulFrenzy",
            warning = true,
            roles = {"hunter"},
            lines = {"Both dragons enrage, causing heavy raid-wide damage. Can be removed with Tranquilizing Shot.",
                     "Logged as spell 35238 (Ebonroc) / 23342 (Flamegor) in BWL combat log."}
        }, {
            -- CHANGED: spell 3391, from BWL combat log "BWL stuff.csv" - both
            -- dragons use it.
            name = "Thrash",
            spellId = 3391,
            icon = "Interface\\Icons\\Ability_Warrior_DecisiveStrike",
            roles = {"tank"},
            lines = {"Passive - occasionally grants an extra melee attack or two on the same swing. Both dragons have it."}
        }, {
            separator = true,
            name = "Ebonroc"
        }, {
            name = "Shadow Nova",
            icon = "Interface\\Icons\\Spell_Shadow_ShadeTrueSight",
            warning = true,
            lines = {"An explosion of Shadow around Ebonroc, inflicting around 500 Shadow damage to everyone nearby. His most frequent ability."}
        }, {
            name = "Embrace of Shadows",
            spellId = 35241,
            icon = "Interface\\Icons\\Spell_Shadow_AntiShadow",
            warning = true,
            roles = {"healer"},
            lines = {"Increases the Shadow damage the target takes from Embrace of Shadows by 500, stacking as the fight goes on."}
        }, {
            name = "Shadows of Ebonroc",
            icon = "Interface\\Icons\\Spell_Shadow_GatherShadows",
            warning = true,
            roles = {"healer"},
            lines = {"When Ebonroc deals damage he heals himself for a multiple of the damage dealt."}
        }, {
            separator = true,
            name = "Flamegor"
        }, {
            name = "Fire Nova",
            spellId = 34425,
            icon = "Interface\\Icons\\Spell_Fire_SealOfFire",
            warning = true,
            lines = {"Inflicts around 955 Fire damage to nearby enemies. His most frequent ability."}
        }, {
            name = "Embrace of Flames",
            spellId = 35242,
            icon = "Interface\\Icons\\Spell_Fire_Immolation",
            warning = true,
            roles = {"healer"},
            lines = {"Increases the Fire damage the target takes from Embrace of Flames by 500, stacking as the fight goes on."}
        }, {
            name = "Flames of Flamegor",
            icon = "Interface\\Icons\\Spell_Fire_MoltenBlood",
            lines = {"When Flamegor deals damage he also damages himself for a portion of it."}
        }}
    },

    chromaggus = {
        name = "Chromaggus",
        npcId = 14020,
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Chromaggus",
        flags = {"tauntable"},
        stats = {armor = 6440, fire = 73, nature = 73, frost = 73, shadow = 73, arcane = 73},
        abilities = {{
            name = "Double Bite",
            spellId = 34429,
            icon = "Interface\\Icons\\Ability_Racial_Cannibalize",
            roles = {"tank"},
            -- CHANGED 2026-09-30: spell 34429 in Spell.csv - inflicts 100% weapon damage to a second enemy.
            lines = {"Inflicts 100% weapon damage to a second enemy as well. His most frequent melee ability."}
        }, {
            name = "Enrage",
            spellId = 28747,
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            warning = true,
            -- CHANGED 2026-09-30: spell 28747 in Spell.csv - +100% damage done, +50% attack speed, +15% size, 10 minutes.
            lines = {"Enrages at 20% health, increasing damage done by 100%, attack speed by 50% and size by 15%. Cannot be removed."}
        }, {
            name = "Frenzy",
            spellId = 28371,
            icon = "Interface\\Icons\\Ability_GhoulFrenzy",
            warning = true,
            roles = {"hunter"},
            -- CHANGED 2026-09-30: spell 28371 in Spell.csv - +100% attack speed, +50% damage done, +25% size, 12 seconds.
            lines = {"Increases attack speed by 100%, damage done by 50% and size by 25% for 12 seconds. Can be removed with Tranquilizing Shot, and still occurs during the enrage phase."}
        }, {
            separator = true,
            name = "Brood Afflictions"
        }, {
            name = "Brood Affliction: Black",
            spellId = 23154,
            icon = "Interface\\Icons\\INV_Misc_Head_Dragon_01",
            warning = true,
            roles = {"decurse", "dps"},
            lines = {"Curse. Increases all damage you cause by 10% but magical damage taken by 100%. Lasts 10 minutes."}
        }, {
            name = "Brood Affliction: Blue",
            spellId = 23153,
            icon = "Interface\\Icons\\INV_Misc_Head_Dragon_Blue",
            warning = true,
            roles = {"dispel", "tank"},
            lines = {"Magic. Burns 1% mana every second, reduces casting speed by 100% and increases armor by 3000. Lasts 10 minutes."}
        }, {
            name = "Brood Affliction: Green",
            spellId = 23169,
            icon = "Interface\\Icons\\INV_Misc_Head_Dragon_Green",
            warning = true,
            roles = {"poison", "healer"},
            lines = {"Poison. Deals 300 damage every 5 seconds, reduces healing received by 50% and increases healing done by 20%. Lasts 10 minutes."}
        }, {
            -- spellId: uncertain - the combat log has 23155 / 23168 for this mob under this name.
            name = "Brood Affliction: Red",
            icon = "Interface\\Icons\\INV_Misc_Head_Dragon_Red",
            warning = true,
            roles = {"disease", "healer"},
            lines = {"Disease. Deals 3% health damage every 3 seconds and increases melee attack speed by 10%. Lasts 10 minutes.",
                     "Heals Chromaggus for 300000 when the afflicted player dies."}
        }, {
            name = "Brood Affliction: Bronze",
            spellId = 23170,
            icon = "Interface\\Icons\\INV_Misc_Head_Dragon_Bronze",
            warning = true,
            roles = {"dispel"},
            lines = {"Increases movement speed by 40%, then every 6 seconds stops time - stunning the target and reducing magical damage taken by 100%. Lasts 10 minutes."}
        }, {
            separator = true,
            name = "Breaths"
        }, {
            name = "Breath rotation",
            icon = "Interface\\Icons\\Spell_Fire_Fire",
            warning = true,
            lines = {"He uses all five breath attacks in a single encounter rather than only two.",
                     "Its breaths can be avoided by breaking line of sight."}
        }, {
            name = "Caustic Breath",
            spellId = 35277,
            icon = "Interface\\Icons\\Spell_Nature_Acid_01",
            warning = true,
            roles = {"tank", "healer"},
            -- CHANGED 2026-09-30: spell 35277 in Spell.csv - 15 seconds, 475-700 per 3s, armor -8000, casting speed +33%.
            lines = {"'Caustic Pain!' - deals 475 to 700 Nature damage every 3 seconds, reduces armor by 8000 and increases casting speed by 33% for 15 seconds."}
        }, {
            name = "Ignite Flesh",
            spellId = 35278,
            icon = "Interface\\Icons\\Spell_Fire_FlameShock",
            warning = true,
            -- CHANGED 2026-09-30: spell 35278 in Spell.csv - 160 seconds, stacks up to 10.
            lines = {"Deals 5% health damage every 3 seconds and increases damage done by 5% for 160 seconds. Stacks up to 10 times."}
        }, {
            name = "Incinerate",
            spellId = 35275,
            icon = "Interface\\Icons\\Spell_Fire_FlameShock",
            warning = true,
            -- CHANGED 2026-09-30: spell 35275 in Spell.csv - 4800-6000 Fire to everyone within 100 yards.
            lines = {"Breath attack that inflicts 4800 to 6000 Fire damage to all enemies within 100 yards."}
        }, {
            name = "Frost Burn",
            spellId = 35279,
            icon = "Interface\\Icons\\Spell_Frost_ChillingBlast",
            warning = true,
            -- CHANGED 2026-09-30: spell 35279 in Spell.csv - 2500-3000 Frost, attack time +400%, 20 seconds.
            lines = {"Breath attack that inflicts 2500 to 3000 Frost damage to all enemies within 100 yards and increases the time between their attacks by 400% for 20 seconds."}
        }, {
            -- CHANGED: spell 35276, from BWL combat log - the fifth breath,
            -- previously missing. Aura text "Frozen in time!"; "$s2" =
            -- EffectBasePoints_2 (-51) + 1 = -50; DurationIndex 8 = 15s.
            name = "Time Lapse",
            spellId = 35276,
            icon = "Interface\\Icons\\Spell_Nature_TimeStop",
            warning = true,
            roles = {"healer"},
            lines = {"Chromaggus' fifth breath - stuns the raid and reduces maximum health by 50% for 15 seconds."}
        }, {
            -- CHANGED: spells 22278 / 22279 / 22281, from BWL combat log - one
            -- per breath school. No Spell.xlsx description text.
            -- spellId: one shield per breath school - 22278 / 22279 / 22281; 22278 is listed.
            name = "Elemental Shield",
            spellId = 22278,
            icon = "Interface\\Icons\\Spell_Fire_FireArmor",
            lines = {"Passive - Chromaggus resists the two damage schools that match his current pair of breaths (spells 22278 / 22279 / 22281)."}
        }}
    },

    nefarian = {
        name = "Neferian",
        npcId = 11583,
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Neferian",
        flags = {"tauntable"},
        stats = {armor = 5680, fire = 314, nature = 58, frost = 58, shadow = 114, arcane = 36},
        abilities = {{
            separator = true,
            name = "Phase 1 - Vaelastrasz"
        }, {
            name = "Essence of the Red",
            icon = "Interface\\Icons\\Spell_Fire_FelFireNova",
            lines = {"A beneficial effect granting mana, energy and rage regeneration. Applied once at the start and lasts 3 minutes.",
                     "Killing Vaelastrasz removes it."}
        }, {
            name = "Burning Adrenaline",
            icon = "Interface\\Icons\\Spell_Fire_Fireball02",
            warning = true,
            roles = {"healer"},
            lines = {"Lasts 20 seconds. Damage done increased by 100% and all spell casts become instant, but damage taken increases by 5% every second.",
                     "On death the victim deals 6250 to 8100 damage to surrounding allies - run out before dying."}
        }, {
            name = "Tail Swipe",
            spellId = 15847,
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_05",
            warning = true,
            roles = {"tank"},
            lines = {"Inflicts 1600 to 2100 damage on enemies in a 15 yard cone behind it, knocking them back.",
                     "Logged as Tail Sweep (spell 15847) in the BWL combat log."}
        }, {
            -- CHANGED: spell 23461, from BWL combat log. "$s1" =
            -- EffectBasePoints_1 (3499) + 1 = 3500.
            name = "Flame Breath",
            spellId = 23461,
            icon = "Interface\\Icons\\Spell_Fire_Fireball",
            warning = true,
            lines = {"Vaelastrasz breathes fire in a frontal cone for around 3500 Fire damage."}
        }, {
            -- CHANGED: spell 35301, from BWL combat log. AuraDescription
            -- "Deals $s1 fire damage a second"; "$s1" = EffectBasePoints_1
            -- (274) + 1 = 275; DurationIndex 28 = 5s.
            name = "Flame Aura",
            spellId = 35301,
            icon = "Interface\\Icons\\Spell_Fire_SealOfFire",
            warning = true,
            lines = {"Burns players near Vaelastrasz for around 275 Fire damage per second."}
        }, {
            -- CHANGED: Lord Victor Nefarius casts these from the balcony during
            -- phase 1 - spells 22665 / 22666 / 22667 / 22678 in the BWL combat
            -- log. He is untargetable; the effects still land on the raid.
            name = "Shadow Bolt Volley",
            spellId = 22665,
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            warning = true,
            lines = {"Lord Victor Nefarius (on the balcony) hits the raid with a volley of Shadow Bolts (spell 22665)."}
        }, {
            name = "Silence",
            spellId = 22666,
            icon = "Interface\\Icons\\Spell_Shadow_ImpPhaseShift",
            warning = true,
            lines = {"Lord Victor Nefarius silences part of the raid (spell 22666)."}
        }, {
            name = "Shadow Command",
            spellId = 22667,
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            warning = true,
            roles = {"dispel"},
            lines = {"Lord Victor Nefarius charms a raid member ('Charmed!', spell 22667) - they attack the raid until it wears off or is dispelled."}
        }, {
            name = "Tunnel adds",
            icon = "Interface\\Icons\\Ability_Hunter_Pet_Dragonhawk",
            warning = true,
            lines = {"Tunnel mobs spawn continuously.",
                     "Roughly 42-84 must die to enter phase 2. Green Drakonid stun (dispellable), Red deal Fire damage, Blue reduce attack speed."}
        }, {
            separator = true,
            name = "Phase 2 - Nefarian"
        }, {
            name = "Class Calls",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
            warning = true,
            lines = {"Nefarian periodically targets a whole class. None of these can be avoided with line of sight.",
                     "Hunters lose their ranged weapons, Warlocks summon infernals to banish, Priests' heals damage their targets, Shamans spawn four totems to kill, Paladins heal Nefarian unless they keep moving, Rogues are teleported and rooted in front of him, Warriors are forced into Berserker Stance, Druids are forced out of form, Mages are polymorphed."}
        }, {
            name = "Tail Lash",
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_14",
            warning = true,
            lines = {"Strikes enemies behind Nefarian, knocking them back and stunning them. His most frequent ability - do not stand behind him."}
        }, {
            name = "Shadow Flame",
            icon = "Interface\\Icons\\Spell_Fire_Incinerate",
            warning = true,
            lines = {"Inflicts very heavy Shadow damage in a cone in front of him."}
        }, {
            name = "Bellowing Roar",
            icon = "Interface\\Icons\\Spell_Shadow_Charm",
            warning = true,
            roles = {"shaman"},
            lines = {"Fears the raid, sending everyone fleeing. The main tank requires a Tremor Totem."}
        }, {
            name = "Curse of Nefarius",
            icon = "Interface\\Icons\\Spell_Shadow_AntiShadow",
            warning = true,
            roles = {"decurse", "healer"},
            lines = {"A curse reducing healing received by 75%."}
        }, {
            name = "Dropped Weapon",
            icon = "Interface\\Icons\\Ability_Warrior_Disarm",
            warning = true,
            roles = {"warrior", "tank"},
            lines = {"Disarms the target, leaving them unable to wield a weapon until it is picked back up."}
        }, {
            name = "Cleave",
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            roles = {"tank", "melee"},
            lines = {"Strikes his target and its nearest allies."}
        }, {
            -- CHANGED: spell 22687, from BWL combat log - was missing. Text
            -- from Spell.xlsx Description; "$s1" = EffectBasePoints_1 (-76)
            -- + 1 = -75; DurationIndex 32 = 6s.
            name = "Veil of Shadow",
            spellId = 22687,
            icon = "Interface\\Icons\\Spell_Shadow_GatherShadows",
            warning = true,
            roles = {"healer"},
            lines = {"Reduces healing received on the target by 75% for 6 seconds. Applied frequently in phase 2."}
        }, {
            -- CHANGED: spell 35324, from BWL combat log. Only flavour aura text
            -- ("You become arrogant...") in Spell.xlsx.
            name = "Dragon sickness",
            spellId = 35324,
            icon = "Interface\\Icons\\INV_Misc_Head_Dragon_Black",
            warning = true,
            lines = {"A debuff (spell 35324) - 'You become arrogant...'. Real effect needs in-game testing."}
        }, {
            -- CHANGED: spell 17131, from BWL combat log - Nefarian lifts off
            -- briefly between phases / positions.
            name = "Hover",
            spellId = 17131,
            icon = "Interface\\Icons\\Ability_Hunter_Pet_Dragonhawk",
            lines = {"Nefarian takes to the air briefly - he is untargetable and immune while hovering."}
        }},
        -- CHANGED: bone piles Nefarian raises in phase 2 to walk toward the
        -- raid - logged as source "Bone Construct" (spell "Exploit Weakness"
        -- 8355) in "BWL stuff.csv".
        adds = {{
            key = "bone_construct",
            name = "Bone Construct",
            npcId = 14605,
            icon = "Interface\\Icons\\INV_Misc_Bone_HumanSkull_01",
            color = "ffcc6600",
            lines = {"Raised from the bone piles on the floor during phase 2 (the 'Bone Constructs!' shout). Slow-moving."},
            abilities = {{
                -- CHANGED: spell 8355. Spell.xlsx Description: "Inflicts normal
                -- damage plus $s1 on an enemy, but only if attacking from
                -- behind."
                name = "Exploit Weakness",
                spellId = 8355,
                icon = "Interface\\Icons\\Ability_BackStab",
                warning = true,
                -- CHANGED 2026-09-30: spell 8355 in Spell.csv is level-scaled - weapon damage bonus 28-32, +3 per caster level above 10, no cap unless stated.
                lines = {"Inflicts weapon damage plus 28 to 32, plus 3 per caster level above 10 (about 178 to 182 at level 60), if attacking from behind."}
            }}
        }}
    },
}

------------------------------------------------------------
-- Trash mob registry - one entry per distinct trash mob (icon/flags/
-- stats/abilities), referenced by key from BWL_TRASH_ORDER above.
--
-- CHANGED: full real trash roster per mob_abilities_summary.txt (every
-- distinct mob name that logged an ability in BWL on this server).
-- Ability icons/descriptions are from Spell.xlsx (Blizzard's spell data,
-- matched by name), filtered to drop entries that were clearly nearby-
-- player heals/buffs mis-attributed to the mob in the log (e.g.
-- Rejuvenation/Hibernate mana refunds, and "Assault Blessing" /
-- "Dragonbane" / "Dragonslayer" which recur identically across many
-- unrelated mobs - almost certainly player buffs, not mob abilities).
-- Flags/roles/stats are otherwise general knowledge / best-guess - see
-- the PR notes.
------------------------------------------------------------
local BWL_TRASH_MOBS = {
    death_talon_captain = {
        name = "Death Talon Captain",
        npcId = 12467,
        icon = "Interface\\Icons\\Ability_Warrior_Cleave",
        flags = {"melee"},
        stats = {armor = 5400, fire = 90, nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {{
            name = "Cleave",
            spellId = 15496,
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            roles = {"tank"},
            -- CHANGED 2026-09-30: spell 15496 in Spell.csv is level-scaled - bonus 10, +1 per caster level above 10, chain 2.
            lines = {"A sweeping attack that strikes its target and nearest ally for weapon damage plus 10, plus 1 per caster level above 10 (about 60 at level 60)."}
        }, {
            -- CHANGED: spell 25050 (Death Talon Captain, BWL combat log). Text
            -- from Spell.xlsx AuraDescription: "$s1" = EffectBasePoints_1 (999)
            -- + 1 = 1000; DurationIndex 4 = 120s.
            name = "Mark of Flames",
            spellId = 25050,
            icon = "Interface\\Icons\\Spell_Fire_Fireball",
            warning = true,
            lines = {"Marks the target, increasing the Fire damage it takes by 1000 for 2 minutes."}
        }, {
            name = "Commanding Shout",
            spellId = 22440,
            icon = "Interface\\Icons\\Spell_Magic_MageArmor",
            lines = {"Buffs nearby allies."}
        }}
    },

    death_talon_seether = {
        name = "Death Talon Seether",
        npcId = 12464,
        icon = "Interface\\Icons\\Spell_Fire_Fire",
        flags = {"caster"},
        stats = {armor = 4000, fire = "immune", nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {{
            name = "Flame Buffet",
            spellId = 22433,
            icon = "Interface\\Icons\\Spell_Fire_Fireball",
            warning = true,
            roles = {"tank"},
            lines = {"Inflicts Fire damage to an enemy and increases the Fire damage it takes."}
        }, {
            name = "Frenzy",
            spellId = 22428,
            icon = "Interface\\Icons\\Ability_GhoulFrenzy",
            warning = true,
            roles = {"hunter"},
            lines = {"Enrages, attacking faster - remove with Tranquilizing Shot."}
        }, {
            separator = true,
            passive = true,
            name = "Passives"
        }, {
            name = "Aura of Flames",
            spellId = 22436,
            icon = "Interface\\Icons\\Spell_Fire_Fire",
            lines = {"A passive Fire damage aura affecting nearby enemies."}
        }}
    },

    death_talon_flamescale = {
        name = "Death Talon Flamescale",
        npcId = 12463,
        icon = "Interface\\Icons\\Ability_Warrior_Charge",
        flags = {"melee"},
        stats = {armor = 5200, fire = "immune", nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {{
            name = "Flame Shock",
            spellId = 22423,
            icon = "Interface\\Icons\\Spell_Fire_FlameShock",
            warning = true,
            roles = {"tank"},
            lines = {"Instantly sears the target with fire, causing Fire damage plus a burn over time."}
        }, {
            name = "Berserker Charge",
            spellId = 16636,
            icon = "Interface\\Icons\\Ability_Warrior_Charge",
            warning = true,
            roles = {"tank"},
            lines = {"Charges at an enemy, knocking it back and inflicting damage."}
        }}
    },

    death_talon_wyrmkin = {
        name = "Death Talon Wyrmkin",
        npcId = 12465,
        icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
        flags = {"caster"},
        stats = {armor = 5400, fire = 90, nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {{
            name = "Fireball Volley",
            icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
            warning = true,
            lines = {"Inflicts Fire damage to nearby enemies."}
        }, {
            name = "Blast Wave",
            spellId = 22424,
            icon = "Interface\\Icons\\Spell_Holy_Excorcism_02",
            warning = true,
            lines = {"A wave of flame radiates outward, damaging and dazing nearby enemies."}
        }}
    },

    corrupted_red_whelp = {
        name = "Corrupted Red Whelp",
        npcId = 14022,
        icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
        flags = {"caster"},
        stats = {armor = 3200, fire = 90, nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {}
    },

    corrupted_green_whelp = {
        name = "Corrupted Green Whelp",
        npcId = 14023,
        icon = "Interface\\Icons\\Spell_Nature_NullifyPoison",
        flags = {"caster"},
        stats = {armor = 3200, fire = 90, nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {}
    },

    corrupted_blue_whelp = {
        name = "Corrupted Blue Whelp",
        npcId = 14024,
        icon = "Interface\\Icons\\Spell_Frost_FrostBolt02",
        flags = {"caster"},
        stats = {armor = 3200, fire = 90, nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {}
    },

    -- CHANGED: added from BWL combat log "BWL stuff.csv" - the fourth whelp
    -- colour in the suppression room, previously missing. Like its siblings
    -- it logged no ability of its own in that run.
    corrupted_bronze_whelp = {
        name = "Corrupted Bronze Whelp",
        npcId = 14025,
        icon = "Interface\\Icons\\Spell_Nature_TimeStop",
        flags = {"caster"},
        stats = {armor = 3200, fire = 90, nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {}
    },

    death_talon_hatcher = {
        name = "Death Talon Hatcher",
        npcId = 12468,
        icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
        flags = {"caster"},
        stats = {armor = 4200, fire = "immune", nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {{
            name = "Flamestrike",
            spellId = 22275,
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            warning = true,
            lines = {"Calls down a pillar of fire, burning the area plus an additional burn over time - move out of it."}
        }, {
            -- spellId: uncertain - the combat log has 22441 / 22442 for this mob under this name.
            name = "Growing Flames",
            icon = "Interface\\Icons\\Spell_Fire_Fire",
            warning = true,
            lines = {"A stacking Fire-damage effect that intensifies over time."}
        }}
    },

    blackwing_taskmaster = {
        name = "Blackwing Taskmaster",
        npcId = 12458,
        icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
        flags = {"caster", "healer"},
        stats = {armor = 4200, fire = 90, nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {{
            -- CHANGED: spell 35183 in the BWL combat log. Spell.xlsx: Shadow
            -- damage plus an aura "Healing effects reduced by $s2%" - "$s2" =
            -- EffectBasePoints_2 (-31) + 1 = -30; DurationIndex 7 = 5s.
            name = "Shadow Shock",
            spellId = 35183,
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            warning = true,
            roles = {"kick"},
            lines = {"Lashes an enemy with dark magic for Shadow damage and reduces healing received on it by 30% for 5 seconds."}
        }, {
            name = "Healing Circle",
            spellId = 22458,
            icon = "Interface\\Icons\\Spell_Holy_PrayerOfHealing02",
            lines = {"Heals nearby allies."}
        }}
    },

    blackwing_warlock = {
        name = "Blackwing Warlock",
        npcId = 12459,
        npcId = 12459,
        npcId = 12459,
        icon = "Interface\\Icons\\Spell_Shadow_RainOfFire",
        flags = {"caster"},
        stats = {armor = 4200, fire = 90, nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {{
            name = "Shadow Bolt",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            warning = true,
            roles = {"kick"},
            lines = {"Sends a shadowy bolt at the enemy, causing Shadow damage."}
        }, {
            name = "Rain of Fire",
            icon = "Interface\\Icons\\Spell_Shadow_RainOfFire",
            warning = true,
            lines = {"Calls down a fiery rain, burning enemies in the area over time - move out."}
        }, {
            name = "Curse of Rot",
            spellId = 35223,
            icon = "Interface\\Icons\\Spell_Holy_NullifyDisease",
            roles = {"decurse"},
            lines = {"Curses the target, reducing Nature resistance, increasing Nature damage taken, and dealing damage over time."}
        }, {
            name = "Howl of Terror",
            icon = "Interface\\Icons\\Spell_Shadow_DeathScream",
            warning = true,
            lines = {"Causes nearby enemies to flee in terror - damage may interrupt the effect."}
        }, {
            name = "Incineration Curse",
            spellId = 35221,
            icon = "Interface\\Icons\\Spell_Fire_Incinerate",
            warning = true,
            lines = {"Curses the target, causing Fire damage over time."}
        }, {
            name = "Summon Felguard Portal",
            icon = "Interface\\Icons\\Spell_Shadow_SummonFelGuard",
            warning = true,
            lines = {"Opens a portal that summons a Felguard."}
        }}
    },

    blackwing_technician = {
        name = "Blackwing Technician",
        npcId = 13996,
        npcId = 13996,
        npcId = 13996,
        icon = "Interface\\Icons\\INV_Misc_Bomb_08",
        flags = {"ranged"},
        stats = {armor = 3800, fire = 90, nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {{
            name = "Bomb",
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            warning = true,
            lines = {"Used when its aggro target is not in melee range - bombs an area, inflicting Fire damage to enemies within it."}
        }, {
            name = "Bottle of Poison",
            icon = "Interface\\Icons\\Spell_Nature_CorrosiveBreath",
            roles = {"poison"},
            lines = {"Used when its aggro target is in melee range - tosses a bottle of poison at an enemy, inflicting Nature damage over time."}
        }}
    },

    death_talon_overseer = {
        name = "Death Talon Overseer",
        npcId = 12461,
        npcId = 12461,
        npcId = 12461,
        icon = "Interface\\Icons\\Ability_Warrior_SavageBlow",
        flags = {"melee"},
        stats = {armor = 5600, fire = 90, nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {{
            name = "Mortal Strike",
            icon = "Interface\\Icons\\Ability_Warrior_SavageBlow",
            warning = true,
            roles = {"tank", "healer"},
            lines = {"A vicious strike that wounds the target, reducing the effectiveness of healing on it."}
        }, {
            name = "Fire Blast",
            icon = "Interface\\Icons\\Spell_Fire_Fireball",
            roles = {"kick"},
            lines = {"Blasts the enemy for Fire damage."}
        }, {
            name = "Retaliation",
            icon = "Interface\\Icons\\Ability_Warrior_Challange",
            warning = true,
            roles = {"melee"},
            lines = {"Instantly counterattacks any enemy that strikes it in melee."}
        }, {
            name = "Cleave",
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            roles = {"tank"},
            lines = {"A sweeping attack that strikes its target and nearest ally."}
        }}
    },

    blackwing_spellbinder = {
        name = "Blackwing Spellbinder",
        npcId = 12457,
        npcId = 12457,
        icon = "Interface\\Icons\\Spell_Fire_Fireball",
        flags = {"caster", "immune_spells"},
        stats = {armor = 4200, fire = 90, nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {{
            name = "Arcane Blast",
            icon = "Interface\\Icons\\Spell_Fire_Fireball",
            warning = true,
            roles = {"kick"},
            lines = {"Blasts a target for Arcane damage."}
        }, {
            name = "Flamestrike",
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            warning = true,
            lines = {"Calls down a pillar of fire, burning the area plus an additional burn over time - move out of it."}
        }, {
            -- CHANGED 2026-09-29: the only "Greatest Polymorph" in Spell.csv is
            -- spell 35168 (sheep, 20s - the one Grethok logs). The Spellbinder
            -- itself is not in "BWL stuff.csv", so its spell ID is assumed.
            name = "Greatest Polymorph",
            spellId = 35168,
            icon = "Interface\\Icons\\Spell_Nature_Polymorph",
            warning = true,
            lines = {"Transforms a random raid member into a sheep for up to 20 seconds, unable to act."}
        }}
    },

    death_talon_wyrmguard = {
        name = "Death Talon Wyrmguard",
        npcId = 12460,
        npcId = 12460,
        icon = "Interface\\Icons\\INV_Misc_MonsterScales_14",
        flags = {"melee"},
        stats = {armor = 5600, fire = 90, nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {{
            name = "Mortal Strike",
            spellId = 16856,
            icon = "Interface\\Icons\\Ability_Warrior_SavageBlow",
            warning = true,
            roles = {"tank", "healer"},
            lines = {"A vicious strike that wounds the target, reducing the effectiveness of healing on it."}
        }, {
            name = "War Stomp",
            spellId = 24375,
            icon = "Interface\\Icons\\Ability_BullRush",
            warning = true,
            lines = {"Knocks nearby enemies back, stunning them."}
        }, {
            name = "Cleave",
            spellId = 15284,
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            roles = {"tank"},
            -- CHANGED 2026-09-30: spell 15284 in Spell.csv is level-scaled - bonus 10, +1 per caster level above 10, chain 3.
            lines = {"A sweeping attack that strikes its target and nearest ally for weapon damage plus 10, plus 1 per caster level above 10 (about 60 at level 60), affecting up to 3 targets."}
        }, {
            -- CHANGED: the five Brood Powers below are real spell IDs from the
            -- BWL combat log ("BWL stuff.csv") - the Wyrmguard rolls one at
            -- random and applies it to a raid member (logged with player
            -- targets). Text + numbers from Spell.xlsx AuraDescription with
            -- "$s1" = EffectBasePoints_1 + 1; DurationIndex 32 = 6s (Bronze
            -- uses index 28 = 5s). These are the debuff counterparts of
            -- Chromaggus's "Brood Affliction: <colour>" - see the Chromaggus
            -- entry. CHANGED 2026-09-29: from Spell.csv - Red's tick interval
            -- is 1000 ms (aura 89, % of health per tick); Blue's aura 138
            -- (melee haste) is -100, i.e. attacks slow down.
            separator = true,
            name = "Brood Powers",
            expanded = true,
        }, {
            name = "Brood Power: Black",
            spellId = 22560,
            icon = "Interface\\Icons\\Spell_Shadow_CorpseExplode",
            warning = true,
            lines = {"Increases the target's damage taken by 10% for 6 seconds (spell 22560)."}
        }, {
            name = "Brood Power: Blue",
            spellId = 22559,
            icon = "Interface\\Icons\\Spell_Frost_FrostBolt02",
            warning = true,
            lines = {"Increases the time between the target's attacks by 100% and drains mana for 6 seconds (spell 22559)."}
        }, {
            name = "Brood Power: Bronze",
            spellId = 22291,
            icon = "Interface\\Icons\\Spell_Nature_TimeStop",
            warning = true,
            lines = {"'Caught in a sandstorm' - periodically stops time on the target for 5 seconds (spell 22291)."}
        }, {
            name = "Brood Power: Green",
            spellId = 22561,
            icon = "Interface\\Icons\\Spell_Nature_NullifyPoison",
            warning = true,
            lines = {"Periodically stuns the target for 6 seconds (spell 22561)."}
        }, {
            name = "Brood Power: Red",
            spellId = 22558,
            icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
            warning = true,
            lines = {"Deals 5% of the target's health as damage every second for 6 seconds (spell 22558)."}
        }}
    },
}

------------------------------------------------------------
-- Builders: expand the order lists + registries above into the flat
-- table shapes the Trash/Bosses views expect (see AGENTS.md "Data
-- model"). Nothing below this point encodes raid content - only edit it
-- if the addon's expected data shape changes.
------------------------------------------------------------

local function BuildBWLBosses()
    local bosses = {}
    for _, key in ipairs(BWL_BOSS_ORDER) do
        local boss = { key = key }
        for field, value in pairs(BWL_BOSSES[key]) do
            boss[field] = value
        end
        table.insert(bosses, boss)
    end
    return bosses
end

local function BuildBWLTrash()
    local trash = {}
    for _, entry in ipairs(BWL_TRASH_ORDER) do
        if type(entry) == "table" and entry.separator then
            table.insert(trash, entry)
        else
            local key, count
            if type(entry) == "table" then
                key, count = entry.key, entry.count
            else
                key = entry
            end
            local mob = BWL_TRASH_MOBS[key]
            local pack = { key = key, grouped = true, count = count }
            for field, value in pairs(mob) do
                pack[field] = value
            end
            table.insert(trash, pack)
        end
    end
    return trash
end

table.insert(DungeonJournal_Raids, {
    key = "BWL",
    name = "Blackwing Lair",
    expanded = false,
    trashExpanded = false,
    trash = BuildBWLTrash(),
    bosses = BuildBWLBosses(),
})
