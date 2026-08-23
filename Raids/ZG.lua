-- Part of the DungeonJournal RAIDS database (see AGENTS.md "Data model").
-- Loaded via DungeonJournal.toc before DungeonJournal.lua; appends this
-- raid's table to the shared DungeonJournal_Raids list in load order.

DungeonJournal_Raids = DungeonJournal_Raids or {}

------------------------------------------------------------
-- ZG order list - START HERE to reorder bosses.
--
-- ZG_BOSS_ORDER is the only thing you should need to touch to change
-- what order bosses appear in the Bosses tab. It is just a flat list of
-- keys - actual boss data (icon/flags/stats/abilities/adds) lives
-- further down in ZG_BOSSES, defined once per key and looked up from
-- here.
------------------------------------------------------------

-- Boss encounter order (Bosses tab tree, top to bottom).
local ZG_BOSS_ORDER = {
    "jeklik",
    "venoxis",
    "marli",
    "mandokir",
    "gahzranka",
    "thekal",
    "arlokk",
    "jindo",
    "hakkar",
    "azus",
    "nameless_hermit",
    -- CHANGED: split from one "Edge of Madness" entry into four real
    -- bosses - only one spawns per reset - grouped under this
    -- non-clickable separator label (see AGENTS.md's boss-list separator
    -- syntax) so the tree still reads as one encounter.
    { separator = true, name = "Edge of Madness", color = "ffcc6600" },
    "renataki",
    "grilek",
    "hazzarah",
    "wushoolay",
}

