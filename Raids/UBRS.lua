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
        {
            name = "Backstab",
            icon = "Interface\\Icons\\Ability_BackStab",
            warning = true,
            lines = {"Inflicts normal damage plus 30 to an enemy, but only if attacking from behind."}
        },
        {
            name = "Blind",
            icon = "Interface\\Icons\\Spell_Shadow_MindSteal",
            warning = true,
            lines = {"Blinds the target, causing it to wander disoriented for up to X seconds. Any damage caused will remove the effect."}
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
            lines = {"Inflicts 20 damage to an enemy and stuns it for up to X seconds. Target must be facing the caster. Any damage received by the stunned target will revive it."}
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
        },
        {
            name = "Shield Toss Return",
            icon = "Interface\\Icons\\Ability_UpgradeMoonGlaive",
            lines = {"X - no ability description available (name suggests an internal return-flight visual tied to Shield Toss, not a standalone ability)."}
        }
        }}
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
        {
            name = "Curse of Thorns",
            icon = "Interface\\Icons\\Spell_Shadow_AntiShadow",
            warning = true,
            roles = {"decurse"},
            lines = {"Curses an enemy for X seconds, giving it a chance to take X damage on attack (bonus damage lives on a separate linked spell not captured in this pass)."}
        },
        {
            name = "Dazed",
            icon = "Interface\\Icons\\Spell_Frost_Stun",
            lines = {"X - no ability description available (standard 'dazed' movement-speed effect applied by many melee mobs)."}
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
            lines = {"Howl, causing enemies within X yards to flee in terror for X seconds. Damage caused may interrupt the effect."}
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
            lines = {"Reduces healing effects on an enemy by 75% for X seconds."}
        }
        }}
    },

    blackhand_elite = {
        name = "Blackhand Elite",
        icon = "Interface\\Icons\\INV_Gauntlets_05",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
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
            lines = {"X - reduces an enemy's Stamina for X seconds (raw sheet value of 1 looks implausibly small for a Stamina debuff, left as X)."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Mortal Strike",
            icon = "Interface\\Icons\\Ability_Warrior_SavageBlow",
            warning = true,
            lines = {"Inflicts 150% weapon damage to an enemy and leaves it wounded, reducing the effectiveness of any healing on it by 50% for 5 seconds."}
        },
        {
            name = "Retaliation",
            icon = "Interface\\Icons\\Ability_Warrior_Challange",
            lines = {
                "Instantly counterattacks any enemy that strikes it in melee for X seconds. Attacks from behind cannot be counterattacked.",
                "(Spell ID 22858 is a companion trigger for this same effect, not a separate ability.)"
            }
        },
        {
            name = "Sap Visual",
            icon = "Interface\\Icons\\Ability_Sap",
            lines = {"X - no ability description available (name suggests a cosmetic 'fake sap' animation, not a real crowd control effect)."}
        },
        {
            name = "Strike",
            icon = "Interface\\Icons\\Ability_Rogue_Ambush",
            lines = {"Strikes at an enemy, inflicting increased melee damage."}
        },
        {
            name = "Shield Toss Return",
            icon = "Interface\\Icons\\Ability_UpgradeMoonGlaive",
            lines = {"X - no ability description available (name suggests an internal return-flight visual tied to Shield Toss, not a standalone ability)."}
        }
        }}
    },

    blackhand_incarcerator = {
        name = "Blackhand Incarcerator",
        icon = "Interface\\Icons\\Ability_ThunderBolt",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
        {
            name = "Dazed",
            icon = "Interface\\Icons\\Spell_Frost_Stun",
            lines = {"X - no ability description available (standard 'dazed' movement-speed effect applied by many melee mobs)."}
        },
        {
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
        }}
    },

    blackhand_iron_guard = {
        name = "Blackhand Iron Guard",
        icon = "Interface\\Icons\\Ability_Warrior_ShieldWall",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
        {
            name = "Dazed",
            icon = "Interface\\Icons\\Spell_Frost_Stun",
            lines = {"X - no ability description available (standard 'dazed' movement-speed effect applied by many melee mobs)."}
        },
        {
            -- CHANGED: percentages resolved from Spell.xlsx spell ID 7376 (the linked passive), not from in-game testing.
            name = "Defensive Stance",
            icon = "Interface\\Icons\\Ability_Warrior_DefensiveStance",
            lines = {"A defensive stance. Decreases damage taken from all sources by 10%. Decreases damage caused by 10%. Increases threat generated by 30%."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Shield Reflection",
            icon = "Interface\\Icons\\Ability_Warrior_ShieldReflection",
            lines = {"Raises its shield, reflecting a spell cast on it. Lasts 5 seconds, but will only reflect X spells."}
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
            lines = {
                "Hurls a shield at the enemy, causing 308 to 348 damage (increased by Attack Power) and knocks it down for X seconds.",
                "This ability causes a high amount of threat."
            }
        },
        {
            name = "Shield Wall",
            icon = "Interface\\Icons\\Ability_Warrior_ShieldWall",
            lines = {"Reduces the Physical and magical damage taken by the caster by 75% for X seconds."}
        }
        }}
    },

    blackhand_summoner = {
        name = "Blackhand Summoner",
        icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
        flags = {"caster"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
        {
            name = "Dazed",
            icon = "Interface\\Icons\\Spell_Frost_Stun",
            lines = {"X - no ability description available (standard 'dazed' movement-speed effect applied by many melee mobs)."}
        },
        {
            name = "Fireball",
            icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
            warning = true,
            lines = {"X - no ability description available."}
        },
        {
            name = "Frost Nova",
            icon = "Interface\\Icons\\Spell_Frost_FrostNova",
            warning = true,
            lines = {"X - no ability description available."}
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
        }}
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
        {
            name = "Dazed",
            icon = "Interface\\Icons\\Spell_Frost_Stun",
            lines = {"X - no ability description available (standard 'dazed' movement-speed effect applied by many melee mobs)."}
        },
        {
            name = "Sap Visual",
            icon = "Interface\\Icons\\Ability_Sap",
            lines = {"X - no ability description available (name suggests a cosmetic 'fake sap' animation, not a real crowd control effect)."}
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
            name = "Shield Toss Return",
            icon = "Interface\\Icons\\Ability_UpgradeMoonGlaive",
            lines = {"X - no ability description available (name suggests an internal return-flight visual tied to Shield Toss, not a standalone ability)."}
        },
        {
            name = "Strike",
            icon = "Interface\\Icons\\Ability_Rogue_Ambush",
            lines = {"Strikes at an enemy, inflicting increased melee damage."}
        }
        }}
    },

    burning_felhound = {
        name = "Burning Felhound",
        icon = "Interface\\Icons\\Spell_Shadow_ManaBurn",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
        {
            name = "Dazed",
            icon = "Interface\\Icons\\Spell_Frost_Stun",
            lines = {"X - no ability description available (standard 'dazed' movement-speed effect applied by many melee mobs)."}
        },
        {
            name = "Mana Burn",
            icon = "Interface\\Icons\\Spell_Shadow_ManaBurn",
            warning = true,
            lines = {"Hits an enemy with an anti-mana bolt, draining 177 to 205 mana; each point of mana consumed deals X damage to the target (per-point value lives on a separate linked effect not captured in this pass)."}
        }
        }}
    },

    burning_imp = {
        name = "Burning Imp",
        icon = "Interface\\Icons\\Spell_Fire_FireBolt",
        flags = {"caster"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
        {
            name = "Firebolt",
            icon = "Interface\\Icons\\Spell_Fire_FireBolt",
            warning = true,
            lines = {"Shoots a bolt of flame at an enemy, inflicting 60 to 80 Fire damage."}
        }
        }}
    },

    chromatic_dragonspawn = {
        name = "Chromatic Dragonspawn",
        icon = "Interface\\Icons\\Ability_Warrior_Cleave",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
        {
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
        }}
    },

    chromatic_elite_guard = {
        name = "Chromatic Elite Guard",
        icon = "Interface\\Icons\\Ability_Warrior_Sunder",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
        {
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
            lines = {"Inflicts 60 to 80 damage to an enemy and its nearest allies, stunning them for X seconds."}
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
            lines = {"Hacks at an enemy's armor, reducing it by 1000 per stack (up to 5 stacks). Lasts X seconds."}
        }
        }}
    },

    chromatic_whelp = {
        name = "Chromatic Whelp",
        icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
        flags = {"caster"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
        {
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
            lines = {"Inflicts 72 to 96 Frost damage to an enemy and reduces its movement speed by 50% for X seconds."}
        },
        {
            name = "Lightning Bolt",
            icon = "Interface\\Icons\\Spell_Nature_Lightning",
            warning = true,
            roles = {"kick"},
            lines = {"Blasts an enemy with lightning, inflicting 96 to 128 Nature damage."}
        }
        }}
    },

    rage_talon_captain = {
        name = "Rage Talon Captain",
        icon = "Interface\\Icons\\Ability_Warrior_Cleave",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
        {
            name = "Arcing Smash",
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            warning = true,
            lines = {"Lashes out in a vicious arc, inflicting normal damage plus 5 to enemies in a cone in front of the caster."}
        },
        {
            name = "Dazed",
            icon = "Interface\\Icons\\Spell_Frost_Stun",
            lines = {"X - no ability description available (standard 'dazed' movement-speed effect applied by many melee mobs)."}
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
        },
        {
            name = "Shield Toss Return",
            icon = "Interface\\Icons\\Ability_UpgradeMoonGlaive",
            lines = {"X - no ability description available (name suggests an internal return-flight visual tied to Shield Toss, not a standalone ability)."}
        }
        }}
    },

    rage_talon_dragon_guard = {
        name = "Rage Talon Dragon Guard",
        icon = "Interface\\Icons\\Ability_Warrior_ShieldReflection",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
        {
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
            lines = {"Raises its shield, reflecting a spell cast on it. Lasts 5 seconds, but will only reflect X spells."}
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
            lines = {"Hacks at an enemy's armor, reducing it by 24 per stack (up to 5 stacks). Lasts X seconds."}
        }
        }}
    },

    rage_talon_dragonspawn = {
        name = "Rage Talon Dragonspawn",
        icon = "Interface\\Icons\\Ability_Warrior_Charge",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
        {
            name = "Charge",
            icon = "Interface\\Icons\\Ability_Warrior_Charge",
            warning = true,
            lines = {"Charges an enemy, inflicting normal damage plus X and stuns the opponent for X seconds (raw bonus-damage value of 1 looks implausibly small, left as X)."}
        },
        {
            name = "Dazed",
            icon = "Interface\\Icons\\Spell_Frost_Stun",
            lines = {"X - no ability description available (standard 'dazed' movement-speed effect applied by many melee mobs)."}
        },
        {
            name = "Enrage",
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            lines = {"Increases the caster's attack speed by 60% and the Physical damage it deals by 50, for X seconds."}
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
            lines = {"Hacks at an enemy's armor, reducing it by 1000 per stack (up to 5 stacks). Lasts X seconds."}
        },
        {
            name = "Sweeping Strikes",
            icon = "Interface\\Icons\\Ability_Rogue_SliceDice",
            lines = {"Its next X melee weapon swings strike an additional nearby opponent."}
        }
        }}
    },

    rage_talon_fire_tongue = {
        name = "Rage Talon Fire Tongue",
        icon = "Interface\\Icons\\Spell_Fire_Incinerate",
        flags = {"caster"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
        {
            name = "Conflagration",
            icon = "Interface\\Icons\\Spell_Fire_Incinerate",
            warning = true,
            lines = {"X - no ability description available (see Conflagration for General Drakkisath's version of the base effect)."}
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
            lines = {"Inflicts 555 to 645 Fire damage to an enemy and increases the Fire damage it takes by 300, for X seconds."}
        },
        {
            name = "Shield Toss Return",
            icon = "Interface\\Icons\\Ability_UpgradeMoonGlaive",
            lines = {"X - no ability description available (name suggests an internal return-flight visual tied to Shield Toss, not a standalone ability)."}
        }
        }}
    },

    rage_talon_flamescale = {
        name = "Rage Talon Flamescale",
        icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
        flags = {"caster"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
        {
            name = "Conflagration",
            icon = "Interface\\Icons\\Spell_Fire_Incinerate",
            warning = true,
            lines = {"X - no ability description available (see Conflagration for General Drakkisath's version of the base effect)."}
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
            lines = {"Calls down a pillar of flame, burning all enemies in the area for 228 to 264 Fire damage plus an additional 48 damage every X seconds, for X seconds."}
        }
        }}
    },

    rookery_guardian = {
        name = "Rookery Guardian",
        icon = "Interface\\Icons\\Ability_Warrior_Cleave",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
        {
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
            lines = {"X - hacks at an enemy's armor per stack (up to 5 stacks), lasts X seconds; raw sheet value (0) looks implausibly small for the per-stack amount, left as X."}
        }
        }}
    },

    rookery_hatcher = {
        name = "Rookery Hatcher",
        icon = "Interface\\Icons\\Temp",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
        {
            name = "Disturb Rookery Egg",
            icon = "Interface\\Icons\\Temp",
            lines = {"X - no ability description available."}
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
            lines = {"X - hacks at an enemy's armor per stack (up to 5 stacks), lasts X seconds; raw sheet value (0) looks implausibly small for the per-stack amount, left as X."}
        }
        }}
    },

    rookery_whelp = {
        name = "Rookery Whelp",
        icon = "Interface\\Icons\\Spell_Frost_Stun",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
        {
            name = "Dazed",
            icon = "Interface\\Icons\\Spell_Frost_Stun",
            lines = {"X - no ability description available (standard 'dazed' movement-speed effect applied by many melee mobs)."}
        }
        }}
    },

    scarshield_acolyte = {
        name = "Scarshield Acolyte",
        icon = "Interface\\Icons\\Spell_Holy_DispelMagic",
        flags = {"caster"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
        {
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
            lines = {"Utters a word of darkness, inflicting 70 Shadow damage to an enemy every X seconds, for X seconds."}
        }
        }}
    },

    scarshield_legionnaire = {
        name = "Scarshield Legionnaire",
        icon = "Interface\\Icons\\Ability_Warrior_Cleave",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
        {
            name = "Cleave",
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            warning = true,
            lines = {"Inflicts weapon damage plus 10 to an enemy and its nearest ally."}
        },
        {
            name = "Dazed",
            icon = "Interface\\Icons\\Spell_Frost_Stun",
            lines = {"X - no ability description available (standard 'dazed' movement-speed effect applied by many melee mobs)."}
        },
        {
            name = "Hate to 50%",
            icon = "Interface\\Icons\\Spell_Shadow_SacrificialShield",
            lines = {"X - no ability description available (internal threat-reset mechanic, name implies it drops the caster's target to 50% threat)."}
        },
        {
            name = "Improved Blocking",
            icon = "Interface\\Icons\\Spell_Fire_FireArmor",
            lines = {"Increases the caster's chance to block by 55%, for X seconds."}
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
        }
        }}
    },

    scarshield_spellbinder = {
        name = "Scarshield Spellbinder",
        icon = "Interface\\Icons\\Spell_Arcane_StarFire",
        flags = {"caster"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
        {
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
            lines = {"A wave of flame radiates outward from the caster, damaging all enemies caught within the blast for 462 to 544 Fire damage and dazing them for X seconds."}
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
            lines = {"Inflicts 111 to 129 Frost damage to nearby enemies, immobilizing them for up to X seconds."}
        },
        {
            name = "Greater Polymorph",
            icon = "Interface\\Icons\\Spell_Nature_Brilliance",
            warning = true,
            roles = {"dispel"},
            lines = {
                "Transforms an enemy into a sheep, forcing it to wander around for up to X seconds. While wandering, the sheep cannot attack or cast spells, but regenerates quickly.",
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
            lines = {"X - increases an ally's Fire resistance for X seconds; raw sheet value (2) looks implausibly small, left as X."}
        }
        }}
    },

    scarshield_warlock = {
        name = "Scarshield Warlock",
        icon = "Interface\\Icons\\Spell_Shadow_Possession",
        flags = {"caster"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
        {
            name = "Fear",
            icon = "Interface\\Icons\\Spell_Shadow_Possession",
            warning = true,
            lines = {"Strikes fear in the enemy, causing it to run in terror for up to X seconds. Damage caused may interrupt the effect. Only 1 target can be feared at a time."}
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
        },
        {
            name = "Shield Toss Return",
            icon = "Interface\\Icons\\Ability_UpgradeMoonGlaive",
            lines = {"X - no ability description available (name suggests an internal return-flight visual tied to Shield Toss, not a standalone ability)."}
        }
        }}
    },

    spectral_assassin = {
        name = "Spectral Assassin",
        icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
        flags = {"melee"},
        -- CHANGED: from a real combat log (UBRS.csv) - stats not present in that
        -- log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
        {
            name = "Defile",
            icon = "Interface\\Icons\\Spell_Shadow_GatherShadows",
            warning = true,
            lines = {"X - no ability description available."}
        },
        {
            name = "Shadow Shock",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            warning = true,
            lines = {"Instantly lashes an enemy with dark magic, inflicting 210 to 242 Shadow damage."}
        }
        }}
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
            lines = {"X - no ability description available (likely the scripted 'growing' event as he powers up before the fight, not a combat ability)."}
        },
        {
            name = "Flame Buffet",
            icon = "Interface\\Icons\\Spell_Fire_Fireball",
            warning = true,
            lines = {"Inflicts 150 to 300 Fire damage to an enemy and increases the Fire damage it takes by 200, for X seconds."}
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
            lines = {"X - no ability description available (see Conflagration for General Drakkisath's version of the base effect)."}
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
            lines = {"Calls down a pillar of flame, burning all enemies in the area for 475 to 627 Fire damage plus an additional 375 to 465 damage every X seconds, for X seconds."}
        },
        {
            name = "War Stomp",
            icon = "Interface\\Icons\\Ability_BullRush",
            warning = true,
            lines = {"Inflicts normal damage plus 50 to nearby enemies, knocking them back and stunning them for X seconds."}
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
            lines = {"X - reduces an enemy's Stamina for X seconds (raw sheet value of 1 looks implausibly small for a Stamina debuff, left as X)."}
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
            name = "Dazed",
            icon = "Interface\\Icons\\Spell_Frost_Stun",
            lines = {"X - no ability description available (standard 'dazed' movement-speed effect applied by many melee mobs)."}
        },
        {
            name = "Disarm",
            icon = "Interface\\Icons\\Ability_Warrior_Disarm",
            warning = true,
            lines = {"Disarms the target's weapon for X seconds."}
        },
        {
            name = "Enrage",
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            lines = {"Increases the caster's attack speed by 60% and the Physical damage it deals by 50, for X seconds."}
        },
        {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 19134) + SpellDuration.csv lookup - not in-game tested.
            name = "Intimidating Shout",
            icon = "Interface\\Icons\\Ability_GolemThunderClap",
            warning = true,
            lines = {"Shouts at an enemy, paralyzing it with terror for 8 seconds and causing all other nearby enemies to flee in fear."}
        },
        {
            name = "Intimidating Shout",
            icon = "Interface\\Icons\\Ability_GolemThunderClap",
            warning = true,
            lines = {
                "Shouts at an enemy, paralyzing it with terror for 8 seconds and causing all other nearby enemies to flee in fear.",
                "(No separate Spell.xlsx description for this rank - reused spell 19134's text since it's the same named ability; duration confirmed from Spell.xlsx DurationIndex 31 + SpellDuration.csv, not in-game testing.)"
            }
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
            lines = {"Attacks nearby enemies in a whirlwind of steel that lasts X seconds and inflicts normal damage plus X (bonus damage lives on a separate linked spell not captured in this pass; raw sheet value was an implausible -9900, also left as X)."}
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
            lines = {"X - no ability description available."}
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
            lines = {"Sends out an ice blast that stuns and damages enemies in a cone in front of the caster for 339 to 361 Frost damage, then inflicts an additional 840 to 1160 Frost damage every X seconds, for X seconds."}
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
            lines = {"X - no ability description available."}
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
            lines = {
                "Sets an enemy aflame, inflicting 700 Fire damage over X seconds and sending it into a state of panic.",
                "While affected, the flames periodically scorch its nearby allies for 500 damage as well."
            }
        },
        {
            name = "Flamestrike",
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            warning = true,
            lines = {"Calls down a pillar of flame, burning all enemies in the area for 342 to 396 Fire damage plus an additional 72 damage every X seconds, for X seconds."}
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
            lines = {"Inflicts 1407 to 1593 Nature damage to nearby enemies, slowing their movement by 60% and increasing the time between their attacks by 100% for X seconds."}
        },
        {
            name = "Dominance",
            icon = "Interface\\Icons\\Spell_Shadow_Charm",
            warning = true,
            lines = {"X - no ability description available."}
        },
        {
            name = "True Fulfillment",
            icon = "Interface\\Icons\\Temp",
            warning = true,
            lines = {"X - no ability description available; raw sheet value (100000) looks like a sentinel, not a real number."}
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
            lines = {"Increases the caster's attack speed by 60% and the Physical damage it deals by 50, for X seconds."}
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
