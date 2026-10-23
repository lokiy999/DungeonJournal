-- Part of the DungeonJournal RAIDS database (see AGENTS.md "Data model").
-- Loaded via DungeonJournal.toc before DungeonJournal.lua; appends this
-- raid's table to the shared DungeonJournal_Raids list in load order.

DungeonJournal_Raids = DungeonJournal_Raids or {}

------------------------------------------------------------
-- LBRS order list - START HERE to reorder bosses.
--
-- LBRS_BOSS_ORDER is the only thing you should need to touch to change
-- what order bosses appear in the Bosses tab. Just a flat list of keys -
-- actual boss data (icon/flags/stats/abilities) lives further down in
-- LBRS_BOSSES, defined once per key and looked up from here.
------------------------------------------------------------

-- Boss encounter order (Bosses tab tree, top to bottom).
local LBRS_BOSS_ORDER = {
    "omokk",
    "voshgajin",
    "voone",
    "smolderweb",
    "urok",
    "zigris",
    "halycon",
    "gizrul",
    "wyrmthalak",
}

-- CHANGED: trash roster sourced from a real combat log ("LBRS.csv" -
-- Source/Source GUID/Action/Spell ID columns), cross-matched against
-- Spell.xlsx by exact Spell ID for icons/descriptions, the same
-- methodology used for MC/BWL/SM/UBRS/ZG's trash tables. Pull order/
-- grouping is NOT known from that log (it's a flat event list, no pull
-- boundaries), so this is just every distinct mob that logged an ability,
-- in no particular order - see TODO_Raid_Data.md. Shaman totems (Magma
-- Totem, Mana Spring Totem, Searing Totem, Stoneclaw Totem, Strength of
-- Earth Totem, Fire Nova Totem [player-cast]) and raw unresolved GUIDs
-- were excluded - they're player pets/totems, not real LBRS mobs.
local LBRS_TRASH_ORDER = {
    "bloodaxe_evoker",
    "bloodaxe_raider",
    "bloodaxe_summoner",
    "bloodaxe_veteran",
    "bloodaxe_warmonger",
    "bloodaxe_worg",
    "bloodaxe_worg_pup",
    "firebrand_darkweaver",
    "firebrand_dreadweaver",
    "firebrand_grunt",
    "firebrand_invoker",
    "firebrand_legionnaire",
    "firebrand_pyromancer",
    "scarshield_acolyte",
    "scarshield_legionnaire",
    "scarshield_raider",
    "scarshield_spellbinder",
    "scarshield_warlock",
    "smolderthorn_axe_thrower",
    "smolderthorn_berserker",
    "smolderthorn_headhunter",
    "smolderthorn_mystic",
    "smolderthorn_seer",
    "smolderthorn_shadow_hunter",
    "smolderthorn_shadow_priest",
    "smolderthorn_witch_doctor",
    "spire_scorpid",
    "spire_spider",
    "spire_spiderling",
    "spirestone_battle_mage",
    "spirestone_enforcer",
    "spirestone_mystic",
    "spirestone_ogre_magus",
    "spirestone_reaver",
    "spirestone_warlord",
}

