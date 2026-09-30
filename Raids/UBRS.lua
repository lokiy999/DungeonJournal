-- Part of the DungeonJournal RAIDS database (see AGENTS.md "Data model").
-- Loaded via DungeonJournal.toc before DungeonJournal.lua; appends this
-- raid's table to the shared DungeonJournal_Raids list in load order.

DungeonJournal_Raids = DungeonJournal_Raids or {}

------------------------------------------------------------
-- UBRS order list - START HERE to reorder bosses.
--
-- UBRS_BOSS_ORDER is the only thing you should need to touch to change
-- what order bosses appear in the Bosses tab. Just a flat list of keys -
-- actual boss data (icon/flags/stats/abilities) lives further down in
-- UBRS_BOSSES, defined once per key and looked up from here.
------------------------------------------------------------

-- Boss encounter order (Bosses tab tree, top to bottom).
local UBRS_BOSS_ORDER = {
    "emberseer",
    "solakar",
    "goraluk",
    "jed",
    "rend",
    "gyth",
    "the_beast",
    "drakkisath",
    "valthalak",
}

-- CHANGED: trash roster sourced from a real combat log ("UBRS.csv" - Source/
-- Action/Spell ID columns), cross-matched against Spell.xlsx by exact Spell ID
-- for icons/descriptions, the same methodology used for SM_TRASH_ORDER. Pull
-- order/grouping is NOT known from that log (flat event list, no pull
-- boundaries), so this is just every distinct mob that logged an ability, in
-- no particular order - see TODO_Raid_Data.md.
local UBRS_TRASH_ORDER = {
    "blackhand_assassin",
    "blackhand_dreadweaver",
    "blackhand_elite",
    "blackhand_incarcerator",
    "blackhand_iron_guard",
    "blackhand_summoner",
    "blackhand_veteran",
    "burning_felhound",
    "burning_imp",
    "chromatic_dragonspawn",
    "chromatic_elite_guard",
    "chromatic_whelp",
    "rage_talon_captain",
    "rage_talon_dragon_guard",
    "rage_talon_dragonspawn",
    "rage_talon_fire_tongue",
    "rage_talon_flamescale",
    "rookery_guardian",
    "rookery_hatcher",
    "rookery_whelp",
    "scarshield_acolyte",
    "scarshield_legionnaire",
    "scarshield_spellbinder",
    "scarshield_warlock",
    "spectral_assassin",
}

