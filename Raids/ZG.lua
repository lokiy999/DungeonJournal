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
    "edge_of_madness",
    "gahzranka",
    "thekal",
    "arlokk",
    "jindo",
    "hakkar",
    "azus",
    "nameless_hermit",
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
        }}
    },

    edge_of_madness = {
        name = "Edge of Madness",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Renataki",
            icon = "Interface\\Icons\\Ability_Rogue_Ambush",
            lines = {"A rogue-style boss. Only one Edge of Madness boss spawns per reset."},
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
        }, {
            name = "Gri'lek",
            icon = "Interface\\Icons\\Ability_WarStomp",
            lines = {"A warrior-style boss."},
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
        }, {
            name = "Hazza'rah",
            icon = "Interface\\Icons\\Spell_Nature_Sleep",
            lines = {"A caster-style boss."},
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
            }}
        }, {
            name = "Wushoolay",
            icon = "Interface\\Icons\\Spell_Nature_ChainLightning",
            lines = {"A lightning-themed boss."},
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

    thekal = {
        name = "High Priest Thekal",
        icon = "Interface\\Icons\\temp",
        stats = {armor = 4620, fire = 45, nature = 58, frost = 35, shadow = 35, arcane = 35},
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
        }}
    },

    nameless_hermit = {
        name = "Nameless Hermit",
        icon = "Interface\\Icons\\temp",
        stats = {armor = 4950, fire = 44, nature = 75, frost = 12, shadow = 44, arcane = 44},
        abilities = {{
            name = "Nameless Hermit's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented - the Hermit has a Transform mechanic but no offensive abilities appeared in the combat log."}
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
    for _, key in ipairs(ZG_BOSS_ORDER) do
        local boss = { key = key }
        for field, value in pairs(ZG_BOSSES[key]) do
            boss[field] = value
        end
        table.insert(bosses, boss)
    end
    return bosses
end

table.insert(DungeonJournal_Raids, {
    -- CHANGED: Zul'Gurub 20-man raid. Mechanics from Spell.dbc and combat logs.
    key = "ZG",
    name = "Zul'Gurub",
    expanded = false,
    bosses = BuildZGBosses(),
})
