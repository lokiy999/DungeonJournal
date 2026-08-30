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
--
-- CHANGED 2026-08-30: every boss EXCEPT Lady Hederine refilled from
-- retail WoW Classic 1.12 references (warcraft.wiki.gg / Warcraft Tavern /
-- Icy Veins tactics pages, cross-checked against the classic-era spell
-- data). User confirmed these five are unchanged from Classic on this
-- server. Damage numbers are the commonly cited retail values and are
-- marked "~" where a range/estimate; not independently tested here.
-- Lady Hederine is a Vanilla+ custom and is left untouched.
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
            lines = {"Blasts nearby enemies with ice for around 450 to 550 Frost damage, increasing the time between their attacks and slowing their movement. His most frequent ability - dispellable."}
        }, {
            name = "Frost Breath",
            icon = "Interface\\Icons\\Spell_Frost_FrostNova",
            warning = true,
            roles = {"tank"},
            lines = {"Frontal cone: roughly 900 to 1100 Frost damage, drains mana and stuns for 4 seconds. Do not stand in front unless tanking.",
                     "Unlike most dragons Azuregos does NOT tail swipe, so standing behind him is safe."}
        }, {
            name = "Mana Storm",
            icon = "Interface\\Icons\\Spell_Frost_IceStorm",
            warning = true,
            lines = {"Calls down a mana storm over a targeted area, dealing around 475 to 525 Frost damage and draining mana every second. Move out of it."}
        }, {
            name = "Aura of Frost",
            icon = "Interface\\Icons\\Spell_Frost_WizardMark",
            lines = {"Passive - deals a small amount of Frost damage every second to everyone in melee range of Azuregos."}
        }, {
            name = "Reflect",
            icon = "Interface\\Icons\\Spell_Frost_WindWalkOn",
            warning = true,
            roles = {"reflect", "caster"},
            lines = {"A 10 second self-buff that reflects all harmful spells back at their caster. Stop all spell casting while it is up."}
        }, {
            name = "Teleport",
            icon = "Interface\\Icons\\Spell_Arcane_PortalIronForge",
            warning = true,
            lines = {"Teleports every player within 30 yards on top of Azuregos and wipes his threat table. He then re-picks a target - stop damage until a tank has re-established threat."}
        }, {
            name = "Mark of Frost",
            icon = "Interface\\Icons\\Spell_Frost_ChainsOfIce",
            warning = true,
            lines = {"A 15 minute undispellable debuff applied to any player he kills. While it is up, coming near Azuregos encases you in a frost tomb, frozen and helpless. Corpse-run wide of his area.",
                     "Azuregos is immune to Frost and has very high Arcane resistance."}
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
            name = "Shadow Bolt Volley",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            warning = true,
            lines = {"Hurls Shadow bolts at everyone for around 800 to 1000 Shadow damage each, ignoring line of sight, with no target limit. By far his most frequent ability."}
        }, {
            name = "Void Bolt",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            roles = {"tank", "healer"},
            lines = {"A single-target bolt on the current tank for around 3000 to 4000 Shadow damage."}
        }, {
            name = "Mark of Kazzak",
            icon = "Interface\\Icons\\Spell_Shadow_AntiShadow",
            warning = true,
            roles = {"decurse"},
            lines = {"A curse on a random player that drains 250 mana per second for 1 minute. If the target reaches 0 mana it explodes for around 4000 damage to everyone nearby.",
                     "Decurse it, or keep your mana above ~2000 so it can't fully drain."}
        }, {
            name = "Twisted Reflection",
            icon = "Interface\\Icons\\Spell_Arcane_PortalDarnassus",
            warning = true,
            roles = {"dispel"},
            lines = {"A debuff on a random player - every time Kazzak damages that player he is healed for 25,000. Dispel it the instant it lands."}
        }, {
            name = "Thunder Clap",
            icon = "Interface\\Icons\\Spell_Nature_ThunderClap",
            warning = true,
            roles = {"dispel", "tank"},
            lines = {"Raid-wide Nature damage that increases the time between attacks and slows movement. Dispel the main tank."}
        }, {
            name = "Cleave",
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            roles = {"tank", "melee"},
            lines = {"A frontal strike hitting his target and its nearest allies - melee stay behind him."}
        }, {
            name = "Enrage",
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            warning = true,
            lines = {"Hard enrage 3 minutes after the pull - he must be dead before then."}
        }, {
            name = "Capture Soul",
            icon = "Interface\\Icons\\Spell_Shadow_SoulGem",
            warning = true,
            lines = {"Passive, very large radius - every player OR pet that dies heals Kazzak for around 90,000. This includes hunter pets and any outside player or pet that dies near him. Do not let anything die."}
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
            lines = {"Reduces healing received on the target by 10% per stack for 15 seconds. Stacks - tanks taunt off each other around 4 to 5 stacks."}
        }, {
            name = "Poison Bolt Volley",
            icon = "Interface\\Icons\\Ability_Poisons",
            warning = true,
            roles = {"poison"},
            lines = {"Shoots poison at enemies in a cone in front of him, applying a stacking Nature damage-over-time. Do not stand in front unless tanking - it is his most frequent ability."}
        }, {
            name = "Tail Sweep",
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_05",
            warning = true,
            lines = {"Damages and knocks back enemies behind him. Stand at his sides, not front or back."}
        }, {
            name = "Sand Trap",
            icon = "Interface\\Icons\\INV_Misc_Dust_02",
            warning = true,
            lines = {"Spawns a sand trap under a random player. Anyone standing in it when it triggers is silenced and unable to act for about 20 seconds - move out the moment it appears."}
        }, {
            name = "Sand Reaver's Rush (Charge)",
            icon = "Interface\\Icons\\Ability_Warrior_Charge",
            warning = true,
            lines = {"Charges an enemy, knocking them back and wiping his threat on that target."}
        }, {
            name = "Wide Slash",
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            roles = {"tank"},
            lines = {"Inflicts normal damage plus around 500 to enemies in a cone in front of him."}
        }, {
            name = "Enrage",
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            warning = true,
            roles = {"warrior"},
            lines = {"Enrages at 30% health, gaining attack speed and Physical damage. Keeping him Disarmed greatly reduces the danger."}
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
            lines = {"Drains health from every enemy nearby and heals himself for a multiple of the amount stolen. His most frequent ability by a wide margin - spread out and keep the raid topped up."}
        }, {
            name = "Devour Essence",
            icon = "Interface\\Icons\\Spell_Shadow_SummonFelHunter",
            warning = true,
            roles = {"healer"},
            lines = {"Channels on the target ('Feeding the Devourer...'), dealing damage every second, stunning them, and healing himself for the damage dealt."}
        }, {
            name = "Unrestrained Corruption",
            icon = "Interface\\Icons\\INV_Misc_Head_Dragon_Black",
            warning = true,
            roles = {"tank"},
            lines = {"A self-buff that increases his Physical damage by 30% and his armor by 45%. Tank damage spikes and raid DPS drops while it is up."}
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
            lines = {"Inflicts damage to nearby enemies, knocks them back, and drops threat."}
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
        flags = {"melee"},
        abilities = {{
            name = "Trample",
            icon = "Interface\\Icons\\Spell_Nature_NaturesWrath",
            warning = true,
            roles = {"tank"},
            lines = {"Inflicts Physical damage to everyone nearby. His most frequent ability - melee take constant incoming damage."}
        }, {
            name = "Terrifying Roar",
            icon = "Interface\\Icons\\Stampede",
            warning = true,
            roles = {"shaman", "tank"},
            lines = {"Fears nearby raid members. Keep a Tremor Totem down for the main tank."}
        }, {
            name = "Vicious Rend",
            icon = "Interface\\Icons\\Ability_Gouge",
            warning = true,
            roles = {"healer"},
            lines = {"A bleed inflicting Physical damage every 3 seconds on the tank."}
        }, {
            name = "Primal Vitality",
            icon = "Interface\\Icons\\INV_Relics_IdolofRejuvenation",
            lines = {"Passive - regenerates a percentage of his total health every few seconds. The raid must out-damage the regeneration."}
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
    -- CHANGED: World bosses. Azuregos / Kazzak / Kurinnaxx / Teremus / King
    -- Mosh from retail Classic 1.12 references; Lady Hederine is a Vanilla+
    -- custom (still needs a combat log).
    key = "WORLD",
    name = "World Bosses",
    expanded = false,
    bosses = BuildWORLDBosses(),
})