------------------------------------------------------------
-- Trash mob registry - one entry per distinct trash mob (icon/flags/
-- stats/abilities), referenced by key from UBRS_TRASH_ORDER above.
------------------------------------------------------------
local UBRS_TRASH_MOBS = {
    blackhand_assassin = {
        name = "Blackhand Assassin",
        icon = "Interface\\Icons\\Ability_BackStab",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Backstab",
            icon = "Interface\\Icons\\Ability_BackStab",
            warning = true,
            lines = {"Inflicts normal damage plus 30 to an enemy, but only if attacking from behind."}
        },
        {
            name = "Blind",
            icon = "Interface\\Icons\\Spell_Shadow_MindSteal",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 2094).
            lines = {"Blinds the target, causing it to wander disoriented for up to 1 minute. Any damage caused will remove the effect."}
        },
        {
            name = "Eviscerate",
            icon = "Interface\\Icons\\Ability_Rogue_Eviscerate",
            warning = true,
            lines = {"X - no ability description available."}
        },
        {
            name = "Gouge",
            icon = "Interface\\Icons\\Ability_Gouge",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 12540).
            lines = {"Inflicts 20 damage to an enemy and stuns it for up to 8 seconds. Target must be facing the caster. Any damage received by the stunned target will revive it."}
        },
        {
            name = "Kidney Shot",
            icon = "Interface\\Icons\\Ability_Rogue_KidneyShot",
            warning = true,
            lines = {"Finishing move that stuns the target."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 6434) + SpellDuration.csv lookup - not in-game tested.
            name = "Slice and Dice",
            icon = "Interface\\Icons\\Ability_Rogue_SliceDice",
            lines = {"Increases the caster's attack speed by 30% for 10 seconds."}
        }
        }
    },

    blackhand_dreadweaver = {
        name = "Blackhand Dreadweaver",
        icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
        flags = {"caster"},
        -- CHANGED: merged with "Summoned Blackhand Dreadweaver" (necromancer-summoned) - it logs the same 3 spells
        -- (Curse of Thorns, Death Coil, Shadow Bolt) as a strict subset of this mob's kit, so it reads as the same
        -- unit type rather than a distinct pack; not listed separately.
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Curse of Thorns",
            icon = "Interface\\Icons\\Spell_Shadow_AntiShadow",
            warning = true,
            roles = {"decurse"},
            -- CHANGED 2026-09-29: from Spell.csv (spell 16247).
            lines = {"Curses an enemy for 3 minutes, giving it a 50% chance to take 38 to 82 damage on attack."}
        },
        {
            name = "Death Coil",
            icon = "Interface\\Icons\\Spell_Shadow_DeathCoil",
            warning = true,
            lines = {"Causes 400 to 700 Shadow damage to the enemy. The caster gains 100% of the damage caused as health."}
        },
        {
            name = "Howl of Terror",
            icon = "Interface\\Icons\\Spell_Shadow_DeathScream",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 17928).
            lines = {"Howl, causing up to X enemies within 10 yards to flee in terror for 15 seconds. Damage caused may interrupt the effect."}
        },
        {
            name = "Shadow Bolt",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            warning = true,
            roles = {"kick"},
            lines = {"Hurls a bolt of dark magic at an enemy, inflicting 156 to 200 Shadow damage."}
        },
        {
            name = "Veil of Shadow",
            icon = "Interface\\Icons\\Spell_Shadow_GatherShadows",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 7068).
            lines = {"Reduces healing effects on an enemy by 75% for 15 seconds."}
        }
        }
    },

    blackhand_elite = {
        name = "Blackhand Elite",
        icon = "Interface\\Icons\\INV_Gauntlets_05",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Backhand",
            icon = "Interface\\Icons\\INV_Gauntlets_05",
            warning = true,
            lines = {"Backhands an enemy, stunning it for 2 seconds."}
        },
        {
            name = "Head Crack",
            icon = "Interface\\Icons\\Ability_ThunderBolt",
            -- CHANGED 2026-09-29: spell 16172 in Spell.csv is level-scaled - base -1 at level 1, -1 per level, no cap.
            lines = {"Reduces an enemy's Stamina by an amount equal to the caster's level (e.g. 60 at level 60) for 20 seconds."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Mortal Strike",
            icon = "Interface\\Icons\\Ability_Warrior_SavageBlow",
            warning = true,
            lines = {"Inflicts 150% weapon damage to an enemy and leaves it wounded, reducing the effectiveness of any healing on it by 50% for 5 seconds."}
        },
        {
            name = "Sap Visual",
            icon = "Interface\\Icons\\Ability_Sap",
            -- CHANGED 2026-09-29: from Spell.csv (spell 35762).
            lines = {"X - a scripted Dummy effect (1 yard) with no values in the spell data; the name suggests a cosmetic sap animation."}
        },
        {
            name = "Retaliation",
            icon = "Interface\\Icons\\Ability_Warrior_Challange",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 22857).
            lines = {
                "Instantly counterattacks any enemy that strikes it in melee for 15 seconds. Attacks from behind cannot be counterattacked.",
                "(Spell ID 22858 is a companion trigger for this same effect, not a separate ability.)"
            }
        },
        {
            name = "Strike",
            icon = "Interface\\Icons\\Ability_Rogue_Ambush",
            lines = {"Strikes at an enemy, inflicting increased melee damage."}
        }
        }
    },

    blackhand_incarcerator = {
        name = "Blackhand Incarcerator",
        icon = "Interface\\Icons\\Ability_ThunderBolt",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell 16045) + SpellDuration.csv lookup - not in-game tested.
            name = "Encage",
            icon = "Interface\\Icons\\Ability_ThunderBolt",
            warning = true,
            lines = {"Encages an enemy, stunning it for 30 seconds."}
        },
        {
            name = "Strike",
            icon = "Interface\\Icons\\Ability_Rogue_Ambush",
            lines = {"Strikes at an enemy, inflicting increased melee damage."}
        }
        }
    },

    blackhand_iron_guard = {
        name = "Blackhand Iron Guard",
        icon = "Interface\\Icons\\Ability_Warrior_ShieldWall",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Shield Reflection",
            icon = "Interface\\Icons\\Ability_Warrior_ShieldReflection",
            -- CHANGED 2026-09-29: from Spell.csv (spell 34073).
            lines = {"Raises its shield, reflecting a spell cast on it. Lasts 5 seconds, but will only reflect 1 spell."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Shield Slam",
            icon = "Interface\\Icons\\Ability_Warrior_ShieldBash",
            warning = true,
            lines = {"Inflicts 100 to 300 damage to an enemy, stunning it for 2 seconds."}
        },
        {
            name = "Shield Toss",
            icon = "Interface\\Icons\\Ability_UpgradeMoonGlaive",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 34130).
            lines = {
                "Hurls a shield at the enemy, causing 308 to 348 damage (increased by Attack Power) and knocks it down for 2 seconds.",
                "This ability causes a high amount of threat."
            }
        },
        {
            name = "Shield Wall",
            icon = "Interface\\Icons\\Ability_Warrior_ShieldWall",
            -- CHANGED 2026-09-29: from Spell.csv (spell 15062).
            lines = {"Reduces the Physical and magical damage taken by the caster by 75% for 10 seconds."}
        },
        {
            separator = true,
            passive = true,
            name = "Passives"
        },
        {
            -- CHANGED: percentages resolved from Spell.xlsx spell ID 7376 (the linked passive), not from in-game testing.
            name = "Defensive Stance",
            icon = "Interface\\Icons\\Ability_Warrior_DefensiveStance",
            lines = {"A defensive stance. Decreases damage taken from all sources by 10%. Decreases damage caused by 10%. Increases threat generated by 30%."}
        }
        }
    },

    blackhand_summoner = {
        name = "Blackhand Summoner",
        icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
        flags = {"caster"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Fireball",
            icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 12466).
            lines = {"Inflicts 258 to 332 Fire damage to an enemy."}
        },
        {
            name = "Frost Nova",
            icon = "Interface\\Icons\\Spell_Frost_FrostNova",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 15532).
            lines = {"Inflicts 42 to 48 Frost damage to enemies within 10 yards, immobilizing them for up to 8 seconds."}
        },
        {
            name = "Summon Blackhand Dreadweaver",
            icon = "Interface\\Icons\\Spell_Shadow_Charm",
            lines = {"Summons a Blackhand Dreadweaver to aid it in battle."}
        },
        {
            name = "Summon Blackhand Veteran",
            icon = "Interface\\Icons\\Spell_Shadow_Charm",
            lines = {"Summons a Blackhand Veteran to aid it in battle."}
        }
        }
    },

    blackhand_veteran = {
        name = "Blackhand Veteran",
        icon = "Interface\\Icons\\Ability_Warrior_ShieldBash",
        flags = {"melee"},
        -- CHANGED: merged with "Summoned Blackhand Veteran" (necromancer-summoned) - it logs the same 3 spells
        -- (Dazed, Shield Charge, Strike) as a strict subset of this mob's kit, so it reads as the same unit
        -- type rather than a distinct pack; not listed separately.
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Sap Visual",
            icon = "Interface\\Icons\\Ability_Sap",
            -- CHANGED 2026-09-29: from Spell.csv (spell 35762).
            lines = {"X - a scripted Dummy effect (1 yard) with no values in the spell data; the name suggests a cosmetic sap animation."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 11972) + SpellDuration.csv lookup - not in-game tested.
            name = "Shield Bash",
            icon = "Interface\\Icons\\Ability_Warrior_ShieldBash",
            warning = true,
            roles = {"kick"},
            lines = {"Bashes an enemy with the caster's shield, inflicting Physical damage and interrupting the spell being cast for 8 seconds."}
        },
        {
            name = "Shield Charge",
            icon = "Interface\\Icons\\Ability_Warrior_Charge",
            warning = true,
            lines = {"Charges an enemy, knocking it back and inflicting normal damage plus 150."}
        },
        {
            name = "Strike",
            icon = "Interface\\Icons\\Ability_Rogue_Ambush",
            lines = {"Strikes at an enemy, inflicting increased melee damage."}
        }
        }
    },

    burning_felhound = {
        name = "Burning Felhound",
        icon = "Interface\\Icons\\Spell_Shadow_ManaBurn",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Mana Burn",
            icon = "Interface\\Icons\\Spell_Shadow_ManaBurn",
            warning = true,
            lines = {"Hits an enemy with an anti-mana bolt, draining 177 to 205 mana; each point of mana consumed deals X damage to the target (per-point value lives on a separate linked effect not captured in this pass)."}
        }
        }
    },

    burning_imp = {
        name = "Burning Imp",
        icon = "Interface\\Icons\\Spell_Fire_FireBolt",
        flags = {"caster"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Firebolt",
            icon = "Interface\\Icons\\Spell_Fire_FireBolt",
            warning = true,
            lines = {"Shoots a bolt of flame at an enemy, inflicting 60 to 80 Fire damage."}
        }
        }
    },

    chromatic_dragonspawn = {
        name = "Chromatic Dragonspawn",
        icon = "Interface\\Icons\\Ability_Warrior_Cleave",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Cleave",
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            warning = true,
            lines = {"Inflicts weapon damage plus 10 to all enemies in front of the caster."}
        },
        {
            name = "Strike",
            icon = "Interface\\Icons\\Ability_Rogue_Ambush",
            lines = {"Strikes at an enemy, inflicting increased melee damage."}
        }
        }
    },

    chromatic_elite_guard = {
        name = "Chromatic Elite Guard",
        icon = "Interface\\Icons\\Ability_Warrior_Sunder",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Cleave",
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            warning = true,
            lines = {"Inflicts weapon damage plus 10 to all enemies in front of the caster."}
        },
        {
            name = "Hate to 50%",
            icon = "Interface\\Icons\\Spell_Shadow_SacrificialShield",
            lines = {"X - no ability description available (internal threat-reset mechanic, name implies it drops the caster's target to 50% threat)."}
        },
        {
            name = "Knockdown",
            icon = "Interface\\Icons\\Ability_GolemThunderClap",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 16790).
            lines = {"Inflicts 60 to 80 damage to an enemy and its nearest allies, stunning them for 2 seconds. Affects up to 3 targets."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Mortal Strike",
            icon = "Interface\\Icons\\Ability_Warrior_SavageBlow",
            warning = true,
            lines = {"Inflicts 300% weapon damage and leaves the target wounded, reducing the effectiveness of any healing by 50% for 5 seconds."}
        },
        {
            name = "Strike",
            icon = "Interface\\Icons\\Ability_Rogue_Ambush",
            lines = {"Strikes at an enemy, inflicting increased melee damage."}
        },
        {
            name = "Sunder Armor",
            icon = "Interface\\Icons\\Ability_Warrior_Sunder",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 24317).
            lines = {"Hacks at an enemy's armor, reducing it by 1000 per stack (up to 5 stacks). Lasts 20 seconds."}
        }
        }
    },

    chromatic_whelp = {
        name = "Chromatic Whelp",
        icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
        flags = {"caster"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Fireball Volley",
            icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
            warning = true,
            lines = {"Inflicts 97 to 129 Fire damage to nearby enemies."}
        },
        {
            name = "Frostbolt",
            icon = "Interface\\Icons\\Spell_Frost_FrostBolt02",
            warning = true,
            roles = {"kick"},
            -- CHANGED 2026-09-29: from Spell.csv (spell 16249).
            lines = {"Inflicts 72 to 96 Frost damage to an enemy and reduces its movement speed by 50% for 4 seconds."}
        },
        {
            name = "Lightning Bolt",
            icon = "Interface\\Icons\\Spell_Nature_Lightning",
            warning = true,
            roles = {"kick"},
            lines = {"Blasts an enemy with lightning, inflicting 96 to 128 Nature damage."}
        }
        }
    },

    rage_talon_captain = {
        name = "Rage Talon Captain",
        icon = "Interface\\Icons\\Ability_Warrior_Cleave",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Arcing Smash",
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            warning = true,
            lines = {"Lashes out in a vicious arc, inflicting normal damage plus 5 to enemies in a cone in front of the caster."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Demoralizing Shout",
            icon = "Interface\\Icons\\Ability_Warrior_WarCry",
            warning = true,
            lines = {"Reduces the melee and ranged attack power of nearby enemies by 300, for 30 seconds."}
        },
        {
            name = "Empower Will",
            icon = "Interface\\Icons\\Ability_Warrior_BattleShout",
            lines = {"Dispels 1 polymorph, charm, or knockout effect from nearby allies."}
        },
        {
            name = "Knock Away",
            icon = "Interface\\Icons\\INV_Gauntlets_05",
            warning = true,
            lines = {"Inflicts normal damage plus 30 to an enemy and knocks it back."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Mortal Strike",
            icon = "Interface\\Icons\\Ability_Warrior_SavageBlow",
            warning = true,
            lines = {"Inflicts 300% weapon damage and leaves the target wounded, reducing the effectiveness of any healing by 50% for 5 seconds."}
        }
        }
    },

    rage_talon_dragon_guard = {
        name = "Rage Talon Dragon Guard",
        icon = "Interface\\Icons\\Ability_Warrior_ShieldReflection",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Cleave",
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            warning = true,
            lines = {"Inflicts weapon damage plus 10 to all enemies in front of the caster."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 22427) + SpellDuration.csv lookup - not in-game tested.
            name = "Concussion Blow",
            icon = "Interface\\Icons\\Ability_ThunderBolt",
            warning = true,
            lines = {"A brutal strike that deals weapon damage and stuns the opponent for 5 seconds."}
        },
        {
            name = "Hate to 50%",
            icon = "Interface\\Icons\\Spell_Shadow_SacrificialShield",
            lines = {"X - no ability description available (internal threat-reset mechanic, name implies it drops the caster's target to 50% threat)."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Shield Reflection",
            icon = "Interface\\Icons\\Ability_Warrior_ShieldReflection",
            -- CHANGED 2026-09-29: from Spell.csv (spell 34073).
            lines = {"Raises its shield, reflecting a spell cast on it. Lasts 5 seconds, but will only reflect 1 spell."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Shield Slam",
            icon = "Interface\\Icons\\Ability_Warrior_ShieldBash",
            warning = true,
            lines = {"Inflicts 100 to 300 damage to an enemy, stunning it for 2 seconds."}
        },
        {
            -- CHANGED: TODO previously claimed no per-stack amount could be
            -- pulled for spell 16145 - it's actually there (EffectBasePoints_1
            -- -25, +1 = 24), just a much smaller value than the 1000-per-stack
            -- rank (24317) used elsewhere in this file; used as-is rather than
            -- borrowed from another rank.
            name = "Sunder Armor",
            icon = "Interface\\Icons\\Ability_Warrior_Sunder",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 16145).
            lines = {"Hacks at an enemy's armor, reducing it by 24 per stack (up to 5 stacks). Lasts 30 seconds."}
        }
        }
    },

    rage_talon_dragonspawn = {
        name = "Rage Talon Dragonspawn",
        icon = "Interface\\Icons\\Ability_Warrior_Charge",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Charge",
            icon = "Interface\\Icons\\Ability_Warrior_Charge",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 24023).
            lines = {"Charges an enemy, inflicting normal damage plus 1 and stuns the opponent for X seconds (no duration in the spell data)."}
        },
        {
            name = "Enrage",
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            -- CHANGED 2026-09-29: from Spell.csv (spell 8269).
            lines = {"Increases the caster's attack speed by 60% and the Physical damage it deals by 50, for 2 minutes."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 12021) + SpellDuration.csv lookup - not in-game tested.
            name = "Fixate",
            icon = "Interface\\Icons\\Spell_Shadow_Charm",
            lines = {"Causes an enemy to fixate upon the caster and increases the caster's attack speed by 50% for 10 seconds. While fixated, the target is very reluctant to attack anything else."}
        },
        {
            name = "Strike",
            icon = "Interface\\Icons\\Ability_Rogue_Ambush",
            lines = {"Strikes at an enemy, inflicting increased melee damage."}
        },
        {
            name = "Sunder Armor",
            icon = "Interface\\Icons\\Ability_Warrior_Sunder",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 24317).
            lines = {"Hacks at an enemy's armor, reducing it by 1000 per stack (up to 5 stacks). Lasts 20 seconds."}
        },
        {
            name = "Sweeping Strikes",
            icon = "Interface\\Icons\\Ability_Rogue_SliceDice",
            lines = {"Its next X melee weapon swings strike an additional nearby opponent."}
        }
        }
    },

    rage_talon_fire_tongue = {
        name = "Rage Talon Fire Tongue",
        icon = "Interface\\Icons\\Spell_Fire_Incinerate",
        flags = {"caster"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Conflagration",
            icon = "Interface\\Icons\\Spell_Fire_Incinerate",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 34418).
            lines = {"Burns enemies within 5 yards for 100 Fire damage every second for 10 seconds."}
        },
        {
            name = "Fire Blast",
            icon = "Interface\\Icons\\Spell_Fire_Fireball",
            warning = true,
            lines = {"Inflicts 360 Fire damage to an enemy."}
        },
        {
            name = "Fire Nova",
            icon = "Interface\\Icons\\Spell_Fire_SealOfFire",
            warning = true,
            lines = {"Inflicts 148 to 170 Fire damage to nearby enemies."}
        },
        {
            name = "Fireball Volley",
            icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
            warning = true,
            lines = {"Inflicts 128 to 172 Fire damage to nearby enemies."}
        },
        {
            name = "Flame Buffet",
            icon = "Interface\\Icons\\Spell_Fire_Fireball",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 16168).
            lines = {"Inflicts 555 to 645 Fire damage to an enemy and increases the Fire damage it takes by 300, for 20 seconds."}
        }
        }
    },

    rage_talon_flamescale = {
        name = "Rage Talon Flamescale",
        icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
        flags = {"caster"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Conflagration",
            icon = "Interface\\Icons\\Spell_Fire_Incinerate",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 34418).
            lines = {"Burns enemies within 5 yards for 100 Fire damage every second for 10 seconds."}
        },
        {
            name = "Fire Nova",
            icon = "Interface\\Icons\\Spell_Fire_SealOfFire",
            warning = true,
            lines = {"Inflicts 298 to 320 Fire damage to nearby enemies."}
        },
        {
            name = "Fireball Volley",
            icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
            warning = true,
            lines = {"Inflicts 128 to 172 Fire damage to nearby enemies."}
        },
        {
            name = "Flamestrike",
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 16102).
            lines = {"Calls down a pillar of flame, burning all enemies in the area for 228 to 264 Fire damage plus an additional 48 damage every 2 seconds, for 8 seconds."}
        }
        }
    },

    rookery_guardian = {
        name = "Rookery Guardian",
        icon = "Interface\\Icons\\Ability_Warrior_Cleave",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Strike",
            icon = "Interface\\Icons\\Ability_Rogue_Ambush",
            lines = {"Strikes at an enemy, inflicting increased melee damage."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 8255) + SpellDuration.csv lookup - not in-game tested.
            name = "Strong Cleave",
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            warning = true,
            lines = {"Inflicts normal damage plus 55 to an enemy and its nearest allies, increasing the time between their attacks by 33%, for 10 seconds."}
        },
        {
            name = "Sunder Armor",
            icon = "Interface\\Icons\\Ability_Warrior_Sunder",
            warning = true,
            -- CHANGED 2026-09-29: spell 15572 in Spell.csv is level-scaled - base 0, -12 armor per caster level, no cap.
            lines = {"Hacks at an enemy's armor, reducing it by 12 per caster level per stack (about 700 at level 60). Stacks up to 5 times, lasts 30 seconds."}
        }
        }
    },

    rookery_hatcher = {
        name = "Rookery Hatcher",
        icon = "Interface\\Icons\\Temp",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Disturb Rookery Egg",
            icon = "Interface\\Icons\\Temp",
            -- CHANGED 2026-09-29: from Spell.csv (spell 15746).
            lines = {"Activates a nearby Rookery Egg (Activate Object effect)."}
        },
        {
            name = "Strike",
            icon = "Interface\\Icons\\Ability_Rogue_Ambush",
            lines = {"Strikes at an enemy, inflicting increased melee damage."}
        },
        {
            name = "Sunder Armor",
            icon = "Interface\\Icons\\Ability_Warrior_Sunder",
            warning = true,
            -- CHANGED 2026-09-29: spell 15572 in Spell.csv is level-scaled - base 0, -12 armor per caster level, no cap.
            lines = {"Hacks at an enemy's armor, reducing it by 12 per caster level per stack (about 700 at level 60). Stacks up to 5 times, lasts 30 seconds."}
        }
        }
    },

    rookery_whelp = {
        name = "Rookery Whelp",
        icon = "Interface\\Icons\\Spell_Frost_Stun",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
    },

    scarshield_acolyte = {
        name = "Scarshield Acolyte",
        icon = "Interface\\Icons\\Spell_Holy_DispelMagic",
        flags = {"caster"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Dispel Magic",
            icon = "Interface\\Icons\\Spell_Holy_DispelMagic",
            roles = {"dispel"},
            lines = {"Dispels magic on the target, removing 1 harmful spell from an ally or 1 beneficial spell from an enemy."}
        },
        {
            name = "Shadow Word: Pain",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
            warning = true,
            roles = {"dispel"},
            -- CHANGED 2026-09-29: from Spell.csv (spell 14032).
            lines = {"Utters a word of darkness, inflicting 70 Shadow damage to an enemy every 3 seconds, for 18 seconds."}
        }
        }
    },

    scarshield_legionnaire = {
        name = "Scarshield Legionnaire",
        icon = "Interface\\Icons\\Ability_Warrior_Cleave",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Cleave",
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            warning = true,
            lines = {"Inflicts weapon damage plus 10 to an enemy and its nearest ally."}
        },
        {
            name = "Hate to 50%",
            icon = "Interface\\Icons\\Spell_Shadow_SacrificialShield",
            lines = {"X - no ability description available (internal threat-reset mechanic, name implies it drops the caster's target to 50% threat)."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 11972) + SpellDuration.csv lookup - not in-game tested.
            name = "Shield Bash",
            icon = "Interface\\Icons\\Ability_Warrior_ShieldBash",
            warning = true,
            roles = {"kick"},
            lines = {"Bashes an enemy with the caster's shield, inflicting Physical damage and interrupting the spell being cast for 8 seconds."}
        },
        {
            name = "Shield Charge",
            icon = "Interface\\Icons\\Ability_Warrior_Charge",
            warning = true,
            lines = {"Charges an enemy, knocking it back and inflicting normal damage plus 150."}
        },
        {
            separator = true,
            passive = true,
            name = "Passives"
        },
        {
            name = "Improved Blocking",
            icon = "Interface\\Icons\\Spell_Fire_FireArmor",
            -- CHANGED 2026-09-29: from Spell.csv (spell 3248).
            lines = {"Increases the caster's chance to block by 55%, for 10 seconds."}
        }
        }
    },

    scarshield_spellbinder = {
        name = "Scarshield Spellbinder",
        icon = "Interface\\Icons\\Spell_Arcane_StarFire",
        flags = {"caster"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Arcane Bolt",
            icon = "Interface\\Icons\\Spell_Arcane_StarFire",
            warning = true,
            roles = {"kick"},
            lines = {"Hurls a magical bolt at an enemy, inflicting 155 to 205 Arcane damage."}
        },
        {
            name = "Blast Wave",
            icon = "Interface\\Icons\\Spell_Holy_Excorcism_02",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 13021).
            lines = {"A wave of flame radiates outward from the caster, damaging all enemies caught within the blast for 462 to 544 Fire damage and dazing them for 6 seconds."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Counterspell",
            icon = "Interface\\Icons\\Spell_Frost_IceShock",
            warning = true,
            lines = {"Counters an enemy's spell, preventing the enemy from casting that spell again for 15 seconds. Generates a high amount of threat."}
        },
        {
            name = "Frost Nova",
            icon = "Interface\\Icons\\Spell_Frost_FrostNova",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 22645).
            lines = {"Inflicts 111 to 129 Frost damage to nearby enemies, immobilizing them for up to 8 seconds."}
        },
        {
            name = "Greater Polymorph",
            icon = "Interface\\Icons\\Spell_Nature_Brilliance",
            warning = true,
            roles = {"dispel"},
            -- CHANGED 2026-09-29: from Spell.csv (spell 22274).
            lines = {
                "Transforms an enemy into a sheep, forcing it to wander around for up to 20 seconds. While wandering, the sheep cannot attack or cast spells, but regenerates quickly.",
                "Only one target can be polymorphed at a time. Only works on beasts, dragons, giants, humanoids, and critters."
            }
        },
        {
            name = "Mana Burn",
            icon = "Interface\\Icons\\Spell_Shadow_ManaBurn",
            warning = true,
            lines = {"Hits an enemy with an anti-mana bolt, draining 363 to 401 mana; each point of mana consumed deals X damage to the target (per-point value lives on a separate linked effect not captured in this pass)."}
        },
        {
            name = "Resist Fire",
            icon = "Interface\\Icons\\Spell_Fire_FireArmor",
            -- CHANGED 2026-09-29: spell 15123 in Spell.csv - base 2, +1.5 per caster level, no cap.
            lines = {"Increases an ally's Fire resistance for 2 hours. Scales with the caster's level: 2 plus 1.5 per level above 1 (X - exact amount depends on the mob's level)."}
        }
        }
    },

    scarshield_warlock = {
        name = "Scarshield Warlock",
        icon = "Interface\\Icons\\Spell_Shadow_Possession",
        flags = {"caster"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Fear",
            icon = "Interface\\Icons\\Spell_Shadow_Possession",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 6215).
            lines = {"Strikes fear in the enemy, causing it to run in terror for up to 20 seconds. Damage caused may interrupt the effect. Only 1 target can be feared at a time."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 15125) + SpellDuration.csv lookup - not in-game tested.
            name = "Scarshield Portal",
            icon = "Interface\\Icons\\Spell_Arcane_TeleportOrgrimmar",
            lines = {"Opens a portal into the Twisting Nether that periodically summons demonic minions to aid the caster in battle, for 30 seconds."}
        },
        {
            name = "Shadow Bolt",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            warning = true,
            roles = {"kick"},
            lines = {"Hurls a bolt of dark magic at an enemy, inflicting 145 to 177 Shadow damage."}
        }
        }
    },

    spectral_assassin = {
        name = "Spectral Assassin",
        icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Defile",
            icon = "Interface\\Icons\\Spell_Shadow_GatherShadows",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 27177).
            lines = {"Stuns the target for 10 seconds and pulses every second. X - what each pulse does is not in the spell data."}
        },
        {
            name = "Shadow Shock",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            warning = true,
            lines = {"Instantly lashes an enemy with dark magic, inflicting 210 to 242 Shadow damage."}
        }
        }
    },

}

