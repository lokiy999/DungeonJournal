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

------------------------------------------------------------
-- Boss registry - one entry per boss (icon/flags/stats/abilities/adds),
-- referenced by key from LBRS_BOSS_ORDER above. Defined once each; add a
-- new boss here and add its key to LBRS_BOSS_ORDER to place it.
------------------------------------------------------------
local LBRS_BOSSES = {
    omokk = {
        name = "Highlord Omokk",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Highlord Omokk's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    },

    voshgajin = {
        name = "Shadow Hunter Vosh'gajin",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Shadow Hunter Vosh'gajin's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    },

    voone = {
        name = "War Master Voone",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "War Master Voone's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    },

    smolderweb = {
        name = "Mother Smolderweb",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Mother Smolderweb's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    },

    urok = {
        name = "Urok Doomhowl",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Urok Doomhowl's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    },

    zigris = {
        name = "Quartermaster Zigris",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Quartermaster Zigris' Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    },

    halycon = {
        name = "Halycon",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Halycon's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    },

    gizrul = {
        name = "Gizrul the Slavener",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Gizrul's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    },

    wyrmthalak = {
        name = "Overlord Wyrmthalak",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Overlord Wyrmthalak's Ability",
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

table.insert(DungeonJournal_Raids, {
    -- CHANGED: LBRS and UBRS bosses are listed for navigation only - their
    -- abilities still need documenting. Boss list confirmed against combat logs.
    key = "LBRS",
    name = "Lower Blackrock Spire",
    expanded = false,
    bosses = BuildLBRSBosses(),
})
