-- Part of the DungeonJournal RAIDS database (see AGENTS.md "Data model").
-- Loaded via DungeonJournal.toc before DungeonJournal.lua; appends this
-- raid's table to the shared DungeonJournal_Raids list in load order.

DungeonJournal_Raids = DungeonJournal_Raids or {}

table.insert(DungeonJournal_Raids, {
    -- CHANGED: the four Dragons of Nightmare. They share a common ability set
    -- (Noxious Breath, Tail Sweep) plus one signature mechanic each.
    key = "GREEN",
    name = "Green Dragons",
    expanded = false,
    bosses = {{
        key = "emeriss",
        name = "Emeriss",
        icon = "Interface\\Icons\\temp",
        flags = {"damage_nature"},
        abilities = {{
            name = "Volatile Infection",
            icon = "Interface\\Icons\\Spell_Holy_HarmUndeadAura",
            warning = true,
            roles = {"dispel", "healer"},
            lines = {"Emeriss' signature mechanic - infects a player so they inflict Nature damage to nearby allies.",
                     "The infected player must move away from the raid. Her most frequent ability."}
        }, {
            name = "Corruption of the Earth",
            icon = "Interface\\Icons\\Ability_Creature_Cursed_03",
            warning = true,
            roles = {"healer"},
            lines = {"Deals a percentage of maximum health as damage every few seconds to the entire raid."}
        }, {
            name = "Noxious Breath",
            icon = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
            warning = true,
            roles = {"tank"},
            lines = {"Frontal breath dealing damage over time and increasing ability cooldowns. Do not stand in front."}
        }, {
            name = "Tail Sweep",
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_05",
            warning = true,
            lines = {"Damages and knocks back enemies behind her. Do not stand behind."}
        }, {
            name = "Mark of Nature",
            icon = "Interface\\Icons\\Spell_Nature_SpiritArmor",
            warning = true,
            lines = {"Applied on death - you are weakened and susceptible to her Aura of Nature if you release nearby."}
        }}
    }, {
        key = "lethon",
        name = "Lethon",
        icon = "Interface\\Icons\\temp",
        flags = {"damage_shadow"},
        abilities = {{
            name = "Shadow Bolt Whirl",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            warning = true,
            lines = {"Spinning bolts of Shadow magic radiate outward from him. His most frequent ability by a wide margin - keep moving to avoid them."}
        }, {
            name = "Draw Spirit",
            icon = "Interface\\Icons\\Spell_Shadow_SummonInfernal",
            warning = true,
            roles = {"dps"},
            lines = {"Lethon draws spirits out of the raid. The spirit shades travel back to him and heal him if they reach him - intercept and kill them."}
        }, {
            name = "Noxious Breath",
            icon = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
            warning = true,
            roles = {"tank"},
            lines = {"Frontal breath dealing damage over time and increasing ability cooldowns. Do not stand in front."}
        }, {
            name = "Tail Sweep",
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_05",
            warning = true,
            lines = {"Damages and knocks back enemies behind him. Do not stand behind."}
        }, {
            name = "Mark of Nature",
            icon = "Interface\\Icons\\Spell_Nature_SpiritArmor",
            warning = true,
            lines = {"Applied on death - you are weakened and susceptible to his aura if you release nearby."}
        }}
    }, {
        key = "taerar",
        name = "Taerar",
        icon = "Interface\\Icons\\temp",
        flags = {"damage_arcane"},
        abilities = {{
            name = "Arcane Blast",
            icon = "Interface\\Icons\\Spell_Shadow_DeathPact",
            warning = true,
            lines = {"Blasts an enemy with Arcane magic for normal damage plus extra, knocking them back."}
        }, {
            name = "Bellowing Roar",
            icon = "Interface\\Icons\\Spell_Shadow_Charm",
            warning = true,
            roles = {"shaman"},
            lines = {"Fears the raid. Keep a Tremor Totem down for the main tank."}
        }, {
            name = "Shades of Taerar",
            icon = "Interface\\Icons\\Spell_Shadow_SummonInfernal",
            warning = true,
            roles = {"tank"},
            lines = {"Taerar splits into shades partway through the fight - they must be tanked and killed before he becomes vulnerable again."}
        }, {
            name = "Noxious Breath",
            icon = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
            warning = true,
            roles = {"tank"},
            lines = {"Frontal breath dealing damage over time and increasing ability cooldowns. Do not stand in front."}
        }, {
            name = "Tail Sweep",
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_05",
            warning = true,
            lines = {"Damages and knocks back enemies behind him. His most frequent ability - do not stand behind."}
        }, {
            name = "Mark of Nature",
            icon = "Interface\\Icons\\Spell_Nature_SpiritArmor",
            warning = true,
            lines = {"Applied on death - you are weakened and susceptible to his aura if you release nearby."}
        }}
    }, {
        key = "ysondre",
        name = "Ysondre",
        icon = "Interface\\Icons\\temp",
        flags = {"damage_nature"},
        stats = {armor = 4691, fire = 126, nature = 126, frost = 126, shadow = 126, arcane = 126},
        abilities = {{
            name = "Lightning Wave",
            icon = "Interface\\Icons\\Spell_Nature_ChainLightning",
            warning = true,
            lines = {"Strikes an enemy with lightning that arcs to nearby enemies, dealing greater Nature damage to each. Her most frequent ability - spread out."}
        }, {
            name = "Summon Druids",
            icon = "Interface\\Icons\\Spell_Nature_ForceOfNature",
            warning = true,
            roles = {"kick", "tank"},
            lines = {"Ysondre summons Demented Druids that cast Moonfire and heal her. Interrupt and kill them quickly."}
        }, {
            name = "Noxious Breath",
            icon = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
            warning = true,
            roles = {"tank"},
            lines = {"Frontal breath dealing damage over time and increasing ability cooldowns. Do not stand in front."}
        }, {
            name = "Tail Sweep",
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_05",
            warning = true,
            lines = {"Damages and knocks back enemies behind her. Do not stand behind."}
        }, {
            name = "Mark of Nature",
            icon = "Interface\\Icons\\Spell_Nature_SpiritArmor",
            warning = true,
            lines = {"Applied on death - you are weakened and susceptible to her aura if you release nearby."}
        }}
    }}

})
