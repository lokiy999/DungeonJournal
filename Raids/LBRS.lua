-- Part of the DungeonJournal RAIDS database (see AGENTS.md "Data model").
-- Loaded via DungeonJournal.toc before DungeonJournal.lua; appends this
-- raid's table to the shared DungeonJournal_Raids list in load order.

DungeonJournal_Raids = DungeonJournal_Raids or {}

table.insert(DungeonJournal_Raids, {
    -- CHANGED: LBRS and UBRS bosses are listed for navigation only - their
    -- abilities still need documenting. Boss list confirmed against combat logs.
    key = "LBRS",
    name = "Lower Blackrock Spire",
    expanded = false,
    bosses = {{
        key = "omokk",
        name = "Highlord Omokk",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Highlord Omokk's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }, {
        key = "voshgajin",
        name = "Shadow Hunter Vosh'gajin",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Shadow Hunter Vosh'gajin's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }, {
        key = "voone",
        name = "War Master Voone",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "War Master Voone's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }, {
        key = "smolderweb",
        name = "Mother Smolderweb",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Mother Smolderweb's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }, {
        key = "urok",
        name = "Urok Doomhowl",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Urok Doomhowl's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }, {
        key = "zigris",
        name = "Quartermaster Zigris",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Quartermaster Zigris' Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }, {
        key = "halycon",
        name = "Halycon",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Halycon's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }, {
        key = "gizrul",
        name = "Gizrul the Slavener",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Gizrul's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }, {
        key = "wyrmthalak",
        name = "Overlord Wyrmthalak",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Overlord Wyrmthalak's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }}

})