-- CHANGED: trash roster sourced from a real combat log ("ZG Spell GO.csv" -
-- Source/Source GUID/Action/Spell ID columns), cross-matched against
-- Spell.xlsx by exact Spell ID for icons/descriptions. Pull order/grouping
-- is NOT known from that log (it's a flat event list, no pull boundaries),
-- so this is just every distinct mob that logged an ability, in no
-- particular order - see TODO_Raid_Data.md.
-- CHANGED: Ohgan (Mandokir's mount), Shade of Jin'do, and Spawn of Mar'li
-- moved out of trash - they're adds of Mandokir/Jin'do/Mar'li respectively,
-- see those boss entries below. Jungle Toad moved into Hakkari Witch
-- Doctor's "Release Toads" ability as a nested summon. Zealot Lor'Khan and
-- Zealot Zath moved out - they're fought together with Thekal as one
-- encounter, see the thekal boss entry below.
local ZG_TRASH_ORDER = {
    "atalai_mistress",
    "bloodscalp_speaker",
    "bloodseeker_bat",
    "bloodseeker_batrider",
    "gurubashi_axe_thrower",
    "gurubashi_bat_rider",
    "gurubashi_berserker",
    "gurubashi_blood_drinker",
    "gurubashi_champion",
    "gurubashi_headhunter",
    "hakkari_blood_priest",
    "hakkari_priest",
    "hakkari_shadow_hunter",
    "hakkari_shadowcaster",
    "hakkari_witch_doctor",
    "hooktooth_frenzy",
    "mad_servant",
    "razzashi_adder",
    "razzashi_broodwidow",
    "razzashi_cobra",
    "razzashi_raptor",
    "razzashi_serpent",
    "razzashi_skitterer",
    "razzashi_venombrood",
    "sacrificed_troll",
    "skullsplitter_speaker",
    "son_of_hakkar",
    "soulflayer",
    "vilebranch_speaker",
    "voodoo_slave",
    "witherbark_speaker",
    "withered_mistress",
    "zulian_crocolisk",
    "zulian_guardian",
    "zulian_panther",
    "zulian_prowler",
    "zulian_stalker",
    "zulian_tiger",
}

local ZG_TRASH_MOBS = {
    atalai_mistress = {
        name = "Atal'ai Mistress",
        icon = "Interface\\Icons\\Ability_Kick",
        flags = {"melee"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Snap Kick",
            icon = "Interface\\Icons\\Ability_Kick",
            warning = true,
            lines = {"Inflicts 875 to 1125 damage to an enemy, stunning it for 2 seconds."}
        }, {
            name = "Thrash",
            icon = "Interface\\Icons\\Ability_GhoulFrenzy",
            lines = {"Gives the caster 2 extra attacks."}
        }}
    },

    bloodscalp_speaker = {
        name = "Bloodscalp Speaker",
        icon = "Interface\\Icons\\Ability_Gouge",
        flags = {"ranged"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Rend",
            icon = "Interface\\Icons\\Ability_Gouge",
            warning = true,
            lines = {"Wounds the target causing them to bleed for 13 damage over 30 seconds."}
        }, {
            name = "Disarm",
            icon = "Interface\\Icons\\Ability_Warrior_Disarm",
            warning = true,
            lines = {"Disarms an enemy, forcing it to stop wielding its weapon for X seconds."}
        }}
    },

    bloodseeker_bat = {
        name = "Bloodseeker Bat",
        icon = "Interface\\Icons\\Spell_Shadow_Charm",
        flags = {"melee"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Fixate",
            icon = "Interface\\Icons\\Spell_Shadow_Charm",
            lines = {"Causes an enemy to fixate upon the caster and increases the caster's attack speed by 50% for X seconds. While the target is fixated upon the caster, the target is very reluctant to attack anything else."}
        }, {
            name = "Charge",
            icon = "Interface\\Icons\\Ability_Warrior_Charge",
            warning = true,
            lines = {"Charges an enemy, inflicting normal damage plus 1 and stuns the opponent for X seconds."}
        }}
    },

    bloodseeker_batrider = {
        name = "Bloodseeker Batrider",
        icon = "Interface\\Icons\\Spell_Fire_Immolation",
        flags = {"caster"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Flames",
            icon = "Interface\\Icons\\Spell_Fire_Immolation",
            warning = true,
            lines = {"Inflicts 750 Fire damage to nearby enemies."}
        }, {
            name = "Summon Flames",
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 19629 - not reverse-engineered from raw effect codes.
            lines = {"X - no ability description available."}
        }, {
            name = "Throw Liquid Fire",
            icon = "Interface\\Icons\\Spell_Fire_MeteorStorm",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 23970 - not reverse-engineered from raw effect codes.
            lines = {"X - no ability description available."}
        }}
    },

    gurubashi_axe_thrower = {
        name = "Gurubashi Axe Thrower",
        icon = "Interface\\Icons\\INV_Axe_08",
        flags = {"ranged"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Throw Axe",
            icon = "Interface\\Icons\\INV_Axe_08",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 16075 - not reverse-engineered from raw effect codes.
            lines = {"X - no ability description available."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 24018) + SpellDuration.csv lookup - not in-game tested.
            name = "Axe Flurry",
            icon = "Interface\\Icons\\INV_Axe_06",
            lines = {"Attacks nearby enemies in a flurry of axes that lasts 10 seconds."}
        }, {
            name = "Enrage",
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            warning = true,
            lines = {"Increases the caster's attack speed by 60% and the Physical damage it deals by 50 for X seconds."}
        }}
    },

    gurubashi_bat_rider = {
        name = "Gurubashi Bat Rider",
        icon = "Interface\\Icons\\Spell_Shadow_CallofBone",
        flags = {"caster"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Infected Bite",
            icon = "Interface\\Icons\\Spell_Shadow_CallofBone",
            warning = true,
            lines = {"Inflicts Nature damage to an enemy every X sec. and increases the Physical damage it takes for 180 seconds."}
        }, {
            name = "Flames",
            icon = "Interface\\Icons\\Spell_Fire_Immolation",
            warning = true,
            lines = {"Inflicts 750 Fire damage to nearby enemies."}
        }, {
            name = "Summon Flames",
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 19629 - not reverse-engineered from raw effect codes.
            lines = {"X - no ability description available."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Demoralizing Shout",
            icon = "Interface\\Icons\\Ability_Warrior_WarCry",
            lines = {"Reduces the attack power of nearby enemies by 42 for 30 seconds."}
        }, {
            name = "Throw Liquid Fire",
            icon = "Interface\\Icons\\Spell_Fire_MeteorStorm",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 23970 - not reverse-engineered from raw effect codes.
            lines = {"X - no ability description available."}
        }, {
            name = "Unstable Concoction",
            icon = "Interface\\Icons\\Spell_Fire_Incinerate",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24024 - not reverse-engineered from raw effect codes.
            lines = {"X - no ability description available."}
        }, {
            name = "Thrash",
            icon = "Interface\\Icons\\Ability_GhoulFrenzy",
            lines = {"Gives the caster 2 extra attacks."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 5115) + SpellDuration.csv lookup - not in-game tested.
            name = "Battle Command",
            icon = "Interface\\Icons\\Ability_Racial_BloodRage",
            lines = {"Increases the attack speed of nearby allies by 50% for 6 seconds."}
        }}
    },

    gurubashi_berserker = {
        name = "Gurubashi Berserker",
        icon = "Interface\\Icons\\INV_Gauntlets_05",
        flags = {"melee"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Knock Away",
            icon = "Interface\\Icons\\INV_Gauntlets_05",
            warning = true,
            lines = {"Inflicts normal damage plus 30 to nearby enemies and knocks them back."}
        }, {
            name = "Sweeping Strikes",
            icon = "Interface\\Icons\\Ability_Rogue_SliceDice",
            lines = {"Your next X melee weapon swings strike an additional nearby opponent."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Thunderclap",
            icon = "Interface\\Icons\\Spell_Nature_ThunderClap",
            warning = true,
            lines = {"Inflicts 71 to 79 Nature damage to nearby enemies, increasing the time between their attacks by 35% and slowing their movement by 42% for 10 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 16508) + SpellDuration.csv lookup - not in-game tested.
            name = "Intimidating Roar",
            icon = "Interface\\Icons\\Ability_GolemThunderClap",
            warning = true,
            lines = {"Roars at an enemy, paralyzing it with terror for 8 seconds. and causing all other nearby enemies to flee in fear."}
        }, {
            name = "Enrage",
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            warning = true,
            lines = {"Increases the caster's attack speed by 60% and the Physical damage it deals by 50 for X seconds."}
        }}
    },

    gurubashi_blood_drinker = {
        name = "Gurubashi Blood Drinker",
        icon = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
        flags = {"melee"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Drain Life",
            icon = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
            warning = true,
            lines = {"Drains 1 health from an enemy over X seconds., transferring it to the caster."}
        }, {
            name = "Blood Leech",
            icon = "Interface\\Icons\\Ability_Racial_Cannibalize",
            warning = true,
            lines = {"Drains 340 to 414 health from nearby enemies, healing the caster for up to three times the amount stolen."}
        }}
    },

    gurubashi_champion = {
        name = "Gurubashi Champion",
        icon = "Interface\\Icons\\Ability_Warrior_ShieldWall",
        flags = {"melee"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Shield Wall",
            icon = "Interface\\Icons\\Ability_Warrior_ShieldWall",
            warning = true,
            lines = {"Reduces the Physical and magical damage taken by the caster by 77% for X seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Shield Slam",
            icon = "Interface\\Icons\\Ability_Warrior_ShieldBash",
            warning = true,
            lines = {"Inflicts 100 to 300 damage to an enemy, stunning it for 2 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Shield Reflection",
            icon = "Interface\\Icons\\Ability_Warrior_ShieldReflection",
            lines = {"Raise your shield, reflecting spell cast on you. Lasts 5 seconds, but will only reflect X effects."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Shield Toss",
            icon = "Interface\\Icons\\Ability_UpgradeMoonGlaive",
            warning = true,
            lines = {"Hurls a shield at the enemy, causing 308 to 348 damage, increased by Attack Power and knocks down for 2 seconds. This ability causes a high amount of threat."}
        }, {
            name = "Defensive Stance",
            icon = "Interface\\Icons\\Ability_Warrior_DefensiveStance",
            warning = true,
            lines = {"A defensive combat stance that decreases damage taken by X% and damage caused by X%. Increases threat generated by X%."}
        }}
    },

    gurubashi_headhunter = {
        name = "Gurubashi Headhunter",
        icon = "Interface\\Icons\\Ability_Hunter_AimedShot",
        flags = {"ranged"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Viper Sting",
            icon = "Interface\\Icons\\Ability_Hunter_AimedShot",
            warning = true,
            lines = {"Stings the target, draining 60 mana over 15 seconds. Only one Sting per Hunter can be active on any one target."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Mortal Strike",
            icon = "Interface\\Icons\\Ability_Warrior_SavageBlow",
            warning = true,
            lines = {"Inflicts 300% weapon damage and leaves the target wounded, reducing the effectiveness of any healing by 52% for 5 seconds."}
        }, {
            name = "Throw",
            icon = "Interface\\Icons\\Ability_Throw",
            warning = true,
            lines = {"Throws a weapon at an enemy, inflicting Physical damage."}
        }, {
            name = "Whirling Trip",
            icon = "Interface\\Icons\\INV_Spear_05",
            warning = true,
            lines = {"Inflicts normal damage plus 50 to nearby enemies."}
        }}
    },

    hakkari_blood_priest = {
        name = "Hakkari Blood Priest",
        icon = "Interface\\Icons\\Spell_Holy_DispelMagic",
        flags = {"melee"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Dispel Magic",
            icon = "Interface\\Icons\\Spell_Holy_DispelMagic",
            lines = {"Dispels magic on an ally, removing 1 harmful effects."}
        }, {
            name = "Poisonous Blood",
            icon = "Interface\\Icons\\Spell_Nature_Regenerate",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24321 - not reverse-engineered from raw effect codes.
            lines = {"X - no ability description available."}
        }, {
            name = "Blood Funnel",
            icon = "Interface\\Icons\\Spell_Shadow_LifeDrain",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24617 - not reverse-engineered from raw effect codes.
            lines = {"X - no ability description available."}
        }, {
            name = "Drain Life",
            icon = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
            warning = true,
            lines = {"Drains 400 health from an enemy over X seconds., transferring it to the caster."}
        }}
    },

    hakkari_priest = {
        name = "Hakkari Priest",
        icon = "Interface\\Icons\\Spell_Shadow_PsychicScream",
        flags = {"caster"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Psychic Scream",
            icon = "Interface\\Icons\\Spell_Shadow_PsychicScream",
            warning = true,
            lines = {"Lets out a psychic scream, causing up to X nearby enemies to flee for X seconds."}
        }, {
            name = "Anti-Magic Shield",
            icon = "Interface\\Icons\\Spell_Shadow_AntiMagicShell",
            lines = {"Creates an anti-magic shell around the caster, giving it magic immunity for X seconds."}
        }, {
            name = "Cleanse Nova",
            icon = "Interface\\Icons\\Spell_Holy_HolyBolt",
            warning = true,
            roles = {"kick"},
            lines = {"Causes an explosion of divine light, inflicting 1 Holy damage to nearby enemies and reducing the caster's threat level for X seconds."}
        }, {
            name = "Psychic Scream",
            icon = "Interface\\Icons\\Spell_Shadow_PsychicScream",
            warning = true,
            lines = {"Lets out a psychic scream, causing up to X nearby enemies to flee for X seconds."}
        }}
    },

    hakkari_shadow_hunter = {
        name = "Hakkari Shadow Hunter",
        icon = "Interface\\Icons\\Ability_Marksmanship",
        flags = {"caster"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Volley",
            icon = "Interface\\Icons\\Ability_Marksmanship",
            warning = true,
            lines = {"Continuously fires a volley of ammo at the target area, causing 800 to 850 Arcane damage to enemy targets within X yards yards every second for X seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 24335) + SpellDuration.csv lookup - not in-game tested.
            name = "Wyvern Sting",
            icon = "Interface\\Icons\\INV_Spear_02",
            warning = true,
            lines = {"A stinging shot that puts the target to sleep for 12 seconds. Any damage will cancel the effect. When the target wakes up, the Sting causes X Nature damage over X."}
        }}
    },

    hakkari_shadowcaster = {
        name = "Hakkari Shadowcaster",
        icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
        flags = {"caster"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Shadow Bolt Volley",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            warning = true,
            roles = {"kick"},
            lines = {"Hurls missiles of dark magic, inflicting Shadow damage to nearby enemies."}
        }, {
            name = "Shadow Nova",
            icon = "Interface\\Icons\\Spell_Shadow_ShadeTrueSight",
            warning = true,
            lines = {"Causes an explosion of Shadow around the caster, causing 500 to 750 Shadow damage to all enemy targets within X yards yards and healing all party members within X yards for X."}
        }, {
            name = "Shadow Nova",
            icon = "Interface\\Icons\\Spell_Shadow_ShadeTrueSight",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 34874 - not reverse-engineered from raw effect codes.
            lines = {"X - no ability description available."}
        }, {
            name = "Shadow Bolt",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            warning = true,
            roles = {"kick"},
            lines = {"Hurls a bolt of dark magic at an enemy, inflicting Shadow damage."}
        }}
    },

    hakkari_witch_doctor = {
        name = "Hakkari Witch Doctor",
        icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
        flags = {"caster"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Shadow Shock",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            warning = true,
            roles = {"kick"},
            lines = {"Instantly lashes an enemy with dark magic, inflicting Shadow damage."}
        }, {
            name = "Hex",
            icon = "Interface\\Icons\\Spell_Nature_Polymorph",
            warning = true,
            lines = {"Transforms an enemy into a frog, rendering it unable to attack or cast spells for X seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Shrink",
            icon = "Interface\\Icons\\Spell_Shadow_AntiShadow",
            lines = {"Reduces nearby enemies' Strength by 202 and Stamina by 102 for 120 seconds."}
        }, {
            -- CHANGED: summons a Jungle Toad - moved out of trash and
            -- nested here since it's this mob's summon, not a standalone
            -- pull.
            name = "Release Toads",
            icon = "Interface\\Icons\\INV_Misc_Eye_01",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24058 - not reverse-engineered from raw effect codes.
            lines = {"X - no ability description available. Summons a Jungle Toad."},
            abilities = {{
                name = "Jungle Toad - Disease Cloud",
                icon = "Interface\\Icons\\Spell_Nature_AbolishMagic",
                -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24063 - not reverse-engineered from raw effect codes.
                lines = {"X - no ability description available."}
            }}
        }, {
            name = "Toad Explode",
            icon = "Interface\\Icons\\Spell_Nature_AbolishMagic",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24062 - not reverse-engineered from raw effect codes.
            lines = {"X - no ability description available."}
        }, {
            name = "Toad Explode",
            icon = "Interface\\Icons\\Spell_Nature_AbolishMagic",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24065 - not reverse-engineered from raw effect codes.
            lines = {"X - no ability description available."}
        }}
    },

    hooktooth_frenzy = {
        name = "Hooktooth Frenzy",
        icon = "Interface\\Icons\\Temp",
        flags = {"melee"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Hooktooth Frenzy's Ability",
            icon = "Interface\\Icons\\Temp",
            lines = {"Placeholder. No offensive abilities were captured in the log for this mob."}
        }}
    },

    mad_servant = {
        name = "Mad Servant",
        icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
        flags = {"caster"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Fireball",
            icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
            warning = true,
            roles = {"kick"},
            lines = {"Inflicts Fire damage to an enemy."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Flamestrike",
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            warning = true,
            roles = {"kick"},
            lines = {"Calls down a pillar of flame, burning all enemies in a selected area and inflicting additional damage every X sec. for 8 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 24621) + SpellDuration.csv lookup - not in-game tested.
            name = "Portal of Madness",
            icon = "Interface\\Icons\\Spell_Arcane_TeleportOrgrimmar",
            lines = {"Opens a portal into the Twisting Nether that periodically summons demonic minions to aid the caster in battle for 14 seconds."}
        }}
    },

    razzashi_adder = {
        name = "Razzashi Adder",
        icon = "Interface\\Icons\\Spell_Nature_CorrosiveBreath",
        flags = {"caster"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Venom Spit",
            icon = "Interface\\Icons\\Spell_Nature_CorrosiveBreath",
            warning = true,
            lines = {"Spits poison at an enemy, inflicting Nature damage, then additional damage every X sec. for X seconds."}
        }, {
            name = "Thrash",
            icon = "Interface\\Icons\\Ability_GhoulFrenzy",
            lines = {"Gives the caster 2 extra attacks."}
        }}
    },

    razzashi_broodwidow = {
        name = "Razzashi Broodwidow",
        icon = "Interface\\Icons\\Ability_Creature_Disease_02",
        flags = {"melee"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Summon Razzashi Skitterer",
            icon = "Interface\\Icons\\Ability_Creature_Disease_02",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24598 - not reverse-engineered from raw effect codes.
            lines = {"X - no ability description available."}
        }, {
            name = "Web Spin",
            icon = "Interface\\Icons\\Spell_Nature_EarthBind",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24600 - not reverse-engineered from raw effect codes.
            lines = {"X - no ability description available."}
        }, {
            name = "Intoxication",
            icon = "Interface\\Icons\\Ability_Poisons",
            roles = {"dispel"},
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 34422 - not reverse-engineered from raw effect codes.
            lines = {"X - no ability description available."}
        }}
    },

    razzashi_cobra = {
        name = "Razzashi Cobra",
        icon = "Interface\\Icons\\Spell_Nature_CorrosiveBreath",
        flags = {"caster"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Spit",
            icon = "Interface\\Icons\\Spell_Nature_CorrosiveBreath",
            warning = true,
            lines = {"Shoots at an enemy, inflicting Nature damage."}
        }, {
            name = "Poison Cloud",
            icon = "Interface\\Icons\\Spell_Nature_NatureTouchDecay",
            warning = true,
            lines = {"Inflicts 575 Nature damage to nearby enemies every X sec. for X seconds."}
        }, {
            name = "Poison Cloud",
            icon = "Interface\\Icons\\Temp",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 34878 - not reverse-engineered from raw effect codes.
            lines = {"X - no ability description available."}
        }, {
            name = "Poison",
            icon = "Interface\\Icons\\Spell_Nature_CorrosiveBreath",
            warning = true,
            lines = {"Inflicts Nature damage to an enemy every X sec. for X seconds."}
        }}
    },

    razzashi_raptor = {
        name = "Razzashi Raptor",
        icon = "Interface\\Icons\\Ability_Warrior_Sunder",
        flags = {"caster"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Sunder Armor",
            icon = "Interface\\Icons\\Ability_Warrior_Sunder",
            lines = {"Hacks at an enemy's armor, reducing it by 1002 per Sunder Armor. Can be applied up to 5 times. Lasts X seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Infected Bite",
            icon = "Interface\\Icons\\Spell_Shadow_CallofBone",
            warning = true,
            lines = {"Inflicts Nature damage to an enemy every X sec. and increases the Physical damage it takes for 180 seconds."}
        }, {
            name = "Thrash",
            icon = "Interface\\Icons\\Ability_GhoulFrenzy",
            lines = {"Adds a chance to do two additional attacks"}
        }}
    },

    razzashi_serpent = {
        name = "Razzashi Serpent",
        icon = "Interface\\Icons\\Spell_Shadow_VampiricAura",
        flags = {"melee"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Pierce Armor",
            icon = "Interface\\Icons\\Spell_Shadow_VampiricAura",
            lines = {"Reduces an enemy's armor by 77% for 20 seconds."}
        }, {
            name = "Tranquilizing Poison",
            icon = "Interface\\Icons\\Ability_Creature_Poison_03",
            roles = {"dispel"},
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24002 - not reverse-engineered from raw effect codes.
            lines = {"X - no ability description available."}
        }}
    },

    razzashi_skitterer = {
        name = "Razzashi Skitterer",
        icon = "Interface\\Icons\\Temp",
        flags = {"melee"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Razzashi Skitterer's Ability",
            icon = "Interface\\Icons\\Temp",
            lines = {"Placeholder. No offensive abilities were captured in the log for this mob."}
        }}
    },

    razzashi_venombrood = {
        name = "Razzashi Venombrood",
        icon = "Interface\\Icons\\Ability_Creature_Poison_01",
        flags = {"melee"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Intoxicating Venom",
            icon = "Interface\\Icons\\Ability_Creature_Poison_01",
            roles = {"dispel"},
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24596 - not reverse-engineered from raw effect codes.
            lines = {"X - no ability description available."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Slowing Poison",
            icon = "Interface\\Icons\\Spell_Nature_SlowPoison",
            warning = true,
            roles = {"dispel"},
            lines = {"Increases the time between an enemy's attacks by 27% and slows its movement by 32% for 25 seconds."}
        }}
    },

    sacrificed_troll = {
        name = "Sacrificed Troll",
        icon = "Interface\\Icons\\Spell_Shadow_UnsummonBuilding",
        flags = {"melee"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Touch of Death",
            icon = "Interface\\Icons\\Spell_Shadow_UnsummonBuilding",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 34896 - not reverse-engineered from raw effect codes.
            lines = {"X - no ability description available."}
        }}
    },

    skullsplitter_speaker = {
        name = "Skullsplitter Speaker",
        icon = "Interface\\Icons\\INV_Spear_05",
        flags = {"ranged"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Whirling Trip",
            icon = "Interface\\Icons\\INV_Spear_05",
            warning = true,
            lines = {"Inflicts normal damage plus 50 to nearby enemies."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Head Crack",
            icon = "Interface\\Icons\\Ability_ThunderBolt",
            lines = {"Reduces an enemy's Stamina by 3 for 20 seconds."}
        }}
    },

    son_of_hakkar = {
        name = "Son of Hakkar",
        icon = "Interface\\Icons\\Ability_GolemThunderClap",
        flags = {"melee"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Knockdown",
            icon = "Interface\\Icons\\Ability_GolemThunderClap",
            warning = true,
            lines = {"Inflicts 60 to 80 damage to an enemy and its nearest allies, stunning them for 2 seconds. Affects up to X targets."}
        }, {
            name = "Poisonous Blood",
            icon = "Interface\\Icons\\Ability_PoisonSting",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24320 - not reverse-engineered from raw effect codes.
            lines = {"X - no ability description available."}
        }, {
            name = "Thrash",
            icon = "Interface\\Icons\\Ability_GhoulFrenzy",
            lines = {"Gives the caster 2 extra attacks."}
        }}
    },

    soulflayer = {
        name = "Soulflayer",
        icon = "Interface\\Icons\\Spell_Shadow_Possession",
        flags = {"caster"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Fear",
            icon = "Interface\\Icons\\Spell_Shadow_Possession",
            warning = true,
            lines = {"Strikes fear in an enemy, causing it to flee in terror for X seconds. Only 1 target can be feared at a time."}
        }, {
            name = "Soul Tap",
            icon = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24619 - not reverse-engineered from raw effect codes.
            lines = {"X - no ability description available."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 30112) + SpellDuration.csv lookup - not in-game tested.
            name = "Frenzied Dive",
            icon = "Interface\\Icons\\Ability_Hunter_Pet_Bat",
            warning = true,
            lines = {"Dives upon an enemy, inflicting normal damage plus 2 and stuns the opponent for 2 seconds."}
        }, {
            name = "Thrash",
            icon = "Interface\\Icons\\Ability_GhoulFrenzy",
            lines = {"Gives the caster 2 extra attacks."}
        }, {
            name = "Hate to Zero(Reset)",
            icon = "Interface\\Icons\\Temp",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 34518 - not reverse-engineered from raw effect codes.
            lines = {"X - no ability description available."}
        }, {
            name = "Enrage",
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            warning = true,
            lines = {"Increases the caster's attack speed by 60% and the Physical damage it deals by 50 for X seconds."}
        }}
    },

    vilebranch_speaker = {
        name = "Vilebranch Speaker",
        icon = "Interface\\Icons\\Ability_Warrior_WarCry",
        flags = {"ranged"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Demoralizing Shout",
            icon = "Interface\\Icons\\Ability_Warrior_WarCry",
            lines = {"Reduces the melee attack power of nearby enemies by 12 for 30 seconds."}
        }, {
            name = "Enrage",
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 8599 - not reverse-engineered from raw effect codes.
            lines = {"X - no ability description available."}
        }}
    },

    voodoo_slave = {
        name = "Voodoo Slave",
        icon = "Interface\\Icons\\Spell_Shadow_ChillTouch",
        flags = {"caster"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Curse of the Elements",
            icon = "Interface\\Icons\\Spell_Shadow_ChillTouch",
            warning = true,
            roles = {"dispel"},
            lines = {"Curses the target for 60 seconds, reducing Fire, Frost and Nature resistances by 82 and increasing Fire, Frost and Nature damage taken by 10%. Only one Curse per Warlock can be active on any one target."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Curse of Shadow",
            icon = "Interface\\Icons\\Spell_Shadow_CurseOfAchimonde",
            warning = true,
            roles = {"dispel"},
            lines = {"Curses the target for 60 seconds, reducing Shadow and Arcane resistances by 82 and increasing Shadow and Arcane damage taken by 10%. Only one Curse per Warlock can be active on any one target."}
        }, {
            name = "Shadow Bolt",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            warning = true,
            roles = {"kick"},
            lines = {"Hurls a bolt of dark magic at an enemy, inflicting Shadow damage."}
        }, {
            name = "Rain of Fire",
            icon = "Interface\\Icons\\Spell_Shadow_RainOfFire",
            warning = true,
            roles = {"kick"},
            lines = {"Calls down a molten rain, burning all enemies in a selected area for 775 Fire damage every X sec. for X seconds."}
        }, {
            name = "Inferno",
            icon = "Interface\\Icons\\Spell_Shadow_SummonInfernal",
            warning = true,
            lines = {"Summons a meteor from the Twisting Nether, causing X Fire damage and stunning all enemy targets in the area for X."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Death Coil",
            icon = "Interface\\Icons\\Spell_Shadow_DeathCoil",
            warning = true,
            lines = {"Causes the enemy target to run in horror for 3 seconds and causes 920 Shadow damage. The caster gains 100% of the damage caused in health."}
        }}
    },

    witherbark_speaker = {
        name = "Witherbark Speaker",
        icon = "Interface\\Icons\\Spell_Nature_EarthShock",
        flags = {"caster"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Earth Shock",
            icon = "Interface\\Icons\\Spell_Nature_EarthShock",
            warning = true,
            roles = {"kick"},
            lines = {"Instantly shocks the target with concussive force, causing 517 to 545 Nature damage. It also interrupts spellcasting and prevents any spell in that school from being cast for X seconds. Causes a high amount of threat."}
        }, {
            name = "Lightning Bolt",
            icon = "Interface\\Icons\\Spell_Nature_Lightning",
            warning = true,
            roles = {"kick"},
            lines = {"Blasts an enemy with lightning, inflicting Nature damage."}
        }}
    },

    withered_mistress = {
        name = "Withered Mistress",
        icon = "Interface\\Icons\\Spell_Nature_Polymorph",
        flags = {"caster"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Hex",
            icon = "Interface\\Icons\\Spell_Nature_Polymorph",
            warning = true,
            lines = {"Transforms an enemy into a frog, rendering it unable to attack or cast spells for X seconds."}
        }, {
            name = "Dispel Magic",
            icon = "Interface\\Icons\\Spell_Holy_DispelMagic",
            lines = {"Dispels magic on an ally, removing 1 harmful effects."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Unholy Frenzy",
            icon = "Interface\\Icons\\Spell_Nature_BloodLust",
            warning = true,
            roles = {"dispel"},
            lines = {"Increases an ally's attack speed by 50% for 20 seconds., but also inflicts 200 Nature damage to that ally every X sec."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Curse of Blood",
            icon = "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice",
            warning = true,
            roles = {"dispel"},
            lines = {"Increases the Physical damage taken by an enemy by 500 for 600 seconds."}
        }, {
            name = "Veil of Shadow",
            icon = "Interface\\Icons\\Spell_Shadow_GatherShadows",
            roles = {"dispel"},
            lines = {"Reduces healing effects for an enemy by 77% for X seconds."}
        }}
    },

    zulian_crocolisk = {
        name = "Zulian Crocolisk",
        icon = "Interface\\Icons\\Ability_Gouge",
        flags = {"melee"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell 19771) + SpellDuration.csv lookup - not in-game tested.
            name = "Serrated Bite",
            icon = "Interface\\Icons\\Ability_Gouge",
            warning = true,
            lines = {"Inflicts 50 Physical damage to an enemy over 30 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 3604) + SpellDuration.csv lookup - not in-game tested.
            name = "Tendon Rip",
            icon = "Interface\\Icons\\Ability_CriticalStrike",
            lines = {"Reduces an enemy's movement speed by 27% for 8 seconds."}
        }}
    },

    zulian_guardian = {
        name = "Zulian Guardian",
        icon = "Interface\\Icons\\Ability_Druid_Rake",
        flags = {"melee"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Claw",
            icon = "Interface\\Icons\\Ability_Druid_Rake",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24187 - not reverse-engineered from raw effect codes.
            lines = {"X - no ability description available."}
        }}
    },

    zulian_panther = {
        name = "Zulian Panther",
        icon = "Interface\\Icons\\Ability_Druid_Disembowel",
        flags = {"melee"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Rake",
            icon = "Interface\\Icons\\Ability_Druid_Disembowel",
            warning = true,
            lines = {"Rake the target for 32 to 48 damage and an additional 195 to 245 damage over X seconds."}
        }, {
            name = "Ravage",
            icon = "Interface\\Icons\\Ability_GhoulFrenzy",
            warning = true,
            lines = {"Inflicts normal damage plus 3 to an enemy, stunning it for X seconds."}
        }}
    },

    zulian_prowler = {
        name = "Zulian Prowler",
        icon = "Interface\\Icons\\Ability_GhoulFrenzy",
        flags = {"melee"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Thrash",
            icon = "Interface\\Icons\\Ability_GhoulFrenzy",
            lines = {"Gives the caster 2 extra attacks."}
        }}
    },

    zulian_stalker = {
        name = "Zulian Stalker",
        icon = "Interface\\Icons\\Ability_Rogue_Ambush",
        flags = {"melee"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Ambush",
            icon = "Interface\\Icons\\Ability_Rogue_Ambush",
            warning = true,
            lines = {"Inflicts 400% weapon damage to wounded enemy."}
        }}
    },

    zulian_tiger = {
        name = "Zulian Tiger",
        icon = "Interface\\Icons\\Ability_Druid_Disembowel",
        flags = {"melee"},
        -- CHANGED: from a real combat log ("ZG Spell GO.csv") - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Rake",
            icon = "Interface\\Icons\\Ability_Druid_Disembowel",
            warning = true,
            lines = {"Rake the target for 32 to 48 damage and an additional 195 to 245 damage over X seconds."}
        }, {
            name = "Ravage",
            icon = "Interface\\Icons\\Ability_GhoulFrenzy",
            warning = true,
            lines = {"Inflicts normal damage plus 3 to an enemy, stunning it for X seconds."}
        }}
    },

}