------------------------------------------------------------
-- Boss registry - one entry per boss (icon/flags/stats/abilities/adds),
-- referenced by key from UBRS_BOSS_ORDER above. Defined once each; add a
-- new boss here and add its key to UBRS_BOSS_ORDER to place it.
------------------------------------------------------------
local UBRS_BOSSES = {
    emberseer = {
        name = "Pyroguard Emberseer",
        icon = "Interface\\Icons\\temp",
        -- CHANGED: real abilities from a combat log (UBRS.csv), cross-matched against
        -- Spell.xlsx by exact Spell ID - see TODO_Raid_Data.md for gaps left as X.
        abilities = {
        {
            name = "Emberseer Growing",
            icon = "Interface\\Icons\\Ability_GolemThunderClap",
            -- CHANGED 2026-09-29: from Spell.csv (spell 16049).
            lines = {"Grows 5% larger per stack, stacking up to 50 times; never expires. Also has a scripted Dummy effect."}
        },
        {
            name = "Flame Buffet",
            icon = "Interface\\Icons\\Spell_Fire_Fireball",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 23341).
            lines = {"Inflicts 150 to 300 Fire damage to an enemy and increases the Fire damage it takes by 200, for 20 seconds."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 20228) + SpellDuration.csv lookup - not in-game tested.
            name = "Pyroblast",
            icon = "Interface\\Icons\\Spell_Fire_Fireball02",
            warning = true,
            roles = {"kick"},
            lines = {"Inflicts 3588 to 4512 Fire damage to an enemy and scorches the target for an additional 474 damage every 12 seconds, for 12 seconds."}
        },
        {
            name = "Fire Nova",
            icon = "Interface\\Icons\\Spell_Fire_SealOfFire",
            warning = true,
            lines = {"Inflicts 955 to 1155 Fire damage to nearby enemies."}
        }
        }
    },

    solakar = {
        name = "Solakar Flamewreath",
        icon = "Interface\\Icons\\temp",
        -- CHANGED: real abilities from a combat log (UBRS.csv), cross-matched against
        -- Spell.xlsx by exact Spell ID - see TODO_Raid_Data.md for gaps left as X.
        abilities = {
        {
            name = "Conflagration",
            icon = "Interface\\Icons\\Spell_Fire_Incinerate",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 34418).
            lines = {"Burns enemies within 5 yards for 100 Fire damage every second for 10 seconds."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 8255) + SpellDuration.csv lookup - not in-game tested.
            name = "Strong Cleave",
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            warning = true,
            lines = {"Inflicts normal damage plus 55 to an enemy and its nearest allies, increasing the time between their attacks by 33%, for 10 seconds."}
        },
        {
            name = "Fire Storm",
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 13899).
            lines = {"Calls down a pillar of flame, burning all enemies in the area for 475 to 627 Fire damage plus an additional 375 to 465 damage every 2 seconds, for 30 seconds."}
        },
        {
            name = "War Stomp",
            icon = "Interface\\Icons\\Ability_BullRush",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 16727).
            lines = {"Inflicts normal damage plus 50 to nearby enemies, knocking them back and stunning them for 5 seconds."}
        },
        {
            name = "Hate to 50%",
            icon = "Interface\\Icons\\Spell_Shadow_SacrificialShield",
            lines = {"X - no ability description available (internal threat-reset mechanic, name implies it drops the caster's target to 50% threat)."}
        }
        }
    },

    goraluk = {
        name = "Goraluk Anvilcrack",
        icon = "Interface\\Icons\\temp",
        -- CHANGED: real abilities from a combat log (UBRS.csv), cross-matched against
        -- Spell.xlsx by exact Spell ID - see TODO_Raid_Data.md for gaps left as X.
        abilities = {
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Backhand",
            icon = "Interface\\Icons\\INV_Gauntlets_05",
            warning = true,
            lines = {"Backhands an enemy, stunning it for 2 seconds."}
        },
        {
            name = "Head Crack",
            icon = "Interface\\Icons\\Ability_ThunderBolt",
            -- CHANGED 2026-09-29: spell 16172 in Spell.csv is level-scaled - base -1 at level 1, -1 per level, no cap.
            lines = {"Reduces an enemy's Stamina by an amount equal to the caster's level (e.g. 60 at level 60) for 20 seconds."}
        },
        {
            name = "Strike",
            icon = "Interface\\Icons\\Ability_Rogue_Ambush",
            lines = {"Strikes at an enemy, inflicting increased melee damage."}
        },
        {
            name = "Brutal Blow",
            icon = "Interface\\Icons\\Spell_Shadow_VampiricAura",
            warning = true,
            lines = {"Attacks the target, causing damage equal to 50% of its target's current Health."}
        },
        {
            name = "Hate to 50%",
            icon = "Interface\\Icons\\Spell_Shadow_SacrificialShield",
            lines = {"X - no ability description available (internal threat-reset mechanic, name implies it drops the caster's target to 50% threat)."}
        }
        }
    },

    jed = {
        name = "Jed Runewatcher",
        icon = "Interface\\Icons\\temp",
        -- CHANGED: no combat data for Jed Runewatcher in UBRS.csv - left as placeholder,
        -- see TODO_Raid_Data.md.
        abilities = {{
            name = "Jed Runewatcher's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    },

    rend = {
        name = "Warchief Rend Blackhand",
        icon = "Interface\\Icons\\temp",
        -- CHANGED: real abilities from a combat log (UBRS.csv), cross-matched against
        -- Spell.xlsx by exact Spell ID - see TODO_Raid_Data.md for gaps left as X.
        abilities = {
        {
            name = "Cleave",
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            warning = true,
            lines = {"Inflicts weapon damage plus 10 to all enemies in front of the caster."}
        },
        {
            name = "Disarm",
            icon = "Interface\\Icons\\Ability_Warrior_Disarm",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 13534).
            lines = {"Disarms the target's weapon for 10 seconds."}
        },
        {
            name = "Enrage",
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            -- CHANGED 2026-09-29: from Spell.csv (spell 8269).
            lines = {"Increases the caster's attack speed by 60% and the Physical damage it deals by 50, for 2 minutes."}
        },
        {
            -- CHANGED: merges two logged ranks (spell 19134, real description;
            -- a second rank with no separate Spell.xlsx description that reused
            -- 19134's text) into one entry, same precedent as Stormstrike/
            -- Retaliation elsewhere in this file - it's the same named ability,
            -- not two distinct ones. Duration confirmed from Spell.xlsx + SpellDuration.csv - not in-game tested.
            name = "Intimidating Shout",
            icon = "Interface\\Icons\\Ability_GolemThunderClap",
            warning = true,
            lines = {"Shouts at an enemy, paralyzing it with terror for 8 seconds and causing all other nearby enemies to flee in fear."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Mortal Strike",
            icon = "Interface\\Icons\\Ability_Warrior_SavageBlow",
            warning = true,
            lines = {"Inflicts 500% weapon damage and leaves the target wounded, reducing the effectiveness of any healing by 50% for 5 seconds."}
        },
        {
            name = "Whirlwind",
            icon = "Interface\\Icons\\Ability_Whirlwind",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 26083 + 26084).
            lines = {"Spins for 15 seconds, hitting enemies within 6 yards every 0.3 seconds for normal damage plus 280 to 390. While spinning he does not auto-attack and moves 40% slower."}
        }
        }
    },

    gyth = {
        name = "Gyth",
        icon = "Interface\\Icons\\temp",
        -- CHANGED: real abilities from a combat log (UBRS.csv), cross-matched against
        -- Spell.xlsx by exact Spell ID - see TODO_Raid_Data.md for gaps left as X.
        abilities = {
        {
            name = "Chromatic Chaos",
            icon = "Interface\\Icons\\Spell_Arcane_StarFire",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 16337).
            lines = {"Increases the caster's hit chance by 40% and reduces the melee damage it takes by 25% for 5 minutes."}
        },
        {
            name = "Knock Away",
            icon = "Interface\\Icons\\INV_Gauntlets_05",
            warning = true,
            lines = {"Inflicts normal damage plus 30 to an enemy and knocks it back."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Corrosive Acid Breath",
            icon = "Interface\\Icons\\Spell_Nature_Acid_01",
            warning = true,
            lines = {"Shoots a cloud of acidic breath at enemies in a cone in front of the caster, reducing their armor by 90 and inflicting 150 Nature damage every 30 seconds, for 30 seconds."}
        },
        {
            name = "Flame Breath",
            icon = "Interface\\Icons\\Spell_Fire_WindsofWoe",
            warning = true,
            lines = {"Inflicts 1233 to 1567 Fire damage to enemies in a cone in front of the caster."}
        },
        {
            name = "Freeze",
            icon = "Interface\\Icons\\Spell_Frost_Glacier",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 16350).
            lines = {"Sends out an ice blast that stuns enemies in a 20 yard cone in front of the caster and deals 840 to 1160 Frost damage, then 339 to 361 Frost damage every 3 seconds for 10 seconds."}
        },
        {
            name = "Wing Buffet",
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_14",
            warning = true,
            lines = {"Inflicts 1500 to 1998 damage to enemies in a cone in front of the caster, knocking them back."}
        }
        }
    },

    the_beast = {
        name = "The Beast",
        icon = "Interface\\Icons\\temp",
        -- CHANGED: real abilities from a combat log (UBRS.csv), cross-matched against
        -- Spell.xlsx by exact Spell ID - see TODO_Raid_Data.md for gaps left as X.
        abilities = {
        {
            name = "Berserker Charge",
            icon = "Interface\\Icons\\Ability_Warrior_Charge",
            warning = true,
            lines = {"Charges at an enemy, knocking it back and inflicting normal damage plus 300."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Immolate",
            icon = "Interface\\Icons\\Spell_Fire_Immolation",
            warning = true,
            lines = {"Burns an enemy for 42, then inflicts an additional 144 Fire damage every 21 seconds, for 21 seconds."}
        },
        {
            name = "Fireball",
            icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
            warning = true,
            roles = {"kick"},
            lines = {"Inflicts 193 to 259 Fire damage to an enemy."}
        },
        {
            name = "Flamebreak",
            icon = "Interface\\Icons\\Spell_Holy_Excorcism_02",
            warning = true,
            lines = {"Inflicts 232 to 268 Fire damage to nearby enemies, knocking them back."}
        },
        {
            name = "Double Bite",
            icon = "Interface\\Icons\\Ability_Racial_Cannibalize",
            warning = true,
            lines = {"Inflicts 100% weapon damage to a second enemy."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Terrifying Roar",
            icon = "Interface\\Icons\\Ability_Devour",
            warning = true,
            lines = {"Causes nearby enemies to flee in fear for 5 seconds."}
        },
        {
            name = "Lava Breath",
            icon = "Interface\\Icons\\Spell_Fire_WindsofWoe",
            warning = true,
            lines = {"Inflicts 1557 to 2043 Fire damage to enemies in front of the caster."}
        },
        {
            name = "Frenzy",
            icon = "Interface\\Icons\\Ability_Druid_ChallangingRoar",
            -- CHANGED 2026-09-29: from Spell.csv (spell 28371).
            lines = {"Increases attack speed by 100%, damage dealt by 50% and size by 25% for 12 seconds."}
        }
        }
    },

    drakkisath = {
        name = "General Drakkisath",
        icon = "Interface\\Icons\\temp",
        -- CHANGED: real abilities from a combat log (UBRS.csv), cross-matched against
        -- Spell.xlsx by exact Spell ID - see TODO_Raid_Data.md for gaps left as X.
        abilities = {
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Pierce Armor",
            icon = "Interface\\Icons\\Spell_Shadow_VampiricAura",
            warning = true,
            lines = {"Reduces an enemy's armor by 75% for 20 seconds."}
        },
        {
            -- CHANGED: splash damage resolved from Spell.xlsx spell ID 16806 (the linked splash effect), not from in-game testing.
            name = "Conflagration",
            icon = "Interface\\Icons\\Spell_Fire_Incinerate",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 16805).
            lines = {
                "Sets an enemy aflame, inflicting 7000 Fire damage over 10 seconds (700 per second) and sending it into a state of panic.",
                "While affected, the flames periodically scorch its nearby allies for 500 damage as well."
            }
        },
        {
            name = "Flamestrike",
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 16419).
            lines = {"Calls down a pillar of flame, burning all enemies in the area for 342 to 396 Fire damage plus an additional 72 damage every 2 seconds, for 8 seconds."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 16789) + SpellDuration.csv lookup - not in-game tested.
            name = "Rage",
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            lines = {"Increases the Physical damage dealt by the caster by 50 and speeds its attacks by 50% for 15 seconds."}
        },
        {
            name = "Thunderclap",
            icon = "Interface\\Icons\\Spell_Nature_ThunderClap",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 23931).
            lines = {"Inflicts 1407 to 1593 Nature damage to nearby enemies, slowing their movement by 60% and increasing the time between their attacks by 100% for 10 seconds."}
        },
        {
            name = "Dominance",
            icon = "Interface\\Icons\\Spell_Shadow_Charm",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 34432).
            lines = {"Mind-controls a player for 20 seconds, increasing their damage dealt by 300% and size by 50%."}
        },
        {
            name = "True Fulfillment",
            icon = "Interface\\Icons\\Temp",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 2313).
            lines = {"Lasts 20 seconds (cast alongside Dominance): +40% movement speed and +50 resistance. X - its third effect is a 100000 casting-speed modifier whose in-game result is unconfirmed."}
        }
        }
    },

    valthalak = {
        name = "Lord Valthalak",
        icon = "Interface\\Icons\\temp",
        -- CHANGED: real abilities from a combat log (UBRS.csv), cross-matched against
        -- Spell.xlsx by exact Spell ID - see TODO_Raid_Data.md for gaps left as X.
        abilities = {
        {
            name = "Enrage",
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            -- CHANGED 2026-09-29: from Spell.csv (spell 8269).
            lines = {"Increases the caster's attack speed by 60% and the Physical damage it deals by 50, for 2 minutes."}
        },
        {
            name = "Summon Spectral Assassin",
            icon = "Interface\\Icons\\Spell_Shadow_Charm",
            lines = {"Summons a Spectral Assassin to aid it in battle."}
        },
        {
            name = "Shadow Bolt Volley",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            warning = true,
            lines = {"Hurls missiles of dark magic, inflicting 128 to 172 Shadow damage to nearby enemies."}
        }
        }
    },

}

------------------------------------------------------------
-- Builder: expands the order list + registry above into the flat table
-- shape the Bosses/Trash views expect (see AGENTS.md "Data model"). Nothing
-- below this point encodes raid content - only edit it if the addon's
-- expected data shape changes.
------------------------------------------------------------

local function BuildUBRSBosses()
    local bosses = {}
    for _, key in ipairs(UBRS_BOSS_ORDER) do
        local boss = { key = key }
        for field, value in pairs(UBRS_BOSSES[key]) do
            boss[field] = value
        end
        table.insert(bosses, boss)
    end
    return bosses
end

local function BuildUBRSTrash()
    local trash = {}
    for _, entry in ipairs(UBRS_TRASH_ORDER) do
        if type(entry) == "table" and entry.separator then
            table.insert(trash, entry)
        else
            local key, count
            if type(entry) == "table" then
                key, count = entry.key, entry.count
            else
                key = entry
            end
            local mob = UBRS_TRASH_MOBS[key]
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
    key = "UBRS",
    name = "Upper Blackrock Spire",
    expanded = false,
    trashExpanded = false,
    trash = BuildUBRSTrash(),
    bosses = BuildUBRSBosses(),
})
