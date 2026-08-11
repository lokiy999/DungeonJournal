-- Part of the DungeonJournal RAIDS database (see AGENTS.md "Data model").
-- Loaded via DungeonJournal.toc before DungeonJournal.lua; appends this
-- raid's table to the shared DungeonJournal_Raids list in load order.

DungeonJournal_Raids = DungeonJournal_Raids or {}

------------------------------------------------------------
-- ONY order list - START HERE to reorder bosses.
--
-- ONY_BOSS_ORDER is the only thing you should need to touch to change
-- what order bosses appear in the Bosses tab. Just a flat list of keys -
-- actual boss data (icon/flags/stats/abilities) lives further down in
-- ONY_BOSSES, defined once per key and looked up from here.
------------------------------------------------------------

-- Boss encounter order (Bosses tab tree, top to bottom).
local ONY_BOSS_ORDER = {
    "onyxia",
}

------------------------------------------------------------
-- Boss registry - one entry per boss (icon/flags/stats/abilities/adds),
-- referenced by key from ONY_BOSS_ORDER above. Defined once each; add a
-- new boss here and add its key to ONY_BOSS_ORDER to place it.
------------------------------------------------------------
local ONY_BOSSES = {
    onyxia = {
        name = "Onyxia",
        icon = "Interface\\Icons\\temp",
        flags = {"damage_fire"},
        stats = {armor = 5550, fire = "immune", nature = 92, frost = 92, shadow = 102, arcane = 88},
        abilities = {{
            separator = true,
            name = "Pre-pull & positioning"
        }, {
            name = "Preparation",
            icon = "Interface\\Icons\\INV_Potion_24",
            lines = {"Stack and buff OUTSIDE the instance - spells are more expensive inside.",
                     "Use Greater Fire Protection Potions. Tremor Totem, Fire Resistance Totem and Devotion Aura in the main tank's group.",
                     "Stack on one side if possible; otherwise keep at least a tank and healer on the other side. Mark a star to move to on the pull."}
        }, {
            name = "Tail Sweep",
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_05",
            warning = true,
            lines = {"Damages and knocks back enemies behind her. Never stand behind Onyxia."}
        }, {
            name = "Flame Breath",
            icon = "Interface\\Icons\\Spell_Fire_Fire",
            warning = true,
            roles = {"tank"},
            lines = {"Inflicts Fire damage in a cone in front of her plus a damage-over-time effect. Do not stand in front unless you are tanking."}
        }, {
            name = "Cleave",
            icon = "Interface\\Icons\\Ability_Warrior_Cleave",
            roles = {"tank", "melee"},
            lines = {"Strikes her target and its nearest allies, knocking them back."}
        }, {
            name = "Knock Away",
            icon = "Interface\\Icons\\INV_Gauntlets_05",
            roles = {"tank"},
            lines = {"Inflicts damage to nearby enemies and knocks them back, shedding threat."}
        }, {
            separator = true,
            name = "Phase 1 (100% - 66%)"
        }, {
            name = "Threatening Gaze",
            icon = "Interface\\Icons\\Ability_Hunter_AspectMastery",
            warning = true,
            lines = {"'Onyxia is watching you closely...' - the target must STOP ALL ACTIONS or they will pull her aggro.",
                     "Track this debuff. It appears in both phase 1 and phase 3."}
        }, {
            name = "Opening rotation",
            icon = "Interface\\Icons\\Ability_Warrior_BattleShout",
            lines = {"Slow DPS until everyone is positioned. Set up debuffs while moving - Expose Armor, curses and DoTs.",
                     "Save damage cooldowns for 66% when she begins to move, then use everything."}
        }, {
            separator = true,
            name = "Phase 2 (66% - 40%) - airborne"
        }, {
            name = "Deep Breath",
            icon = "Interface\\Icons\\Spell_Fire_Fire",
            warning = true,
            lines = {"The phase 2 wipe mechanic. Call out safe spots when she moves to a new position and never stand in the middle of the room."}
        }, {
            name = "Fireball",
            icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
            warning = true,
            roles = {"healer"},
            lines = {"An AoE conflagration - spread out so it cannot chain through the raid.",
                     "She telegraphs the target, who receives a mark roughly 3 seconds before impact, so it can be dodged or avoided with defensive abilities."}
        }, {
            name = "Whelps",
            icon = "Interface\\Icons\\Ability_Hunter_Pet_Dragonhawk",
            warning = true,
            roles = {"tank", "dps"},
            lines = {"Assign a dedicated whelp tank and kill every whelp that spawns.",
                     "Make sure healers do not pick up whelp aggro."}
        }, {
            name = "Eruption",
            icon = "Interface\\Icons\\Spell_Fire_Fire",
            warning = true,
            lines = {"Damage from the erupting floor as she takes flight and repositions."}
        }, {
            name = "Wing Buffet",
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_14",
            warning = true,
            roles = {"tank"},
            lines = {"Inflicts damage in a cone in front of her and knocks enemies back."}
        }, {
            separator = true,
            name = "Phase 3 (40% - 0%) - landed"
        }, {
            name = "Bellowing Roar",
            icon = "Interface\\Icons\\Spell_Fire_Fire",
            warning = true,
            roles = {"shaman", "tank"},
            lines = {"An AoE fear - a TREMOR TOTEM must be up.",
                     "Druid tanks can spec Enrage to avoid every fear, warriors can stance dance most of them, and paladins can spec Improved Morale."}
        }, {
            name = "Engulfing Flames",
            icon = "Interface\\Icons\\Spell_Fire_Incinerate",
            warning = true,
            roles = {"healer"},
            lines = {"Sets enemies aflame with a Fire damage-over-time effect and sends them into a panic.",
                     "By far her most frequent ability in logs (16000+ entries) - track this debuff."}
        }, {
            name = "Landing",
            icon = "Interface\\Icons\\Ability_Warrior_Charge",
            warning = true,
            roles = {"tank"},
            lines = {"Slow DPS as she lands and let the main tank reposition to the phase 1 tanking spot.",
                     "Be careful with damage-over-time aggro during the phase change."}
        }}
    },
}

------------------------------------------------------------
-- Builder: expands the order list + registry above into the flat table
-- shape the Bosses view expects (see AGENTS.md "Data model"). Nothing
-- below this point encodes raid content - only edit it if the addon's
-- expected data shape changes.
------------------------------------------------------------

local function BuildONYBosses()
    local bosses = {}
    for _, key in ipairs(ONY_BOSS_ORDER) do
        local boss = { key = key }
        for field, value in pairs(ONY_BOSSES[key]) do
            boss[field] = value
        end
        table.insert(bosses, boss)
    end
    return bosses
end

table.insert(DungeonJournal_Raids, {
    -- CHANGED: Onyxia. Phases are driven by separators; mechanics come from
    -- Spell.dbc plus the raid-lead tips document, with cast frequencies from
    -- combat logs. Trash is deliberately not documented yet.
    key = "ONY",
    name = "Onyxia's Lair",
    expanded = false,
    bosses = BuildONYBosses(),
})