------------------------------------------------------------
-- Boss registry - one entry per boss (icon/flags/stats/abilities/adds),
-- referenced by key from ZG_BOSS_ORDER above. Defined once each; add a
-- new boss here and add its key to ZG_BOSS_ORDER to place it.
------------------------------------------------------------
local ZG_BOSSES = {
    jeklik = {
        name = "High Priestess Jeklik",
        icon = "Interface\\Icons\\temp",
        stats = {armor = 4222, fire = 92, nature = 92, frost = 27, shadow = 92, arcane = 27},
        abilities = {{
            name = "Sonic Burst",
            icon = "Interface\\Icons\\Spell_Shadow_Teleport",
            warning = true,
            roles = {"kick"},
            lines = {"Inflicts around 1950 damage to nearby enemies and prevents them from casting spells. Her most frequent ability."}
        }, {
            name = "Swoop",
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            warning = true,
            roles = {"tank"},
            lines = {"Inflicts 500 damage in a cone in front of her and stuns the targets."}
        }, {
            name = "Terrifying Screech",
            icon = "Interface\\Icons\\Spell_Shadow_DeathScream",
            warning = true,
            roles = {"shaman"},
            lines = {"Fears nearby enemies. Keep a Tremor Totem down."}
        }, {
            name = "Curse of Blood",
            icon = "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice",
            warning = true,
            roles = {"decurse"},
            lines = {"Increases Physical damage taken by 500. Decurse the tanks."}
        }, {
            name = "Charge",
            icon = "Interface\\Icons\\Ability_Warrior_Charge",
            lines = {"Charges a distant target."}
        }}
    },

    venoxis = {
        name = "High Priest Venoxis",
        icon = "Interface\\Icons\\temp",
        flags = {"damage_nature"},
        stats = {armor = 4691, fire = 23, nature = 270, frost = 23, shadow = 23, arcane = 23},
        abilities = {{
            name = "Holy Wrath",
            icon = "Interface\\Icons\\Spell_Shadow_SiphonMana",
            warning = true,
            lines = {"His second most frequent ability. Chains to nearby targets."}
        }, {
            name = "Holy Smite",
            icon = "Interface\\Icons\\Spell_Holy_HolySmite",
            roles = {"kick"},
            lines = {"Smites a target for Holy damage. His most frequent cast."}
        }, {
            name = "Holy Nova",
            icon = "Interface\\Icons\\Spell_Holy_HolyNova",
            warning = true,
            lines = {"AoE Holy damage to everyone nearby."}
        }, {
            name = "Venom Spit",
            icon = "Interface\\Icons\\Spell_Nature_CorrosiveBreath",
            warning = true,
            roles = {"poison"},
            lines = {"Spits poison at nearby enemies for 850 Nature damage plus 200 Nature damage every 5 seconds."}
        }, {
            name = "Poison Cloud",
            icon = "Interface\\Icons\\Spell_Nature_NatureTouchDecay",
            warning = true,
            lines = {"Inflicts 575 Nature damage every second and slows movement by 50%. Move out of the cloud."}
        }, {
            name = "Dispel Magic",
            icon = "Interface\\Icons\\Spell_Holy_DispelMagic",
            lines = {"Venoxis dispels magic from himself, removing your debuffs."}
        }}
    },

    marli = {
        name = "High Priestess Mar'li",
        icon = "Interface\\Icons\\temp",
        flags = {"damage_nature"},
        stats = {armor = 4880, fire = 7, nature = 126, frost = 24, shadow = 126, arcane = 126},
        abilities = {{
            name = "Poison Bolt Volley",
            icon = "Interface\\Icons\\Ability_Poisons",
            warning = true,
            roles = {"poison"},
            lines = {"Her most frequent ability by far - a volley of poison bolts hitting multiple targets."}
        }, {
            name = "Enveloping Webs",
            icon = "Interface\\Icons\\Spell_Nature_EarthBind",
            warning = true,
            lines = {"Immobilises the target, increases the time between their attacks, and prevents casting."}
        }, {
            name = "Corrosive Poison",
            icon = "Interface\\Icons\\Spell_Nature_CorrosiveBreath",
            warning = true,
            roles = {"poison", "tank"},
            lines = {"Reduces armour by 9000 and inflicts 2660 Nature damage every 5 seconds. Cleanse from the tank immediately."}
        }, {
            name = "Enlarge",
            icon = "Interface\\Icons\\Spell_Nature_Strength",
            lines = {"Buffs an ally, increasing their Physical damage by 50."}
        }, {
            name = "Charge",
            icon = "Interface\\Icons\\Ability_Warrior_Charge",
            lines = {"Charges a distant target."}
        }},
        -- CHANGED: Spawn of Mar'li moved out of trash - it's her add.
        adds = {{
            name = "Spawn of Mar'li",
            icon = "Interface\\Icons\\Spell_Holy_InnerFire",
            lines = {"An add summoned during the Mar'li encounter."},
            abilities = {{
                name = "Level Up",
                icon = "Interface\\Icons\\Spell_Holy_InnerFire",
                -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24312 - not reverse-engineered from raw effect codes.
                lines = {"X - no ability description available."}
            }}
        }}
    },

    mandokir = {
        name = "Bloodlord Mandokir",
        icon = "Interface\\Icons\\temp",
        stats = {armor = 4950, fire = 44, nature = 75, frost = 12, shadow = 44, arcane = 44},
        abilities = {{
            name = "Whirlwind",
            icon = "Interface\\Icons\\Ability_Whirlwind",
            warning = true,
            roles = {"melee"},
            lines = {"Spins in a whirlwind, hitting all nearby enemies. His most frequent ability."}
        }, {
            name = "Threatening Gaze",
            icon = "Interface\\Icons\\Ability_Hunter_AspectMastery",
            warning = true,
            lines = {"Mandokir watches a target closely - they must STOP ALL ACTIONS or they will pull aggro and be killed."}
        }, {
            name = "Charge",
            icon = "Interface\\Icons\\Ability_Warrior_Charge",
            warning = true,
            lines = {"Charges a distant target, dealing heavy damage."}
        }, {
            name = "Mortal Strike",
            icon = "Interface\\Icons\\Ability_Warrior_SavageBlow",
            roles = {"tank", "healer"},
            lines = {"A heavy strike that reduces healing received."}
        }, {
            name = "Intimidating Shout",
            icon = "Interface\\Icons\\Ability_GolemThunderClap",
            warning = true,
            lines = {"Fears enemies near the target."}
        }},
        -- CHANGED: Ohgan is Mandokir's mount - moved out of trash and
        -- listed here as an add for now (a real second-boss relationship,
        -- but the addon doesn't yet have a way to model "fought together as
        -- one encounter" for a boss + its own mount the way it does for
        -- Thekal's zealots - see TODO_Raid_Data.md).
        adds = {{
            name = "Ohgan",
            icon = "Interface\\Icons\\Ability_Warrior_Sunder",
            lines = {"Bloodlord Mandokir's mount - a second boss fought alongside him in this encounter."},
            abilities = {{
                name = "Sunder Armor",
                icon = "Interface\\Icons\\Ability_Warrior_Sunder",
                lines = {"Hacks at an enemy's armor, reducing it by 1002 per Sunder Armor. Can be applied up to 5 times. Lasts X seconds."}
            }, {
                name = "Charge",
                icon = "Interface\\Icons\\Ability_Warrior_Charge",
                warning = true,
                lines = {"Charges an enemy, inflicting normal damage plus 2 and stuns the opponent for X seconds."}
            }, {
                name = "Thrash",
                icon = "Interface\\Icons\\Ability_GhoulFrenzy",
                lines = {"Gives the caster 2 extra attacks."}
            }}
        }}
    },

    -- CHANGED: split out of a single "Edge of Madness" entry into four
    -- real top-level bosses (only one spawns per reset) - see the
    -- "Edge of Madness" separator in ZG_BOSS_ORDER above. Splitting gives
    -- each one real stats/adds support and lets Broadcast/Tactics work on
    -- whichever one actually spawned, instead of a nested ability-shaped
    -- entry that BuildAbilityLines can't see into.
    renataki = {
        name = "Renataki",
        icon = "Interface\\Icons\\Ability_Rogue_Ambush",
        abilities = {{
            name = "Thousand Blades",
            icon = "Interface\\Icons\\Ability_Whirlwind",
            warning = true,
            lines = {"A deadly blade storm."}
        }, {
            name = "Gouge",
            icon = "Interface\\Icons\\Ability_Gouge",
            warning = true,
            roles = {"tank"},
            lines = {"Incapacitates the target."}
        }, {
            name = "Ambush",
            icon = "Interface\\Icons\\Ability_Rogue_Ambush",
            warning = true,
            lines = {"Stealths and ambushes a target for heavy damage."}
        }}
    },

    grilek = {
        name = "Gri'lek",
        icon = "Interface\\Icons\\Ability_WarStomp",
        abilities = {{
            name = "Sweeping Strikes",
            icon = "Interface\\Icons\\Ability_Rogue_SliceDice",
            warning = true,
            lines = {"His most frequent ability - his next strikes hit additional targets."}
        }, {
            name = "Entangling Roots",
            icon = "Interface\\Icons\\Spell_Nature_StrangleVines",
            warning = true,
            lines = {"Roots a target in place."}
        }, {
            name = "Ground Tremor",
            icon = "Interface\\Icons\\Ability_WarStomp",
            warning = true,
            lines = {"Damages and stuns nearby enemies."}
        }}
    },

    hazzarah = {
        name = "Hazza'rah",
        icon = "Interface\\Icons\\Spell_Nature_Sleep",
        abilities = {{
            name = "Earth Shock",
            icon = "Interface\\Icons\\Spell_Nature_EarthShock",
            warning = true,
            roles = {"healer"},
            lines = {"Nature damage that also interrupts casting."}
        }, {
            name = "Chain Burn",
            icon = "Interface\\Icons\\Spell_Fire_Fireball",
            warning = true,
            lines = {"Fire damage that chains to nearby targets - spread out."}
        }, {
            name = "Sleep",
            icon = "Interface\\Icons\\Spell_Nature_Sleep",
            warning = true,
            lines = {"Puts a target to sleep. Any damage will wake them."}
        }, {
            -- CHANGED: real ability standing in for the Nightmare Illusion
            -- summon, now that this add can be a proper `adds` entry below.
            name = "Summon Nightmare Illusion",
            icon = "Interface\\Icons\\Temp",
            lines = {"Summons a Nightmare Illusion to aid him in battle."}
        }},
        adds = {{
            name = "Nightmare Illusion",
            icon = "Interface\\Icons\\Temp",
            lines = {"An add summoned during the Hazza'rah encounter. No offensive abilities were captured in the log for this mob."}
        }}
    },

    wushoolay = {
        name = "Wushoolay",
        icon = "Interface\\Icons\\Spell_Nature_ChainLightning",
        abilities = {{
            name = "Lightning Cloud",
            icon = "Interface\\Icons\\Spell_Nature_CallStorm",
            warning = true,
            lines = {"Creates a lightning cloud that damages everyone in it. His most frequent ability - move out."}
        }, {
            name = "Forked Lightning",
            icon = "Interface\\Icons\\Spell_Nature_ChainLightning",
            warning = true,
            lines = {"Strikes multiple targets with lightning."}
        }, {
            name = "Chain Lightning",
            icon = "Interface\\Icons\\Spell_Nature_ChainLightning",
            warning = true,
            lines = {"Lightning that chains to nearby targets - spread out."}
        }}
    },

    gahzranka = {
        name = "Gahz'ranka",
        icon = "Interface\\Icons\\temp",
        stats = {armor = 4400, fire = 15, nature = 15, frost = 15, shadow = 15, arcane = 15},
        abilities = {{
            name = "Frost Breath",
            icon = "Interface\\Icons\\Spell_Frost_FrostNova",
            warning = true,
            roles = {"tank"},
            lines = {"Inflicts Frost damage in a cone in front of him and stuns the targets."}
        }, {
            name = "Mighty Slam",
            icon = "Interface\\Icons\\Ability_Devour",
            warning = true,
            lines = {"Inflicts around 950 damage to nearby enemies and knocks them back."}
        }, {
            name = "Double Bite",
            icon = "Interface\\Icons\\Ability_Racial_Cannibalize",
            roles = {"tank"},
            lines = {"Bites twice, hitting a second enemy as well."}
        }, {
            name = "Triple Bite",
            icon = "Interface\\Icons\\Ability_Racial_Cannibalize",
            roles = {"tank"},
            lines = {"Bites three times, hitting additional enemies."}
        }, {
            name = "Tail Sweep",
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_05",
            warning = true,
            lines = {"Damages and knocks back enemies behind him. Do not stand behind."}
        }}
    },

    -- CHANGED: Thekal, Zealot Lor'Khan, and Zealot Zath are fought
    -- together as one encounter (three bosses at once, all present at
    -- once - unlike Edge of Madness above where only one of four spawns)
    -- - moved Lor'Khan/Zath out of trash and wrapped all three as
    -- sub-boss entries under this one key.
    thekal = {
        name = "High Priest Thekal",
        icon = "Interface\\Icons\\temp",
        -- CHANGED: stats are for Thekal himself (the primary tank target) -
        -- no confirmed stats exist for Lor'Khan/Zath.
        stats = {armor = 4620, fire = 45, nature = 58, frost = 35, shadow = 35, arcane = 35},
        abilities = {{
            name = "High Priest Thekal",
            icon = "Interface\\Icons\\temp",
            lines = {"The warrior of the trio - primary melee target."},
            abilities = {{
                name = "Force Punch",
                icon = "Interface\\Icons\\INV_Gauntlets_31",
                warning = true,
                roles = {"tank"},
                lines = {"His most frequent ability - a heavy melee strike."}
            }, {
                name = "Mortal Cleave",
                icon = "Interface\\Icons\\Ability_Warrior_SavageBlow",
                warning = true,
                roles = {"tank", "healer"},
                lines = {"Inflicts weapon damage and reduces healing effectiveness on the target by 75%."}
            }, {
                name = "Panic",
                icon = "Interface\\Icons\\Spell_Shadow_DeathScream",
                warning = true,
                roles = {"shaman"},
                lines = {"Fears nearby enemies. Keep a Tremor Totem down."}
            }, {
                name = "Silence",
                icon = "Interface\\Icons\\Spell_Frost_IceShock",
                warning = true,
                lines = {"Silences a target, preventing them from casting."}
            }, {
                name = "Charge",
                icon = "Interface\\Icons\\Ability_Warrior_Charge",
                lines = {"Charges a distant target."}
            }}
        }, {
            name = "Zealot Lor'Khan",
            icon = "Interface\\Icons\\Spell_Fire_SealOfFire",
            lines = {"The shaman of the trio."},
            abilities = {{
                -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
                name = "Fire Nova Totem",
                icon = "Interface\\Icons\\Spell_Fire_SealOfFire",
                warning = true,
                lines = {"Summons a Fire Nova Totem that has 1000 health and lasts 5 seconds. Unless it is destroyed within X sec., the totem inflicts X fire damage to enemies within X yd."}
            }, {
                -- CHANGED: duration confirmed from Spell.xlsx (spell 34881) + SpellDuration.csv lookup - not in-game tested.
                name = "Lightning Shield",
                icon = "Interface\\Icons\\Spell_Nature_LightningShield",
                warning = true,
                lines = {"Surrounds the caster with balls of lightning that have X% chance of striking melee or ranged attackers for 8 damage. Thus, the shield expires after 600 seconds."}
            }, {
                name = "Disarm",
                icon = "Interface\\Icons\\Ability_Warrior_Disarm",
                warning = true,
                lines = {"Disarm the enemy's weapon for X seconds."}
            }}
        }, {
            name = "Zealot Zath",
            icon = "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice",
            lines = {"The rogue of the trio."},
            abilities = {{
                name = "Sinister Strike",
                icon = "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice",
                warning = true,
                lines = {"Inflicts normal damage plus 2 to an enemy."}
            }, {
                -- CHANGED: duration confirmed from Spell.xlsx (spell 21060) + SpellDuration.csv lookup - not in-game tested.
                name = "Blind",
                icon = "Interface\\Icons\\Spell_Shadow_MindSteal",
                warning = true,
                lines = {"Blinds the target and its nearby allies, causing them to wander confused for up to 10 seconds."}
            }, {
                name = "Gouge",
                icon = "Interface\\Icons\\Ability_Gouge",
                warning = true,
                lines = {"Inflicts 20 damage to an enemy and stuns it for up to X seconds. You will automatically stop attacking. Target must be facing you. Any damage received by the stunned target will revive it."}
            }, {
                -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
                name = "Cloak of Shadows",
                icon = "Interface\\Icons\\Spell_Shadow_NetherCloak",
                lines = {"Protects the rogue from spells for 5 seconds. Does not break stealth."}
            }, {
                name = "Wound Poison",
                icon = "Interface\\Icons\\INV_Misc_Herb_16",
                roles = {"dispel"},
                -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 34883 - not reverse-engineered from raw effect codes.
                lines = {"X - no ability description available."}
            }, {
                -- CHANGED: duration confirmed from Spell.xlsx (spell 34886) + SpellDuration.csv lookup - not in-game tested.
                name = "Sprint",
                icon = "Interface\\Icons\\Ability_Rogue_Sprint",
                lines = {"Increases run speed by 100% for 8 seconds."}
            }}
        }}
    },

    arlokk = {
        name = "High Priestess Arlokk",
        icon = "Interface\\Icons\\temp",
        stats = {armor = 4700, fire = 38, nature = 84, frost = 38, shadow = 84, arcane = 38},
        abilities = {{
            name = "Whirlwind",
            icon = "Interface\\Icons\\Ability_Whirlwind",
            warning = true,
            roles = {"melee"},
            lines = {"Spins in a whirlwind, hitting all nearby enemies. Her most frequent ability - melee watch out."}
        }, {
            name = "Ravage",
            icon = "Interface\\Icons\\Ability_GhoulFrenzy",
            warning = true,
            roles = {"tank"},
            lines = {"Inflicts 500 damage and stuns the target."}
        }, {
            name = "Gouge",
            icon = "Interface\\Icons\\Ability_Gouge",
            warning = true,
            roles = {"tank"},
            lines = {"Gouges the target, incapacitating them. Another player must attack her to break the gouge."}
        }, {
            name = "Backstab",
            icon = "Interface\\Icons\\Ability_BackStab",
            lines = {"Backstabs a target for heavy damage. Keep her faced away from the raid."}
        }}
    },

    jindo = {
        name = "Jin'do the Hexxer",
        icon = "Interface\\Icons\\temp",
        stats = {armor = 4950, fire = 44, nature = 168, frost = 30, shadow = 168, arcane = 168},
        abilities = {{
            name = "Hex",
            icon = "Interface\\Icons\\Spell_Nature_Polymorph",
            warning = true,
            lines = {"Transforms nearby enemies into frogs, preventing them from attacking or casting. His signature mechanic."}
        }, {
            name = "Delusions of Jin'do",
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            warning = true,
            roles = {"healer"},
            lines = {"'Your eyes tingle...' - inflicts around 175 damage every 2 seconds. His most frequent ability."}
        }, {
            name = "Shadow Beam",
            icon = "Interface\\Icons\\Spell_Shadow_SiphonMana",
            warning = true,
            lines = {"A heavy Shadow bolt for around 1825 damage."}
        }, {
            name = "Touch of Shadow",
            icon = "Interface\\Icons\\Spell_Nature_Drowsy",
            warning = true,
            roles = {"dispel"},
            lines = {"Increases Shadow damage taken by 300%. Dispel it promptly."}
        }, {
            name = "Call of Jin'do",
            icon = "Interface\\Icons\\Spell_Nature_AstralRecal",
            warning = true,
            lines = {"Charms a player - damage increased by 300%, spells cast instantly, and resistances boosted. They must be crowd-controlled, not killed."}
        }},
        -- CHANGED: Shade of Jin'do moved out of trash - it's his add.
        adds = {{
            name = "Shade of Jin'do",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            lines = {"An add summoned during the Jin'do encounter."},
            abilities = {{
                name = "Shadow Shock",
                icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
                warning = true,
                roles = {"kick"},
                lines = {"Instantly lashes an enemy with dark magic, inflicting Shadow damage."}
            }}
        }}
    },

    hakkar = {
        name = "Hakkar",
        icon = "Interface\\Icons\\temp",
        stats = {armor = 4880, fire = 51, nature = 51, frost = 14, shadow = 141, arcane = 51},
        abilities = {{
            name = "Corrupted Blood",
            icon = "Interface\\Icons\\Spell_Shadow_CorpseExplode",
            warning = true,
            roles = {"healer"},
            lines = {"Deals 263 damage every 2 seconds and spreads to nearby players. His most frequent ability - spread out to limit the chain."}
        }, {
            name = "Blood Siphon",
            icon = "Interface\\Icons\\Spell_Shadow_LifeDrain",
            warning = true,
            roles = {"healer"},
            lines = {"Drains 700 health per second from the raid and feeds Hakkar health in return."}
        }, {
            name = "Curse of Nemesis",
            icon = "Interface\\Icons\\Spell_Shadow_CurseOfTounges",
            warning = true,
            roles = {"decurse"},
            lines = {"Deals 20% health damage every 2 seconds. If dispelled it causes instant Shadow damage, so only decurse when the target can survive the burst."}
        }, {
            name = "Hysteria",
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            warning = true,
            lines = {"Increases the cost of spells and abilities. If you fail to cast three spells or abilities you become insane."}
        }, {
            -- CHANGED: added from "ZG 2.csv" (spell ID 24327) - real numbers from Spell.xlsx; duration confirmed from Spell.xlsx DurationIndex 18 + SpellDuration.csv (20000ms = 20s), not tested in-game.
            name = "Cause Insanity",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
            warning = true,
            lines = {"Drives an enemy target temporarily insane, speeding its attacks by 100% and its movement by 200%, as well as causing it to attack its own allies for 20 seconds."}
        }, {
            -- CHANGED: added from "ZG 2.csv" (spell ID 24689) - Description_enUS empty in Spell.xlsx, not reverse-engineered from raw effect codes.
            name = "Aspect of Thekal",
            icon = "Interface\\Icons\\Ability_Druid_ChallangingRoar",
            lines = {"X - no ability description available."}
        }}
    },

    azus = {
        name = "Azus the Bloodseeker",
        icon = "Interface\\Icons\\temp",
        stats = {armor = 4950, fire = 44, nature = 75, frost = 12, shadow = 44, arcane = 44},
        abilities = {{
            name = "Blood Leech",
            icon = "Interface\\Icons\\Ability_Racial_Cannibalize",
            warning = true,
            roles = {"healer"},
            lines = {"Drains health from nearby enemies and heals himself for up to three times the amount stolen. His most frequent ability by far."}
        }, {
            name = "Lacerate",
            icon = "Interface\\Icons\\Spell_Shadow_LifeDrain",
            warning = true,
            lines = {"'The blood seeps through your skin. It hurts to move.'"}
        }, {
            name = "Blood Cloud",
            icon = "Interface\\Icons\\Spell_Nature_NatureTouchDecay",
            warning = true,
            lines = {"Inflicts 375 damage every second to nearby enemies and slows movement. Move out."}
        }, {
            name = "Blood Tide",
            icon = "Interface\\Icons\\Spell_Holy_HolyBolt",
            warning = true,
            lines = {"A massive burst of 2875 damage."}
        }, {
            name = "Charge",
            icon = "Interface\\Icons\\Ability_Warrior_Charge",
            lines = {"Charges a distant target."}
        }, {
            -- CHANGED: added from "ZG 2.csv" (spell ID 34923) - Description_enUS empty in Spell.xlsx, not reverse-engineered from raw effect codes.
            name = "Rupture",
            icon = "Interface\\Icons\\Ability_Rogue_Rupture",
            warning = true,
            lines = {"X - no ability description available."}
        }, {
            -- CHANGED: added from "ZG 2.csv" (spell ID 34919) - Description_enUS empty in Spell.xlsx, not reverse-engineered from raw effect codes.
            name = "Wound",
            icon = "Interface\\Icons\\Ability_CriticalStrike",
            warning = true,
            lines = {"X - no ability description available."}
        }, {
            -- CHANGED: added from "ZG 2.csv" (spell ID 34914) - Description_enUS empty in Spell.xlsx; raw base points (39999-70000) look like a sentinel/formula value rather than a real number, left as X rather than presented as real.
            name = "Thirst",
            icon = "Interface\\Icons\\Spell_Nature_BloodLust",
            lines = {"X - no ability description available."}
        }}
    },

    -- CHANGED: real abilities from "ZG 2.csv", cross-matched against
    -- Spell.xlsx by exact Spell ID - replaces the old placeholder.
    nameless_hermit = {
        name = "Nameless Hermit",
        icon = "Interface\\Icons\\temp",
        stats = {armor = 4950, fire = 44, nature = 75, frost = 12, shadow = 44, arcane = 44},
        abilities = {{
            name = "Devour",
            icon = "Interface\\Icons\\Spell_Shadow_SummonFelHunter",
            -- CHANGED: Description_enUS empty in Spell.xlsx - number below computed from raw effect fields (spell ID 34938).
            warning = true,
            lines = {"Deals 3000 to 3500 damage to an enemy."}
        }, {
            name = "Silence",
            icon = "Interface\\Icons\\Spell_Holy_Silence",
            warning = true,
            lines = {"Silences nearby enemies, preventing them from casting spells for X seconds."}
        }, {
            name = "Whirlwind",
            icon = "Interface\\Icons\\Ability_Whirlwind",
            warning = true,
            roles = {"melee"},
            lines = {"Attacks up to X enemies within X yards, causing weapon damage to each."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 34934) + SpellDuration.csv lookup - not in-game tested.
            name = "Wild Charge",
            icon = "Interface\\Icons\\INV_Misc_Bone_09",
            warning = true,
            lines = {"Charges an enemy, stunning the opponent for 5 seconds."}
        }},
        -- CHANGED: Caverngloom Crocolisk moved out of trash - it's his add.
        adds = {{
            name = "Caverngloom Crocolisk",
            icon = "Interface\\Icons\\Spell_Shadow_CallofBone",
            lines = {"An add summoned during the Nameless Hermit encounter."},
            abilities = {{
                -- CHANGED: Description_enUS for spell ID 34936 is literally the word "Trash" in Spell.xlsx - a dev placeholder, not real flavor text - so left as X rather than used.
                name = "Infected Bite",
                icon = "Interface\\Icons\\Spell_Shadow_CallofBone",
                warning = true,
                lines = {"X - no ability description available."}
            }}
        }}
    },
}

------------------------------------------------------------
-- Builder: expand the order list + registry above into the flat table
-- shape the Bosses view expects (see AGENTS.md "Data model"). Nothing
-- below this point encodes raid content - only edit it if the addon's
-- expected data shape changes.
------------------------------------------------------------

local function BuildZGBosses()
    local bosses = {}
    for _, entry in ipairs(ZG_BOSS_ORDER) do
        if type(entry) == "table" and entry.separator then
            table.insert(bosses, entry)
        else
            local boss = { key = entry }
            for field, value in pairs(ZG_BOSSES[entry]) do
                boss[field] = value
            end
            table.insert(bosses, boss)
        end
    end
    return bosses
end

local function BuildZGTrash()
    local trash = {}
    for _, entry in ipairs(ZG_TRASH_ORDER) do
        if type(entry) == "table" and entry.separator then
            table.insert(trash, entry)
        else
            local key, count
            if type(entry) == "table" then
                key, count = entry.key, entry.count
            else
                key = entry
            end
            local mob = ZG_TRASH_MOBS[key]
            local pack = { key = key, count = count }
            for field, value in pairs(mob) do
                pack[field] = value
            end
            table.insert(trash, pack)
        end
    end
    return trash
end

table.insert(DungeonJournal_Raids, {
    -- CHANGED: Zul'Gurub 20-man raid. Mechanics from Spell.dbc and combat logs.
    key = "ZG",
    name = "Zul'Gurub",
    expanded = false,
    trashExpanded = false,
    trash = BuildZGTrash(),
    bosses = BuildZGBosses(),
})
