-- Part of the DungeonJournal RAIDS database (see AGENTS.md "Data model").
-- Loaded via DungeonJournal.toc before DungeonJournal.lua; appends this
-- raid's table to the shared DungeonJournal_Raids list in load order.

DungeonJournal_Raids = DungeonJournal_Raids or {}

------------------------------------------------------------
-- WORLD order list - START HERE to reorder bosses.
--
-- WORLD_BOSS_ORDER is the only thing you should need to touch to change
-- what order bosses appear in the Bosses tab. Just a flat list of keys -
-- actual boss data (icon/flags/stats/abilities) lives further down in
-- WORLD_BOSSES, defined once per key and looked up from here.
------------------------------------------------------------

-- Boss encounter order (Bosses tab tree, top to bottom).
local WORLD_BOSS_ORDER = {
    "azuregos",
    "hederine",
    "kazzak",
    "kurinnaxx",
    "teremus",
    "king_mosh",
}

------------------------------------------------------------
-- Boss registry - one entry per boss (icon/flags/stats/abilities/adds),
-- referenced by key from WORLD_BOSS_ORDER above. Defined once each; add a
-- new boss here and add its key to WORLD_BOSS_ORDER to place it.
------------------------------------------------------------
local WORLD_BOSSES = {
    azuregos = {
        name = "Azuregos",
        icon = "Interface\\Icons\\temp",
        flags = {"damage_frost"},
        stats = {armor = 5880, fire = 126, nature = 126, frost = "immune", shadow = 126, arcane = 300},
        abilities = {{
            name = "Chill",
            icon = "Interface\\Icons\\Spell_Frost_Glacier",
            warning = true,
            roles = {"dispel", "tank"},
            lines = {"Blasts nearby enemies with ice, increasing the time between their attacks and slowing movement. His most frequent ability.",
                     "Dispel tanks first, then melee - skip the rest."}
        }, {
            name = "Frost Breath",
            icon = "Interface\\Icons\\Spell_Frost_FrostNova",
            warning = true,
            roles = {"tank"},
            lines = {"Inflicts Frost damage in a cone in front of him, steals mana and stuns. Do not stand in front unless you are tanking.",
                     "Unlike most dragons he does NOT tail swipe, so standing behind him is safe."}
        }, {
            name = "Manastorm",
            icon = "Interface\\Icons\\Spell_Frost_IceStorm",
            warning = true,
            lines = {"Calls down a mana storm inflicting Frost damage and draining mana every second in a selected area. Move out of it."}
        }, {
            name = "Deep Freeze",
            icon = "Interface\\Icons\\Spell_Frost_ChainsOfIce",
            warning = true,
            roles = {"healer"},
            lines = {"Freezes the target in place with a large damage-over-time effect. Assign 1-2 resto druids to heal these targets."}
        }, {
            name = "Magic Reflection",
            icon = "Interface\\Icons\\Spell_Frost_WindWalkOn",
            warning = true,
            roles = {"reflect", "caster"},
            lines = {"Casters must stop all spell damage while this is up or it will be reflected back."}
        }, {
            name = "Teleport",
            icon = "Interface\\Icons\\Spell_Arcane_PortalIronForge",
            warning = true,
            lines = {"Stop DPS when he teleports - he resets threat and will otherwise kill the raid."}
        }, {
            name = "Mark of Frost",
            icon = "Interface\\Icons\\Spell_Frost_ChainsOfIce",
            warning = true,
            lines = {"A 15 minute undispellable debuff applied on death - it freezes you in place if you release while Azuregos is nearby.",
                     "He is immune to Arcane and has very high Frost resistance."}
        }}
    },

    hederine = {
        name = "Lady Hederine",
        icon = "Interface\\Icons\\temp",
        flags = {"damage_nature"},
        stats = {armor = 4316, fire = 93, nature = 93, frost = 93, shadow = 93, arcane = 55},
        abilities = {{
            name = "Bloating Toxins",
            icon = "Interface\\Icons\\Ability_Creature_Disease_02",
            warning = true,
            roles = {"poison"},
            lines = {"The defining mechanic - the target's flesh bloats and explodes, firing a poison bolt volley at everyone in their line of sight, including themselves.",
                     "Targets must break line of sight with the whole raid. Each cast marks 2 players: the furthest raid member and someone in the top 3 threat."}
        }, {
            name = "Flesh Explosion",
            icon = "Interface\\Icons\\Ability_Poisons",
            warning = true,
            roles = {"poison", "healer"},
            lines = {"Nature damage every second after Bloating Toxins expires. Cleanse poison to remove it. Her most frequent log entry."}
        }, {
            name = "Tears of the Hederine",
            icon = "Interface\\Icons\\Ability_Mage_ColdAsIce",
            warning = true,
            lines = {"Green gas on the ground - standing in it too long freezes you, applies a heavy damage-over-time effect and prevents healing. Move out."}
        }, {
            name = "Curse of Weakness",
            icon = "Interface\\Icons\\Spell_Shadow_CurseOfMannoroth",
            warning = true,
            roles = {"decurse", "tank"},
            lines = {"Reduces Physical damage dealt. Decurse tanks first, then hunters and melee DPS - skip the rest."}
        }, {
            name = "Impotence",
            icon = "Interface\\Icons\\Spell_Shadow_ChillTouch",
            warning = true,
            roles = {"dispel"},
            lines = {"Reduces magical damage dealt by 90%. Dispel priority: shaman/paladin tank, then DPS shaman/warlock, then mages and boomkins.",
                     "DPS priests and paladins should dispel themselves."}
        }, {
            name = "Sonic Lash",
            icon = "Interface\\Icons\\Spell_Shadow_Curse",
            warning = true,
            roles = {"tank"},
            lines = {"Nature damage in a cone in front of her, knocking enemies back and wiping aggro. Keep a Nature Resistance totem in the main tank's group."}
        }, {
            name = "Lash of Pain",
            icon = "Interface\\Icons\\Spell_Shadow_Curse",
            lines = {"Shadow damage lash. Fire damage component - keep a Fire Resistance totem in the main tank's group."}
        }, {
            name = "Mind Control",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
            warning = true,
            lines = {"Crowd control the mind controlled player - do NOT kill them."}
        }, {
            name = "Adds",
            icon = "Interface\\Icons\\Ability_Hunter_Pet_Bat",
            warning = true,
            roles = {"tank"},
            lines = {"Requires 5 tanks total: a main tank plus 2 tanks for each add. Off tanks must pull.",
                     "Tanks taunt off each other at 3 stacks of Sunder Armor, and must taunt immediately when adds charge the main tank."}
        }}
    },

    kazzak = {
        name = "Lord Kazzak",
        icon = "Interface\\Icons\\temp",
        flags = {"damage_shadow"},
        stats = {armor = 5880, fire = 143, nature = 75, frost = 75, shadow = 143, arcane = 75},
        abilities = {{
            name = "Mark of Kazzak",
            icon = "Interface\\Icons\\Spell_Shadow_AntiShadow",
            warning = true,
            roles = {"decurse"},
            lines = {"A curse draining mana over time. If the target runs out of mana while afflicted they explode.",
                     "Decurse it, and never let your mana fall below 2000."}
        }, {
            name = "Shadow Bolt Volley",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            warning = true,
            lines = {"Hurls Shadow bolts at everyone, ignoring line of sight. By far his most frequent ability (25000+ log entries)."}
        }, {
            name = "Twisted Reflection",
            icon = "Interface\\Icons\\Spell_Arcane_PortalDarnassus",
            warning = true,
            roles = {"dispel"},
            lines = {"Heals Kazzak whenever damage is dealt to the affected target. Dispel it promptly."}
        }, {
            name = "Thunderclap",
            icon = "Interface\\Icons\\Spell_Nature_ThunderClap",
            warning = true,
            roles = {"dispel", "tank"},
            lines = {"Nature damage that slows attack speed and movement. Dispel from the main tank and assign a dedicated dispeller for high value melee DPS."}
        }, {
            name = "A Falling Star (Meteor)",
            icon = "Interface\\Icons\\Spell_Fire_Fireball02",
            warning = true,
            roles = {"melee"},
            lines = {"An AoE knockback that can also hit the tank. Melee must stay at maximum range behind him to avoid this and the frontal Cleave."}
        }, {
            name = "Void Bolt",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            lines = {"A single-target bolt of dark magic."}
        }, {
            name = "Capture Soul",
            icon = "Interface\\Icons\\Spell_Shadow_SoulGem",
            warning = true,
            lines = {"Every player OR pet that dies heals Kazzak for 70000+ health - including hunter pets and Eskhandar.",
                     "Any player or pet outside the raid also heals him if they are near or in combat with him. Do not die."}
        }}
    },

    kurinnaxx = {
        name = "Kurinnaxx",
        icon = "Interface\\Icons\\temp",
        flags = {"damage_nature"},
        stats = {armor = 6700, fire = 83, nature = 151, frost = 83, shadow = 115, arcane = 115},
        abilities = {{
            name = "Mortal Wound",
            icon = "Interface\\Icons\\Ability_CriticalStrike",
            warning = true,
            roles = {"tank", "healer"},
            lines = {"Reduces healing taken by 10% per stack. Tanks must taunt off each other at three to five stacks."}
        }, {
            name = "Poison Bolt Volley",
            icon = "Interface\\Icons\\Ability_Poisons",
            warning = true,
            roles = {"poison"},
            lines = {"Shoots poison at enemies in a cone in front of him. Keep a Poison Cleansing Totem in the tank group.",
                     "Do not stand in front of him unless you are tanking. His most frequent ability."}
        }, {
            name = "Tail Sweep",
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_05",
            warning = true,
            lines = {"Damages and knocks back enemies behind him. Do not stand behind Kurinnaxx.",
                     "All DPS and healers should be positioned at his left or right side."}
        }, {
            name = "Sand Trap",
            icon = "Interface\\Icons\\INV_Misc_Dust_02",
            warning = true,
            lines = {"Move away from the sand trap or you will be silenced and unable to cast for 20 seconds."}
        }, {
            name = "Sand Reaver's Rush (Charge)",
            icon = "Interface\\Icons\\Ability_Warrior_Charge",
            warning = true,
            lines = {"Stop DPS when he charges."}
        }, {
            name = "Wide Slash",
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            roles = {"tank"},
            lines = {"Inflicts normal damage plus extra to enemies in a cone in front of him."}
        }, {
            name = "Enrage",
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            warning = true,
            roles = {"warrior"},
            lines = {"Enrages at 30% health. Save damage cooldowns for this phase.",
                     "He should be disarmed as much as possible while enraged."}
        }}
    },

    teremus = {
        name = "Teremus the Devourer",
        icon = "Interface\\Icons\\temp",
        color = "ffffd100",
        flags = {"damage_shadow"},
        abilities = {{
            name = "Soul Consumption",
            icon = "Interface\\Icons\\Ability_Racial_Cannibalize",
            warning = true,
            roles = {"healer"},
            lines = {"Drains health from everyone nearby and heals himself for a multiple of the amount stolen.",
                     "His most frequent ability by a wide margin - spread out and keep the raid topped up so he gains as little as possible."}
        }, {
            name = "Devour Essence",
            icon = "Interface\\Icons\\Spell_Shadow_SummonFelHunter",
            warning = true,
            roles = {"healer"},
            lines = {"'Feeding the Devourer...' - devours the target's flesh, dealing damage every second, stunning them and healing himself."}
        }, {
            name = "Unrestrained Corruption",
            icon = "Interface\\Icons\\INV_Misc_Head_Dragon_Black",
            warning = true,
            roles = {"tank"},
            lines = {"A self-buff increasing his Physical damage by 30% and his armour by 45%.",
                     "Tank damage spikes and your damage output drops while this is up."}
        }, {
            name = "Shadow Flame",
            icon = "Interface\\Icons\\Spell_Fire_Incinerate",
            warning = true,
            lines = {"Inflicts heavy Shadow damage to enemies in a cone in front of him. Do not stand in front."}
        }, {
            name = "Knock Away",
            icon = "Interface\\Icons\\INV_Gauntlets_05",
            warning = true,
            roles = {"tank"},
            lines = {"Inflicts damage to nearby enemies and knocks them back, shedding threat."}
        }, {
            name = "Cleave",
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            roles = {"tank", "melee"},
            lines = {"Strikes his target and its nearest allies, knocking them back."}
        }}
    },

    king_mosh = {
        name = "King Mosh",
        icon = "Interface\\Icons\\temp",
        color = "ffffd100",
        abilities = {{
            name = "Trample",
            icon = "Interface\\Icons\\Spell_Nature_NaturesWrath",
            warning = true,
            roles = {"tank"},
            lines = {"Inflicts Physical damage to everyone nearby. His most frequent ability - melee should expect constant incoming damage."}
        }, {
            name = "Terrifying Roar",
            icon = "Interface\\Icons\\Stampede",
            warning = true,
            roles = {"shaman", "tank"},
            lines = {"Paralyses the target with terror and sends nearby raid members fleeing in fear.",
                     "Keep a Tremor Totem down for the main tank."}
        }, {
            name = "Vicious Rend",
            icon = "Interface\\Icons\\Ability_Gouge",
            warning = true,
            roles = {"healer"},
            lines = {"A bleed inflicting Physical damage every 3 seconds on the tank."}
        }, {
            name = "Primal Vitality",
            icon = "Interface\\Icons\\INV_Relics_IdolofRejuvenation",
            warning = true,
            lines = {"Regenerates a percentage of his total health every 3 seconds - the raid must out-damage the regeneration."}
        }}
    },
}

------------------------------------------------------------
-- Builder: expands the order list + registry above into the flat table
-- shape the Bosses view expects (see AGENTS.md "Data model"). Nothing
-- below this point encodes raid content - only edit it if the addon's
-- expected data shape changes.
------------------------------------------------------------

local function BuildWORLDBosses()
    local bosses = {}
    for _, key in ipairs(WORLD_BOSS_ORDER) do
        local boss = { key = key }
        for field, value in pairs(WORLD_BOSSES[key]) do
            boss[field] = value
        end
        table.insert(bosses, boss)
    end
    return bosses
end

table.insert(DungeonJournal_Raids, {
    -- CHANGED: World bosses. Mechanics come from Spell.dbc plus the raid-lead
    -- tips document, with cast frequencies observed in combat logs.
    key = "WORLD",
    name = "World Bosses",
    expanded = false,
    bosses = BuildWORLDBosses(),
})