------------------------------------------------------------
-- Trash mob registry - one entry per distinct trash mob (icon/flags/
-- stats/abilities), referenced by key from LBRS_TRASH_ORDER above.
------------------------------------------------------------
local LBRS_TRASH_MOBS = {
    bloodaxe_evoker = {
        name = "Bloodaxe Evoker",
        icon = "Interface\\Icons\\Spell_Arcane_StarFire",
        flags = {"caster"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Arcane Bolt",
            spellId = 13748,
            icon = "Interface\\Icons\\Spell_Arcane_StarFire",
            warning = true,
            lines = {"Hurls a magical bolt at an enemy, inflicting 155 to 205 Arcane damage."}
        }, {
            name = "Blast Wave",
            spellId = 15744,
            icon = "Interface\\Icons\\Spell_Holy_Excorcism_02",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 15744).
            lines = {"Unleashes a wave of flame, inflicting 122 to 140 Fire damage to nearby enemies and reducing their movement speed for 6 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Cone of Cold",
            spellId = 30095,
            icon = "Interface\\Icons\\Spell_Frost_Glacier",
            warning = true,
            lines = {"Inflicts Frost damage to enemies in a cone in front of the caster, reducing their movement speed for 8 seconds."}
        }, {
            name = "Flamecrack",
            spellId = 15743,
            icon = "Interface\\Icons\\Spell_Fire_Fire",
            warning = true,
            lines = {"Inflicts 1250 Fire damage to all enemies in a selected area, knocking them back and stunning them for X seconds."}
        }}
    },

    bloodaxe_raider = {
        name = "Bloodaxe Raider",
        icon = "Interface\\Icons\\Ability_Warrior_Cleave",
        flags = {"melee"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Cleave",
            spellId = 15284,
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            warning = true,
            -- CHANGED 2026-09-30: spell 15284 in Spell.csv is level-scaled - bonus 10, +1 per caster level above 10.
            lines = {"Inflicts weapon damage plus 10, plus 1 per caster level above 10 (about 60 at level 60) to all enemies in front of the caster."}
        }, {
            name = "Sunder Armor",
            spellId = 15572,
            icon = "Interface\\Icons\\Ability_Warrior_Sunder",
            warning = true,
            -- CHANGED: duration confirmed from Spell.xlsx (spell ID 15572, DurationIndex 9) + SpellDuration.csv -> 30s; per-stack armor is level-scaled (see below).
            -- CHANGED 2026-09-29: from Spell.csv (spell 15572).
            lines = {"Hacks at an enemy's armor, reducing it by 12 per caster level per stack (about 700 at level 60). Can be applied up to 5 times, lasts 30 seconds."}
        }, {
            name = "Summon Bloodaxe Worg",
            spellId = 34485,
            icon = "Interface\\Icons\\Ability_Mount_WhiteDireWolf",
            lines = {"Summons a Bloodaxe Worg to aid it in battle."}
        }}
    },

    bloodaxe_summoner = {
        name = "Bloodaxe Summoner",
        icon = "Interface\\Icons\\Spell_Nature_StarFall",
        flags = {"caster"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Arcane Missiles",
            spellId = 15791,
            icon = "Interface\\Icons\\Spell_Nature_StarFall",
            warning = true,
            -- CHANGED: merges the channel-tick rank (spell ID 15790, empty Description_enUS) with the
            -- cast rank (15791, real text) - same named ability, not a distinct spell for this purpose.
            lines = {"Launches magical missiles at an enemy, inflicting 139 Arcane damage."}
        }, {
            name = "Arcane Explosion",
            spellId = 21073,
            icon = "Interface\\Icons\\Spell_Nature_WispSplode",
            warning = true,
            lines = {"Sends out a blast wave of magic, inflicting 190 to 195 Arcane damage to nearby enemies."}
        }, {
            name = "Summon",
            spellId = 15734,
            icon = "Interface\\Icons\\Spell_Arcane_Blink",
            warning = true,
            lines = {"Teleports 1 enemy target to the caster."}
        }, {
            name = "Frost Nova",
            spellId = 15532,
            icon = "Interface\\Icons\\Spell_Frost_FrostNova",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 15532).
            lines = {"Inflicts 42 to 48 Frost damage to enemies within 10 yards, immobilizing them for up to 8 seconds."}
        }}
    },

    bloodaxe_veteran = {
        name = "Bloodaxe Veteran",
        icon = "Interface\\Icons\\Ability_Rogue_Ambush",
        flags = {"melee"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Strike",
            spellId = 19730,
            icon = "Interface\\Icons\\Ability_Rogue_Ambush",
            -- CHANGED 2026-09-30: spell 19730 in Spell.csv is level-scaled - bonus 25, +7.5 per caster level above 1.
            lines = {"Strikes at an enemy, inflicting weapon damage plus 25, plus 7.5 per caster level above 1 (about 468 at level 60)."}
        }, {
            name = "Disarm",
            spellId = 8379,
            icon = "Interface\\Icons\\Ability_Warrior_Disarm",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 8379).
            lines = {"Disarms an enemy, forcing it to stop wielding its weapon for 10 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Pummel",
            spellId = 15615,
            icon = "Interface\\Icons\\INV_Gauntlets_04",
            warning = true,
            lines = {"Pummels an enemy for 44 damage and interrupts the spell being cast for 5 seconds."}
        }, {
            name = "Snap Kick",
            spellId = 15618,
            icon = "Interface\\Icons\\Ability_Kick",
            warning = true,
            -- CHANGED: duration confirmed from Spell.xlsx (spell ID 15618, DurationIndex 39) + SpellDuration.csv -> 2s; stun-damage value still left as X (raw sheet value implausibly small).
            -- CHANGED 2026-09-30: spell 15618 in Spell.csv is level-scaled - damage 4, +4 per caster level above 1, no cap unless stated.
            lines = {"Inflicts 4 plus 4 per caster level above 1 (about 240 at level 60) damage to an enemy, stunning it for 2 seconds."}
        }, {
            name = "Dual Wield",
            spellId = 674,
            icon = "Interface\\Icons\\Ability_DualWield",
            lines = {"Allows one-hand and off-hand weapons to be equipped in the off-hand."}
        }, {
            name = "Recklessness",
            spellId = 13847,
            icon = "Interface\\Icons\\Ability_CriticalStrike",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 13847 - not reverse-engineered from raw effect codes (likely a self-buff based on the name).
            -- CHANGED 2026-09-29: from Spell.csv (spell 13847).
            lines = {"Increases the caster's critical strike chance by 100% and reduces its resistances by 35% for 15 seconds. Also grants an immunity (aura 38) - X, which one is unconfirmed."}
        }}
    },

    bloodaxe_warmonger = {
        name = "Bloodaxe Warmonger",
        icon = "Interface\\Icons\\Ability_Warrior_SavageBlow",
        flags = {"melee"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Mortal Strike",
            spellId = 17547,
            icon = "Interface\\Icons\\Ability_Warrior_SavageBlow",
            warning = true,
            lines = {"Inflicts 200% weapon damage and leaves the target wounded, reducing the effectiveness of any healing by 50% for 5 seconds."}
        }, {
            name = "Uppercut",
            spellId = 10966,
            icon = "Interface\\Icons\\INV_Gauntlets_05",
            warning = true,
            lines = {"Inflicts weapon damage plus 50 to an enemy, knocking it back."}
        }, {
            -- CHANGED: radius confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellRadius.csv lookup - not in-game tested.
            name = "Whirlwind",
            spellId = 34421,
            icon = "Interface\\Icons\\Ability_Whirlwind",
            warning = true,
            -- CHANGED 2026-09-30: target count is not in the spell data (spell 34421).
            lines = {"In a whirlwind of steel you attack nearby enemies within 8 yards, causing weapon damage to each enemy."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Demoralizing Shout",
            spellId = 16244,
            icon = "Interface\\Icons\\Ability_Warrior_WarCry",
            -- CHANGED 2026-09-30: spell 16244 in Spell.csv is level-scaled - AP reduction 20, +4 per caster level above 5.
            lines = {"Reduces the melee attack power of nearby enemies by 20 plus 4 per caster level above 5 (about 240 at level 60) for 30 seconds."}
        }, {
            name = "Enrage",
            spellId = 8269,
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 8269).
            -- CHANGED 2026-09-30: spell 8269 in Spell.csv is level-scaled - base 50, +2 per caster level above 26, no cap unless stated.
            lines = {"Increases the caster's attack speed by 60% and the Physical damage it deals by 50 plus 2 per caster level above 26 (about 118 at level 60) for 2 minutes."}
        }}
    },

    bloodaxe_worg = {
        name = "Bloodaxe Worg",
        icon = "Interface\\Icons\\Spell_Frost_Stun",
        flags = {"melee"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
    },

    bloodaxe_worg_pup = {
        name = "Bloodaxe Worg Pup",
        icon = "Interface\\Icons\\Spell_Frost_Stun",
        flags = {"melee"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
    },

    firebrand_darkweaver = {
        name = "Firebrand Darkweaver",
        icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
        flags = {"caster"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell 16071) + SpellDuration.csv lookup - not in-game tested.
            name = "Curse of the Firebrand",
            spellId = 16071,
            icon = "Interface\\Icons\\Ability_Creature_Cursed_03",
            warning = true,
            roles = {"decurse"},
            -- CHANGED 2026-09-29: from Spell.csv (spell 16071).
            lines = {"Inflicts 1457 to 1843 Fire damage to an enemy every 20 seconds for 300 seconds."}
        }, {
            name = "Dispel Magic",
            spellId = 15090,
            icon = "Interface\\Icons\\Spell_Holy_DispelMagic",
            lines = {"Dispels magic on the target, removing 1 harmful spell from an ally or 1 beneficial spell from an enemy."}
        }, {
            name = "Shadow Bolt",
            spellId = 15232,
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            warning = true,
            roles = {"kick"},
            lines = {"Hurls a bolt of dark magic at an enemy, inflicting 192 to 258 Shadow damage."}
        }, {
            name = "Mark of Flames",
            spellId = 15128,
            icon = "Interface\\Icons\\Spell_Fire_Fireball",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 15128).
            lines = {"Increases the Fire damage taken by an enemy by 1000 for 5 minutes."}
        }, {
            name = "Shadow Bolt Volley",
            spellId = 14887,
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            warning = true,
            roles = {"kick"},
            lines = {"Hurls missiles of dark magic, inflicting 96 to 128 Shadow damage to nearby enemies."}
        }}
    },

    firebrand_dreadweaver = {
        name = "Firebrand Dreadweaver",
        icon = "Interface\\Icons\\Ability_Creature_Cursed_03",
        flags = {"caster"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell 16071) + SpellDuration.csv lookup - not in-game tested.
            name = "Curse of the Firebrand",
            spellId = 16071,
            icon = "Interface\\Icons\\Ability_Creature_Cursed_03",
            warning = true,
            roles = {"decurse"},
            -- CHANGED 2026-09-29: from Spell.csv (spell 16071).
            lines = {"Inflicts 1457 to 1843 Fire damage to an enemy every 20 seconds for 300 seconds."}
        }, {
            name = "Mark of Flames",
            spellId = 15128,
            icon = "Interface\\Icons\\Spell_Fire_Fireball",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 15128).
            lines = {"Increases the Fire damage taken by an enemy by 1000 for 5 minutes."}
        }, {
            name = "Plague Cloud",
            spellId = 15728,
            icon = "Interface\\Icons\\Spell_Shadow_CallofBone",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 15728).
            lines = {"Reduces Strength, Agility and Intellect of all enemies within 5 yards of the target area for 4 minutes. Each stat drops by 1 plus 2 per caster level above 1 (about 119 at level 60)."}
        }, {
            name = "Howl of Terror",
            spellId = 5484,
            icon = "Interface\\Icons\\Spell_Shadow_DeathScream",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 5484).
            -- CHANGED 2026-09-30: target count is not in the spell data (spell 5484), wording no longer claims a number.
            lines = {"Howl, causing nearby enemies within 10 yards to flee in terror for 10 seconds. Damage caused may interrupt the effect."}
        }}
    },

    firebrand_grunt = {
        name = "Firebrand Grunt",
        icon = "Interface\\Icons\\Ability_Warrior_Challange",
        flags = {"melee"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell 8255) + SpellDuration.csv lookup - not in-game tested.
            name = "Strong Cleave",
            spellId = 8255,
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 8255).
            lines = {"Inflicts weapon damage plus 55 to an enemy and its nearest allies, affecting up to 5 targets and increasing the time between their attacks by 33% for 10 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Mortal Strike",
            spellId = 13737,
            icon = "Interface\\Icons\\Ability_Warrior_SavageBlow",
            warning = true,
            lines = {"Inflicts 130% weapon damage and leaves the target wounded, reducing the effectiveness of any healing by 50% for 5 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 18499) + SpellDuration.csv lookup - not in-game tested.
            name = "Berserker Rage",
            spellId = 18499,
            icon = "Interface\\Icons\\Spell_Nature_AncestralGuardian",
            lines = {"The warrior enters a berserker rage, becoming immune to Fear and Incapacitate effects and generating double amount of rage when taking damage. Lasts 10 seconds."}
        }, {
            name = "Mark of Flames",
            spellId = 15128,
            icon = "Interface\\Icons\\Spell_Fire_Fireball",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 15128).
            lines = {"Increases the Fire damage taken by an enemy by 1000 for 5 minutes."}
        }, {
            name = "Enrage",
            spellId = 8269,
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 8269).
            -- CHANGED 2026-09-30: spell 8269 in Spell.csv is level-scaled - base 50, +2 per caster level above 26, no cap unless stated.
            lines = {"Increases the caster's attack speed by 60% and the Physical damage it deals by 50 plus 2 per caster level above 26 (about 118 at level 60) for 2 minutes."}
        }, {
            name = "Charge",
            spellId = 25821,
            icon = "Interface\\Icons\\Ability_Warrior_Charge",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 25821).
            -- CHANGED 2026-09-30: spell 25821: effect 2 is a 1300 weapon damage bonus.
            lines = {"Charges an enemy, inflicting weapon damage plus 1300 and stunning it for 2 seconds."}
        }, {
            name = "Retaliation",
            spellId = 22857,
            icon = "Interface\\Icons\\Ability_Warrior_Challange",
            warning = true,
            -- CHANGED: duration confirmed from Spell.xlsx (spell ID 22857, DurationIndex 8) + SpellDuration.csv -> 15s.
            lines = {
                "Instantly counterattacks any enemy that strikes it in melee for 15 seconds. Attacks from behind cannot be counterattacked.",
                "(Spell ID 22858 is a companion trigger for this same effect, not a separate ability.)"
            }
        }, {
            separator = true,
            passive = true,
            name = "Passives"
        }, {
            name = "Berserker Stance",
            spellId = 2458,
            icon = "Interface\\Icons\\Ability_Racial_Avatar",
            -- CHANGED: crit chance and damage taken resolved from Spell.xlsx spell ID 7381 (the linked passive), not from in-game testing. That spell does not document a "chance of being critically hit" value, so that figure is left as X.
            -- CHANGED 2026-09-29: from Spell.csv (spell 2458).
            lines = {"An aggressive stance. Critical hit chance is increased by 3%. The chance of being critically hit is increased by 10%. All damage taken is increased by 10%."}
        }}
    },

    firebrand_invoker = {
        name = "Firebrand Invoker",
        icon = "Interface\\Icons\\Spell_Fire_SealOfFire",
        flags = {"caster"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Fire Nova",
            spellId = 12470,
            icon = "Interface\\Icons\\Spell_Fire_SealOfFire",
            warning = true,
            lines = {"Inflicts 298 to 320 Fire damage to nearby enemies."}
        }, {
            name = "Fireball",
            spellId = 15242,
            icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
            warning = true,
            roles = {"kick"},
            lines = {"Inflicts Fire damage to an enemy."}
        }, {
            name = "Mark of Flames",
            spellId = 15128,
            icon = "Interface\\Icons\\Spell_Fire_Fireball",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 15128).
            lines = {"Increases the Fire damage taken by an enemy by 1000 for 5 minutes."}
        }, {
            name = "Counterspell",
            spellId = 2139,
            icon = "Interface\\Icons\\Spell_Frost_IceShock",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 2139).
            lines = {"Counters the enemy's spellcast, preventing any spell from that school of magic from being cast for 6 seconds. Generates a high amount of threat."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Flamestrike",
            spellId = 12468,
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 12468).
            lines = {"Calls down a pillar of flame, burning all enemies in a selected area and inflicting additional damage every 2 seconds for 8 seconds."}
        }}
    },

    firebrand_legionnaire = {
        name = "Firebrand Legionnaire",
        icon = "Interface\\Icons\\INV_Shield_05",
        flags = {"melee"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Shield Slam",
            spellId = 23925,
            icon = "Interface\\Icons\\INV_Shield_05",
            warning = true,
            lines = {"Slam the target with your shield, causing 394 to 427 damage, modified by your shield block value, and dispels 1 magic effect on the target. This ability causes a high amount of threat."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Shield Reflection",
            spellId = 34073,
            icon = "Interface\\Icons\\Ability_Warrior_ShieldReflection",
            -- CHANGED 2026-09-29: from Spell.csv (spell 34073).
            lines = {"Raise your shield, reflecting spell cast on you. Lasts 5 seconds, but will only reflect 1 spell."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Shield Toss",
            spellId = 34130,
            icon = "Interface\\Icons\\Ability_UpgradeMoonGlaive",
            warning = true,
            lines = {"Hurls a shield at the enemy, causing 308 to 348 damage, increased by Attack Power and knocks down for 2 seconds. This ability causes a high amount of threat."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 11972) + SpellDuration.csv lookup - not in-game tested.
            name = "Shield Bash",
            spellId = 11972,
            icon = "Interface\\Icons\\Ability_Warrior_ShieldBash",
            warning = true,
            roles = {"kick"},
            lines = {"Bashes an enemy with the caster's shield, inflicting Physical damage and interrupting the spell being cast for 8 seconds."}
        }, {
            name = "Disarm",
            spellId = 27581,
            icon = "Interface\\Icons\\Ability_Warrior_Disarm",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 27581).
            lines = {"Disarm the enemy's weapon for 10 seconds."}
        }, {
            name = "Mark of Flames",
            spellId = 15128,
            icon = "Interface\\Icons\\Spell_Fire_Fireball",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 15128).
            lines = {"Increases the Fire damage taken by an enemy by 1000 for 5 minutes."}
        }, {
            name = "Shield Charge",
            spellId = 15749,
            icon = "Interface\\Icons\\Ability_Warrior_Charge",
            warning = true,
            lines = {"Charges an enemy, knocking it back and inflicting weapon damage plus 150."}
        }, {
            separator = true,
            passive = true,
            name = "Passives"
        }, {
            name = "Defensive Stance",
            spellId = 71,
            icon = "Interface\\Icons\\Ability_Warrior_DefensiveStance",
            -- CHANGED 2026-09-29: from Spell.csv (spell 71).
            lines = {"A defensive combat stance that decreases damage taken by 10% and damage caused by 10%. Increases threat generated by 30%."}
        }, {
            name = "Improved Blocking",
            spellId = 3248,
            icon = "Interface\\Icons\\Spell_Fire_FireArmor",
            -- CHANGED 2026-09-29: from Spell.csv (spell 3248).
            -- CHANGED 2026-09-30: spell 3248 in Spell.csv is level-scaled - base 55%, +0.5 per caster level above 9, no cap unless stated.
            lines = {"Increases the caster's chance to block by 55% plus 0.5% per caster level above 9 (about 80% at level 60) for 10 seconds."}
        }}
    },

    firebrand_pyromancer = {
        name = "Firebrand Pyromancer",
        icon = "Interface\\Icons\\Spell_Fire_FlameShock",
        flags = {"caster"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Flame Shock",
            spellId = 15096,
            icon = "Interface\\Icons\\Spell_Fire_FlameShock",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 15096).
            lines = {"Instantly burns an enemy, then inflicts additional Fire damage every 3 seconds for 12 seconds."}
        }, {
            name = "Mark of Flames",
            spellId = 15128,
            icon = "Interface\\Icons\\Spell_Fire_Fireball",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 15128).
            lines = {"Increases the Fire damage taken by an enemy by 1000 for 5 minutes."}
        }, {
            name = "Blast Wave",
            spellId = 23039,
            icon = "Interface\\Icons\\Spell_Holy_Excorcism_02",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 23039).
            lines = {"Unleashes a wave of flame, inflicting Fire damage to nearby enemies and reducing their movement speed for 6 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 20294) + SpellDuration.csv lookup - not in-game tested.
            name = "Immolate",
            spellId = 20294,
            icon = "Interface\\Icons\\Spell_Fire_Immolation",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 20294).
            lines = {"Inflicts 760 to 840 Fire damage to an enemy and scorches it for an additional 680 to 720 damage every 3 seconds for 21 seconds."}
        }}
    },

    scarshield_acolyte = {
        name = "Scarshield Acolyte",
        icon = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
        flags = {"caster"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Shadow Word: Pain",
            spellId = 14032,
            icon = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 14032).
            lines = {"Utters a word of darkness, inflicting 70 Shadow damage to an enemy every 3 seconds, for 18 seconds."}
        }, {
            name = "Dispel Magic",
            spellId = 15090,
            icon = "Interface\\Icons\\Spell_Holy_DispelMagic",
            lines = {"Dispels magic on the target, removing 1 harmful spell from an ally or 1 beneficial spell from an enemy."}
        }, {
            -- CHANGED: duration and radius confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv + SpellRadius.csv lookup - not in-game tested.
            name = "Psychic Scream",
            spellId = 27610,
            icon = "Interface\\Icons\\Spell_Shadow_PsychicScream",
            warning = true,
            -- CHANGED 2026-09-30: target count is not in the spell data, wording no longer claims a number.
            lines = {"The caster lets out a psychic scream, causing nearby enemies within 8 yards to flee for 8 seconds. Damage caused may interrupt the effect."}
        }}
    },

    scarshield_legionnaire = {
        name = "Scarshield Legionnaire",
        icon = "Interface\\Icons\\Ability_Warrior_Charge",
        flags = {"melee"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Shield Charge",
            spellId = 15749,
            icon = "Interface\\Icons\\Ability_Warrior_Charge",
            warning = true,
            lines = {"Charges an enemy, knocking it back and inflicting weapon damage plus 150."}
        }, {
            name = "Cleave",
            spellId = 15496,
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            warning = true,
            -- CHANGED 2026-09-30: spell 15496 in Spell.csv is level-scaled - bonus 10, +1 per caster level above 10.
            lines = {"Inflicts weapon damage plus 10, plus 1 per caster level above 10 (about 60 at level 60) to an enemy and its nearest ally."}
        }, {
            -- CHANGED 2026-09-30: added from the combat log - spell 11972 in Spell.csv.
            name = "Shield Bash",
            spellId = 11972,
            icon = "Interface\\Icons\\Ability_Warrior_ShieldBash",
            warning = true,
            lines = {"Bashes an enemy with the caster's shield, inflicting 10 Physical damage and interrupting the spell being cast for 8 seconds."}
        }, {
            separator = true,
            passive = true,
            name = "Passives"
        }, {
            name = "Improved Blocking",
            spellId = 3248,
            icon = "Interface\\Icons\\Spell_Fire_FireArmor",
            -- CHANGED 2026-09-29: from Spell.csv (spell 3248).
            -- CHANGED 2026-09-30: spell 3248 in Spell.csv is level-scaled - base 55%, +0.5 per caster level above 9, no cap unless stated.
            lines = {"Increases the caster's chance to block by 55% plus 0.5% per caster level above 9 (about 80% at level 60) for 10 seconds."}
        }}
    },

    scarshield_raider = {
        name = "Scarshield Raider",
        icon = "Interface\\Icons\\Ability_Rogue_Ambush",
        flags = {"melee"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Strike",
            spellId = 11976,
            icon = "Interface\\Icons\\Ability_Rogue_Ambush",
            -- CHANGED 2026-09-30: spell 11976 in Spell.csv is level-scaled - bonus 5, +1.5 per caster level above 1.
            lines = {"Strikes at an enemy, inflicting weapon damage plus 5, plus 1.5 per caster level above 1 (about 94 at level 60)."}
        }, {
            name = "Summon Scarshield Worg",
            spellId = 34484,
            icon = "Interface\\Icons\\Ability_Mount_WhiteDireWolf",
            lines = {"Summons a Scarshield Worg to aid it in battle."}
        }}
    },

    scarshield_spellbinder = {
        name = "Scarshield Spellbinder",
        icon = "Interface\\Icons\\Spell_Nature_Brilliance",
        flags = {"caster"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Greater Polymorph",
            spellId = 22274,
            icon = "Interface\\Icons\\Spell_Nature_Brilliance",
            warning = true,
            roles = {"dispel"},
            -- CHANGED 2026-09-30: spell 22274 duration 20 seconds.
            lines = {
                "Transforms an enemy into a sheep, forcing it to wander around for up to 20 seconds. While wandering, the sheep cannot attack or cast spells, but regenerates very quickly.",
                "Only one target can be polymorphed at a time. Only works on beasts, dragons, giants, humanoids, and critters."
            }
        }, {
            -- CHANGED 2026-09-30: added from the combat log - spell 15122 in Spell.csv.
            name = "Counterspell",
            spellId = 15122,
            icon = "Interface\\Icons\\Spell_Frost_IceShock",
            warning = true,
            lines = {"Counters an enemy's spell, preventing the enemy from casting that spell again for 15 seconds."}
        }, {
            name = "Frost Nova",
            spellId = 22645,
            icon = "Interface\\Icons\\Spell_Frost_FrostNova",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 22645).
            lines = {"Inflicts 111 to 129 Frost damage to nearby enemies, immobilizing them for up to 8 seconds."}
        }, {
            name = "Resist Fire",
            spellId = 15123,
            icon = "Interface\\Icons\\Spell_Fire_FireArmor",
            -- CHANGED 2026-09-29: from Spell.csv (spell 15123).
            lines = {"Increases an ally's Fire resistance for 2 hours. Scales with the caster's level: 2 plus 1.5 per level above 1 (about 90 at level 60)."}
        }, {
            name = "Arcane Bolt",
            spellId = 13748,
            icon = "Interface\\Icons\\Spell_Arcane_StarFire",
            warning = true,
            lines = {"Hurls a magical bolt at an enemy, inflicting 155 to 205 Arcane damage."}
        }, {
            name = "Mana Burn",
            spellId = 15785,
            icon = "Interface\\Icons\\Spell_Shadow_ManaBurn",
            warning = true,
            -- CHANGED 2026-09-30: spell 15785, damage multiplier per mana read from the effect multiplier column (0.5, matching the player Mana Burn tooltip).
            lines = {"Hits an enemy with an anti-mana bolt, draining 363 to 401 mana; each point of mana consumed deals 0.5 Shadow damage to the target."}
        }, {
            name = "Blast Wave",
            spellId = 13021,
            icon = "Interface\\Icons\\Spell_Holy_Excorcism_02",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 13021).
            -- CHANGED 2026-09-30: spell 13021 in Spell.csv is level-scaled - 462-544 at level 60, +1.9 per level up to level 66, no cap unless stated.
            lines = {"A wave of flame radiates outward from the caster, damaging all enemies caught within the blast for 462 to 544 Fire damage (plus 1.9 per caster level above 60, up to level 66) and dazing them for 6 seconds."}
        }}
    },

    scarshield_warlock = {
        name = "Scarshield Warlock",
        icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
        flags = {"caster"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Shadow Bolt",
            spellId = 12471,
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            warning = true,
            roles = {"kick"},
            lines = {"Hurls a bolt of dark magic at an enemy, inflicting 145 to 177 Shadow damage."}
        }, {
            name = "Fear",
            spellId = 6215,
            icon = "Interface\\Icons\\Spell_Shadow_Possession",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 6215).
            lines = {"Strikes fear in the enemy, causing it to run in fear for up to 20 seconds. Damage caused may interrupt the effect. Only 1 target can be feared at a time."}
        }, {
            -- CHANGED 2026-09-30: added from the combat log - spell 15125 in Spell.csv.
            name = "Scarshield Portal",
            spellId = 15125,
            icon = "Interface\\Icons\\Spell_Arcane_PortalOrgrimmar",
            warning = true,
            lines = {"Opens a portal into the Twisting Nether that periodically summons demonic minions to aid the caster in battle for 30 seconds."}
        }}
    },

    smolderthorn_axe_thrower = {
        name = "Smolderthorn Axe Thrower",
        icon = "Interface\\Icons\\INV_Axe_08",
        flags = {"ranged"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Throw Axe",
            spellId = 16075,
            icon = "Interface\\Icons\\INV_Axe_08",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 16075 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: from Spell.csv (spell 16075).
            lines = {"Throws an axe at an enemy for 1750 Physical damage, stunning it for 2 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Knockdown",
            spellId = 11428,
            icon = "Interface\\Icons\\Ability_GolemThunderClap",
            warning = true,
            lines = {"Inflicts 60 to 80 damage to an enemy, stunning it for 2 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 24018) + SpellDuration.csv lookup - not in-game tested.
            name = "Axe Flurry",
            spellId = 24018,
            icon = "Interface\\Icons\\INV_Axe_06",
            lines = {"Attacks nearby enemies in a flurry of axes that lasts 10 seconds."}
        }, {
            separator = true,
            passive = true,
            name = "Passives"
        }, {
            name = "Thrash",
            spellId = 3391,
            icon = "Interface\\Icons\\Ability_GhoulFrenzy",
            lines = {"Gives the caster 2 extra attacks."}
        }}
    },

    smolderthorn_berserker = {
        name = "Smolderthorn Berserker",
        icon = "Interface\\Icons\\Ability_Rogue_SliceDice",
        flags = {"melee"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Sweeping Strikes",
            spellId = 12723,
            icon = "Interface\\Icons\\Ability_Rogue_SliceDice",
            -- CHANGED 2026-09-30: swing count is not in the spell data (spell 12723).
            lines = {"Its next melee weapon swings strike an additional nearby opponent."}
        }, {
            name = "Strike",
            spellId = 13446,
            icon = "Interface\\Icons\\Ability_Rogue_Ambush",
            -- CHANGED 2026-09-30: spell 13446 in Spell.csv is level-scaled - bonus 8, +2.25 per caster level above 1.
            lines = {"Strikes at an enemy, inflicting weapon damage plus 8, plus 2.25 per caster level above 1 (about 141 at level 60)."}
        }, {
            name = "Uppercut",
            spellId = 26007,
            icon = "Interface\\Icons\\INV_Gauntlets_05",
            warning = true,
            lines = {"Inflicts weapon damage plus 950 to 1050 to an enemy, knocking it back."}
        }, {
            name = "War Stomp",
            spellId = 11876,
            icon = "Interface\\Icons\\Ability_BullRush",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 11876).
            -- CHANGED 2026-09-30: spell 11876 in Spell.csv is level-scaled - bonus 23, +0.5 per caster level above 45, no cap unless stated.
            lines = {"Inflicts weapon damage plus 23 plus 0.5 per caster level above 45 (about 30 at level 60) to nearby enemies, knocking them back and stunning them for 5 seconds."}
        }, {
            name = "Knock Away",
            spellId = 11130,
            icon = "Interface\\Icons\\INV_Gauntlets_05",
            warning = true,
            lines = {"Inflicts weapon damage plus 30 to nearby enemies and knocks them back."}
        }, {
            name = "Enrage",
            spellId = 8269,
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 8269).
            -- CHANGED 2026-09-30: spell 8269 in Spell.csv is level-scaled - base 50, +2 per caster level above 26, no cap unless stated.
            lines = {"Increases the caster's attack speed by 60% and the Physical damage it deals by 50 plus 2 per caster level above 26 (about 118 at level 60) for 2 minutes."}
        }}
    },

    smolderthorn_headhunter = {
        name = "Smolderthorn Headhunter",
        icon = "Interface\\Icons\\Ability_Throw",
        flags = {"ranged"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Impale",
            spellId = 16001,
            icon = "Interface\\Icons\\Ability_Throw",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 16001).
            lines = {"Inflicts Physical damage to an enemy every 1 second for 9 seconds."}
        }, {
            name = "Throw",
            spellId = 22887,
            icon = "Interface\\Icons\\Ability_Throw",
            warning = true,
            lines = {"Throws a weapon at an enemy, inflicting Physical damage."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Viper Sting",
            spellId = 14280,
            icon = "Interface\\Icons\\Ability_Hunter_AimedShot",
            warning = true,
            lines = {"Stings the target, draining 60 mana over 15 seconds. Only one Sting per Hunter can be active on any one target."}
        }}
    },

    smolderthorn_mystic = {
        name = "Smolderthorn Mystic",
        icon = "Interface\\Icons\\Spell_Nature_GroundingTotem",
        flags = {"caster"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell 4979) + SpellDuration.csv lookup - not in-game tested.
            name = "Quick Flame Ward",
            spellId = 4979,
            icon = "Interface\\Icons\\Spell_Fire_SealOfFire",
            lines = {"Renders an ally immune to Fire spells for 10 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 8177) + SpellDuration.csv lookup - not in-game tested.
            name = "Grounding Totem",
            spellId = 8177,
            icon = "Interface\\Icons\\Spell_Nature_GroundingTotem",
            lines = {"Summons a Grounding Totem with 5 health at the feet of the caster that will redirect one harmful spell cast on a nearby party member to itself every 40 seconds. Will not redirect area of effect spells. Lasts 40 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 4980) + SpellDuration.csv lookup - not in-game tested.
            name = "Quick Frost Ward",
            spellId = 4980,
            icon = "Interface\\Icons\\Spell_Fire_SealOfFire",
            lines = {"Renders an ally immune to Frost spells for 10 seconds."}
        }, {
            name = "Earth Shock",
            spellId = 24685,
            icon = "Interface\\Icons\\Spell_Nature_EarthShock",
            warning = true,
            roles = {"kick"},
            -- CHANGED 2026-09-29: from Spell.csv (spell 24685).
            lines = {"Shocks an enemy with concussive force, inflicting Nature damage and interrupting the spell being cast for 4 seconds."}
        }, {
            name = "Chain Heal",
            spellId = 15799,
            icon = "Interface\\Icons\\Spell_Nature_HealingWaveGreater",
            roles = {"tank"},
            -- CHANGED 2026-09-29: from Spell.csv (spell 15799).
            lines = {"Infuses a wounded ally with healing energy that spreads to another nearby ally. The spell affects up to 3 targets, but the healing energy is diminished by 50% for each successive target."}
        }}
    },

    smolderthorn_seer = {
        name = "Smolderthorn Seer",
        icon = "Interface\\Icons\\Spell_Nature_LightningShield",
        flags = {"caster"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Lightning Shield",
            spellId = 13585,
            icon = "Interface\\Icons\\Spell_Nature_LightningShield",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 13585).
            lines = {"Surrounds an ally with 3 balls of lightning that each have a 50% chance of striking melee or ranged attackers for 2 damage plus 2 per caster level above 1 (about 120 at level 60). Each strike uses up one ball; the shield expires after 10 minutes."}
        }}
    },

    smolderthorn_shadow_hunter = {
        name = "Smolderthorn Shadow Hunter",
        icon = "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice",
        flags = {"melee"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Sinister Strike",
            spellId = 15581,
            icon = "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice",
            -- CHANGED 2026-09-30: spell 15581 in Spell.csv is level-scaled - bonus 3, +3.6 per caster level above 20.
            lines = {"Inflicts weapon damage plus 3, plus 3.6 per caster level above 20 (about 147 at level 60) to an enemy."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Kick",
            spellId = 15614,
            icon = "Interface\\Icons\\Ability_Kick",
            warning = true,
            roles = {"kick"},
            -- CHANGED 2026-09-30: spell 15614 in Spell.csv is level-scaled - damage 4, +2 per caster level above 20.
            lines = {"Kicks an enemy for 4 damage plus 2 per caster level above 20 (about 84 at level 60), interrupting the spell being cast for 6 seconds."}
        }, {
            name = "Gouge",
            spellId = 12540,
            icon = "Interface\\Icons\\Ability_Gouge",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 12540).
            lines = {"Inflicts 20 damage to an enemy and stuns it for up to 8 seconds. Target must be facing the caster. Any damage received by the stunned target will revive it."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 21060) + SpellDuration.csv lookup - not in-game tested.
            name = "Blind",
            spellId = 21060,
            icon = "Interface\\Icons\\Spell_Shadow_MindSteal",
            warning = true,
            lines = {"Blinds the target and its nearby allies, causing them to wander confused for up to 10 seconds."}
        }, {
            name = "Eviscerate",
            spellId = 15691,
            icon = "Interface\\Icons\\Ability_Rogue_Eviscerate",
            warning = true,
            -- CHANGED 2026-09-30: spell 15691 in Spell.csv is level-scaled - damage 1, +50 per caster level above 1.
            lines = {"Inflicts 1 plus 50 per caster level above 1 (about 2951 at level 60) damage to an enemy."}
        }}
    },

    smolderthorn_shadow_priest = {
        name = "Smolderthorn Shadow Priest",
        icon = "Interface\\Icons\\Spell_Shadow_SummonVoidWalker",
        flags = {"caster"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Dispel Magic",
            spellId = 15090,
            icon = "Interface\\Icons\\Spell_Holy_DispelMagic",
            lines = {"Dispels magic on the target, removing 1 harmful spell from an ally or 1 beneficial spell from an enemy."}
        }, {
            name = "Hex",
            spellId = 11641,
            icon = "Interface\\Icons\\Spell_Nature_Polymorph",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 11641).
            lines = {"Transforms an enemy into a frog, rendering it unable to attack or cast spells for 10 seconds."}
        }, {
            name = "Shadowform",
            spellId = 22917,
            icon = "Interface\\Icons\\Spell_Shadow_SummonVoidWalker",
            lines = {"Assumes a Shadowform, increasing Shadow damage dealt by 40% and reducing melee damage taken by 40%. Shadowform lasts until cancelled."}
        }, {
            name = "Silence",
            spellId = 18327,
            icon = "Interface\\Icons\\Spell_Holy_Silence",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 18327).
            lines = {"Silences nearby enemies, preventing them from casting spells for 10 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Mind Flay",
            spellId = 18807,
            icon = "Interface\\Icons\\Spell_Shadow_SiphonMana",
            warning = true,
            roles = {"kick"},
            lines = {"Assault the target's mind with Shadow energy, causing 180 Shadow damage over 5 seconds and slowing their movement speed by 50%."}
        }, {
            name = "Mana Burn",
            spellId = 15800,
            icon = "Interface\\Icons\\Spell_Shadow_ManaBurn",
            warning = true,
            -- CHANGED 2026-09-30: spell 15800, damage multiplier per mana read from the effect multiplier column (1).
            lines = {"Hits nearby enemies with anti-mana bolts, draining 354 to 410 mana total; each point of mana consumed deals 1 Shadow damage to the target."}
        }}
    },

    smolderthorn_witch_doctor = {
        name = "Smolderthorn Witch Doctor",
        icon = "Interface\\Icons\\Spell_Fire_SearingTotem",
        flags = {"caster"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell 15867) + SpellDuration.csv lookup - not in-game tested.
            name = "Flame Buffet Totem",
            spellId = 15867,
            icon = "Interface\\Icons\\Spell_Fire_SearingTotem",
            warning = true,
            lines = {"Summons a Flame Buffet Totem at the caster's feet. Totem lasts for 35 seconds. and attacks an enemy every 2 sec."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 15869) + SpellDuration.csv lookup - not in-game tested.
            name = "Superior Healing Ward",
            spellId = 15869,
            icon = "Interface\\Icons\\Spell_Holy_LayOnHands",
            lines = {"Summons a ward that lasts 30 seconds. and periodically heals allies in an area around it."}
        }}
    },

    spire_scorpid = {
        name = "Spire Scorpid",
        icon = "Interface\\Icons\\Spell_Frost_Stun",
        flags = {"melee"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
    },

    spire_spider = {
        name = "Spire Spider",
        icon = "Interface\\Icons\\Spell_Shadow_Teleport",
        flags = {"melee"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell 16104) + SpellDuration.csv lookup - not in-game tested.
            name = "Crystallize",
            spellId = 16104,
            icon = "Interface\\Icons\\Spell_Shadow_Teleport",
            warning = true,
            lines = {"Stuns enemies in a cone in front of the caster, rendering them unable to move or attack for 6 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 3609) + SpellDuration.csv lookup - not in-game tested.
            name = "Paralyzing Poison",
            spellId = 3609,
            icon = "Interface\\Icons\\Ability_PoisonSting",
            warning = true,
            lines = {"Stuns an enemy, rendering it unable to move or attack for 8 seconds."}
        }, {
            name = "Summon Spire Spiderling",
            spellId = 16103,
            icon = "Interface\\Icons\\Spell_Frost_FrostShock",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 16103 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: from Spell.csv (spell 16103).
            lines = {"Summons 4 Spire Spiderlings, which last 90 seconds."}
        }, {
            separator = true,
            passive = true,
            name = "Passives"
        }, {
            name = "Thrash",
            spellId = 3391,
            icon = "Interface\\Icons\\Ability_GhoulFrenzy",
            lines = {"Gives the caster 2 extra attacks."}
        }}
    },

    spire_spiderling = {
        name = "Spire Spiderling",
        icon = "Interface\\Icons\\Spell_Frost_Stun",
        flags = {"melee"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
    },

    spirestone_battle_mage = {
        name = "Spirestone Battle Mage",
        icon = "Interface\\Icons\\Spell_Fire_FlameShock",
        flags = {"caster"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Flame Shock",
            spellId = 29228,
            icon = "Interface\\Icons\\Spell_Fire_FlameShock",
            warning = true,
            lines = {"Instantly sears the target with fire, causing 320 Fire damage immediately and 90 Fire damage over 15 seconds."}
        }, {
            name = "Tremor Totem",
            spellId = 8143,
            icon = "Interface\\Icons\\Spell_Nature_TremorTotem",
            roles = {"shaman"},
            -- CHANGED 2026-09-29: from Spell.csv (spell 8143).
            lines = {"Summons a Tremor Totem with 5 health at the feet of the caster that shakes the ground around it, removing Fear, Charm and Sleep effects from party members within 40 yards. Lasts 20 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Frost Shock",
            spellId = 23115,
            icon = "Interface\\Icons\\Spell_Frost_FrostShock",
            warning = true,
            lines = {"Inflicts Frost damage to an enemy and reduces its movement speed for 8 seconds."}
        }, {
            name = "Blast Wave",
            spellId = 13021,
            icon = "Interface\\Icons\\Spell_Holy_Excorcism_02",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 13021).
            -- CHANGED 2026-09-30: spell 13021 in Spell.csv is level-scaled - 462-544 at level 60, +1.9 per level up to level 66, no cap unless stated.
            lines = {"A wave of flame radiates outward from the caster, damaging all enemies caught within the blast for 462 to 544 Fire damage (plus 1.9 per caster level above 60, up to level 66) and dazing them for 6 seconds."}
        }, {
            name = "Bloodlust",
            spellId = 16170,
            icon = "Interface\\Icons\\Spell_Nature_BloodLust",
            -- CHANGED 2026-09-29: from Spell.csv (spell 16170).
            lines = {"Increases an ally's attack speed by 60% for 30 seconds."}
        }, {
            name = "Chain Lightning",
            spellId = 15305,
            icon = "Interface\\Icons\\Spell_Nature_ChainLightning",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 15305).
            lines = {"Strikes an enemy with a lightning bolt that arcs to another nearby enemy. The spell affects up to 5 targets, inflicting greater Nature damage to each successive target."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Fire Nova Totem",
            spellId = 11315,
            icon = "Interface\\Icons\\Spell_Fire_SealOfFire",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 11315).
            lines = {"Summons a Fire Nova Totem that has 5 health and lasts 5 seconds. Unless it is destroyed within 4 seconds, the totem inflicts 396 to 442 Fire damage to enemies within 8 yards."}
        }}
    },

    spirestone_enforcer = {
        name = "Spirestone Enforcer",
        icon = "Interface\\Icons\\Ability_Warrior_Cleave",
        flags = {"melee"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Cleave",
            spellId = 15496,
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            warning = true,
            -- CHANGED 2026-09-30: spell 15496 in Spell.csv is level-scaled - bonus 10, +1 per caster level above 10.
            lines = {"Inflicts weapon damage plus 10, plus 1 per caster level above 10 (about 60 at level 60) to an enemy and its nearest ally."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Mortal Strike",
            spellId = 16856,
            icon = "Interface\\Icons\\Ability_Warrior_SavageBlow",
            warning = true,
            lines = {"Inflicts 200% weapon damage and leaves the target wounded, reducing the effectiveness of any healing by 50% for 5 seconds."}
        }, {
            separator = true,
            passive = true,
            name = "Passives"
        }, {
            name = "Berserker Stance",
            spellId = 2458,
            icon = "Interface\\Icons\\Ability_Racial_Avatar",
            -- CHANGED: "chance of being critically hit" resolved from Spell.xlsx spell ID 35490 (the linked passive), not from in-game testing. That spell's other two effect slots are undocumented in its description text, so crit chance and damage taken are left as X.
            -- CHANGED 2026-09-29: from Spell.csv (spell 2458).
            lines = {"An aggressive stance. Critical hit chance is increased by 3%. The chance of being critically hit is increased by 10%. All damage taken is increased by 10%."}
        }}
    },

    spirestone_mystic = {
        name = "Spirestone Mystic",
        icon = "Interface\\Icons\\Spell_Nature_Rejuvenation",
        flags = {"caster"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Rejuvenation",
            spellId = 15981,
            icon = "Interface\\Icons\\Spell_Nature_Rejuvenation",
            roles = {"tank"},
            -- CHANGED 2026-09-29: from Spell.csv (spell 15981).
            lines = {"Heals an ally every 3 seconds for 12 seconds."}
        }, {
            name = "Chain Lightning",
            spellId = 15659,
            icon = "Interface\\Icons\\Spell_Nature_ChainLightning",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 15659).
            lines = {"Strikes an enemy with a lightning bolt that arcs to another nearby enemy. The spell affects up to 3 targets, causing Nature damage to each."}
        }, {
            name = "Forked Lightning",
            spellId = 8435,
            icon = "Interface\\Icons\\Spell_Nature_ChainLightning",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 8435).
            lines = {"Inflicts Nature damage to enemies in a 30 yard cone in front of the caster: 5 plus 5 per caster level above 1 (about 300 at level 60)."}
        }}
    },

    spirestone_ogre_magus = {
        name = "Spirestone Ogre Magus",
        icon = "Interface\\Icons\\Spell_Nature_Slow",
        flags = {"caster"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Slow",
            spellId = 13747,
            icon = "Interface\\Icons\\Spell_Nature_Slow",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 13747).
            lines = {"Increases the time between nearby enemies' melee and ranged attacks by 60%, slows their movement by 60% and reduces their casting speed by 60% for 10 seconds."}
        }, {
            name = "Arcane Bolt",
            spellId = 15979,
            icon = "Interface\\Icons\\Spell_Arcane_StarFire",
            warning = true,
            lines = {"Hurls magic at nearby enemies, inflicting Arcane damage."}
        }, {
            name = "Bloodlust",
            spellId = 6742,
            icon = "Interface\\Icons\\Spell_Nature_BloodLust",
            -- CHANGED 2026-09-29: from Spell.csv (spell 6742).
            lines = {"Increases an ally's attack speed by 30% for 30 seconds."}
        }}
    },

    spirestone_reaver = {
        name = "Spirestone Reaver",
        icon = "Interface\\Icons\\Ability_Whirlwind",
        flags = {"melee"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            -- CHANGED: radius confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellRadius.csv lookup - not in-game tested.
            name = "Whirlwind",
            spellId = 34421,
            icon = "Interface\\Icons\\Ability_Whirlwind",
            warning = true,
            -- CHANGED 2026-09-30: target count is not in the spell data (spell 34421).
            lines = {"In a whirlwind of steel you attack nearby enemies within 8 yards, causing weapon damage to each enemy."}
        }, {
            name = "Cleave",
            spellId = 15284,
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            warning = true,
            -- CHANGED 2026-09-30: spell 15284 in Spell.csv is level-scaled - bonus 10, +1 per caster level above 10.
            lines = {"Inflicts weapon damage plus 10, plus 1 per caster level above 10 (about 60 at level 60) to all enemies in front of the caster."}
        }, {
            name = "War Stomp",
            spellId = 11876,
            icon = "Interface\\Icons\\Ability_BullRush",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 11876).
            -- CHANGED 2026-09-30: spell 11876 in Spell.csv is level-scaled - bonus 23, +0.5 per caster level above 45, no cap unless stated.
            lines = {"Inflicts weapon damage plus 23 plus 0.5 per caster level above 45 (about 30 at level 60) to nearby enemies, knocking them back and stunning them for 5 seconds."}
        }}
    },

    spirestone_warlord = {
        name = "Spirestone Warlord",
        icon = "Interface\\Icons\\Ability_Warrior_BattleShout",
        flags = {"melee"},
        -- CHANGED: from a real combat log (LBRS.csv) - stats not present in that log, never tested.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            name = "Empower Will",
            spellId = 16171,
            icon = "Interface\\Icons\\Ability_Warrior_BattleShout",
            lines = {"Dispels 1 polymorph, charm, or knockout effect from nearby allies."}
        }, {
            name = "Haste",
            spellId = 13533,
            icon = "Interface\\Icons\\Spell_Nature_Invisibilty",
            -- CHANGED 2026-09-29: from Spell.csv (spell 13533).
            lines = {"Increases your attack speed by 30% for 10 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Demoralizing Shout",
            spellId = 23511,
            icon = "Interface\\Icons\\Ability_Warrior_WarCry",
            -- CHANGED 2026-09-30: spell 23511 in Spell.csv is level-scaled - AP reduction 40, +10 per caster level above 5.
            lines = {"Reduces the attack power of nearby enemies by 40 plus 10 per caster level above 5 (about 590 at level 60) for 30 seconds."}
        }, {
            name = "Enrage",
            spellId = 8269,
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 8269).
            -- CHANGED 2026-09-30: spell 8269 in Spell.csv is level-scaled - base 50, +2 per caster level above 26, no cap unless stated.
            lines = {"Increases the caster's attack speed by 60% and the Physical damage it deals by 50 plus 2 per caster level above 26 (about 118 at level 60) for 2 minutes."}
        }, {
            separator = true,
            passive = true,
            name = "Passives"
        }, {
            name = "Haste Aura",
            spellId = 13589,
            icon = "Interface\\Icons\\Spell_Holy_FistOfJustice",
            lines = {"Increases the attack speed of all nearby party members by 20%. Players may only have one aura on them per paladin at any one time. The aura lasts until cancelled."}
        }}
    },

}

