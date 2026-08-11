-- Part of the DungeonJournal RAIDS database (see AGENTS.md "Data model").
-- Loaded via DungeonJournal.toc before DungeonJournal.lua; appends this
-- raid's table to the shared DungeonJournal_Raids list in load order.

DungeonJournal_Raids = DungeonJournal_Raids or {}

table.insert(DungeonJournal_Raids, {
    key = "UBRS",
    name = "Upper Blackrock Spire",
    expanded = false,
    bosses = {{
        key = "emberseer",
        name = "Pyroguard Emberseer",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Pyroguard Emberseer's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }, {
        key = "solakar",
        name = "Solakar Flamewreath",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Solakar Flamewreath's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }, {
        key = "goraluk",
        name = "Goraluk Anvilcrack",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Goraluk Anvilcrack's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }, {
        key = "jed",
        name = "Jed Runewatcher",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Jed Runewatcher's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }, {
        key = "rend",
        name = "Warchief Rend Blackhand",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Warchief Rend Blackhand's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }, {
        key = "gyth",
        name = "Gyth",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Gyth's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }, {
        key = "the_beast",
        name = "The Beast",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "The Beast's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }, {
        key = "drakkisath",
        name = "General Drakkisath",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "General Drakkisath's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }, {
        key = "valthalak",
        name = "Lord Valthalak",
        icon = "Interface\\Icons\\temp",
        abilities = {{
            name = "Lord Valthalak's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }}

})
