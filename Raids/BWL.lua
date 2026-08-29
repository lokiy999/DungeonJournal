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
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Razorgore",
        flags = {"nottauntable"},
        stats = {armor = 5675, fire = 243, nature = 71, frost = 71, shadow = 71, arcane = 108},
        abilities = {{
            name = "Conflagration",
            icon = "Interface\\Icons\\Spell_Fire_Incinerate",
            warning = true,
            roles = {"healer"},
            lines = {"Razorgore's most frequent ability by far - burns the target for 100 Fire damage every second."}
        }, {
            name = "Fireball Volley",
            icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
            warning = true,
            lines = {"Inflicts 455 Fire damage to nearby enemies and slows their movement speed by 50%."}
        }, {
            name = "Untamed Strike",
            icon = "Interface\\Icons\\temp",
            roles = {"tank"},
            lines = {"A heavy strike on his current target."}
        }, {
            name = "Eternal Livingflame",
            icon = "Interface\\Icons\\Spell_Fire_Fire",
            lines = {"Heals his allies but burns enemies, ticking every second."}
        }, {
            name = "Cleave",
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            roles = {"tank", "melee"},
            lines = {"Strikes his target and its nearest allies."}
        }, {
            -- CHANGED: spell 35177, from BWL combat log "BWL stuff.csv". Text
            -- from Spell.xlsx AuraDescription; "$s1" = EffectBasePoints_1 (19)
            -- + 1 = 20; StackAmount 5.
            name = "Untamed Fury",
            icon = "Interface\\Icons\\Spell_Nature_BloodLust",
            warning = true,
            lines = {"Increases Razorgore's attack speed by 20% per stack, up to 5 stacks."}
        }, {
            -- CHANGED: spell 35176, from BWL combat log. No Spell.xlsx text
            -- (icon is the Temp placeholder). May be the same mechanic as the
            -- existing Eternal Livingflame entry above.
            name = "Summon Livingflame",
            icon = "Interface\\Icons\\Spell_Fire_Fire",
            warning = true,
            lines = {"Summons a Livingflame add (spell 35176). Behaviour needs in-game testing."}
        }, {
            -- CHANGED: spell 23040, from BWL combat log. No Spell.xlsx text.
            name = "Warming Flames",
            icon = "Interface\\Icons\\Spell_Fire_Fire",
            lines = {"No ability description available (spell 23040) - retail Razorgore uses this to regenerate health while near the orb; not confirmed for this server."}
        }},
        -- CHANGED: orc handlers that guard Razorgore's eggs during the egg
        -- phase - moved here from the Trash view since they're specific to
        -- this encounter rather than hallway trash.
        adds = {{
            key = "blackwing_guardsman",
            name = "Blackwing Guardsman",
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            roles = {"tank"},
            color = "ffcc6600",
            lines = {"Guards the eggs during the egg-destruction phase alongside Grethok the Controller."},
            abilities = {{
                name = "Cleave",
                icon = "Interface\\Icons\\Ability_Warrior_Cleave",
                roles = {"tank"},
                lines = {"A sweeping attack that strikes its target and nearest ally - avoid clumping melee on it."}
            }, {
                name = "Concussion Blow",
                icon = "Interface\\Icons\\Ability_ThunderBolt",
                warning = true,
                roles = {"tank"},
                lines = {"A brutal strike that stuns its target."}
            }, {
                -- CHANGED: spell 35166, from BWL combat log. Text from
                -- Spell.xlsx Description; "$s2" = EffectBasePoints_2 (-51)
                -- + 1 = -50; DurationIndex 29 = 12s.
                name = "Thunder Clap",
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
            icon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
            roles = {"kick", "dispel"},
            color = "ffcc6600",
            lines = {"Guards the eggs during the egg-destruction phase - if left alive too long it can Dominate Mind a raid member. Kill or interrupt it quickly."},
            abilities = {{
                -- CHANGED: spell 35169 in the BWL combat log. Spell.xlsx
                -- Description: "inflicting $s1 Arcane damage and interrupting
                -- spellcasting"; "$s1" = EffectBasePoints_1 (1899) + 1 = 1900.
                name = "Arcane Missiles",
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
                icon = "Interface\\Icons\\Spell_Nature_Brilliance",
                warning = true,
                roles = {"dispel"},
                lines = {"Polymorphs a raid member into a sheep for up to 20 seconds - they cannot act but regenerate quickly. Only one target at a time."}
            }, {
                -- CHANGED: spell 13747, from BWL combat log.
                name = "Slow",
                icon = "Interface\\Icons\\Spell_Nature_Slow",
                warning = true,
                lines = {"Reduces the target's movement speed and increases the time between its attacks."}
            }}
        }, {
            key = "death_talon_dragonspawn",
            name = "Death Talon Dragonspawn",
            icon = "Interface\\Icons\\Ability_Whirlwind",
            roles = {"tank"},
            color = "ffcc6600",
            lines = {"Melee dragonkin add during the Razorgore encounter."},
            abilities = {{
                name = "Ring Cleave",
                icon = "Interface\\Icons\\Ability_Whirlwind",
                roles = {"tank"},
                lines = {"Attacks all nearby enemies in a whirlwind, causing weapon damage to each - avoid clumping melee on it."}
            }}
        }, {
            key = "blackwing_legionnaire",
            name = "Blackwing Legionnaire",
            icon = "Interface\\Icons\\Ability_Rogue_Ambush",
            roles = {"tank"},
            color = "ffcc6600",
            lines = {"Melee orc add during the Razorgore encounter."},
            abilities = {{
                name = "Cleave",
                icon = "Interface\\Icons\\Ability_Warrior_Cleave",
                roles = {"tank"},
                lines = {"A sweeping attack that strikes its target and nearest ally - avoid clumping melee on it."}
            }, {
                name = "Strike",
                icon = "Interface\\Icons\\Ability_Rogue_Ambush",
                roles = {"tank"},
                lines = {"Strikes at an enemy, inflicting increased melee damage."}
            }}
        }, {
            key = "blackwing_mage",
            name = "Blackwing Mage",
            icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
            roles = {"kick"},
            color = "ffcc6600",
            lines = {"Caster add during the Razorgore encounter - priority CC or interrupt."},
            abilities = {{
                name = "Fireball",
                icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
                warning = true,
                roles = {"kick"},
                lines = {"Hurls a fiery ball that causes Fire damage plus a burn over time - priority CC or interrupt target."}
            }, {
                name = "Arcane Intellect",
                icon = "Interface\\Icons\\Spell_Holy_MagicalSentry",
                lines = {"Buffs its own Intellect - kill or CC quickly to limit its casting."}
            }, {
                -- CHANGED: spell 35174, from BWL combat log. Text from
                -- Spell.xlsx Description; DurationIndex 1 = 10s.
                name = "Counterspell",
                icon = "Interface\\Icons\\Spell_Frost_IceShock",
                warning = true,
                roles = {"kick"},
                lines = {"Interrupts the current cast and locks that school of magic for 10 seconds."}
            }, {
                -- CHANGED: spell 35171, from BWL combat log. Text from
                -- Spell.xlsx; DurationIndex 7 = 5s.
                name = "Ice Mirror",
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
            icon = "Interface\\Icons\\Spell_Shadow_Metamorphosis",
            color = "ffcc6600",
            lines = {"The controllable orb used to take command of Razorgore and destroy the eggs. Stops working (and pulses damage) if the controller is knocked off."},
            abilities = {{
                -- CHANGED: spell 35165, from BWL combat log. Custom V+, no
                -- Spell.xlsx text.
                name = "Mental Strike",
                icon = "Interface\\Icons\\Spell_Shadow_MindTwisting",
                warning = true,
                lines = {"No ability description available (spell 35165) - reads as the backlash on whoever is controlling the orb. Needs in-game testing."}
            }}
        }}
    },

    elementium_decapitator = {
        name = "Elementium Decapitator Mk III",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\ElementiumDecapitator",
        flags = {"nottauntable"},
        stats = {armor = 6600, fire = 322, nature = 58, frost = 98, shadow = 78, arcane = 58},
        abilities = {{
            name = "Heavy Thorium Grenade",
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            warning = true,
            lines = {"Lobs grenades at the raid - by far its most frequent ability (26000+ log entries)."}
        }, {
            name = "Coke Ejection",
            icon = "Interface\\Icons\\Spell_Fire_MeteorStorm",
            warning = true,
            roles = {"tank"},
            lines = {"Inflicts 3000 to 6000 Fire damage to enemies in a cone in front of it. Keep it faced away from the raid."}
        }, {
            -- CHANGED: spell 35135, from BWL combat log. Text from Spell.xlsx
            -- AuraDescription; "$s1" = EffectBasePoints_1 (24) + 1 = 25;
            -- DurationIndex 387 = 16s. (Same debuff wording as MC Firelord's
            -- Incinerate.)
            name = "Sticky Oil Tar",
            icon = "Interface\\Icons\\INV_Misc_Slime_02",
            warning = true,
            lines = {"Coats the target in tar, increasing the Fire damage it takes by 25% for 16 seconds. Stacks."}
        }, {
            -- CHANGED: spells 35147 (Ice Sprinkler) + 35148 (its slow), from
            -- BWL combat log. Neither has Spell.xlsx description text.
            name = "Ice Sprinkler",
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
            name = "Sawblade",
            icon = "Interface\\Icons\\Ability_Whirlwind",
            color = "ffcc6600",
            lines = {"Spinning blades launched across the room. Being hit deals damage and (per the boss's 'Stun 5s' cast, spell 35162) stuns for about 5 seconds - do not stand in their path."},
            abilities = {{
                -- CHANGED: spell 35138. "$s1" = EffectBasePoints_1 (1349) + 1.
                name = "Saw Blade",
                icon = "Interface\\Icons\\INV_Misc_SawBlade_01",
                warning = true,
                lines = {"Inflicts 1350 damage to anyone the blade passes through."}
            }}
        }}
    },

    broodlord = {
        name = "Broodlord Lashlayer",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Broodlord",
        flags = {"nottauntable"},
        stats = {armor = 5675, fire = 94, nature = 94, frost = 94, shadow = 94, arcane = 94},
        abilities = {{
            name = "Blast Wave",
            icon = "Interface\\Icons\\Spell_Holy_Excorcism_02",
            warning = true,
            lines = {"A wave of flame radiates outward, inflicting heavy Fire damage to everyone within roughly 10 yards, knocking them back and slowing them.",
                     "His signature ability - by far his most common log entry."}
        }, {
            name = "Knock Back",
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_14",
            warning = true,
            roles = {"tank"},
            lines = {"Resets or reduces threat. Any DPS who pulls threat must run towards the boss so the tanks can recover him - the tanks are slowed and cannot chase."}
        }, {
            name = "Mortal Strike",
            icon = "Interface\\Icons\\Ability_Warrior_SavageBlow",
            warning = true,
            roles = {"tank", "healer"},
            lines = {"A brutal strike that also reduces healing received on the target. Tank healing must account for this."}
        }, {
            name = "Cleave",
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            roles = {"tank", "melee"},
            lines = {"Strikes his target and its nearest allies."}
        }, {
            -- CHANGED: spell 35187, from BWL combat log. AuraDescription is
            -- "Reflecting Frost spells." - amount / duration not in Spell.xlsx.
            name = "Frost Reflection",
            icon = "Interface\\Icons\\Spell_Frost_FrostArmor02",
            warning = true,
            roles = {"caster"},
            lines = {"Reflects Frost spells cast at him back at the caster - stop casting Frost while it is up. Duration needs testing."}
        }}
    },

    firemaw = {
        name = "Firemaw",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Firemaw",
        flags = {"tauntable"},
        stats = {armor = 5280, fire = 384, nature = 76, frost = 31, shadow = 76, arcane = 31},
        abilities = {{
            name = "Flame Buffet",
            icon = "Interface\\Icons\\Spell_Fire_Fireball",
            warning = true,
            roles = {"tank"},
            lines = {"Firemaw's defining mechanic and his most frequent ability by an enormous margin (37000+ log entries).",
                     "Increases Fire damage taken and stacks indefinitely. It CANNOT be removed with Vial of Elune's Light.",
                     "Tanks never run away to reset stacks - maximum threat is required, so healers must rotate to keep them alive. Ensure only one tank is hit by Wing Buffet at a time."}
        }, {
            name = "Shadow Flame",
            icon = "Interface\\Icons\\Spell_Fire_Incinerate",
            warning = true,
            lines = {"Inflicts heavy Shadow damage to enemies in a cone in front of him. Do not stand in front."}
        }, {
            name = "Wing Buffet",
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_14",
            warning = true,
            roles = {"tank"},
            lines = {"Knocks nearby enemies back for around 1500 damage, shedding threat."}
        }, {
            -- CHANGED: spell 3391, from BWL combat log "BWL stuff.csv".
            name = "Thrash",
            icon = "Interface\\Icons\\Ability_Warrior_DecisiveStrike",
            roles = {"tank"},
            lines = {"Passive - occasionally grants an extra melee attack or two on the same swing."}
        }}
    },

    krixix = {
        name = "Master Elemental Shaper Krixix",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Krixix",
        flags = {"tauntable"},
        stats = {armor = 5240, fire = 102, nature = 102, frost = 102, shadow = 84, arcane = 31},
        abilities = {{
            name = "Mirrors System",
            icon = "Interface\\Icons\\Spell_Nature_AstralRecalGroup",
            warning = true,
            roles = {"caster"},
            lines = {"Reflects the next several direct damage spells back at everyone around him.",
                     "This is why the combat log shows him 'casting' the raid's own spells - stop casting while it is up."}
        }, {
            name = "Elemental Blast",
            icon = "Interface\\Icons\\Spell_Nature_EarthShock",
            warning = true,
            lines = {"Inflicts around 1100 damage of a rotating school (Nature, Fire or Frost). The cast cannot be interrupted by damage."}
        }, {
            -- CHANGED: the four below are from the BWL combat log (spells 35272
            -- / 35488 / 35273 / 35274). Text from Spell.xlsx where present;
            -- "$s2" on Disrupting Ray = EffectBasePoints_2 (99) + 1 = 100,
            -- DurationIndex 2 = 30s. Shrink Ray / Death Ray only have flavour
            -- aura text, so damage/effect still needs testing.
            name = "Disrupting Ray",
            icon = "Interface\\Icons\\INV_Misc_EngGizmos_03",
            warning = true,
            roles = {"tank"},
            lines = {"Completely strips the target's defences and increases the damage it takes by 100% for 30 seconds."}
        }, {
            name = "Gravity Defied",
            icon = "Interface\\Icons\\Spell_Nature_Levitate",
            warning = true,
            lines = {"Hooks the targeted player and pulls them back to Krixix (spell 35488)."}
        }, {
            name = "Shrink Ray",
            icon = "Interface\\Icons\\INV_Misc_EngGizmos_06",
            warning = true,
            lines = {"Shrinks the target ('So tiny!', spell 35273) - reads as a damage / stat reduction debuff. Values need testing."}
        }, {
            name = "Death Ray",
            icon = "Interface\\Icons\\INV_Misc_EngGizmos_01",
            warning = true,
            lines = {"A heavy single-target shock (spell 35274). Damage needs testing."}
        }}
    },

    ebonroc_flamegor = {
        name = "Ebonroc & Flamegor",
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
            lines = {"Both dragons are active at once and must be tanked far apart with casters in between, so their auras do not overlap."}
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
            name = "Frenzy",
            icon = "Interface\\Icons\\Ability_GhoulFrenzy",
            warning = true,
            roles = {"hunter"},
            lines = {"Both dragons enrage, causing heavy raid-wide damage. MUST be removed with Tranquilizing Shot - ideally 2 hunters per dragon.",
                     "Logged as spell 35238 (Ebonroc) / 23342 (Flamegor) in BWL combat log."}
        }, {
            -- CHANGED: spell 3391, from BWL combat log "BWL stuff.csv" - both
            -- dragons use it.
            name = "Thrash",
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
            icon = "Interface\\Icons\\Spell_Fire_SealOfFire",
            warning = true,
            lines = {"Inflicts around 955 Fire damage to nearby enemies. His most frequent ability."}
        }, {
            name = "Embrace of Flames",
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
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Chromaggus",
        flags = {"tauntable"},
        stats = {armor = 6440, fire = 73, nature = 73, frost = 73, shadow = 73, arcane = 73},
        abilities = {{
            name = "Double Bite",
            icon = "Interface\\Icons\\Ability_Racial_Cannibalize",
            roles = {"tank"},
            lines = {"Chromaggus bites twice, hitting a second enemy as well. His most frequent melee ability."}
        }, {
            name = "Enrage",
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            warning = true,
            lines = {"Enrages at 20% health. Cannot be removed - time your damage so he reaches enrage just after a breath to maximise DPS."}
        }, {
            name = "Frenzy",
            icon = "Interface\\Icons\\Ability_GhoulFrenzy",
            warning = true,
            roles = {"hunter"},
            lines = {"Must be removed with Tranquilizing Shot. Still occurs during the enrage phase - the Frenzy can be removed even though the Enrage cannot."}
        }, {
            separator = true,
            name = "Brood Afflictions - dispel assignments"
        }, {
            name = "Brood Affliction: Black",
            icon = "Interface\\Icons\\INV_Misc_Head_Dragon_01",
            warning = true,
            roles = {"decurse", "dps"},
            lines = {"Curse. Increases all damage you cause by 10% but magical damage taken by 100%.",
                     "All DPS keep this one and remove the rest."}
        }, {
            name = "Brood Affliction: Blue",
            icon = "Interface\\Icons\\INV_Misc_Head_Dragon_Blue",
            warning = true,
            roles = {"dispel", "tank"},
            lines = {"Magic. Burns 1% mana every second, reduces casting speed by 100% and increases armour by 3000.",
                     "All tanks keep this one and remove the rest. Do not dispel Blue from tanks."}
        }, {
            name = "Brood Affliction: Green",
            icon = "Interface\\Icons\\INV_Misc_Head_Dragon_Green",
            warning = true,
            roles = {"poison", "healer"},
            lines = {"Poison. Deals 300 damage every 5 seconds, reduces healing received by 50% and increases healing done by 20%.",
                     "All healers keep this one and remove the rest."}
        }, {
            name = "Brood Affliction: Red",
            icon = "Interface\\Icons\\INV_Misc_Head_Dragon_Red",
            warning = true,
            roles = {"disease", "healer"},
            lines = {"Disease. Deals 3% health damage every 3 seconds and increases melee attack speed by 10%.",
                     "Heals Chromaggus when the afflicted player dies."}
        }, {
            name = "Brood Affliction: Bronze",
            icon = "Interface\\Icons\\INV_Misc_Head_Dragon_Bronze",
            warning = true,
            roles = {"dispel"},
            lines = {"Increases movement speed by 40%, then periodically stops time - stunning the target and reducing magical damage taken by 100%.",
                     "Removed with a Free Action Potion (Sand)."}
        }, {
            separator = true,
            name = "Breaths"
        }, {
            name = "Breath rotation",
            icon = "Interface\\Icons\\Spell_Fire_Fire",
            warning = true,
            lines = {"He uses all five breath attacks in a single encounter rather than only two.",
                     "Everyone except the current tank must hide for a breath - including off tanks, who need to pick him up afterwards.",
                     "Stack tightly against the wall so dispels stay in line of sight."}
        }, {
            name = "Caustic Breath",
            icon = "Interface\\Icons\\Spell_Nature_Acid_01",
            warning = true,
            roles = {"tank", "healer"},
            lines = {"'Caustic Pain!' - deals 475 to 700 damage every 3 seconds, reduces armour by 8000 to 9000 and increases casting speed by 33%.",
                     "Off tanks must avoid this. During the enrage phase only one tank should ever carry it."}
        }, {
            name = "Ignite Flesh",
            icon = "Interface\\Icons\\Spell_Fire_FlameShock",
            warning = true,
            lines = {"Deals 5% health damage every 3 seconds and increases physical damage done by 5%."}
        }, {
            name = "Incinerate",
            icon = "Interface\\Icons\\Spell_Fire_FlameShock",
            warning = true,
            lines = {"One of Chromaggus' breath attacks (spell 35275)."}
        }, {
            name = "Frost Burn",
            icon = "Interface\\Icons\\Spell_Frost_ChillingBlast",
            warning = true,
            lines = {"A Frost breath that increases the time between the target's attacks (spell 35279)."}
        }, {
            -- CHANGED: spell 35276, from BWL combat log - the fifth breath,
            -- previously missing. Aura text "Frozen in time!"; "$s2" =
            -- EffectBasePoints_2 (-51) + 1 = -50; DurationIndex 8 = 15s.
            name = "Time Lapse",
            icon = "Interface\\Icons\\Spell_Nature_TimeStop",
            warning = true,
            roles = {"healer"},
            lines = {"Chromaggus' fifth breath - stuns the raid and reduces maximum health by 50% for 15 seconds. Healers must not overheal into the drop."}
        }, {
            -- CHANGED: spells 22278 / 22279 / 22281, from BWL combat log - one
            -- per breath school. No Spell.xlsx description text.
            name = "Elemental Shield",
            icon = "Interface\\Icons\\Spell_Fire_FireArmor",
            lines = {"Passive - Chromaggus resists the two damage schools that match his current pair of breaths (spells 22278 / 22279 / 22281)."}
        }}
    },

    nefarian = {
        name = "Neferian",
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
                     "Killing Vaelastrasz removes it, so he must be kept alive for the full 3 minutes and then killed swiftly."}
        }, {
            name = "Burning Adrenaline",
            icon = "Interface\\Icons\\Spell_Fire_Fireball02",
            warning = true,
            roles = {"healer"},
            lines = {"Lasts 20 seconds. Damage done increased by 100% and all spell casts become instant, but damage taken increases by 5% every second.",
                     "On death the victim deals 6250 to 8100 damage to surrounding allies - run out before dying."}
        }, {
            name = "Tail Swipe",
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_05",
            warning = true,
            roles = {"tank"},
            lines = {"Tanks position front and back, away from the raid during phase 1.",
                     "Logged as Tail Sweep (spell 15847) in the BWL combat log."}
        }, {
            -- CHANGED: spell 23461, from BWL combat log. "$s1" =
            -- EffectBasePoints_1 (3499) + 1 = 3500.
            name = "Flame Breath",
            icon = "Interface\\Icons\\Spell_Fire_Fireball",
            warning = true,
            lines = {"Vaelastrasz breathes fire in a frontal cone for around 3500 Fire damage. Keep him faced away from the raid."}
        }, {
            -- CHANGED: spell 35301, from BWL combat log. AuraDescription
            -- "Deals $s1 fire damage a second"; "$s1" = EffectBasePoints_1
            -- (274) + 1 = 275; DurationIndex 28 = 5s.
            name = "Flame Aura",
            icon = "Interface\\Icons\\Spell_Fire_SealOfFire",
            warning = true,
            lines = {"Burns players near Vaelastrasz for around 275 Fire damage per second."}
        }, {
            -- CHANGED: Lord Victor Nefarius casts these from the balcony during
            -- phase 1 - spells 22665 / 22666 / 22667 / 22678 in the BWL combat
            -- log. He is untargetable; the effects still land on the raid.
            name = "Shadow Bolt Volley",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            warning = true,
            lines = {"Lord Victor Nefarius (on the balcony) hits the raid with a volley of Shadow Bolts (spell 22665)."}
        }, {
            name = "Silence",
            icon = "Interface\\Icons\\Spell_Shadow_ImpPhaseShift",
            warning = true,
            lines = {"Lord Victor Nefarius silences part of the raid (spell 22666)."}
        }, {
            name = "Shadow Command",
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            warning = true,
            roles = {"dispel"},
            lines = {"Lord Victor Nefarius charms a raid member ('Charmed!', spell 22667) - they attack the raid until it wears off or is dispelled."}
        }, {
            name = "Tunnel adds",
            icon = "Interface\\Icons\\Ability_Hunter_Pet_Dragonhawk",
            warning = true,
            lines = {"Tunnel mobs spawn continuously and are the number one priority - they overwhelm the raid quickly.",
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
            lines = {"A curse reducing healing received by 75%. Decurse it as a priority."}
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
            icon = "Interface\\Icons\\Spell_Shadow_GatherShadows",
            warning = true,
            roles = {"healer"},
            lines = {"Reduces healing received on the target by 75% for 6 seconds. Applied frequently in phase 2."}
        }, {
            -- CHANGED: spell 35324, from BWL combat log. Only flavour aura text
            -- ("You become arrogant...") in Spell.xlsx.
            name = "Dragon sickness",
            icon = "Interface\\Icons\\INV_Misc_Head_Dragon_Black",
            warning = true,
            lines = {"A debuff (spell 35324) - 'You become arrogant...'. Real effect needs in-game testing."}
        }, {
            -- CHANGED: spell 17131, from BWL combat log - Nefarian lifts off
            -- briefly between phases / positions.
            name = "Hover",
            icon = "Interface\\Icons\\Ability_Hunter_Pet_Dragonhawk",
            lines = {"Nefarian takes to the air briefly - he is untargetable and immune while hovering."}
        }},
        -- CHANGED: bone piles Nefarian raises in phase 2 to walk toward the
        -- raid - logged as source "Bone Construct" (spell "Exploit Weakness"
        -- 8355) in "BWL stuff.csv".
        adds = {{
            key = "bone_construct",
            name = "Bone Construct",
            icon = "Interface\\Icons\\INV_Misc_Bone_HumanSkull_01",
            color = "ffcc6600",
            lines = {"Raised from the bone piles on the floor during phase 2 (the 'Bone Constructs!' shout). Slow-moving; block or kite them off the healers."},
            abilities = {{
                -- CHANGED: spell 8355. Spell.xlsx Description: "Inflicts normal
                -- damage plus $s1 on an enemy, but only if attacking from
                -- behind."
                name = "Exploit Weakness",
                icon = "Interface\\Icons\\Ability_BackStab",
                warning = true,
                lines = {"Hits for normal melee damage plus a bonus when striking from behind - keep it facing the tank."}
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
        icon = "Interface\\Icons\\Ability_Warrior_Cleave",
        flags = {"melee"},
        stats = {armor = 5400, fire = 90, nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {{
            name = "Cleave",
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            roles = {"tank"},
            lines = {"A sweeping attack that strikes its target and nearest ally - avoid clumping melee on it."}
        }, {
            -- CHANGED: spell 25050 (Death Talon Captain, BWL combat log). Text
            -- from Spell.xlsx AuraDescription: "$s1" = EffectBasePoints_1 (999)
            -- + 1 = 1000; DurationIndex 4 = 120s.
            name = "Mark of Flames",
            icon = "Interface\\Icons\\Spell_Fire_Fireball",
            warning = true,
            lines = {"Marks the target, increasing the Fire damage it takes by 1000 for 2 minutes."}
        }, {
            name = "Commanding Shout",
            icon = "Interface\\Icons\\Spell_Magic_MageArmor",
            lines = {"Buffs nearby allies."}
        }}
    },

    death_talon_seether = {
        name = "Death Talon Seether",
        icon = "Interface\\Icons\\Spell_Fire_Fire",
        flags = {"caster"},
        stats = {armor = 4000, fire = "immune", nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {{
            name = "Flame Buffet",
            icon = "Interface\\Icons\\Spell_Fire_Fireball",
            warning = true,
            roles = {"tank"},
            lines = {"Inflicts Fire damage to an enemy and increases the Fire damage it takes - tanks should rotate."}
        }, {
            name = "Frenzy",
            icon = "Interface\\Icons\\Ability_GhoulFrenzy",
            warning = true,
            roles = {"hunter"},
            lines = {"Enrages, attacking faster - remove with Tranquilizing Shot."}
        }, {
            name = "Aura of Flames",
            icon = "Interface\\Icons\\Spell_Fire_Fire",
            lines = {"A passive Fire damage aura affecting nearby enemies."}
        }}
    },

    death_talon_flamescale = {
        name = "Death Talon Flamescale",
        icon = "Interface\\Icons\\Ability_Warrior_Charge",
        flags = {"melee"},
        stats = {armor = 5200, fire = "immune", nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {{
            name = "Flame Shock",
            icon = "Interface\\Icons\\Spell_Fire_FlameShock",
            warning = true,
            roles = {"tank"},
            lines = {"Instantly sears the target with fire, causing Fire damage plus a burn over time."}
        }, {
            name = "Berserker Charge",
            icon = "Interface\\Icons\\Ability_Warrior_Charge",
            warning = true,
            roles = {"tank"},
            lines = {"Charges at an enemy, knocking it back and inflicting damage."}
        }}
    },

    death_talon_wyrmkin = {
        name = "Death Talon Wyrmkin",
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
            icon = "Interface\\Icons\\Spell_Holy_Excorcism_02",
            warning = true,
            lines = {"A wave of flame radiates outward, damaging and dazing nearby enemies."}
        }}
    },

    corrupted_red_whelp = {
        name = "Corrupted Red Whelp",
        icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
        flags = {"caster"},
        stats = {armor = 3200, fire = 90, nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {}
    },

    corrupted_green_whelp = {
        name = "Corrupted Green Whelp",
        icon = "Interface\\Icons\\Spell_Nature_NullifyPoison",
        flags = {"caster"},
        stats = {armor = 3200, fire = 90, nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {}
    },

    corrupted_blue_whelp = {
        name = "Corrupted Blue Whelp",
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
        icon = "Interface\\Icons\\Spell_Nature_TimeStop",
        flags = {"caster"},
        stats = {armor = 3200, fire = 90, nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {}
    },

    death_talon_hatcher = {
        name = "Death Talon Hatcher",
        icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
        flags = {"caster"},
        stats = {armor = 4200, fire = "immune", nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {{
            name = "Flamestrike",
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            warning = true,
            lines = {"Calls down a pillar of fire, burning the area plus an additional burn over time - move out of it."}
        }, {
            name = "Growing Flames",
            icon = "Interface\\Icons\\Spell_Fire_Fire",
            warning = true,
            lines = {"A stacking Fire-damage effect that intensifies over time."}
        }}
    },

    blackwing_taskmaster = {
        name = "Blackwing Taskmaster",
        icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
        flags = {"caster", "healer"},
        stats = {armor = 4200, fire = 90, nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {{
            -- CHANGED: spell 35183 in the BWL combat log. Spell.xlsx: Shadow
            -- damage plus an aura "Healing effects reduced by $s2%" - "$s2" =
            -- EffectBasePoints_2 (-31) + 1 = -30; DurationIndex 7 = 5s.
            name = "Shadow Shock",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            warning = true,
            roles = {"kick"},
            lines = {"Lashes an enemy with dark magic for Shadow damage and reduces healing received on it by 30% for 5 seconds."}
        }, {
            name = "Healing Circle",
            icon = "Interface\\Icons\\Spell_Holy_PrayerOfHealing02",
            lines = {"Heals nearby allies - kill or interrupt to limit its support."}
        }}
    },

    blackwing_warlock = {
        name = "Blackwing Warlock",
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
            icon = "Interface\\Icons\\Spell_Fire_Incinerate",
            warning = true,
            lines = {"Curses the target, causing Fire damage over time."}
        }, {
            name = "Summon Felguard Portal",
            icon = "Interface\\Icons\\Spell_Shadow_SummonFelGuard",
            warning = true,
            lines = {"Opens a portal that summons a Felguard - destroy the portal quickly."}
        }}
    },

    blackwing_technician = {
        name = "Blackwing Technician",
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
            lines = {"Instantly counterattacks any enemy that strikes it in melee - melee should stop attacking while this is active."}
        }, {
            name = "Cleave",
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            roles = {"tank"},
            lines = {"A sweeping attack that strikes its target and nearest ally - avoid clumping melee on it."}
        }}
    },

    blackwing_spellbinder = {
        name = "Blackwing Spellbinder",
        icon = "Interface\\Icons\\Spell_Fire_Fireball",
        flags = {"caster", "immune_spells"},
        stats = {armor = 4200, fire = 90, nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {{
            name = "Arcane Blast",
            icon = "Interface\\Icons\\Spell_Fire_Fireball",
            warning = true,
            roles = {"kick"},
            lines = {"Blasts a target for Arcane damage - priority CC or interrupt target."}
        }, {
            name = "Flamestrike",
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            warning = true,
            lines = {"Calls down a pillar of fire, burning the area plus an additional burn over time - move out of it."}
        }, {
            name = "Greatest Polymorph",
            icon = "Interface\\Icons\\Spell_Nature_Polymorph",
            warning = true,
            lines = {"Transforms a random raid member into a critter for X seconds, unable to act."}
        }}
    },

    death_talon_wyrmguard = {
        name = "Death Talon Wyrmguard",
        icon = "Interface\\Icons\\INV_Misc_MonsterScales_14",
        flags = {"melee"},
        stats = {armor = 5600, fire = 90, nature = 90, frost = 90, shadow = 90, arcane = 90},
        abilities = {{
            name = "Mortal Strike",
            icon = "Interface\\Icons\\Ability_Warrior_SavageBlow",
            warning = true,
            roles = {"tank", "healer"},
            lines = {"A vicious strike that wounds the target, reducing the effectiveness of healing on it."}
        }, {
            name = "War Stomp",
            icon = "Interface\\Icons\\Ability_BullRush",
            warning = true,
            lines = {"Knocks nearby enemies back, stunning them - melee should not clump on it."}
        }, {
            name = "Cleave",
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            roles = {"tank"},
            lines = {"A sweeping attack that strikes its target and nearest ally."}
        }, {
            -- CHANGED: the five Brood Powers below are real spell IDs from the
            -- BWL combat log ("BWL stuff.csv") - the Wyrmguard rolls one at
            -- random and applies it to a raid member (logged with player
            -- targets). Text + numbers from Spell.xlsx AuraDescription with
            -- "$s1" = EffectBasePoints_1 + 1; DurationIndex 32 = 6s (Bronze
            -- uses index 28 = 5s). These are the debuff counterparts of
            -- Chromaggus's "Brood Affliction: <colour>" - see the Chromaggus
            -- entry. Tick interval ($t1 on Red) still unknown.
            separator = true,
            name = "Brood Powers",
            expanded = true,
        }, {
            name = "Brood Power: Black",
            icon = "Interface\\Icons\\Spell_Shadow_CorpseExplode",
            warning = true,
            lines = {"Increases the target's damage taken by 10% for 6 seconds (spell 22560)."}
        }, {
            name = "Brood Power: Blue",
            icon = "Interface\\Icons\\Spell_Frost_FrostBolt02",
            warning = true,
            lines = {"Alters the time between the target's attacks by 100% and drains mana for 6 seconds (spell 22559). In-game sign of the attack-speed change not confirmed."}
        }, {
            name = "Brood Power: Bronze",
            icon = "Interface\\Icons\\Spell_Nature_TimeStop",
            warning = true,
            lines = {"'Caught in a sandstorm' - periodically stops time on the target for 5 seconds (spell 22291)."}
        }, {
            name = "Brood Power: Green",
            icon = "Interface\\Icons\\Spell_Nature_NullifyPoison",
            warning = true,
            lines = {"Periodically stuns the target for 6 seconds (spell 22561)."}
        }, {
            name = "Brood Power: Red",
            icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
            warning = true,
            lines = {"Deals 5% of the target's health as damage every few seconds for 6 seconds (spell 22558)."}
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