------------------------------------------------------------
-- Boss registry - one entry per boss (icon/flags/stats/abilities),
-- referenced by key from LBRS_BOSS_ORDER above. Defined once each; add a
-- new boss here and add its key to LBRS_BOSS_ORDER to place it.
------------------------------------------------------------
local LBRS_BOSSES = {
    omokk = {
        name = "Highlord Omokk",
        icon = "Interface\\Icons\\temp",
        -- CHANGED: real abilities from a combat log (LBRS.csv), cross-matched against
        -- Spell.xlsx by exact Spell ID - see TODO_Raid_Data.md for gaps left as X.
        abilities = {{
            name = "Sunder Armor",
            spellId = 24317,
            icon = "Interface\\Icons\\Ability_Warrior_Sunder",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 24317).
            lines = {"Hacks at an enemy's armor, reducing it by 1000 per Sunder Armor. Can be applied up to 5 times. Lasts 20 seconds."}
        }, {
            name = "Knock Away",
            spellId = 20686,
            icon = "Interface\\Icons\\INV_Gauntlets_05",
            warning = true,
            lines = {"Inflicts weapon damage plus 30 to nearby enemies and knocks them back."}
        }, {
            name = "Stormstrike",
            spellId = 17364,
            icon = "Interface\\Icons\\Spell_Holy_SealOfMight",
            warning = true,
            -- CHANGED: merges the off-hand companion cast (spell ID 34592, Description_enUS is just "OH")
            -- with the main-hand cast (17364, real text) - same named ability, not a distinct spell.
            -- Duration confirmed from Spell.xlsx (spell ID 17364, DurationIndex 1) + SpellDuration.csv -> 10s.
            lines = {"Instantly attack with both weapons. In addition, Nature damage taken by the target is increased by 10%. Lasts 10 seconds."}
        }, {
            name = "Strike",
            spellId = 18368,
            icon = "Interface\\Icons\\Ability_Rogue_Ambush",
            -- CHANGED 2026-09-30: spell 18368 in Spell.csv is level-scaled - bonus 15, +4.5 per caster level above 1.
            lines = {"Strikes at an enemy, inflicting weapon damage plus 15, plus 4.5 per caster level above 1 (about 281 at level 60)."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Vicious Rend",
            spellId = 14331,
            icon = "Interface\\Icons\\Ability_Gouge",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 14331).
            lines = {"Inflicts Physical damage to an enemy every 3 seconds for 15 seconds."}
        }, {
            name = "Slow",
            spellId = 22356,
            icon = "Interface\\Icons\\Spell_Nature_GroundingTotem",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 22356).
            lines = {"Increases the time between nearby enemies' attacks by 54%, their casting speed 54% and slows their movement by 60% for 10 seconds."}
        }, {
            name = "War Stomp",
            spellId = 24375,
            icon = "Interface\\Icons\\Ability_BullRush",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 24375).
            lines = {"Inflicts weapon damage plus 500 to nearby enemies, knocking them back and stunning them for 5 seconds."}
        }}
    },

    voshgajin = {
        name = "Shadow Hunter Vosh'gajin",
        icon = "Interface\\Icons\\temp",
        -- CHANGED: real abilities from a combat log (LBRS.csv), cross-matched against
        -- Spell.xlsx by exact Spell ID - see TODO_Raid_Data.md for gaps left as X.
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell 34420) + SpellDuration.csv lookup - not in-game tested.
            name = "Lingering Death",
            spellId = 34420,
            icon = "Interface\\Icons\\Ability_Gouge",
            warning = true,
            lines = {"Wounds the target causing them to bleed for 50 damage over 120 seconds."}
        }, {
            name = "Cleave",
            spellId = 20691,
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 20691).
            lines = {"Inflicts weapon damage to an enemy and its nearest allies, affecting up to 5 targets."}
        }, {
            name = "Hex",
            spellId = 16708,
            icon = "Interface\\Icons\\Spell_Nature_Polymorph",
            warning = true,
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 16708 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: from Spell.csv (spell 16708).
            lines = {"Hexes an enemy for 20 seconds, transforming it and leaving it confused."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Curse of Blood",
            spellId = 24673,
            icon = "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice",
            warning = true,
            roles = {"decurse"},
            lines = {"Increases the Physical damage taken by an enemy by 500 for 600 seconds."}
        }}
    },

    voone = {
        name = "War Master Voone",
        icon = "Interface\\Icons\\temp",
        -- CHANGED: real abilities from a combat log (LBRS.csv), cross-matched against
        -- Spell.xlsx by exact Spell ID - see TODO_Raid_Data.md for gaps left as X.
        abilities = {{
            name = "Throw Axe",
            spellId = 16075,
            icon = "Interface\\Icons\\INV_Axe_08",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 16075 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: from Spell.csv (spell 16075).
            lines = {"Throws an axe at an enemy for 1750 Physical damage, stunning it for 2 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Snap Kick",
            spellId = 24671,
            icon = "Interface\\Icons\\Ability_Kick",
            warning = true,
            lines = {"Inflicts 875 to 1125 damage to an enemy, stunning it for 2 seconds."}
        }, {
            -- CHANGED: radius confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellRadius.csv lookup - not in-game tested.
            name = "Whirlwind",
            spellId = 34421,
            icon = "Interface\\Icons\\Ability_Whirlwind",
            warning = true,
            -- CHANGED 2026-09-30: target count is not in the spell data (spell 34421).
            lines = {"In a whirlwind of steel you attack nearby enemies within 8 yards, causing weapon damage to each enemy."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 19134) + SpellDuration.csv lookup - not in-game tested.
            name = "Intimidating Shout",
            spellId = 19134,
            icon = "Interface\\Icons\\Ability_GolemThunderClap",
            warning = true,
            lines = {"Shouts at an enemy, paralyzing it with terror for 8 seconds and causing all other nearby enemies to flee in fear."}
        }, {
            name = "Berserker Charge",
            spellId = 19471,
            icon = "Interface\\Icons\\Ability_Warrior_Charge",
            warning = true,
            lines = {"Charges at an enemy, knocking it back and inflicting weapon damage plus 150."}
        }, {
            name = "Uppercut",
            spellId = 10966,
            icon = "Interface\\Icons\\INV_Gauntlets_05",
            warning = true,
            lines = {"Inflicts weapon damage plus 50 to an enemy, knocking it back."}
        }}
    },

    smolderweb = {
        name = "Mother Smolderweb",
        icon = "Interface\\Icons\\temp",
        -- CHANGED: real abilities from a combat log (LBRS.csv), cross-matched against
        -- Spell.xlsx by exact Spell ID - see TODO_Raid_Data.md for gaps left as X.
        abilities = {{
            name = "Intoxication",
            spellId = 34422,
            icon = "Interface\\Icons\\Ability_Poisons",
            warning = true,
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 34422 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: from Spell.csv (spell 34422).
            lines = {"After 5 seconds, deals 1750 to 2500 Nature damage to the target and enemies within 8 yards."}
        }, {
            name = "Summon Spire Spiderling",
            spellId = 16103,
            icon = "Interface\\Icons\\Spell_Frost_FrostShock",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 16103 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: from Spell.csv (spell 16103).
            lines = {"Summons 4 Spire Spiderlings, which last 90 seconds."}
        }, {
            name = "Mother's Milk",
            spellId = 16468,
            icon = "Interface\\Icons\\Ability_Creature_Poison_02",
            warning = true,
            lines = {"Poisons nearby enemies. Until the poison is entirely removed from the bloodstream by a knowledgeable medical professional, it will periodically immobilize a poisoned individual and any nearby allies."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 16104) + SpellDuration.csv lookup - not in-game tested.
            name = "Crystallize",
            spellId = 16104,
            icon = "Interface\\Icons\\Spell_Shadow_Teleport",
            warning = true,
            lines = {"Stuns enemies in a cone in front of the caster, rendering them unable to move or attack for 6 seconds."}
        }}
    },

    urok = {
        name = "Urok Doomhowl",
        icon = "Interface\\Icons\\temp",
        -- CHANGED: no combat data for Urok Doomhowl in LBRS.csv (no "Urok Doomhowl" source
        -- with a 0xF130-prefixed GUID logged any ability) - left as placeholder, see
        -- TODO_Raid_Data.md.
        abilities = {{
            name = "Urok Doomhowl's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    },

    zigris = {
        name = "Quartermaster Zigris",
        icon = "Interface\\Icons\\temp",
        -- CHANGED: real abilities from a combat log (LBRS.csv), cross-matched against
        -- Spell.xlsx by exact Spell ID - see TODO_Raid_Data.md for gaps left as X.
        abilities = {{
            name = "Stun Bomb",
            spellId = 16497,
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 16497).
            -- CHANGED 2026-09-30: spell 16497 in Spell.csv is level-scaled - bonus 1, +1.5 per caster level above 1, no cap unless stated.
            lines = {"Hurls a stun bomb, inflicting weapon damage plus 1 plus 1.5 per caster level above 1 (about 90 at level 60) to all enemies in a selected area and stunning them for 5 seconds."}
        }, {
            name = "Gas Bomb",
            spellId = 8901,
            icon = "Interface\\Icons\\INV_Misc_Ammo_Bullet_01",
            warning = true,
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 8901 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: from Spell.csv (spell 8901).
            lines = {"Stuns enemies within 3 yards of the impact for 20 seconds."}
        }, {
            name = "Shoot",
            spellId = 16496,
            icon = "Interface\\Icons\\Ability_Marksmanship",
            warning = true,
            lines = {"Shoots at an enemy, inflicting Physical damage."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Hooked Net",
            spellId = 15609,
            icon = "Interface\\Icons\\Ability_Ensnare",
            warning = true,
            lines = {"Immobilizes nearby enemies for 10 seconds. and inflicts Physical damage."}
        }}
    },

    halycon = {
        name = "Halycon",
        icon = "Interface\\Icons\\temp",
        -- CHANGED: real abilities from a combat log (LBRS.csv), cross-matched against
        -- Spell.xlsx by exact Spell ID - see TODO_Raid_Data.md for gaps left as X.
        abilities = {{
            name = "Mighty Blow",
            spellId = 14099,
            icon = "Interface\\Icons\\INV_Gauntlets_05",
            warning = true,
            -- CHANGED 2026-09-30: spell 14099 in Spell.csv is level-scaled - bonus 25, +2 per caster level above 20.
            lines = {"Inflicts weapon damage plus 25, plus 2 per caster level above 20 (about 105 at level 60) to an enemy, knocking it back."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 8715) + SpellDuration.csv lookup - not in-game tested.
            name = "Terrifying Howl",
            spellId = 8715,
            icon = "Interface\\Icons\\Ability_Devour",
            warning = true,
            lines = {"Causes nearby enemies to flee in fear for 3 seconds."}
        }, {
            name = "Frenzy",
            spellId = 28371,
            icon = "Interface\\Icons\\Ability_Druid_ChallangingRoar",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 28371 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: from Spell.csv (spell 28371).
            lines = {"Increases attack speed by 100%, damage dealt by 50% and size by 25% for 12 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 10887) + SpellDuration.csv lookup - not in-game tested.
            name = "Crowd Pummel",
            spellId = 10887,
            icon = "Interface\\Icons\\INV_Gauntlets_04",
            warning = true,
            lines = {"Pummels nearby enemies for weapon damage plus 10 and interrupts any spell being cast 75% of the time for 5 seconds."}
        }}
    },

    gizrul = {
        name = "Gizrul the Slavener",
        icon = "Interface\\Icons\\temp",
        -- CHANGED: real abilities from a combat log (LBRS.csv), cross-matched against
        -- Spell.xlsx by exact Spell ID - see TODO_Raid_Data.md for gaps left as X.
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Infected Bite",
            spellId = 16128,
            icon = "Interface\\Icons\\Spell_Shadow_CallofBone",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 16128).
            -- CHANGED 2026-09-30: spell 16128 in Spell.csv is level-scaled - DoT 45 +2/level above 20; damage taken 30 +5/level above 20 (per-slot split read from a 3-field row - verify), no cap unless stated.
            lines = {"Inflicts 45 plus 2 per caster level above 20 (about 125 at level 60) Nature damage to an enemy every 10 seconds and increases the Physical damage it takes by 30 plus 5 per caster level above 20 (about 230 at level 60) for 180 seconds."}
        }, {
            name = "Forceful Howl",
            spellId = 30121,
            icon = "Interface\\Icons\\Ability_BullRush",
            warning = true,
            lines = {"Inflicts weapon damage plus 30 to an enemy and knocks it back."}
        }, {
            name = "Frenzy",
            spellId = 28371,
            icon = "Interface\\Icons\\Ability_Druid_ChallangingRoar",
            -- CHANGED: Description_enUS empty in Spell.xlsx for spell ID 28371 - not reverse-engineered from raw effect codes.
            -- CHANGED 2026-09-29: from Spell.csv (spell 28371).
            lines = {"Increases attack speed by 100%, damage dealt by 50% and size by 25% for 12 seconds."}
        }, {
            name = "Enrage",
            spellId = 8269,
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 8269).
            -- CHANGED 2026-09-30: spell 8269 in Spell.csv is level-scaled - base 50, +2 per caster level above 26, no cap unless stated.
            lines = {"Increases the caster's attack speed by 60% and the Physical damage it deals by 50 plus 2 per caster level above 26 (about 118 at level 60) for 2 minutes."}
        }}
    },

    wyrmthalak = {
        name = "Overlord Wyrmthalak",
        icon = "Interface\\Icons\\temp",
        -- CHANGED: real abilities from a combat log (LBRS.csv), cross-matched against
        -- Spell.xlsx by exact Spell ID - see TODO_Raid_Data.md for gaps left as X.
        abilities = {{
            -- CHANGED: duration confirmed from Spell.xlsx (spell 20229) + SpellDuration.csv lookup - not in-game tested.
            name = "Blast Wave",
            spellId = 20229,
            icon = "Interface\\Icons\\Spell_Holy_Excorcism_02",
            warning = true,
            lines = {"Inflicts 994 to 1406 Fire damage to nearby enemies and reduces their movement speed by 50% for 12 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell ambiguous rank, but value agrees across all matching ranks) + SpellDuration.csv lookup - not in-game tested.
            name = "Demoralizing Shout",
            spellId = 23511,
            icon = "Interface\\Icons\\Ability_Warrior_WarCry",
            -- CHANGED 2026-09-30: spell 23511 in Spell.csv is level-scaled - AP reduction 40, +10 per caster level above 5.
            lines = {"Reduces the attack power of nearby enemies by 40 plus 10 per caster level above 5 (about 590 at level 60) for 30 seconds."}
        }, {
            name = "Disarm",
            spellId = 13534,
            icon = "Interface\\Icons\\Ability_Warrior_Disarm",
            warning = true,
            -- CHANGED 2026-09-29: from Spell.csv (spell 13534).
            lines = {"Disarm target's weapon for 10 seconds."}
        }, {
            -- CHANGED: duration confirmed from Spell.xlsx (spell 34424) + SpellDuration.csv lookup - not in-game tested.
            name = "Brutal Knockout",
            spellId = 34424,
            icon = "Interface\\Icons\\INV_Gauntlets_05",
            warning = true,
            lines = {"Inflicts weapon damage plus 500 to an enemy, reducing healing taken by 100% and stunning it for 8 seconds."}
        }}
    },
}

------------------------------------------------------------
-- Builder: expands the order list + registry above into the flat table
-- shape the Bosses/Trash views expect (see AGENTS.md "Data model"). Nothing
-- below this point encodes raid content - only edit it if the addon's
-- expected data shape changes.
------------------------------------------------------------

local function BuildLBRSBosses()
    local bosses = {}
    for _, key in ipairs(LBRS_BOSS_ORDER) do
        local boss = { key = key }
        for field, value in pairs(LBRS_BOSSES[key]) do
            boss[field] = value
        end
        table.insert(bosses, boss)
    end
    return bosses
end

local function BuildLBRSTrash()
    local trash = {}
    for _, entry in ipairs(LBRS_TRASH_ORDER) do
        if type(entry) == "table" and entry.separator then
            table.insert(trash, entry)
        else
            local key, count
            if type(entry) == "table" then
                key, count = entry.key, entry.count
            else
                key = entry
            end
            local mob = LBRS_TRASH_MOBS[key]
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
    -- CHANGED: boss list confirmed against a real combat log (LBRS.csv); 8 of 9
    -- bosses now have real ability data (Urok Doomhowl still placeholder - no
    -- combat data for him in this log). Trash roster added from the same log.
    key = "LBRS",
    name = "Lower Blackrock Spire",
    expanded = false,
    trashExpanded = false,
    trash = BuildLBRSTrash(),
    bosses = BuildLBRSBosses(),
})
