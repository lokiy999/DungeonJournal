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

------------------------------------------------------------
-- Boss registry - one entry per boss (icon/flags/stats/abilities/adds),
-- referenced by key from UBRS_BOSS_ORDER above. Defined once each; add a
-- new boss here and add its key to UBRS_BOSS_ORDER to place it.
------------------------------------------------------------
local UBRS_BOSSES = {
    emberseer = {
        name = "Pyroguard Emberseer",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Pyroguard Emberseer's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    },

    solakar = {
        name = "Solakar Flamewreath",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Solakar Flamewreath's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    },

    goraluk = {
        name = "Goraluk Anvilcrack",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Goraluk Anvilcrack's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    },

    jed = {
        name = "Jed Runewatcher",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Jed Runewatcher's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    },

    rend = {
        name = "Warchief Rend Blackhand",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Warchief Rend Blackhand's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    },

    gyth = {
        name = "Gyth",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Gyth's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    },

    the_beast = {
        name = "The Beast",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "The Beast's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    },

    drakkisath = {
        name = "General Drakkisath",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "General Drakkisath's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    },

    valthalak = {
        name = "Lord Valthalak",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Lord Valthalak's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    },
}

------------------------------------------------------------
-- Builder: expands the order list + registry above into the flat table
-- shape the Bosses view expects (see AGENTS.md "Data model"). Nothing
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

table.insert(DungeonJournal_Raids, {
    key = "UBRS",
    name = "Upper Blackrock Spire",
    expanded = false,
    bosses = BuildUBRSBosses(),
})
