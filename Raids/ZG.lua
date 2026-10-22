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
            separator = true,
            passive = true,
            name = "Passives"
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
            spellId = 22691,
            icon = "Interface\\Icons\\Ability_Warrior_Disarm",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 22691).
            lines = {"Disarms an enemy, forcing it to stop wielding its weapon for 6 seconds."}
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
            spellId = 12021,
            icon = "Interface\\Icons\\Spell_Shadow_Charm",
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 12021).
            lines = {"Causes an enemy to fixate upon the caster and increases the caster's attack speed by 50% for 10 seconds. While the target is fixated upon the caster, the target is very reluctant to attack anything else."}
        }, {
            name = "Charge",
            spellId = 24023,
            icon = "Interface\\Icons\\Ability_Warrior_Charge",
            warning = true,
            -- CHANGED 2026-09-30: spell 24023: weapon damage 75, triggers Fixate (spell 12021) - there is no stun effect in the data.
            lines = {"Charges an enemy, inflicting weapon damage plus 75 and causing it to fixate on the caster, which gains 50% attack speed for 10 seconds."}
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
            spellId = 19629,
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 19629 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 19629).
            -- CHANGED 2026-09-30: spell 19629 is only the game-object summon; the flames' damage is not in the spell data.
            lines = {"Places flames on the ground (a game object) that last 15 seconds."}
        }, {
            name = "Throw Liquid Fire",
            spellId = 23970,
            icon = "Interface\\Icons\\Spell_Fire_MeteorStorm",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 23970 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 23970).
            lines = {"Throws liquid fire at an enemy for 575 to 825 Fire damage."}
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
            spellId = 16075,
            icon = "Interface\\Icons\\INV_Axe_08",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 16075 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 16075).
            lines = {"Throws an axe at an enemy for 1750 Physical damage, stunning it for 2 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 24018) + SpellDuration.csv lookup - not in-game tested.
            name = "Axe Flurry",
            spellId = 24018,
            icon = "Interface\\Icons\\INV_Axe_06",
            lines = {"Attacks nearby enemies in a flurry of axes that lasts 10 seconds."}
        }, {
            name = "Enrage",
            spellId = 8269,
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 8269).
            -- CHANGED 2026-09-30: spell 8269 in Spell.csv is level-scaled - base 50, +2 per caster level above 26, no cap unless stated.
            lines = {"Increases the caster's attack speed by 60% and the Physical damage it deals by 50 plus 2 per caster level above 26 (about 118 at level 60) for 2 minutes."}
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
            spellId = 16128,
            icon = "Interface\\Icons\\Spell_Shadow_CallofBone",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 16128).
            -- CHANGED 2026-09-30: spell 16128 in Spell.csv is level-scaled - DoT 45 +2/level above 20; damage taken 30 +5/level above 20 (per-slot split read from a 3-field row - verify), no cap unless stated.
            lines = {"Inflicts 45 plus 2 per caster level above 20 (about 125 at level 60) Nature damage to an enemy every 10 seconds and increases the Physical damage it takes by 30 plus 5 per caster level above 20 (about 230 at level 60) for 180 seconds."}
        }, {
            name = "Flames",
            icon = "Interface\\Icons\\Spell_Fire_Immolation",
            warning = true,
            lines = {"Inflicts 750 Fire damage to nearby enemies."}
        }, {
            name = "Summon Flames",
            spellId = 19629,
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 19629 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 19629).
            -- CHANGED 2026-09-30: spell 19629 is only the game-object summon; the flames' damage is not in the spell data.
            lines = {"Places flames on the ground (a game object) that last 15 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Demoralizing Shout",
            spellId = 23511,
            icon = "Interface\\Icons\\Ability_Warrior_WarCry",
            -- CHANGED 2026-09-30: spell 23511 in Spell.csv is level-scaled - AP reduction 40, +10 per caster level above 5.
            lines = {"Reduces the attack power of nearby enemies by 40 plus 10 per caster level above 5 (about 590 at level 60) for 30 seconds."}
        }, {
            name = "Throw Liquid Fire",
            spellId = 23970,
            icon = "Interface\\Icons\\Spell_Fire_MeteorStorm",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 23970 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 23970).
            lines = {"Throws liquid fire at an enemy for 575 to 825 Fire damage."}
        }, {
            name = "Unstable Concoction",
            spellId = 24024,
            icon = "Interface\\Icons\\Spell_Fire_Incinerate",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24024 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 24024).
            lines = {"Explodes for 6375 to 7375 Fire damage to enemies within 13 yards, killing the caster."}
        }, {
            name = "Thrash",
            icon = "Interface\\Icons\\Ability_GhoulFrenzy",
            lines = {"Gives the caster 2 extra attacks."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 5115) + SpellDuration.csv lookup - not in-game tested.
            name = "Battle Command",
            spellId = 5115,
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
            lines = {"Inflicts weapon damage plus 30 to nearby enemies and knocks them back."}
        }, {
            name = "Sweeping Strikes",
            spellId = 12723,
            icon = "Interface\\Icons\\Ability_Rogue_SliceDice",
            -- CHANGED 2026-09-30: swing count is not in the spell data (spell 12723).
            lines = {"Its next melee weapon swings strike an additional nearby opponent."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Thunderclap",
            spellId = 15588,
            icon = "Interface\\Icons\\Spell_Nature_ThunderClap",
            warning = true,
            -- CHANGED 2026-09-30: spell 15588 in Spell.csv is level-scaled - damage 71-79 +3/level above 20; slow 40% +0.5/level above 20 (split-decimal reading - verify).
            lines = {"Inflicts 71 to 79 Nature damage plus 3 per caster level above 20 (about 191 to 199 at level 60) to nearby enemies, increasing the time between their attacks by 33% and slowing their movement by 40% plus 0.5% per caster level above 20 (about 60% at level 60) for 10 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 16508) + SpellDuration.csv lookup - not in-game tested.
            name = "Intimidating Roar",
            spellId = 16508,
            icon = "Interface\\Icons\\Ability_GolemThunderClap",
            warning = true,
            lines = {"Roars at an enemy, paralyzing it with terror for 8 seconds. and causing all other nearby enemies to flee in fear."}
        }, {
            name = "Enrage",
            spellId = 8269,
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 8269).
            -- CHANGED 2026-09-30: spell 8269 in Spell.csv is level-scaled - base 50, +2 per caster level above 26, no cap unless stated.
            lines = {"Increases the caster's attack speed by 60% and the Physical damage it deals by 50 plus 2 per caster level above 26 (about 118 at level 60) for 2 minutes."}
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
            spellId = 24435,
            icon = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 24435).
            lines = {"Drains 1 health from an enemy over 5 seconds, transferring it to the caster."}
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
            spellId = 15062,
            icon = "Interface\\Icons\\Ability_Warrior_ShieldWall",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 15062).
            lines = {"Reduces the Physical and magical damage taken by the caster by 75% for 10 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Shield Slam",
            spellId = 15655,
            icon = "Interface\\Icons\\Ability_Warrior_ShieldBash",
            warning = true,
            -- CHANGED 2026-09-30: spell 15655 in Spell.csv is level-scaled - damage 100-300, +10 per caster level above 10.
            lines = {"Inflicts 100 to 300 damage plus 10 per caster level above 10 (about 600 to 800 at level 60) to an enemy, stunning it for 2 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Shield Reflection",
            spellId = 34073,
            icon = "Interface\\Icons\\Ability_Warrior_ShieldReflection",
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 34073).
            lines = {"Raise your shield, reflecting spell cast on you. Lasts 5 seconds, but will only reflect 1 spell."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Shield Toss",
            icon = "Interface\\Icons\\Ability_UpgradeMoonGlaive",
            warning = true,
            lines = {"Hurls a shield at the enemy, causing 308 to 348 damage, increased by Attack Power and knocks down for 2 seconds. This ability causes a high amount of threat."}
        }, {
            separator = true,
            passive = true,
            name = "Passives"
        }, {
            name = "Defensive Stance",
            icon = "Interface\\Icons\\Ability_Warrior_DefensiveStance",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 71).
            lines = {"A defensive combat stance that decreases damage taken by 10% and damage caused by 10%. Increases threat generated by 30%."}
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
            lines = {"Inflicts 300% weapon damage and leaves the target wounded, reducing the effectiveness of any healing by 50% for 5 seconds."}
        }, {
            name = "Throw",
            icon = "Interface\\Icons\\Ability_Throw",
            warning = true,
            lines = {"Throws a weapon at an enemy, inflicting Physical damage."}
        }, {
            name = "Whirling Trip",
            icon = "Interface\\Icons\\INV_Spear_05",
            warning = true,
            lines = {"Inflicts weapon damage plus 50 to nearby enemies."}
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
            name = "Blood Funnel",
            spellId = 24617,
            icon = "Interface\\Icons\\Spell_Shadow_LifeDrain",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24617 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 24617).
            lines = {"Channels the caster's own health into an ally at 500 per second for 10 seconds."}
        }, {
            name = "Drain Life",
            spellId = 24618,
            icon = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 24618).
            lines = {"Drains 4000 health from an enemy over 5 seconds, transferring it to the caster."}
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
            spellId = 13704,
            icon = "Interface\\Icons\\Spell_Shadow_PsychicScream",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 13704).
            -- CHANGED 2026-09-30: target count is not in the spell data (spell 13704).
            lines = {"Lets out a psychic scream, causing nearby enemies to flee for 6 seconds."}
        }, {
            name = "Anti-Magic Shield",
            spellId = 24021,
            icon = "Interface\\Icons\\Spell_Shadow_AntiMagicShell",
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 24021).
            lines = {"Creates an anti-magic shell around the caster, giving it magic immunity for 8 seconds."}
        }, {
            name = "Cleanse Nova",
            spellId = 24022,
            icon = "Interface\\Icons\\Spell_Holy_HolyBolt",
            warning = true,
            roles = {"kick"},
            -- CHANGED 2026-09-30: spell 24022 in Spell.csv (the logged ID) - effects are Dispel + Heal 25188 to 25812 within 15 yards; the old line described a different spell.
            lines = {"Causes an explosion of divine light within 15 yards that dispels effects and heals for 25188 to 25812."}
        }, {
            name = "Psychic Scream",
            spellId = 34865,
            icon = "Interface\\Icons\\Spell_Shadow_PsychicScream",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 34865).
            -- CHANGED 2026-09-30: target count is not in the spell data (spell 34865).
            lines = {"Lets out a psychic scream, causing nearby enemies to flee for 10 seconds."}
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
            spellId = 22908,
            icon = "Interface\\Icons\\Ability_Marksmanship",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 22908).
            lines = {"Continuously fires a volley of ammo at the target area, causing 800 to 850 Arcane damage to enemy targets within 10 yards every second for 20 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 24335) + SpellDuration.csv lookup - not in-game tested.
            name = "Wyvern Sting",
            spellId = 24335,
            icon = "Interface\\Icons\\INV_Spear_02",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 24335).
            lines = {"A stinging shot that puts the target to sleep for 12 seconds. Any damage will cancel the effect. When the target wakes up, the Sting causes 1314 Nature damage over 12 seconds."}
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
            spellId = 34873,
            icon = "Interface\\Icons\\Spell_Shadow_ShadeTrueSight",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 34873).
            lines = {"Causes an explosion of Shadow around the caster, causing 500 to 750 Shadow damage to all enemy targets within 10 yards and healing all allies within 10 yards for 5000 to 7500."}
        }, {
            name = "Shadow Nova",
            spellId = 34874,
            icon = "Interface\\Icons\\Spell_Shadow_ShadeTrueSight",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 34874 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 34874).
            lines = {"Heals allies within 10 yards for 5000 to 7500."}
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
            spellId = 24053,
            icon = "Interface\\Icons\\Spell_Nature_Polymorph",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 24053).
            lines = {"Transforms an enemy into a frog, rendering it unable to attack or cast spells for 5 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Shrink",
            icon = "Interface\\Icons\\Spell_Shadow_AntiShadow",
            lines = {"Reduces nearby enemies' Strength by 200 and Stamina by 100 for 120 seconds."}
        }, {
            -- CHANGED: summons a Jungle Toad - moved out of trash and
            -- nested here since it's this mob's summon, not a standalone
            -- pull.
            name = "Release Toads",
            spellId = 24058,
            icon = "Interface\\Icons\\INV_Misc_Eye_01",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24058 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 24058).
            lines = {"Summons 5 Jungle Toads, which last up to 4 minutes."},
            abilities = {{
                name = "Jungle Toad - Disease Cloud",
                spellId = 24063,
                icon = "Interface\\Icons\\Spell_Nature_AbolishMagic",
                -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24063 - not reverse-engineered from raw effect codes.
                -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 24063).
                lines = {"Bursts for 750 to 1050 Nature damage within 5 yards, killing the toad, and leaves a cloud that deals 438 to 562 Nature damage per second within 10 yards for 30 seconds."}
            }}
        }, {
            name = "Toad Explode",
            spellId = 24062,
            icon = "Interface\\Icons\\Spell_Nature_AbolishMagic",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24062 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 24062).
            lines = {"Scripted trigger with a 100 yard range. No damage of its own - the damage comes from the toads' Disease Cloud."}
        }, {
            name = "Toad Explode",
            spellId = 24065,
            icon = "Interface\\Icons\\Spell_Nature_AbolishMagic",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24065 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 24065).
            lines = {"Fires Toad Explode every second for 5 seconds."}
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
            spellId = 24612,
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            warning = true,
            roles = {"kick"},
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 24612).
            lines = {"Calls down a pillar of flame, burning all enemies in a selected area and inflicting additional damage every 1 second for 8 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 24621) + SpellDuration.csv lookup - not in-game tested.
            name = "Portal of Madness",
            spellId = 24621,
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
            spellId = 24011,
            icon = "Interface\\Icons\\Spell_Nature_CorrosiveBreath",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 24011).
            lines = {"Spits poison at an enemy, inflicting Nature damage, then additional damage every 2 seconds for 10 seconds."}
        }, {
            separator = true,
            passive = true,
            name = "Passives"
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
            spellId = 24598,
            icon = "Interface\\Icons\\Ability_Creature_Disease_02",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24598 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 24598).
            lines = {"Summons 7 Razzashi Skitterers."}
        }, {
            name = "Web Spin",
            spellId = 24600,
            icon = "Interface\\Icons\\Spell_Nature_EarthBind",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24600 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 24600).
            lines = {"Wraps an enemy in a web, stunning it for 7 seconds."}
        }, {
            name = "Intoxication",
            spellId = 34422,
            icon = "Interface\\Icons\\Ability_Poisons",
            roles = {"dispel"},
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 34422 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 34422).
            lines = {"After 5 seconds, deals 1750 to 2500 Nature damage to the target and enemies within 8 yards."}
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
            spellId = 27919,
            icon = "Interface\\Icons\\Spell_Nature_CorrosiveBreath",
            warning = true,
            -- CHANGED 2026-09-30: spell 27919 in Spell.csv is level-scaled - damage 85-115, +10 per caster level above 20.
            lines = {"Shoots at an enemy, inflicting 85 to 115 Nature damage plus 10 per caster level above 20 (about 485 to 515 at level 60) and knocking it back."}
        }, {
            name = "Poison Cloud",
            spellId = 34877,
            icon = "Interface\\Icons\\Spell_Nature_NatureTouchDecay",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 34877).
            lines = {"Inflicts 575 Nature damage to nearby enemies every 1 second for 2 minutes."}
        }, {
            name = "Poison Cloud",
            spellId = 34878,
            icon = "Interface\\Icons\\Temp",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 34878 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 34878).
            lines = {"Summons a Poison Cloud that lasts 75 seconds."}
        }, {
            name = "Poison",
            spellId = 34949,
            icon = "Interface\\Icons\\Spell_Nature_CorrosiveBreath",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 34949).
            lines = {"Inflicts Nature damage to an enemy every 3 seconds for 30 seconds."}
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
            spellId = 24317,
            icon = "Interface\\Icons\\Ability_Warrior_Sunder",
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 24317).
            lines = {"Hacks at an enemy's armor, reducing it by 1000 per Sunder Armor. Can be applied up to 5 times. Lasts 20 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            -- spellId: uncertain - the line uses both 24339 and 16128.
            name = "Infected Bite",
            icon = "Interface\\Icons\\Spell_Shadow_CallofBone",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 24339).
            -- CHANGED 2026-09-30: spell 16128 in Spell.csv is level-scaled - DoT 45 +2/level above 20; damage taken 30 +5/level above 20 (per-slot split read from a 3-field row - verify), no cap unless stated.
            lines = {"Inflicts 45 plus 2 per caster level above 20 (about 125 at level 60) Nature damage to an enemy every 10 seconds and increases the Physical damage it takes by 30 plus 5 per caster level above 20 (about 230 at level 60) for 180 seconds."}
        }, {
            separator = true,
            passive = true,
            name = "Passives"
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
            lines = {"Reduces an enemy's armor by 75% for 20 seconds."}
        }, {
            name = "Tranquilizing Poison",
            spellId = 24002,
            icon = "Interface\\Icons\\Ability_Creature_Poison_03",
            roles = {"dispel"},
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24002 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 24002).
            lines = {"Increases the time between the target's attacks by 150%, slows its movement by 70% and drains 100 mana per second for 5 seconds."}
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
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Slowing Poison",
            spellId = 7992,
            icon = "Interface\\Icons\\Spell_Nature_SlowPoison",
            warning = true,
            roles = {"dispel"},
            -- CHANGED 2026-09-30: spell 7992 in Spell.csv is level-scaled - slow 30%, +1 per caster level above 20 (split-decimal reading - verify).
            lines = {"Increases the time between an enemy's attacks by 25% and slows its movement by 30% plus 1% per caster level above 20 (about 70% at level 60) for 25 seconds."}
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
            spellId = 34896,
            icon = "Interface\\Icons\\Spell_Shadow_UnsummonBuilding",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 34896 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 34896).
            lines = {"Lasts 2 minutes and pulses every second, stacking up to 100 times. X - what each pulse does is not in the spell data."}
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
            lines = {"Inflicts weapon damage plus 50 to nearby enemies."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Head Crack",
            spellId = 3148,
            icon = "Interface\\Icons\\Ability_ThunderBolt",
            -- CHANGED 2026-09-29: spell 3148 - level-scaled in Spell.csv - base -1 at level 1, -0.2 per caster level, no cap.
            lines = {"Reduces an enemy's Stamina by 1 plus 0.2 per caster level above 1 (about 13 at level 60) for 20 seconds."}
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
            spellId = 16790,
            icon = "Interface\\Icons\\Ability_GolemThunderClap",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 16790).
            -- CHANGED 2026-09-30: spell 16790 in Spell.csv is level-scaled - damage 60-80, +1.5 per caster level above 1, no cap unless stated.
            lines = {"Inflicts 60 to 80 damage plus 1.5 per caster level above 1 (about 149 to 169 at level 60) to an enemy and its nearest allies, stunning them for 2 seconds. Affects up to 3 targets."}
        }, {
            separator = true,
            passive = true,
            name = "Passives"
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
            spellId = 22678,
            icon = "Interface\\Icons\\Spell_Shadow_Possession",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 22678).
            lines = {"Strikes fear in an enemy, causing it to flee in terror for 6 seconds. Only 1 target can be feared at a time."}
        }, {
            name = "Soul Tap",
            spellId = 24619,
            icon = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24619 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 24619).
            -- CHANGED 2026-09-30: spell 24619: aura 162 is a periodic mana burn.
            lines = {"Silences the target for 12 seconds and burns 500 of its mana every second for the same duration."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 30112) + SpellDuration.csv lookup - not in-game tested.
            name = "Frenzied Dive",
            spellId = 30112,
            icon = "Interface\\Icons\\Ability_Hunter_Pet_Bat",
            warning = true,
            lines = {"Dives upon an enemy, inflicting weapon damage plus 2 and stuns the opponent for 2 seconds."}
        }, {
            name = "Thrash",
            icon = "Interface\\Icons\\Ability_GhoulFrenzy",
            lines = {"Gives the caster 2 extra attacks."}
        }, {
            name = "Hate to Zero(Reset)",
            spellId = 34518,
            icon = "Interface\\Icons\\Temp",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 34518 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 34518).
            lines = {"Resets the caster's threat on all targets to zero."}
        }, {
            name = "Enrage",
            spellId = 8269,
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 8269).
            -- CHANGED 2026-09-30: spell 8269 in Spell.csv is level-scaled - base 50, +2 per caster level above 26, no cap unless stated.
            lines = {"Increases the caster's attack speed by 60% and the Physical damage it deals by 50 plus 2 per caster level above 26 (about 118 at level 60) for 2 minutes."}
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
            spellId = 13730,
            icon = "Interface\\Icons\\Ability_Warrior_WarCry",
            -- CHANGED 2026-09-30: spell 13730 in Spell.csv is level-scaled - AP reduction 10, +2 per caster level above 5.
            lines = {"Reduces the melee attack power of nearby enemies by 10 plus 2 per caster level above 5 (about 120 at level 60) for 30 seconds."}
        }, {
            name = "Enrage",
            spellId = 8599,
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 8599 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 8599).
            -- CHANGED 2026-09-30: spell 8599 in Spell.csv is level-scaled - damage effect base 1, +2 per caster level above 1, no cap unless stated.
            lines = {"Increases the caster's attack speed by 40% and the Physical damage it deals by 1 plus 2 per caster level above 1 (about 119 at level 60) for 2 minutes."}
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
            lines = {"Curses the target for 60 seconds, reducing Fire, Frost and Nature resistances by 80 and increasing Fire, Frost and Nature damage taken by 10%. Only one Curse per Warlock can be active on any one target."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Curse of Shadow",
            icon = "Interface\\Icons\\Spell_Shadow_CurseOfAchimonde",
            warning = true,
            roles = {"dispel"},
            lines = {"Curses the target for 60 seconds, reducing Shadow and Arcane resistances by 80 and increasing Shadow and Arcane damage taken by 10%. Only one Curse per Warlock can be active on any one target."}
        }, {
            name = "Shadow Bolt",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            warning = true,
            roles = {"kick"},
            lines = {"Hurls a bolt of dark magic at an enemy, inflicting Shadow damage."}
        }, {
            name = "Rain of Fire",
            spellId = 24669,
            icon = "Interface\\Icons\\Spell_Shadow_RainOfFire",
            warning = true,
            roles = {"kick"},
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 24669).
            lines = {"Calls down a molten rain, burning all enemies in a selected area for 775 Fire damage every 2 seconds for 10 seconds."}
        }, {
            name = "Inferno",
            spellId = 24670,
            icon = "Interface\\Icons\\Spell_Shadow_SummonInfernal",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 24670).
            lines = {"Summons a meteor from the Twisting Nether, causing 500 Fire damage and stunning all enemy targets in the area for 4 seconds."}
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
            spellId = 10414,
            icon = "Interface\\Icons\\Spell_Nature_EarthShock",
            warning = true,
            roles = {"kick"},
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 10414).
            -- CHANGED 2026-09-30: spell 10414 in Spell.csv is level-scaled - 517-545 at level 60, +3.1 per level up to level 65, no cap unless stated.
            lines = {"Instantly shocks the target with concussive force, causing 517 to 545 Nature damage (plus 3.1 per caster level above 60, up to level 65). It also interrupts spellcasting and prevents any spell in that school from being cast for 2 seconds. Causes a high amount of threat."}
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
            spellId = 17172,
            icon = "Interface\\Icons\\Spell_Nature_Polymorph",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 17172).
            lines = {"Transforms an enemy into a frog, rendering it unable to attack or cast spells for 5 seconds."}
        }, {
            name = "Dispel Magic",
            icon = "Interface\\Icons\\Spell_Holy_DispelMagic",
            lines = {"Dispels magic on an ally, removing 1 harmful effects."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Unholy Frenzy",
            spellId = 24672,
            icon = "Interface\\Icons\\Spell_Nature_BloodLust",
            warning = true,
            roles = {"dispel"},
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 24672).
            lines = {"Increases an ally's attack speed by 50% for 20 seconds, but also inflicts 200 Nature damage to that ally every 2 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Curse of Blood",
            icon = "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice",
            warning = true,
            roles = {"dispel"},
            lines = {"Increases the Physical damage taken by an enemy by 500 for 600 seconds."}
        }, {
            name = "Veil of Shadow",
            spellId = 24674,
            icon = "Interface\\Icons\\Spell_Shadow_GatherShadows",
            roles = {"dispel"},
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 24674).
            lines = {"Reduces healing effects for an enemy by 75% for 10 seconds."}
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
            spellId = 19771,
            icon = "Interface\\Icons\\Ability_Gouge",
            warning = true,
            lines = {"Inflicts 50 Physical damage to an enemy over 30 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 3604) + SpellDuration.csv lookup - not in-game tested.
            name = "Tendon Rip",
            spellId = 3604,
            icon = "Interface\\Icons\\Ability_CriticalStrike",
            -- CHANGED 2026-09-29: spell 3604 in Spell.csv - base -25%, -1% per caster level, capped at level 46 = -70% for any mob level 46+.
            lines = {"Reduces an enemy's movement speed by 70% for 8 seconds."}
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
            spellId = 24187,
            icon = "Interface\\Icons\\Ability_Druid_Rake",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24187 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 24187).
            lines = {"Inflicts weapon damage plus 100 to an enemy."}
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
            spellId = 24332,
            icon = "Interface\\Icons\\Ability_Druid_Disembowel",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 24332).
            lines = {"Rake the target for 32 to 48 damage and an additional 195 to 245 damage every 0.5 seconds for 9 seconds."}
        }, {
            name = "Ravage",
            spellId = 24333,
            icon = "Interface\\Icons\\Ability_GhoulFrenzy",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 24333).
            -- CHANGED 2026-09-30: spell 24333 in Spell.csv is level-scaled - bonus 3, +0.5 per caster level above 6, no cap unless stated.
            lines = {"Inflicts weapon damage plus 3 plus 0.5 per caster level above 6 (about 30 at level 60) to an enemy, stunning it for 4 seconds."}
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
            spellId = 24332,
            icon = "Interface\\Icons\\Ability_Druid_Disembowel",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 24332).
            lines = {"Rake the target for 32 to 48 damage and an additional 195 to 245 damage every 0.5 seconds for 9 seconds."}
        }, {
            name = "Ravage",
            spellId = 24333,
            icon = "Interface\\Icons\\Ability_GhoulFrenzy",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 24333).
            -- CHANGED 2026-09-30: spell 24333 in Spell.csv is level-scaled - bonus 3, +0.5 per caster level above 6, no cap unless stated.
            lines = {"Inflicts weapon damage plus 3 plus 0.5 per caster level above 6 (about 30 at level 60) to an enemy, stunning it for 4 seconds."}
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
            -- CHANGED 2026-09-30: added from the combat log - spell 23953 in Spell.csv.
            name = "Mind Flay",
            spellId = 23953,
            icon = "Interface\\Icons\\Spell_Shadow_SiphonMana",
            warning = true,
            lines = {"Inflicts 750 to 1000 Shadow damage every second for 10 seconds and reduces movement speed by 80%. Affects up to 5 targets."}
        }, {
            -- CHANGED 2026-09-30: added from the combat log - spell 34876 in Spell.csv.
            name = "Mind Blast",
            spellId = 34876,
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            warning = true,
            lines = {"Blasts the target for 2557 to 3057 Shadow damage."}
        }, {
            -- CHANGED 2026-09-30: added from the combat log - spell 23952 in Spell.csv.
            name = "Shadow Word: Pain",
            spellId = 23952,
            icon = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
            warning = true,
            lines = {"Inflicts 422 to 478 Shadow damage to an enemy every 3 seconds for 30 seconds."}
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
            lines = {"Increases Physical damage taken by 500."}
        }, {
            name = "Charge",
            spellId = 24023,
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
            -- CHANGED 2026-09-30: added from the combat log - spell 23895 in Spell.csv.
            name = "Renew",
            spellId = 23895,
            icon = "Interface\\Icons\\Spell_Holy_Renew",
            lines = {"Heals an ally for 3000 every second for 15 seconds."}
        }, {
            -- CHANGED 2026-09-30: added from the combat log - spell 23865 in Spell.csv.
            name = "Parasitic Serpent",
            spellId = 23865,
            icon = "Interface\\Icons\\Spell_Nature_NullifyPoison_02",
            warning = true,
            lines = {"Inflicts 300 Nature damage every 2 seconds for 10 seconds."}
        }, {
            -- CHANGED 2026-09-30: added from the combat log - spell 23849 in Spell.csv.
            name = "Venoxis Transform",
            spellId = 23849,
            icon = "Interface\\Icons\\Spell_Nature_Regeneration",
            warning = true,
            lines = {"Transforms into a snake, increasing damage done by 100% and regenerating health over time."}
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
            spellId = 23862,
            icon = "Interface\\Icons\\Spell_Nature_CorrosiveBreath",
            warning = true,
            roles = {"poison"},
            -- CHANGED 2026-09-30: spell 23862 in Spell.csv - 2000-2500 direct, 325-375 every 2s for 10s, stacks to 3 (old line said 850 + 200 every 5s).
            lines = {"Spits poison at an enemy for 2000 to 2500 Nature damage, then 325 to 375 Nature damage every 2 seconds for 10 seconds. Stacks up to 3 times."}
        }, {
            name = "Poison Cloud",
            spellId = 23861,
            icon = "Interface\\Icons\\Spell_Nature_NatureTouchDecay",
            warning = true,
            -- CHANGED 2026-09-30: spell 23861 in Spell.csv - 500 Nature/s in an 8 yard area for 20s; no slow in the data (data wins over the old 575/s + 50% slow).
            lines = {"Inflicts 500 Nature damage every second to enemies within 8 yards for 20 seconds. Move out of the cloud."}
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
            -- CHANGED 2026-09-30: added from the combat log - spell 24300 in Spell.csv.
            name = "Drain Life",
            spellId = 24300,
            icon = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
            warning = true,
            lines = {"Drains 500 health every second from an enemy for 7 seconds, transferring it to the caster."}
        }, {
            -- CHANGED 2026-09-30: added from the combat log - spell 24084 in Spell.csv.
            name = "Mar'li Transform",
            spellId = 24084,
            icon = "Interface\\Icons\\Spell_Nature_Regeneration",
            lines = {"Transforms into a spider, increasing critical strike chance by 10% and regenerating health over time."}
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
            spellId = 24023,
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
                spellId = 24312,
                icon = "Interface\\Icons\\Spell_Holy_InnerFire",
                -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 24312 - not reverse-engineered from raw effect codes.
                -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 24312).
                lines = {"Increases the caster's damage dealt by 30% and size by 20%, and heals it for 20000 to 25000. Stacks up to 99 times and does not expire."}
            }}
        }}
    },

    mandokir = {
        name = "Bloodlord Mandokir",
        icon = "Interface\\Icons\\temp",
        stats = {armor = 4950, fire = 44, nature = 75, frost = 12, shadow = 44, arcane = 44},
        abilities = {{
            -- spellId: 13736 is the cast, 15589 the damage.
            name = "Whirlwind",
            spellId = 13736,
            icon = "Interface\\Icons\\Ability_Whirlwind",
            warning = true,
            roles = {"melee"},
            -- CHANGED 2026-09-30: spells 13736 / 15589 in Spell.csv - hits within 8 yards for weapon damage plus 300 (+6 per caster level above 1, about 654 at level 60).
            lines = {"Spins in a whirlwind, hitting all enemies within 8 yards for weapon damage plus 300, plus 6 per caster level above 1 (about 654 at level 60). His most frequent ability."}
        }, {
            name = "Threatening Gaze",
            icon = "Interface\\Icons\\Ability_Hunter_AspectMastery",
            warning = true,
            lines = {"Mandokir watches a target closely - they must STOP ALL ACTIONS or they will pull aggro and be killed."}
        }, {
            name = "Charge",
            spellId = 24023,
            icon = "Interface\\Icons\\Ability_Warrior_Charge",
            warning = true,
            lines = {"Charges a distant target, dealing heavy damage."}
        }, {
            name = "Mortal Strike",
            icon = "Interface\\Icons\\Ability_Warrior_SavageBlow",
            roles = {"tank", "healer"},
            lines = {"A heavy strike that reduces healing received."}
        }, {
            -- CHANGED 2026-09-30: added from the combat log - spell 24316 in Spell.csv.
            name = "Guillotine",
            spellId = 24316,
            icon = "Interface\\Icons\\Ability_Warrior_Decapitate",
            warning = true,
            lines = {"Inflicts weapon damage plus 7500 to 12500."}
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
                spellId = 24317,
                icon = "Interface\\Icons\\Ability_Warrior_Sunder",
                -- CHANGED 2026-09-29: X filled from Spell.csv (spell 24317).
                lines = {"Hacks at an enemy's armor, reducing it by 1000 per Sunder Armor. Can be applied up to 5 times. Lasts 20 seconds."}
            }, {
                name = "Charge",
                spellId = 24023,
                icon = "Interface\\Icons\\Ability_Warrior_Charge",
                warning = true,
                -- CHANGED 2026-09-29: X filled from Spell.csv (spell 24408).
                lines = {"Charges an enemy, inflicting weapon damage and stuns the opponent for 2 seconds."}
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
            lines = {"Fire damage that chains to nearby targets ."}
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
            lines = {"Lightning that chains to nearby targets ."}
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
            -- CHANGED 2026-09-30: added from the combat log - spell 34911 in Spell.csv.
            name = "Acidic Ink",
            spellId = 34911,
            icon = "Interface\\Icons\\Spell_Nature_Acid_01",
            warning = true,
            lines = {"Reduces the armor of enemies within 8 yards by 75% for 20 seconds."}
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
            -- CHANGED 2026-09-30: added from the combat log - spell 34888 in Spell.csv.
            name = "Killing Frenzy",
            spellId = 34888,
            icon = "Interface\\Icons\\Ability_GhoulFrenzy",
            warning = true,
            lines = {"Increases attack speed by 100% for 15 seconds."}
        }, {
            -- CHANGED 2026-09-30: added from the combat log - spell 24169 in Spell.csv.
            name = "Thekal Transform",
            spellId = 24169,
            icon = "Interface\\Icons\\Spell_Nature_Regeneration",
            warning = true,
            lines = {"Transforms into a tiger, healing to full health and increasing attack speed by 100%."}
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
                spellId = 24023,
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
                spellId = 34758,
                icon = "Interface\\Icons\\Spell_Fire_SealOfFire",
                warning = true,
                -- CHANGED 2026-09-29: X filled from Spell.csv (spell 34758).
                lines = {"Summons a Fire Nova Totem that has 1000 health and lasts 5 seconds. Unless it is destroyed within 4 seconds, the totem inflicts 1996 to 2496 Fire damage to enemies within 13 yards."}
            }, {
                -- CHANGED: duration confirmed from Spell.xlsx (spell 34881) + SpellDuration.csv lookup - not in-game tested.
                name = "Lightning Shield",
                spellId = 34881,
                icon = "Interface\\Icons\\Spell_Nature_LightningShield",
                warning = true,
                -- CHANGED 2026-09-29: X filled from Spell.csv (spell 34881).
                -- CHANGED 2026-09-30: spell 34881 in Spell.csv is level-scaled - strike damage 8, +4 per caster level above 1, no cap unless stated.
                lines = {"Surrounds the caster with balls of lightning that have 100% chance of striking melee or ranged attackers for 8 damage plus 4 per caster level above 1 (about 244 at level 60). The shield expires after 10 minutes."}
            }, {
                name = "Disarm",
                spellId = 34887,
                icon = "Interface\\Icons\\Ability_Warrior_Disarm",
                warning = true,
                -- CHANGED 2026-09-29: X filled from Spell.csv (spell 34887).
                lines = {"Disarm the enemy's weapon for 10 seconds."}
            }}
        }, {
            name = "Zealot Zath",
            icon = "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice",
            lines = {"The rogue of the trio."},
            abilities = {{
                name = "Sinister Strike",
                spellId = 15667,
                icon = "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice",
                warning = true,
                -- CHANGED 2026-09-30: spell 15667 in Spell.csv is level-scaled - bonus 2, +2.4 per caster level above 20.
                lines = {"Inflicts weapon damage plus 2, plus 2.4 per caster level above 20 (about 98 at level 60) to an enemy."}
            }, {
                -- CHANGED: duration confirmed from Spell.xlsx (spell 21060) + SpellDuration.csv lookup - not in-game tested.
                name = "Blind",
                spellId = 21060,
                icon = "Interface\\Icons\\Spell_Shadow_MindSteal",
                warning = true,
                lines = {"Blinds the target and its nearby allies, causing them to wander confused for up to 10 seconds."}
            }, {
                name = "Gouge",
                spellId = 24698,
                icon = "Interface\\Icons\\Ability_Gouge",
                warning = true,
                -- CHANGED 2026-09-29: X filled from Spell.csv (spell 24698).
                lines = {"Inflicts 20 damage to an enemy and stuns it for up to 6 seconds. You will automatically stop attacking. Target must be facing you. Any damage received by the stunned target will revive it."}
            }, {
                -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
                name = "Cloak of Shadows",
                icon = "Interface\\Icons\\Spell_Shadow_NetherCloak",
                lines = {"Protects the rogue from spells for 5 seconds. Does not break stealth."}
            }, {
                name = "Wound Poison",
                spellId = 34883,
                icon = "Interface\\Icons\\INV_Misc_Herb_16",
                roles = {"dispel"},
                -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 34883 - not reverse-engineered from raw effect codes.
                -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 34883).
                lines = {"Reduces healing received by 150 for 30 seconds. Stacks up to 10 times."}
            }, {
                -- CHANGED: duration confirmed from Spell.xlsx (spell 34886) + SpellDuration.csv lookup - not in-game tested.
                name = "Sprint",
                spellId = 34886,
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
            spellId = 15589,
            icon = "Interface\\Icons\\Ability_Whirlwind",
            warning = true,
            roles = {"melee"},
            -- CHANGED 2026-09-30: spell 15589 in Spell.csv - hits within 8 yards for weapon damage plus 300 (+6 per caster level above 1, about 654 at level 60).
            lines = {"Spins in a whirlwind, hitting all enemies within 8 yards for weapon damage plus 300, plus 6 per caster level above 1 (about 654 at level 60). Her most frequent ability."}
        }, {
            -- CHANGED 2026-09-30: added from the combat log - spell 34890 in Spell.csv.
            name = "Hamstring",
            spellId = 34890,
            icon = "Interface\\Icons\\Ability_ShockWave",
            warning = true,
            lines = {"Inflicts weapon damage plus 1, plus 1 per caster level (about 61 at level 60), to an enemy and reduces its movement speed by 40% for 12 seconds."}
        }, {
            -- CHANGED 2026-09-30: added from the combat log - spell 24212 in Spell.csv.
            name = "Shadow Word: Pain",
            spellId = 24212,
            icon = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
            warning = true,
            lines = {"Inflicts 704 to 796 Shadow damage to an enemy every 3 seconds for 18 seconds."}
        }, {
            -- CHANGED 2026-09-30: added from the combat log - spell 1714 in Spell.csv.
            name = "Curse of Tongues",
            spellId = 1714,
            icon = "Interface\\Icons\\Spell_Shadow_CurseOfTounges",
            warning = true,
            lines = {"Slows the casting time of all spells by 40% for 30 seconds."}
        }, {
            -- CHANGED 2026-09-30: added from the combat log - spell 34891 in Spell.csv.
            name = "Strangulating Chainlink Lasso",
            spellId = 34891,
            icon = "Interface\\Icons\\Spell_Frost_ChainsOfIce",
            warning = true,
            lines = {"After 4 seconds, stuns the target for 30 seconds and inflicts 10% of its health as Frost damage every 2 seconds."}
        }, {
            -- CHANGED 2026-09-30: added from the combat log - spell 24210 in Spell.csv.
            name = "Mark of Arlokk",
            spellId = 24210,
            icon = "Interface\\Icons\\Spell_Shadow_CurseOfMannoroth",
            warning = true,
            lines = {"Pacifies the target for 60 seconds and generates 5000 threat against it every 2 seconds."}
        }, {
            -- CHANGED 2026-09-30: added from the combat log - spell 24190 in Spell.csv.
            name = "Arlokk Transform",
            spellId = 24190,
            icon = "Interface\\Icons\\Spell_Nature_Regeneration",
            lines = {"Transforms into a panther, increasing damage done by 50%."}
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
            spellId = 15582,
            icon = "Interface\\Icons\\Ability_BackStab",
            -- CHANGED 2026-09-30: spell 15582 in Spell.csv is level-scaled - bonus 30, +5.25 per caster level above 4.
            lines = {"Backstabs a target for weapon damage plus 30, plus 5.25 per caster level above 4 (about 324 at level 60)."}
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
            -- CHANGED 2026-09-30: added from the combat log - spell 24309 in Spell.csv.
            name = "Powerful Healing Ward",
            spellId = 24309,
            icon = "Interface\\Icons\\Spell_Holy_PrayerOfHealing02",
            warning = true,
            lines = {"Summons a ward that lasts 4 minutes and periodically heals allies in an area around it."}
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
            lines = {"Charms a player - damage increased by 300%, spells cast instantly, and resistances boosted."}
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
            lines = {"Deals 263 damage every 2 seconds and spreads to nearby players. His most frequent ability."}
        }, {
            name = "Blood Siphon",
            spellId = 24324,
            icon = "Interface\\Icons\\Spell_Shadow_LifeDrain",
            warning = true,
            roles = {"healer"},
            -- CHANGED 2026-09-30: spell 24324 in Spell.csv - script effect (100 yd) + 8s stun; no drain amount in the data (data wins over the old 700/s).
            lines = {"Stuns enemies within 100 yards for 8 seconds. X - the scripted effect is not in the spell data."}
        }, {
            name = "Curse of Nemesis",
            icon = "Interface\\Icons\\Spell_Shadow_CurseOfTounges",
            warning = true,
            roles = {"decurse"},
            lines = {"Deals 20% health damage every 2 seconds. If dispelled it causes instant Shadow damage."}
        }, {
            name = "Hysteria",
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            warning = true,
            lines = {"Increases the cost of spells and abilities. If you fail to cast three spells or abilities you become insane."}
        }, {
            -- CHANGED: added from "ZG 2.csv" (spell ID 24327) - real numbers from Spell.xlsx; duration confirmed from Spell.xlsx DurationIndex 18 + SpellDuration.csv (20000ms = 20s), not tested in-game.
            name = "Cause Insanity",
            spellId = 24327,
            icon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
            warning = true,
            lines = {"Drives an enemy target temporarily insane, speeding its attacks by 100% and its movement by 200%, as well as causing it to attack its own allies for 20 seconds."}
        }, {
            -- CHANGED: added from "ZG 2.csv" (spell ID 24689) - Description_enUS empty in Spell.xlsx, not reverse-engineered from raw effect codes.
            name = "Aspect of Thekal",
            spellId = 24689,
            icon = "Interface\\Icons\\Ability_Druid_ChallangingRoar",
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 24689).
            lines = {"Increases attack speed by 150% and size by 20% for 8 seconds."}
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
            spellId = 24023,
            icon = "Interface\\Icons\\Ability_Warrior_Charge",
            lines = {"Charges a distant target."}
        }, {
            -- CHANGED: added from "ZG 2.csv" (spell ID 34923) - Description_enUS empty in Spell.xlsx, not reverse-engineered from raw effect codes.
            name = "Rupture",
            spellId = 34923,
            icon = "Interface\\Icons\\Ability_Rogue_Rupture",
            warning = true,
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 34923).
            lines = {"Deals 15% of the target's maximum health every 2 seconds for 60 seconds."}
        }, {
            -- CHANGED: added from "ZG 2.csv" (spell ID 34919) - Description_enUS empty in Spell.xlsx, not reverse-engineered from raw effect codes.
            name = "Wound",
            spellId = 34919,
            icon = "Interface\\Icons\\Ability_CriticalStrike",
            warning = true,
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 34919).
            lines = {"Deals 100 Physical damage every 3 seconds and reduces healing received by 1% for 15 seconds. Stacks up to 100 times."}
        }, {
            -- CHANGED: added from "ZG 2.csv" (spell ID 34914) - Description_enUS empty in Spell.xlsx; raw base points (39999-70000) look like a sentinel/formula value rather than a real number, left as X rather than presented as real.
            name = "Thirst",
            spellId = 34914,
            icon = "Interface\\Icons\\Spell_Nature_BloodLust",
            -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 34914).
            lines = {"Heals the caster for 40000 to 70000."}
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
            spellId = 34938,
            icon = "Interface\\Icons\\Spell_Shadow_SummonFelHunter",
            -- CHANGED: Description_enUS empty in Spell.xlsx - number below computed from raw effect fields (spell ID 34938).
            warning = true,
            -- CHANGED 2026-09-30: spell 34938 in Spell.csv is level-scaled - damage 3000-3500, +2 per caster level, no cap unless stated.
            lines = {"Deals 3000 to 3500 damage plus 2 per caster level (about 3120 to 3620 at level 60) to an enemy."}
        }, {
            name = "Silence",
            spellId = 34930,
            icon = "Interface\\Icons\\Spell_Holy_Silence",
            warning = true,
            -- CHANGED 2026-09-29: X filled from Spell.csv (spell 34930).
            lines = {"Silences nearby enemies, preventing them from casting spells for 10 seconds."}
        }, {
            name = "Whirlwind",
            spellId = 1680,
            icon = "Interface\\Icons\\Ability_Whirlwind",
            warning = true,
            roles = {"melee"},
            -- CHANGED 2026-09-30: spell 1680 in Spell.csv - radius 8 yards; target count is not in the data.
            lines = {"Attacks nearby enemies within 8 yards, causing weapon damage to each."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 34934) + SpellDuration.csv lookup - not in-game tested.
            name = "Wild Charge",
            spellId = 34934,
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
                spellId = 34936,
                icon = "Interface\\Icons\\Spell_Shadow_CallofBone",
                warning = true,
                -- CHANGED 2026-09-29: written from Spell.csv effect/aura data (spell 34936).
                lines = {"Deals 10% of the target's maximum health every 10 seconds and increases its damage taken by 50% for 3 minutes."}
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
