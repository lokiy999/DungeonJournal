-- DungeonJournal.lua
-- WoW 1.12.1 addon: an "Adventure Guide"-style window.
-- Left side  = collapsible tree (Raid -> Bosses)
-- Right side = boss header + tabbed accordion list of abilities and adds.

------------------------------------------------------------
-- Config
------------------------------------------------------------
-- CHANGED: the window and left panel are wider so boss names always fit in
-- the tree. LEFT_WIDTH is sized to hold the longest boss name up to a cap
-- of MAX_TREE_CHARS characters (roughly 6px each at GameFontHighlightSmall),
-- plus indentation, so the right panel never gets squeezed too hard.
local MAX_TREE_CHARS      = 25
local LEFT_WIDTH          = 18 + MAX_TREE_CHARS * 6   -- 18px indent + ~6px per char
local WINDOW_WIDTH        = LEFT_WIDTH + 60 + 340      -- left + gap + right content
local WINDOW_HEIGHT       = 504  -- CHANGED: +24 to make room for the top nav bar
local RIGHT_CONTENT_WIDTH = WINDOW_WIDTH - LEFT_WIDTH - 60
local TREE_ROW_HEIGHT     = 22
local ABILITY_ROW_TOP_H   = 26   -- height of the icon/name/icons line
local ABILITY_ICON_SIZE   = 20
local SEPARATOR_ROW_H     = 20   -- CHANGED: height of a phase separator bar
local STATS_ROW_H         = 18   -- CHANGED: height of the boss armor/resistance line

-- CHANGED: schools shown on a boss's optional stats line, in display order.
-- Holy is deliberately omitted - 1.12 has no meaningful Holy resistance.
-- Each entry is { data key, label, ARGB colour }.
local RESISTANCE_SCHOOLS = {
    {"fire",   "Fire",   "ffff4400"},
    {"nature", "Nature", "ff4dc94d"},
    {"frost",  "Frost",  "ff4dc9ff"},
    {"shadow", "Shadow", "ffa335ee"},
    {"arcane", "Arcane", "ffff80ff"},
}

-- CHANGED: top nav bar ("Bosses" / "Explaination") and the full-width panel
-- used by the Explaination view.
local NAV_BAR_HEIGHT            = 22
local Explaination_CONTENT_WIDTH = WINDOW_WIDTH - 58

local WARNING_ICON = "Interface\\GossipFrame\\AvailableQuestIcon" -- classic yellow "!" texture
local DEFAULT_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

-- CHANGED: The 1.12.1 client doesn't ship separate "ClassIcon_X" files (those
-- were added in later expansions). The real class icons live as one shared
-- atlas texture - the same one used on the character-creation screen - and
-- each class is just a cropped rectangle out of it via SetTexCoord. We define
-- our own coords table here (rather than relying on Blizzard's global
-- CLASS_ICON_TCOORDS, which isn't guaranteed to exist in 1.12 FrameXML) so
-- this works reliably regardless of client build.
local CLASS_ICON_TEXTURE = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes"
local CLASS_ICON_COORDS = {
    warrior = {0,    0.25, 0,    0.25},
    mage    = {0.25, 0.5,  0,    0.25},
    rogue   = {0.5,  0.75, 0,    0.25},
    druid   = {0.75, 1.0,  0,    0.25},
    hunter  = {0,    0.25, 0.25, 0.5},
    shaman  = {0.25, 0.5,  0.25, 0.5},
    priest  = {0.5,  0.75, 0.25, 0.5},
    warlock = {0.75, 1.0,  0.25, 0.5},
    paladin = {0,    0.25, 0.5,  0.75},
}

-- Combined Roles & Utility Cleansing icons
local UTILITY_ICONS = {
    -- Core Roles
    tank    = "Interface\\Icons\\INV_Shield_04",
    healer  = "Interface\\Icons\\Spell_Holy_Heal",
    dps     = "Interface\\Icons\\Ability_DualWield", -- THIS IS THE MELEE ICON
    caster = "Interface\\Icons\\Spell_Nature_StarFall", --! needs different icon
    melee = "Interface\\Icons\\Ability_BackStab", --! check icon, change if needed
    ranged = "Interface\\Icons\\Ability_TheBlackArrow", --! needs different icon
    
    -- Cleansing / Dispel Mechanics
    decurse = "Interface\\Icons\\Spell_Nature_RemoveCurse",
    dispel  = "Interface\\Icons\\Spell_Holy_DispelMagic",
    poison  = "Interface\\Icons\\Spell_Nature_NullifyPoison",
    disease = "Interface\\Icons\\Spell_Nature_NullifyDisease",
    kick = "Interface\\Icons\\Ability_Kick",
    -- CHANGED: reflect - abilities worth turning back on the caster (this
    -- server's bosses take heavy self-damage from reflected spells).
    reflect = "Interface\\Icons\\Spell_Frost_WindWalkOn",

    -- CHANGED: Per-class icons. All nine share the same CLASS_ICON_TEXTURE
    -- atlas; CLASS_ICON_COORDS (above) picks out the right square for each.
    -- Tag an ability with roles = { "warrior" } (etc.) to call out that a
    -- specific class should handle it.
    warrior = CLASS_ICON_TEXTURE,
    paladin = CLASS_ICON_TEXTURE,
    hunter  = CLASS_ICON_TEXTURE,
    rogue   = CLASS_ICON_TEXTURE,
    priest  = CLASS_ICON_TEXTURE,
    shaman  = CLASS_ICON_TEXTURE,
    mage    = CLASS_ICON_TEXTURE,
    warlock = CLASS_ICON_TEXTURE,
    druid   = CLASS_ICON_TEXTURE,
}

-- CHANGED: applies a UTILITY_ICONS entry to a texture widget. Handles the
-- class icons transparently by also applying the matching SetTexCoord crop
-- when the key is a class; every other icon just gets reset to the full
-- texture (0,1,0,1) so texture objects can be reused safely between rows.
local function ApplyUtilityIcon(texture, key)
    texture:SetTexture(UTILITY_ICONS[key] or DEFAULT_ICON)
    local coords = CLASS_ICON_COORDS[key]
    if coords then
        texture:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    else
        texture:SetTexCoord(0, 1, 0, 1)
    end
end

------------------------------------------------------------
-- CHANGED: Boss/trash "flag" icons - shown in a row to the right of the
-- boss or trash-pack portrait/name, for quick-glance notes like "this can/
-- can't be taunted" or "this pack is immune to Fire". Tag a boss OR a trash
-- pack in the RAIDS database with e.g. flags = { "nottauntable", "damage_fire" }
-- or flags = { "caster", "melee" } and the matching icons will appear
-- automatically - see RebuildBossFlags() below. Same table, same mechanism,
-- used by both the Bosses view and the Trash view.
--
-- To add a new flag type, just add another entry here (icon/name/desc, and
-- optionally positive/negative to color the border). Nothing else needs to
-- change. Double check the icon paths below render correctly in-game and
-- swap them for whichever texture you prefer.
------------------------------------------------------------
local BOSS_FLAGS = {
    tauntable = {
        icon = "Interface\\Icons\\spell_nature_reincarnation",
        name = "Tauntable",
        desc = "This boss can be taunted normally.",
    },
    nottauntable = {
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\notauntable",
        name = "Not Tauntable",
        desc = "This boss cannot be taunted!",
    },
    -- CHANGED: for bosses that are normally tauntable but become immune to taunt
    -- during certain mechanics - check the ability list for the details.
    notalwaystauntable = {
        icon = "Interface\\Icons\\spell_nature_reincarnation",
        name = "Not Always Tauntable",
        desc = "This boss cannot be taunted at all times - see the abilities for details.",
    },
    damage_fire = {
        icon = "Interface\\Icons\\INV_Potion_24",
        name = "Fire damage",
        desc = "This encounter deals Fire damage.",
    },
    damage_nature = {
        icon = "Interface\\Icons\\INV_Potion_22",
        name = "Nature damage",
        desc = "This encounter deals Nature damage.",
    },
    damage_frost = {
        icon = "Interface\\Icons\\INV_Potion_20",
        name = "Frost damage",
        desc = "This encounter deals Frost damage.",
    },
    damage_shadow = {
        icon = "Interface\\Icons\\INV_Potion_23",
        name = "Shadow damage",
        desc = "This encounter deals Shadow damage.",
    },
    damage_arcane = {
        icon = "Interface\\Icons\\INV_Potion_83",
        name = "Arcane damage",
        desc = "This encounter deals Arcane damage.",
    },

    -- CHANGED: trash mob "type" tags - reuse the same flag mechanism as the
    -- boss tauntable/damage flags above so trash packs get the same icon row.
    caster = {
        icon = "Interface\\Icons\\Spell_Nature_StarFall",
        name = "Caster",
        desc = "This mob casts spells - consider interrupting or CC'ing it.",
    },
    melee = {
        icon = "Interface\\Icons\\Ability_BackStab",
        name = "Melee",
        desc = "This mob attacks in melee range.",
    },
    ranged = {
        icon = "Interface\\Icons\\Ability_TheBlackArrow",
        name = "Ranged",
        desc = "This mob attacks from range with physical ranged attacks.",
    },
    -- CHANGED: NOT flags for immune_fire/nature/frost/shadow/arcane - a
    -- resistance-school immunity is already shown on the stats line (e.g.
    -- fire = "immune"), so a matching flag icon would just be a redundant
    -- second way of saying the same thing. Only immune_poly stays, since
    -- Polymorph immunity isn't a resistance school and has no other home.
    immune_poly = {
        icon = "Interface\\Icons\\Spell_Nature_Polymorph",
        name = "Immune: Polymorph",
        desc = "This mob cannot be Polymorphed.",
    },
    -- CHANGED: for mobs that flat-out ignore spells/abilities (e.g. Blackwing
    -- Spellbinder) - only melee damage lands on them.
    immune_spells = {
        icon = "Interface\\Icons\\Spell_Shadow_AntiShadow",
        name = "Immune: Spells",
        desc = "This mob is immune to all spells and abilities - only melee damage affects it.",
    },
}

------------------------------------------------------------
-- Icon Legend for the "Explaination" tab.
-- CHANGED: to explain a new icon, just add another entry below - icon,
-- name, and a short description. Nothing else in the file needs to change.
------------------------------------------------------------
local ICON_ExplainationS = {{
    icon = UTILITY_ICONS.tank,
    name = "Tank",
    desc = "Position yourself to hold the boss or add's attention and mitigate the incoming damage."
}, {
    icon = UTILITY_ICONS.healer,
    name = "Healer",
    desc = "Keep the raid topped up and be ready to react to burst damage during this mechanic."
}, {
    icon = UTILITY_ICONS.dps,
    name = "DPS",
    desc = "Focus your damage on the boss or the specific add(s) indicated."
}, {
    icon = UTILITY_ICONS.decurse,
    name = "Decurse",
    desc = "Remove a curse effect from the affected player."
}, {
    icon = UTILITY_ICONS.dispel,
    name = "Dispel Magic",
    desc = "Remove a harmful magic effect from the affected player."
}, {
    icon = UTILITY_ICONS.poison,
    name = "Cure Poison",
    desc = "Remove a poison effect from the affected player."
}, {
    icon = UTILITY_ICONS.disease,
    name = "Cure Disease",
    desc = "Remove a disease effect from the affected player."
}, {
    icon = UTILITY_ICONS.kick,
    name = "Kick / Interrupt",
    desc = "Interrupt a spell cast."
}, {
    icon = UTILITY_ICONS.reflect,
    name = "Reflect",
    desc = "This spell can be reflected back at the caster, often for very heavy damage."
}, {
    icon = WARNING_ICON,
    name = "Warning",
    desc = "A mechanic that can wipe the raid if it isn't handled correctly - pay close attention!"
}, {
    icon = UTILITY_ICONS.warrior,
    coords = CLASS_ICON_COORDS.warrior,
    name = "Warrior",
    desc = "This mechanic should be handled by a Warrior."
}, {
    icon = UTILITY_ICONS.paladin,
    coords = CLASS_ICON_COORDS.paladin,
    name = "Paladin",
    desc = "This mechanic should be handled by a Paladin."
}, {
    icon = UTILITY_ICONS.hunter,
    coords = CLASS_ICON_COORDS.hunter,
    name = "Hunter",
    desc = "This mechanic should be handled by a Hunter."
}, {
    icon = UTILITY_ICONS.rogue,
    coords = CLASS_ICON_COORDS.rogue,
    name = "Rogue",
    desc = "This mechanic should be handled by a Rogue."
}, {
    icon = UTILITY_ICONS.priest,
    coords = CLASS_ICON_COORDS.priest,
    name = "Priest",
    desc = "This mechanic should be handled by a Priest."
}, {
    icon = UTILITY_ICONS.shaman,
    coords = CLASS_ICON_COORDS.shaman,
    name = "Shaman",
    desc = "This mechanic should be handled by a Shaman."
}, {
    icon = UTILITY_ICONS.mage,
    coords = CLASS_ICON_COORDS.mage,
    name = "Mage",
    desc = "This mechanic should be handled by a Mage."
}, {
    icon = UTILITY_ICONS.warlock,
    coords = CLASS_ICON_COORDS.warlock,
    name = "Warlock",
    desc = "This mechanic should be handled by a Warlock."
}, {
    icon = UTILITY_ICONS.druid,
    coords = CLASS_ICON_COORDS.druid,
    name = "Druid",
    desc = "This mechanic should be handled by a Druid."
}, {
    icon = BOSS_FLAGS.tauntable.icon,
    name = BOSS_FLAGS.tauntable.name,
    desc = BOSS_FLAGS.tauntable.desc
}, {
    icon = BOSS_FLAGS.nottauntable.icon,
    name = BOSS_FLAGS.nottauntable.name,
    desc = BOSS_FLAGS.nottauntable.desc
}, {
    icon = BOSS_FLAGS.notalwaystauntable.icon,
    name = BOSS_FLAGS.notalwaystauntable.name,
    desc = BOSS_FLAGS.notalwaystauntable.desc
}, {
    icon = BOSS_FLAGS.damage_fire.icon,
    name = BOSS_FLAGS.damage_fire.name,
    desc = BOSS_FLAGS.damage_fire.desc
}, {
    icon = BOSS_FLAGS.damage_nature.icon,
    name = BOSS_FLAGS.damage_nature.name,
    desc = BOSS_FLAGS.damage_nature.desc
}, {
    icon = BOSS_FLAGS.damage_frost.icon,
    name = BOSS_FLAGS.damage_frost.name,
    desc = BOSS_FLAGS.damage_frost.desc
}, {
    icon = BOSS_FLAGS.damage_shadow.icon,
    name = BOSS_FLAGS.damage_shadow.name,
    desc = BOSS_FLAGS.damage_shadow.desc
}, {
    icon = BOSS_FLAGS.damage_arcane.icon,
    name = BOSS_FLAGS.damage_arcane.name,
    desc = BOSS_FLAGS.damage_arcane.desc
}, {
    icon = BOSS_FLAGS.caster.icon,
    name = BOSS_FLAGS.caster.name,
    desc = BOSS_FLAGS.caster.desc
}, {
    icon = BOSS_FLAGS.melee.icon,
    name = BOSS_FLAGS.melee.name,
    desc = BOSS_FLAGS.melee.desc
}, {
    icon = BOSS_FLAGS.ranged.icon,
    name = BOSS_FLAGS.ranged.name,
    desc = BOSS_FLAGS.ranged.desc
}, {
    icon = BOSS_FLAGS.immune_poly.icon,
    name = BOSS_FLAGS.immune_poly.name,
    desc = BOSS_FLAGS.immune_poly.desc
}, {
    icon = BOSS_FLAGS.immune_spells.icon,
    name = BOSS_FLAGS.immune_spells.name,
    desc = BOSS_FLAGS.immune_spells.desc
}}

------------------------------------------------------------
-- Database: raids -> bosses -> abilities & adds
-- CHANGED: Added 'icon' field to the bosses!
------------------------------------------------------------
-- CHANGED: RAIDS content now lives in per-raid files under raids/,
-- loaded via DungeonJournal.toc before this file. Each raid file appends
-- its table to DungeonJournal_Raids in load order (see AGENTS.md).
local RAIDS = DungeonJournal_Raids

-- Setup accordion initial states
for _, raid in ipairs(RAIDS) do
    for _, boss in ipairs(raid.bosses) do
        if not boss.abilities then boss.abilities = {} end
        for _, ability in ipairs(boss.abilities) do
            -- CHANGED: phase separators start expanded so all abilities are
            -- visible by default; normal ability rows start collapsed.
            if ability.separator then
                ability.expanded = true
            else
                ability.expanded = false
            end
        end
        if boss.adds then
            for _, add in ipairs(boss.adds) do
                add.expanded = false
                -- CHANGED: adds can now have their own nested abilities
                if add.abilities then
                    for _, subAbility in ipairs(add.abilities) do
                        subAbility.expanded = false
                    end
                end
            end
        end
    end
    if raid.trash then
        -- CHANGED: trash packs use the same ability-list separator
        -- convention as bosses (see AGENTS.md "Phase separators"), so they
        -- need the same accordion init - otherwise a trash pack's
        -- separator (e.g. Ancient Core Hound's "One of Five") never gets
        -- expanded = true and starts collapsed instead of open.
        for _, pack in ipairs(raid.trash) do
            if pack.abilities then
                for _, ability in ipairs(pack.abilities) do
                    if ability.separator then
                        ability.expanded = true
                    else
                        ability.expanded = false
                    end
                end
            end
        end
    end
end

------------------------------------------------------------
-- Main window
------------------------------------------------------------
local frame = CreateFrame("Frame", "DungeonJournalFrame", UIParent)
frame:SetWidth(WINDOW_WIDTH)
frame:SetHeight(WINDOW_HEIGHT)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function() this:StartMoving() end)
frame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
frame:SetFrameStrata("DIALOG")

frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", frame, "TOP", 0, -15)
title:SetText("Dungeon Journal")

local closeBtn = CreateFrame("Button", "DungeonJournalCloseButton", frame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -3, -3)

------------------------------------------------------------
-- Vertical separator line between left and right panels
------------------------------------------------------------
local vSeparator = frame:CreateTexture(nil, "ARTWORK")
vSeparator:SetTexture("Interface\\Buttons\\WHITE8X8")
vSeparator:SetVertexColor(0.5, 0.5, 0.5, 0.8)
vSeparator:SetWidth(1)
vSeparator:SetPoint("TOP", frame, "TOPLEFT", LEFT_WIDTH + 14, -64)
vSeparator:SetPoint("BOTTOM", frame, "BOTTOMLEFT", LEFT_WIDTH + 14, 15)

------------------------------------------------------------
-- Left side: scrollable, collapsible tree
------------------------------------------------------------
local scrollFrame = CreateFrame("ScrollFrame", "DungeonJournalScrollFrame", frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -64)
scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", LEFT_WIDTH + 4, 15)

local scrollChild = CreateFrame("Frame", "DungeonJournalScrollChild", scrollFrame)
scrollChild:SetHeight(1)
scrollFrame:SetScrollChild(scrollChild)
scrollChild:SetWidth(LEFT_WIDTH - 10)

------------------------------------------------------------
-- Right side: boss header
------------------------------------------------------------
local portrait = frame:CreateTexture(nil, "ARTWORK")
portrait:SetWidth(64)
portrait:SetHeight(64)
portrait:SetPoint("TOPLEFT", frame, "TOPLEFT", LEFT_WIDTH + 26, -70)
portrait:SetTexture(DEFAULT_ICON)

local bossNameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
bossNameText:SetPoint("LEFT", portrait, "RIGHT", 10, 0)
bossNameText:SetText("Select a boss")

-- CHANGED: the boss stats line (armor + resistances) is rendered above the
-- "Abilities" header so it sits between the portrait and the ability list.
-- It is only visible when the current boss has a `stats` table.
local bossStatsLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
bossStatsLabel:SetPoint("TOPLEFT", portrait, "BOTTOMLEFT", 0, -8)
bossStatsLabel:SetJustifyH("LEFT")
bossStatsLabel:Hide()

local abilitiesHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
abilitiesHeader:SetPoint("TOPLEFT", portrait, "BOTTOMLEFT", 0, -16)
abilitiesHeader:SetText("Abilities")

------------------------------------------------------------
-- CHANGED: Right side of the boss header - a row of "flag" icons (e.g.
-- Tauntable / Not Tauntable, Fire Protection Potion) driven by boss.flags.
-- Anchored the same way the ability role icons are (chained TOPRIGHT ->
-- TOPLEFT off the previous slot), just at the boss-header level instead of
-- per-ability-row.
------------------------------------------------------------

local bossFlagAnchor = CreateFrame("Frame", "DungeonJournalBossFlagAnchor", frame)
bossFlagAnchor:SetWidth(1)
bossFlagAnchor:SetHeight(1)
bossFlagAnchor:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -34, -74)

local bossFlagSlots = {}

local function CreateBossFlagSlot(index)
    local slot = CreateFrame("Button", "DungeonJournalBossFlag"..index, frame)
    slot:SetWidth(30)
    slot:SetHeight(30)

    local tex = slot:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints(slot) -- Fills the entire button without inset padding
    slot.texture = tex

    slot:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_TOP")
        GameTooltip:SetText(this.flagDef.name, 1, 1, 1)
        GameTooltip:AddLine(this.flagDef.desc, 0.9, 0.9, 0.9, true)
        GameTooltip:Show()
    end)
    slot:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return slot
end

-- CHANGED: rebuilds the boss flag icon row for the given boss (or clears it
-- if there's no boss / no flags). Call this any time the selected boss
-- changes, right alongside the portrait/name update.
function RebuildBossFlags(boss)
    local flags = (boss and boss.flags) or {}

    local anchorTo = bossFlagAnchor
    for i, flagKey in ipairs(flags) do
        local def = BOSS_FLAGS[flagKey]
        if def then
            local slot = bossFlagSlots[i]
            if not slot then
                slot = CreateBossFlagSlot(i)
                bossFlagSlots[i] = slot
            end

            slot.texture:SetTexture(def.icon or DEFAULT_ICON)
            slot.flagDef = def

            slot:ClearAllPoints()
            slot:SetPoint("TOPRIGHT", anchorTo, "TOPLEFT", -6, 0)
            slot:Show()
            anchorTo = slot
        end
    end

    for i = table.getn(flags) + 1, table.getn(bossFlagSlots) do
        bossFlagSlots[i]:Hide()
    end
end

------------------------------------------------------------
-- Right side: scrollable accordion list
------------------------------------------------------------
local abilityScrollFrame = CreateFrame("ScrollFrame", "DungeonJournalAbilityScrollFrame", frame, "UIPanelScrollFrameTemplate")
abilityScrollFrame:SetPoint("TOPLEFT", abilitiesHeader, "BOTTOMLEFT", 0, -8)
abilityScrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -34, 40)

local abilityScrollChild = CreateFrame("Frame", "DungeonJournalAbilityScrollChild", abilityScrollFrame)
abilityScrollChild:SetHeight(1)
abilityScrollFrame:SetScrollChild(abilityScrollChild)
abilityScrollChild:SetWidth(RIGHT_CONTENT_WIDTH)

------------------------------------------------------------
-- Scrollbar range helper
------------------------------------------------------------
-- CHANGED: UIPanelScrollFrameTemplate does NOT automatically recompute the
-- scrollbar's min/max range when the scroll child's height changes. Without
-- this, the scrollbar track/thumb never updates once content grows past the
-- visible area, so dragging it (or clicking the up/down buttons) does
-- nothing. This must be called any time a scroll child's height changes.
local function UpdateScrollBarRange(scrollFrame)
    local child = scrollFrame:GetScrollChild()
    if not child then return end

    local scrollbar = getglobal(scrollFrame:GetName() .. "ScrollBar")
    if not scrollbar then return end

    local maxScroll = child:GetHeight() - scrollFrame:GetHeight()
    if maxScroll < 0 then
        maxScroll = 0
    end

    local currentValue = scrollbar:GetValue()

    scrollbar:SetMinMaxValues(0, maxScroll)

    if currentValue > maxScroll then
        scrollbar:SetValue(maxScroll)
        scrollFrame:SetVerticalScroll(maxScroll)
    end

    if maxScroll <= 0 then
        scrollbar:Hide()
    else
        scrollbar:Show()
    end
end

-- CHANGED: let the mouse wheel scroll these lists too, using the same
-- scrollbar so range/clamping stays consistent.
local function EnableMouseWheelScroll(scrollFrame)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function()
        local scrollbar = getglobal(this:GetName() .. "ScrollBar")
        if not scrollbar then return end
        local _, maxScroll = scrollbar:GetMinMaxValues()
        local newValue = scrollbar:GetValue() - (arg1 * 30)
        if newValue < 0 then newValue = 0 end
        if newValue > maxScroll then newValue = maxScroll end
        scrollbar:SetValue(newValue)
    end)
end

EnableMouseWheelScroll(scrollFrame)
EnableMouseWheelScroll(abilityScrollFrame)

local currentBoss = nil
local currentTrashPack = nil
local activeTab = "abilities"
local abilityRowPool = {}

------------------------------------------------------------
-- CHANGED: Tactics hook - lets the separate, optional
-- DungeonJournalTactics addon register strategy content per boss without
-- this addon knowing anything about it. If that addon isn't installed,
-- DungeonJournal_TacticsData just stays empty and the button never shows.
------------------------------------------------------------
DungeonJournal_TacticsData = {}

function DungeonJournal_RegisterTactics(bossKey, data)
    DungeonJournal_TacticsData[bossKey] = data
end

-- CHANGED: forward-declared so SelectTab() below (defined before the tactics
-- UI further down the file) can call HideTactics() as an upvalue once it's
-- assigned later.
local tacticsScrollFrame, tacticsScrollChild
local tacticsShown = false
local ShowTactics, HideTactics

-- CHANGED: tactics lines can be a plain string (a paragraph of body text) or
-- a table shaped like the main ability list's phase separators
-- (`{ separator = true, name = "...", color = "..." }`, see AGENTS.md's Data
-- model) to break the tactics into labeled sections. These three helpers are
-- generic (parent frame passed in) so the boss panel and the trash panel
-- below can each render into their own scroll child with their own row pools.
local function CreateTacticsTextRow(parent, frameName)
    local fs = parent:CreateFontString(frameName, "OVERLAY", "GameFontHighlightSmall")
    fs:SetWidth(RIGHT_CONTENT_WIDTH)
    fs:SetJustifyH("LEFT")
    fs:SetJustifyV("TOP")
    return fs
end

local function CreateTacticsSepRow(parent, frameName)
    local btn = CreateFrame("Frame", frameName, parent)
    btn:SetHeight(SEPARATOR_ROW_H)
    btn:SetWidth(RIGHT_CONTENT_WIDTH)

    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(btn)
    bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    bg:SetVertexColor(0.15, 0.15, 0.3, 1)
    btn.bg = bg

    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", btn, "LEFT", 6, 0)
    label:SetJustifyH("LEFT")
    btn.label = label

    return btn
end

-- CHANGED: short resistance abbreviations for the (space-constrained) chat
-- broadcast - the panel's own stats line still spells out "Fire"/"Frost"/etc.
-- Defined up here (rather than by FormatBossStatsPlain further down) so
-- BuildRecommendedResistText/PrepareTacticsPreview below can use it too.
local RESIST_ABBR = {
    fire = "FR", frost = "FrR", nature = "NR", shadow = "SR", arcane = "AR",
}

-- Reads the optional `resistances` table a DungeonJournalTactics entry can
-- carry (e.g. `resistances = { fire = 315, nature = 200 }`, keyed the same
-- as RESISTANCE_SCHOOLS/stats) and formats it as abbreviated "FR: 315 NR:
-- 200 recommended". A value can also be `{ amount = 200, note = "buffed" }`
-- to append a short parenthesized note after that school's amount. Returns
-- nil (caller ignores this part) if the boss/pack has no tactics data or no
-- resistances field. Defined up here (rather than down by the rest of the
-- Broadcast line-builders) so ShowTactics/ShowTrashTactics below can also
-- use it, to preview the recommended resistances inside the Tactics panel.
local function BuildRecommendedResistText(entry)
    local data = entry.key and DungeonJournal_TacticsData[entry.key]
    if not data or not data.resistances then return nil end

    local parts = {}
    for _, school in ipairs(RESISTANCE_SCHOOLS) do
        local value = data.resistances[school[1]]
        if value then
            local amount, note = value, nil
            if type(value) == "table" then
                amount, note = value.amount, value.note
            end

            local text = RESIST_ABBR[school[1]] .. ": " .. amount
            if note then
                text = text .. " (" .. note .. ")"
            end
            table.insert(parts, text)
        end
    end

    if table.getn(parts) == 0 then return nil end
    return table.concat(parts, " ") .. " recommended"
end

-- Lays `lines` out top-to-bottom into `scrollChild` using `textPool`/`sepPool`
-- (each keyed by row index, created lazily), hides leftover pooled rows from
-- a previous (longer) render, and returns the total content height.
--
-- CHANGED: a separator can carry `broadcast = true` (see AGENTS.md's Data
-- model / DungeonJournalTactics's schema comment) to mark "everything under
-- this heading, until the next separator, is exactly what Broadcast sends."
-- That section renders in green here (tinted bar + tinted text) so a raid
-- lead can see precisely what will go out before clicking the button -
-- BuildCuratedBroadcastLines() (below) reads the same flag to collect it.
local function RenderTacticsLines(lines, scrollChild, textPool, sepPool, namePrefix)
    local yOffset = 0
    local textIndex = 0
    local sepIndex = 0
    local inBroadcastSection = false

    if lines then
        for _, line in ipairs(lines) do
            if type(line) == "table" and line.separator then
                sepIndex = sepIndex + 1
                local sep = sepPool[sepIndex]
                if not sep then
                    sep = CreateTacticsSepRow(scrollChild, namePrefix .. "Sep" .. sepIndex)
                    sepPool[sepIndex] = sep
                end

                sep:ClearAllPoints()
                sep:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -yOffset)
                sep:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, -yOffset)

                inBroadcastSection = line.broadcast and true or false

                if line.color then
                    sep.label:SetText("|c" .. line.color .. line.name .. "|r")
                elseif inBroadcastSection then
                    sep.label:SetText("|cff66ff88[Broadcast] " .. line.name .. "|r")
                else
                    sep.label:SetText(line.name)
                end
                if inBroadcastSection then
                    sep.bg:SetVertexColor(0.1, 0.3, 0.15, 1)
                else
                    sep.bg:SetVertexColor(0.15, 0.15, 0.3, 1)
                end
                sep:Show()

                yOffset = yOffset + sep:GetHeight() + 6
            else
                textIndex = textIndex + 1
                local fs = textPool[textIndex]
                if not fs then
                    fs = CreateTacticsTextRow(scrollChild, namePrefix .. "Text" .. textIndex)
                    textPool[textIndex] = fs
                end

                fs:ClearAllPoints()
                fs:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -yOffset)
                if inBroadcastSection then
                    fs:SetText("|cff88ff99" .. line .. "|r")
                else
                    fs:SetText(line)
                end
                fs:Show()

                yOffset = yOffset + fs:GetHeight() + 10
            end
        end
    end

    for i = sepIndex + 1, table.getn(sepPool) do
        sepPool[i]:Hide()
    end
    for i = textIndex + 1, table.getn(textPool) do
        textPool[i]:Hide()
    end

    return yOffset
end

-- CHANGED: prepares `lines` for display in the Tactics panel - pulls every
-- broadcast = true section (its separator plus every line under it, up to
-- the next separator) out of wherever it's written and moves the whole
-- chunk to the front, then injects the recommended-resistances text (if
-- any) right after that section's separator. So the green "what Broadcast
-- sends" preview always sits at the top of the panel regardless of where
-- the author placed bsep() in the data, and always shows resistances too.
-- BroadcastEntry() computes the same resistance text independently via
-- BuildHeaderLine() for the actual chat message - this just keeps the
-- preview honest about what will actually be sent (see
-- BuildCuratedBroadcastLines()'s doc comment further down for how the
-- broadcast section itself is collected for the real broadcast).
local function PrepareTacticsPreview(lines, entry)
    if not lines then return lines end

    local broadcastChunk = {}
    local rest = {}
    local inBroadcast = false

    for _, line in ipairs(lines) do
        if type(line) == "table" and line.separator then
            inBroadcast = line.broadcast and true or false
        end
        if inBroadcast then
            table.insert(broadcastChunk, line)
        else
            table.insert(rest, line)
        end
    end

    if table.getn(broadcastChunk) == 0 then return lines end

    local resistText = BuildRecommendedResistText(entry)
    if resistText then
        table.insert(broadcastChunk, 2, resistText)
    end

    local result = {}
    for _, line in ipairs(broadcastChunk) do
        table.insert(result, line)
    end
    for _, line in ipairs(rest) do
        table.insert(result, line)
    end
    return result
end

------------------------------------------------------------
-- Tabs creation
------------------------------------------------------------
local tabAbilities = CreateFrame("Button", "DungeonJournalTabAbilities", frame)
tabAbilities:SetWidth(85)
tabAbilities:SetHeight(22)
tabAbilities:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", LEFT_WIDTH + 26, 15)
tabAbilities:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
tabAbilities:SetBackdropColor(0, 0, 0, 0.8)
tabAbilities:SetBackdropBorderColor(1, 0.82, 0, 1)

local tabAbilitiesText = tabAbilities:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
tabAbilitiesText:SetPoint("CENTER", tabAbilities, "CENTER", 0, 0)
tabAbilitiesText:SetText("Abilities")

local tabAdds = CreateFrame("Button", "DungeonJournalTabAdds", frame)
tabAdds:SetWidth(85)
tabAdds:SetHeight(22)
tabAdds:SetPoint("LEFT", tabAbilities, "RIGHT", 5, 0)
tabAdds:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
tabAdds:SetBackdropColor(0, 0, 0, 0.5)
tabAdds:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.5)

local tabAddsText = tabAdds:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
tabAddsText:SetPoint("CENTER", tabAdds, "CENTER", 0, 0)
tabAddsText:SetText("Adds")

local function SelectTab(tabName)
    HideTactics()
    activeTab = tabName
    if tabName == "abilities" then
        tabAbilities:SetBackdropBorderColor(1, 0.82, 0, 1)
        tabAbilities:SetBackdropColor(0, 0, 0, 0.8)
        tabAbilitiesText:SetTextColor(1, 0.82, 0)
        
        tabAdds:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.5)
        tabAdds:SetBackdropColor(0, 0, 0, 0.5)
        tabAddsText:SetTextColor(0.8, 0.8, 0.8)
        
        abilitiesHeader:SetText("Abilities")
    else
        tabAdds:SetBackdropBorderColor(1, 0.82, 0, 1)
        tabAdds:SetBackdropColor(0, 0, 0, 0.8)
        tabAddsText:SetTextColor(1, 0.82, 0)
        
        tabAbilities:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.5)
        tabAbilities:SetBackdropColor(0, 0, 0, 0.5)
        tabAbilitiesText:SetTextColor(0.8, 0.8, 0.8)
        
        abilitiesHeader:SetText("Adds")
    end
    RebuildAbilityList(currentBoss)
end

tabAbilities:SetScript("OnClick", function() SelectTab("abilities") end)
tabAdds:SetScript("OnClick", function() SelectTab("adds") end)

tabAbilities:Hide()
tabAdds:Hide()

------------------------------------------------------------
-- CHANGED: Tactics button - bottom row, right of the Adds tab. Only shown
-- when the (optional, separate) DungeonJournalTactics addon has registered
-- data for the current boss via DungeonJournal_RegisterTactics().
------------------------------------------------------------
local tacticsButton = CreateFrame("Button", "DungeonJournalTacticsButton", frame)
tacticsButton:SetWidth(85)
tacticsButton:SetHeight(22)
tacticsButton:SetPoint("LEFT", tabAdds, "RIGHT", 20, 0)
tacticsButton:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
tacticsButton:SetBackdropColor(0, 0, 0, 0.8)
tacticsButton:SetBackdropBorderColor(0.2, 0.8, 1, 1)

local tacticsButtonText = tacticsButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
tacticsButtonText:SetPoint("CENTER", tacticsButton, "CENTER", 0, 0)
tacticsButtonText:SetTextColor(0.4, 0.9, 1)
tacticsButtonText:SetText("Tactics")

-- CHANGED: tactics content renders inline in the same right-panel slot the
-- ability list uses (anchored the same way as abilityScrollFrame below, so
-- it lines up exactly), instead of a separate popup window.
tacticsScrollFrame = CreateFrame("ScrollFrame", "DungeonJournalTacticsScrollFrame", frame, "UIPanelScrollFrameTemplate")
tacticsScrollFrame:SetPoint("TOPLEFT", abilitiesHeader, "BOTTOMLEFT", 0, -8)
tacticsScrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -34, 40)

tacticsScrollChild = CreateFrame("Frame", "DungeonJournalTacticsScrollChild", tacticsScrollFrame)
tacticsScrollChild:SetHeight(1)
tacticsScrollFrame:SetScrollChild(tacticsScrollChild)
tacticsScrollChild:SetWidth(RIGHT_CONTENT_WIDTH)

EnableMouseWheelScroll(tacticsScrollFrame)
tacticsScrollFrame:Hide()

local tacticsTextRowPool = {}
local tacticsSepRowPool = {}

ShowTactics = function()
    if not currentBoss then return end
    local data = DungeonJournal_TacticsData[currentBoss.key]
    if not data then return end

    tacticsShown = true
    abilitiesHeader:SetText(data.title or "Tactics")

    local previewLines = PrepareTacticsPreview(data.lines, currentBoss)
    local height = RenderTacticsLines(previewLines, tacticsScrollChild, tacticsTextRowPool, tacticsSepRowPool, "DungeonJournalTactics")
    tacticsScrollChild:SetHeight(height)
    UpdateScrollBarRange(tacticsScrollFrame)

    abilityScrollFrame:Hide()
    tacticsScrollFrame:Show()
end

-- CHANGED: also called by SelectTab() above (as a forward-declared upvalue)
-- to leave the tactics view whenever the Abilities/Adds tabs are clicked.
HideTactics = function()
    tacticsShown = false
    tacticsScrollFrame:Hide()
    abilityScrollFrame:Show()
end

tacticsButton:SetScript("OnClick", function()
    if tacticsShown then
        HideTactics()
        SelectTab(activeTab)
    else
        ShowTactics()
    end
end)

tacticsButton:Hide()

------------------------------------------------------------
-- CHANGED: Top nav bar - "Bosses" / "Explaination"
------------------------------------------------------------
local currentView = "bosses"

local navBosses = CreateFrame("Button", "DungeonJournalNavBosses", frame)
navBosses:SetWidth(130)
navBosses:SetHeight(NAV_BAR_HEIGHT)
navBosses:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, -34)
navBosses:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})

local navBossesText = navBosses:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
navBossesText:SetPoint("CENTER", navBosses, "CENTER", 0, 0)
navBossesText:SetText("Bosses")

-- CHANGED: "Trash" nav tab - own tree + own right panel, kept fully separate
-- from the boss browsing view so trash lists (CC priorities, patrol paths,
-- pull order notes) can grow long without crowding the boss UI.
local navTrash = CreateFrame("Button", "DungeonJournalNavTrash", frame)
navTrash:SetWidth(130)
navTrash:SetHeight(NAV_BAR_HEIGHT)
navTrash:SetPoint("LEFT", navBosses, "RIGHT", 6, 0)
navTrash:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})

local navTrashText = navTrash:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
navTrashText:SetPoint("CENTER", navTrash, "CENTER", 0, 0)
navTrashText:SetText("Trash")

local navExplaination = CreateFrame("Button", "DungeonJournalNavExplaination", frame)
navExplaination:SetWidth(130)
navExplaination:SetHeight(NAV_BAR_HEIGHT)
navExplaination:SetPoint("LEFT", navTrash, "RIGHT", 6, 0)
navExplaination:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})

local navExplainationText = navExplaination:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
navExplainationText:SetPoint("CENTER", navExplaination, "CENTER", 0, 0)
navExplainationText:SetText("Icon Guide")

------------------------------------------------------------
-- CHANGED: Explaination panel - full-width icon legend
-- (tank / healer / dispel / etc, driven by the ICON_ExplainationS table)
------------------------------------------------------------
local ExplainationHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ExplainationHeader:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, -64)
ExplainationHeader:SetText("Icon Guide")
ExplainationHeader:Hide()

local ExplainationScrollFrame = CreateFrame("ScrollFrame", "DungeonJournalExplainationScrollFrame", frame, "UIPanelScrollFrameTemplate")
ExplainationScrollFrame:SetPoint("TOPLEFT", ExplainationHeader, "BOTTOMLEFT", 0, -8)
ExplainationScrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -34, 15)
ExplainationScrollFrame:Hide()

local ExplainationScrollChild = CreateFrame("Frame", "DungeonJournalExplainationScrollChild", ExplainationScrollFrame)
ExplainationScrollChild:SetHeight(1)
ExplainationScrollFrame:SetScrollChild(ExplainationScrollChild)
ExplainationScrollChild:SetWidth(Explaination_CONTENT_WIDTH)

EnableMouseWheelScroll(ExplainationScrollFrame)

local ExplainationRowPool = {}

local function CreateExplainationRow(parent, index)
    local btn = CreateFrame("Frame", "DungeonJournalExplainationRow"..index, parent)

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(28)
    icon:SetHeight(28)
    icon:SetPoint("TOPLEFT", btn, "TOPLEFT", 4, -2)
    btn.icon = icon

    local nameLabel = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameLabel:SetPoint("TOPLEFT", icon, "TOPRIGHT", 8, -2)
    nameLabel:SetJustifyH("LEFT")
    btn.nameLabel = nameLabel

    local descLabel = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    descLabel:SetPoint("TOPLEFT", icon, "TOPRIGHT", 8, -18)
    descLabel:SetJustifyH("LEFT")
    descLabel:SetJustifyV("TOP")
    btn.descLabel = descLabel

    return btn
end

local function ConfigureExplainationRow(btn, entry, width)
    btn.icon:SetTexture(entry.icon or DEFAULT_ICON)
    if entry.coords then
        btn.icon:SetTexCoord(entry.coords[1], entry.coords[2], entry.coords[3], entry.coords[4])
    else
        btn.icon:SetTexCoord(0, 1, 0, 1)
    end
    btn.nameLabel:SetText(entry.name)

    local descWidth = width - 28 - 8
    btn.descLabel:SetWidth(descWidth)
    btn:SetHeight(1000) -- CHANGED: let the text wrap before measuring its height
    btn.descLabel:SetText(entry.desc)

    local descHeight = btn.descLabel:GetHeight()
    if descHeight == 0 then descHeight = 12 end

    local totalHeight = 18 + descHeight + 10
    if totalHeight < 36 then totalHeight = 36 end
    btn:SetHeight(totalHeight)
end

function RebuildExplainationList()
    local yOffset = 0
    for i, entry in ipairs(ICON_ExplainationS) do
        local btn = ExplainationRowPool[i]
        if not btn then
            btn = CreateExplainationRow(ExplainationScrollChild, i)
            ExplainationRowPool[i] = btn
        end

        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", ExplainationScrollChild, "TOPLEFT", 0, -yOffset)
        btn:SetPoint("TOPRIGHT", ExplainationScrollChild, "TOPRIGHT", 0, -yOffset)

        ConfigureExplainationRow(btn, entry, Explaination_CONTENT_WIDTH)
        btn:Show()

        yOffset = yOffset + btn:GetHeight() + 6
    end

    for i = table.getn(ICON_ExplainationS) + 1, table.getn(ExplainationRowPool) do
        ExplainationRowPool[i]:Hide()
    end

    ExplainationScrollChild:SetHeight(yOffset)
    UpdateScrollBarRange(ExplainationScrollFrame)
end

------------------------------------------------------------
-- CHANGED: Trash view - its own left tree (raid -> trash pack). The tree
-- lives here; the right-hand detail panel is built further down (after
-- CreateAbilityRow/ConfigureAbilityRow/RebuildBossFlags exist) since it
-- reuses that same boss-panel rendering wholesale - see ShowTrashPack() and
-- RebuildTrashAbilityList() below the boss panel code. ShowTrashPack is only
-- ever *called* from a click, by which point the whole file has loaded, so
-- it's fine to reference it here before it's defined.
------------------------------------------------------------
local trashTreeScrollFrame = CreateFrame("ScrollFrame", "DungeonJournalTrashTreeScrollFrame", frame, "UIPanelScrollFrameTemplate")
trashTreeScrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -64)
trashTreeScrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", LEFT_WIDTH + 4, 15)
trashTreeScrollFrame:Hide()

local trashTreeScrollChild = CreateFrame("Frame", "DungeonJournalTrashTreeScrollChild", trashTreeScrollFrame)
trashTreeScrollChild:SetHeight(1)
trashTreeScrollFrame:SetScrollChild(trashTreeScrollChild)
trashTreeScrollChild:SetWidth(LEFT_WIDTH - 10)

EnableMouseWheelScroll(trashTreeScrollFrame)

local trashVSeparator = frame:CreateTexture(nil, "ARTWORK")
trashVSeparator:SetTexture("Interface\\Buttons\\WHITE8X8")
trashVSeparator:SetVertexColor(0.5, 0.5, 0.5, 0.8)
trashVSeparator:SetWidth(1)
trashVSeparator:SetPoint("TOP", frame, "TOPLEFT", LEFT_WIDTH + 14, -64)
trashVSeparator:SetPoint("BOTTOM", frame, "BOTTOMLEFT", LEFT_WIDTH + 14, 15)
trashVSeparator:Hide()

local trashTreeButtonPool = {}

local function BuildTrashEntries()
    local entries = {}
    for _, raid in ipairs(RAIDS) do
        table.insert(entries, { entryType = "header", raid = raid })
        if raid.trashExpanded and raid.trash then
            -- CHANGED: a separator entry in a raid's trash list (e.g. "Death
            -- Talon Hall" before a run of packs that always spawn together)
            -- is rendered as a clickable, collapsible grouping label -
            -- clicking it hides/shows every pack listed after it, up to the
            -- next separator, the same way ability-list phase separators
            -- collapse abilities in RebuildAbilityList(). Separators default
            -- to collapsed so trash packs start hidden until opened.
            local groupVisible = false
            local inGroup = false
            for _, pack in ipairs(raid.trash) do
                if pack.separator then
                    table.insert(entries, { entryType = "separator", pack = pack })
                    groupVisible = (pack.expanded == true)
                    inGroup = true
                elseif inGroup and not pack.grouped then
                    inGroup = false
                    table.insert(entries, { entryType = "pack", raid = raid, pack = pack, grouped = false })
                elseif inGroup then
                    if groupVisible then
                        table.insert(entries, { entryType = "pack", raid = raid, pack = pack, grouped = true })
                    end
                else
                    table.insert(entries, { entryType = "pack", raid = raid, pack = pack, grouped = false })
                end
            end
        end
    end
    return entries
end

local function CreateTrashTreeRow(index)
    local btn = CreateFrame("Button", "DungeonJournalTrashTreeRow"..index, trashTreeScrollChild)
    btn:SetWidth(LEFT_WIDTH - 10)
    btn:SetHeight(TREE_ROW_HEIGHT)
    btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("LEFT", btn, "LEFT", 4, 0)
    label:SetJustifyH("LEFT")
    btn.label = label

    btn:SetScript("OnClick", function()
        local entry = this.entry
        if entry.entryType == "header" then
            entry.raid.trashExpanded = not entry.raid.trashExpanded
            RebuildTrashTree()
        elseif entry.entryType == "separator" then
            -- CHANGED: click to collapse/expand the group of packs listed
            -- under this separator (default nil/collapsed - see
            -- BuildTrashEntries() - so "not expanded" flips nil straight to
            -- true on the first click).
            entry.pack.expanded = not entry.pack.expanded
            RebuildTrashTree()
        else
            ShowTrashPack(entry.pack)
        end
    end)

    return btn
end

function RebuildTrashTree()
    local entries = BuildTrashEntries()

    for i, entry in ipairs(entries) do
        local btn = trashTreeButtonPool[i]
        if not btn then
            btn = CreateTrashTreeRow(i)
            trashTreeButtonPool[i] = btn
        end

        btn.entry = entry
        if entry.entryType == "header" then
            local prefix = entry.raid.trashExpanded and "- " or "+ "
            btn.label:SetText(prefix .. entry.raid.name)
            btn.label:SetPoint("LEFT", btn, "LEFT", 4, 0)
            btn.label:SetFontObject(GameFontNormalSmall)
        elseif entry.entryType == "separator" then
            -- CHANGED: clickable grouping label with a +/- expand indicator,
            -- e.g. "+ Death Talon Hall". Starts collapsed, hiding every pack
            -- listed under it until clicked open (see BuildTrashEntries()).
            local isExpanded = (entry.pack.expanded == true)
            local prefix = isExpanded and "- " or "+ "
            -- CHANGED: no fallback gold here - GameFontNormalSmall is
            -- already gold by default, so a hardcoded gold color code was
            -- just duplicating it. Per-raid separator colors are set
            -- explicitly on the data (see BWL_TRASH_ORDER/MC_TRASH_ORDER);
            -- if a raid doesn't set one, its separators just use the font's
            -- default gold.
            if entry.pack.color then
                btn.label:SetText(prefix .. "|c" .. entry.pack.color .. entry.pack.name .. "|r")
            else
                btn.label:SetText(prefix .. entry.pack.name)
            end
            btn.label:SetPoint("LEFT", btn, "LEFT", 18, 0)
            btn.label:SetFontObject(GameFontNormalSmall)
        else
            local text = entry.pack.name
            if entry.pack.count then
                text = text .. " (" .. entry.pack.count .. ")"
            end
            btn.label:SetText(text)
            local indent = entry.grouped and 32 or 18
            btn.label:SetPoint("LEFT", btn, "LEFT", indent, 0)
            btn.label:SetFontObject(GameFontHighlightSmall)
        end

        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", trashTreeScrollChild, "TOPLEFT", 0, -(i - 1) * TREE_ROW_HEIGHT)
        btn:Show()
    end

    for i = table.getn(entries) + 1, table.getn(trashTreeButtonPool) do
        trashTreeButtonPool[i]:Hide()
    end

    trashTreeScrollChild:SetHeight(table.getn(entries) * TREE_ROW_HEIGHT)
    UpdateScrollBarRange(trashTreeScrollFrame)
end

RebuildTrashTree()

------------------------------------------------------------
-- CHANGED: SelectView() toggles between the "Bosses" view (tree + boss
-- detail, the window's original content), the new "Trash" view, and the
-- "Explaination" view.
------------------------------------------------------------
local function SelectView(view)
    currentView = view

    -- CHANGED: reset all three nav buttons, then re-highlight the active one
    -- below - avoids repeating the "un-highlight the other two" dance per branch.
    local navButtons = {
        {btn = navBosses, text = navBossesText},
        {btn = navTrash, text = navTrashText},
        {btn = navExplaination, text = navExplainationText},
    }
    for _, nb in ipairs(navButtons) do
        nb.btn:SetBackdropColor(0, 0, 0, 0.5)
        nb.btn:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.5)
        nb.text:SetTextColor(0.8, 0.8, 0.8)
    end

    -- Hide everything view-specific; the branch below re-shows what's needed.
    scrollFrame:Hide()
    vSeparator:Hide()
    portrait:Hide()
    bossNameText:Hide()
    abilitiesHeader:Hide()
    abilityScrollFrame:Hide()
    tabAbilities:Hide()
    tabAdds:Hide()
    tacticsButton:Hide()
    tacticsScrollFrame:Hide()
    tacticsShown = false
    broadcastButton:Hide()
    RebuildBossFlags(nil)
    bossStatsLabel:Hide()

    trashTreeScrollFrame:Hide()
    trashVSeparator:Hide()
    trashPortrait:Hide()
    trashNameText:Hide()
    trashStatsLabel:Hide()
    trashAbilitiesHeader:Hide()
    trashAbilityScrollFrame:Hide()
    trashTabAbilities:Hide()
    trashTacticsButton:Hide()
    trashTacticsScrollFrame:Hide()
    trashBroadcastButton:Hide()
    RebuildTrashFlags(nil)

    ExplainationHeader:Hide()
    ExplainationScrollFrame:Hide()

    if view == "bosses" then
        navBosses:SetBackdropColor(0, 0, 0, 0.8)
        navBosses:SetBackdropBorderColor(1, 0.82, 0, 1)
        navBossesText:SetTextColor(1, 0.82, 0)

        scrollFrame:Show()
        vSeparator:Show()
        portrait:Show()
        bossNameText:Show()
        abilitiesHeader:Show()
        abilityScrollFrame:Show()
        RebuildBossFlags(currentBoss) -- CHANGED: re-show the flag icon row for the current boss
        if currentBoss then
            tabAbilities:Show()
            broadcastButton:Show()
            if currentBoss.adds and table.getn(currentBoss.adds) > 0 then
                tabAdds:Show()
            end
        end
        if currentBoss and currentBoss.key and DungeonJournal_TacticsData[currentBoss.key] then
            tacticsButton:Show()
        end
    elseif view == "trash" then
        navTrash:SetBackdropColor(0, 0, 0, 0.8)
        navTrash:SetBackdropBorderColor(1, 0.82, 0, 1)
        navTrashText:SetTextColor(1, 0.82, 0)

        trashTreeScrollFrame:Show()
        trashVSeparator:Show()
        trashPortrait:Show()
        trashNameText:Show()
        trashAbilitiesHeader:Show()
        trashAbilityScrollFrame:Show()
        if currentTrashPack then
            ShowTrashPack(currentTrashPack) -- CHANGED: refresh icon/name/flags/stats/abilities for the current pack
        else
            RebuildTrashFlags(nil)
        end
    else
        navExplaination:SetBackdropColor(0, 0, 0, 0.8)
        navExplaination:SetBackdropBorderColor(1, 0.82, 0, 1)
        navExplainationText:SetTextColor(1, 0.82, 0)

        ExplainationHeader:Show()
        ExplainationScrollFrame:Show()
        RebuildExplainationList()
    end
end

navBosses:SetScript("OnClick", function() SelectView("bosses") end)
navTrash:SetScript("OnClick", function() SelectView("trash") end)
navExplaination:SetScript("OnClick", function() SelectView("Explaination") end)

-- CHANGED: NOT called here - SelectView() also touches the trash panel
-- globals (trashPortrait, RebuildTrashFlags, etc.), which aren't created
-- until further down the file (after ShowBossInfo). The initial call is
-- deferred to the very end of the file, once everything exists.

------------------------------------------------------------
-- List Item Creation and configuration
------------------------------------------------------------
-- CHANGED: phase separator bars. An entry in a boss's `abilities` list that
-- carries `separator = true` is rendered as a full-width labelled bar instead
-- of an ability row. Every ability listed after it belongs to that phase,
-- until the next separator - so the grouping is driven purely by where the
-- separator sits in the data. Clicking the bar collapses/expands that phase.
-- Separators are only handled at the top level of the list (not inside an
-- add's nested `abilities`).
local separatorRowPool = {}

local function CreateSeparatorRow(parent, index)
    local btn = CreateFrame("Button", "DungeonJournalPhaseRow" .. index, parent)
    btn:SetHeight(SEPARATOR_ROW_H)

    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(btn)
    bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    bg:SetVertexColor(0.15, 0.15, 0.3, 1)
    btn.bg = bg

    btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

    local expandLabel = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    expandLabel:SetPoint("LEFT", btn, "LEFT", 6, 0)
    expandLabel:SetWidth(12)
    expandLabel:SetJustifyH("LEFT")
    btn.expandLabel = expandLabel

    local nameLabel = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameLabel:SetPoint("LEFT", expandLabel, "RIGHT", 2, 0)
    nameLabel:SetJustifyH("LEFT")
    btn.nameLabel = nameLabel

    btn:SetScript("OnClick", function()
        this.separatorData.expanded = not this.separatorData.expanded
        -- CHANGED: shared between the boss and trash panels - see the same
        -- fix in CreateAbilityRow's OnClick above.
        if currentView == "trash" then
            RebuildTrashAbilityList(currentTrashPack)
        else
            RebuildAbilityList(currentBoss)
        end
    end)

    return btn
end

local function ConfigureSeparatorRow(btn, entry)
    btn.separatorData = entry
    btn.expandLabel:SetText(entry.expanded and "-" or "+")

    if entry.color then
        btn.nameLabel:SetText("|c" .. entry.color .. entry.name .. "|r")
    else
        btn.nameLabel:SetText(entry.name)
    end
end

-- NOTE: the stats line is now rendered via bossStatsLabel (a persistent
-- FontString above the abilities header) rather than a pooled frame inside
-- the scroll child. See ShowBossInfo() for the show/hide logic.

local function FormatBossStats(stats)
    local text = "|cffffd100Armor|r " .. (stats.armor or 0)
    for _, school in ipairs(RESISTANCE_SCHOOLS) do
        local val = stats[school[1]]
        if val == nil then val = 0 end
        local valText
        if val == "immune" then
            valText = "|cffff0000Immune|r"
        else
            valText = "|c" .. school[3] .. val .. "|r"
        end
        text = text .. "   |c" .. school[3] .. school[2] .. "|r " .. valText
    end
    return text
end

------------------------------------------------------------
-- CHANGED: Broadcast - formats a boss or trash pack (same shape, see
-- AGENTS.md's Data model) into plain-text chat lines and sends them to
-- raid/party chat. Works for either a boss or a trash pack since both share
-- name/flags/stats/abilities/key.
------------------------------------------------------------
local ROLE_LABELS = {
    tank = "Tank", healer = "Healer", dps = "DPS",
    caster = "Caster", melee = "Melee", ranged = "Ranged",
    decurse = "Decurse", dispel = "Dispel", poison = "Cure Poison", disease = "Cure Disease",
    kick = "Interrupt", reflect = "Reflect",
    warrior = "Warrior", paladin = "Paladin", hunter = "Hunter", rogue = "Rogue",
    priest = "Priest", shaman = "Shaman", mage = "Mage", warlock = "Warlock", druid = "Druid",
}

-- Chat messages can't render |c/|r color codes, so strip them rather than
-- send the literal escape sequences.
local function StripColorCodes(text)
    text = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
    text = string.gsub(text, "|r", "")
    return text
end

local function FormatBossStatsPlain(stats)
    local text = "Armor: " .. (stats.armor or 0)
    for _, school in ipairs(RESISTANCE_SCHOOLS) do
        local val = stats[school[1]]
        if val == nil then val = 0 end
        if val == "immune" then val = "Immune" end
        text = text .. "  " .. RESIST_ABBR[school[1]] .. ": " .. val
    end
    return text
end

-- "Name - Armor: X FR: X ... - Tauntable/Not Tauntable - FR: X NR: X recommended"
-- (the last part only appears if the Tactics addon registered a
-- `resistances` table for this boss/pack - see BuildRecommendedResistText).
local function BuildHeaderLine(entry)
    local parts = { entry.name }

    if entry.stats then
        table.insert(parts, FormatBossStatsPlain(entry.stats))
    end

    local flagSet = {}
    if entry.flags then
        for _, f in ipairs(entry.flags) do
            flagSet[f] = true
        end
    end

    if flagSet.nottauntable then
        table.insert(parts, "Not Tauntable")
    else
        table.insert(parts, "Tauntable")
    end

    local recommended = BuildRecommendedResistText(entry)
    if recommended then
        table.insert(parts, recommended)
    end

    return table.concat(parts, " - ")
end

-- Only top-level abilities flagged warning = true - the ones important
-- enough to call out proactively, same as the yellow "!" icon in the panel.
local function BuildAbilityLines(abilities)
    local lines = {}
    if not abilities then return lines end

    for _, ability in ipairs(abilities) do
        if not ability.separator and ability.warning then
            local text = ability.name
            if ability.lines and table.getn(ability.lines) > 0 then
                text = text .. ": " .. table.concat(ability.lines, " ")
            end
            if ability.roles and table.getn(ability.roles) > 0 then
                local roleLabels = {}
                for _, role in ipairs(ability.roles) do
                    table.insert(roleLabels, ROLE_LABELS[role] or role)
                end
                text = text .. " - " .. table.concat(roleLabels, "/")
            end
            table.insert(lines, StripColorCodes(text))
        end
    end

    return lines
end

-- "Separator tag: info", one per line, using whichever separator most
-- recently preceded that line (see AGENTS.md's Data model for the same
-- separator shape used by ability phase bars).
local function BuildTacticsLines(entry)
    local lines = {}
    local data = entry.key and DungeonJournal_TacticsData[entry.key]
    if not data or not data.lines then return lines end

    local currentTag = data.title or entry.name
    for _, line in ipairs(data.lines) do
        if type(line) == "table" and line.separator then
            currentTag = line.name
        else
            table.insert(lines, currentTag .. ": " .. line)
        end
    end

    return lines
end

-- CHANGED: a tactics separator can be marked `broadcast = true` (see the
-- schema comment in DungeonJournalTactics.lua) to hand-pick exactly which
-- plain-text lines under it - up to the next separator - get sent by
-- Broadcast, instead of it auto-summarizing every warning ability and every
-- tactics line. Lets a raid lead keep the Tactics panel itself as the full
-- voice-explained writeup while curating only the wipe-mechanic essentials
-- for chat. Multiple broadcast sections in the same entry are all collected.
local function BuildCuratedBroadcastLines(entry)
    local lines = {}
    local data = entry.key and DungeonJournal_TacticsData[entry.key]
    if not data or not data.lines then return lines end

    local collecting = false
    for _, line in ipairs(data.lines) do
        if type(line) == "table" and line.separator then
            collecting = line.broadcast and true or false
        elseif collecting then
            table.insert(lines, line)
        end
    end

    return lines
end

local function BuildBroadcastLines(entry)
    local lines = {}

    table.insert(lines, BuildHeaderLine(entry))

    local curated = BuildCuratedBroadcastLines(entry)
    if table.getn(curated) > 0 then
        -- Curated section present - use it verbatim instead of the
        -- auto-generated ability/tactics summary below.
        for _, line in ipairs(curated) do
            table.insert(lines, line)
        end
    else
        for _, line in ipairs(BuildAbilityLines(entry.abilities)) do
            table.insert(lines, line)
        end

        for _, line in ipairs(BuildTacticsLines(entry)) do
            table.insert(lines, line)
        end
    end

    return lines
end

-- Sends to raid chat if in a raid, party chat if in a party, otherwise just
-- prints locally (so Broadcast is still usable solo, e.g. while testing).
local function BroadcastEntry(entry)
    if not entry then return end

    local channel = nil
    if GetNumRaidMembers() > 0 then
        channel = "RAID"
    elseif GetNumPartyMembers() > 0 then
        channel = "PARTY"
    end

    local lines = BuildBroadcastLines(entry)

    if channel then
        -- CHANGED: cap at 4 lines to raid/party - each Broadcast is one
        -- chat message per line, and dumping a long ability/tactics list
        -- into raid chat spams the channel. Anything past 4 is dropped
        -- rather than sent, no overflow/continuation handling for now.
        local sent = 0
        for _, line in ipairs(lines) do
            if sent >= 4 then break end
            SendChatMessage(line, channel)
            sent = sent + 1
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99DungeonJournal:|r Not in a group - printing locally instead:")
        for _, line in ipairs(lines) do
            DEFAULT_CHAT_FRAME:AddMessage(line)
        end
    end
end

------------------------------------------------------------
-- CHANGED: Broadcast button - right of the Tactics button. Always shown
-- when a boss is selected (unlike Tactics, it doesn't depend on the
-- optional DungeonJournalTactics addon - it can broadcast stats/abilities
-- with no tactics data registered, tactics lines are just appended if any
-- exist).
------------------------------------------------------------
-- CHANGED: intentionally NOT local - SelectView() (defined earlier in the
-- file, before this point) needs to Hide() this as part of its view-switch
-- hide-list, same reason trashTacticsButton/etc. aren't local either.
broadcastButton = CreateFrame("Button", "DungeonJournalBroadcastButton", frame)
broadcastButton:SetWidth(85)
broadcastButton:SetHeight(22)
broadcastButton:SetPoint("LEFT", tacticsButton, "RIGHT", 8, 0)
broadcastButton:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
broadcastButton:SetBackdropColor(0, 0, 0, 0.8)
broadcastButton:SetBackdropBorderColor(0.4, 0.9, 0.3, 1)

local broadcastButtonText = broadcastButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
broadcastButtonText:SetPoint("CENTER", broadcastButton, "CENTER", 0, 0)
broadcastButtonText:SetTextColor(0.5, 1, 0.4)
broadcastButtonText:SetText("Broadcast")
broadcastButton:Hide()

broadcastButton:SetScript("OnClick", function() BroadcastEntry(currentBoss) end)

-- CHANGED: now generic - takes a parent, indent, and optional frame-name prefix.
-- This lets the same row "widget" be used both for the top-level list (abilities
-- or adds) AND for a nested sub-list of abilities belonging to a single add.
local function CreateAbilityRow(parent, index, indent, namePrefix)
    indent = indent or 18

    local frameName = nil
    if namePrefix then
        frameName = namePrefix .. index
    end

    local btn = CreateFrame("Button", frameName, parent)
    btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    btn.indent = indent

    local expandLabel = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    expandLabel:SetPoint("TOPLEFT", btn, "TOPLEFT", indent - 16, -5)
    expandLabel:SetWidth(12)
    expandLabel:SetJustifyH("LEFT")
    btn.expandLabel = expandLabel

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(ABILITY_ICON_SIZE)
    icon:SetHeight(ABILITY_ICON_SIZE)
    icon:SetPoint("TOPLEFT", btn, "TOPLEFT", indent, -3)
    btn.icon = icon

    local nameLabel = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    nameLabel:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    nameLabel:SetJustifyH("LEFT")
    btn.nameLabel = nameLabel

    local warningIcon = btn:CreateTexture(nil, "OVERLAY")
    warningIcon:SetWidth(16)
    warningIcon:SetHeight(16)
    warningIcon:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -4, -3)
    warningIcon:SetTexture(WARNING_ICON)
    warningIcon:Hide()
    btn.warningIcon = warningIcon

    btn.roleIconSlots = {}
    btn.warningIconAnchor = warningIcon

    btn.textLinesPool = {}
    btn.subRowPool = {} -- CHANGED: pool of nested ability rows (used by adds)

    btn:SetScript("OnClick", function()
        this.ability.expanded = not this.ability.expanded
        -- CHANGED: this row widget is shared between the boss panel and the
        -- trash panel, so it must rebuild whichever list is actually on
        -- screen rather than always assuming the boss list.
        if currentView == "trash" then
            RebuildTrashAbilityList(currentTrashPack)
        else
            RebuildAbilityList(currentBoss)
        end
    end)

    return btn
end

-- CHANGED: now generic - forward-declared as global (no "local function") so
-- it can call itself recursively when rendering an add's nested abilities.
function ConfigureAbilityRow(btn, ability, indent, textWidth)
    indent = indent or 18
    textWidth = textWidth or (RIGHT_CONTENT_WIDTH - 24)

    btn.ability = ability
    btn.expandLabel:SetText(ability.expanded and "-" or "+")
    btn.icon:SetTexture(ability.icon or DEFAULT_ICON)

    if ability.color then
        btn.nameLabel:SetText("|c" .. ability.color .. ability.name .. "|r")
    else
        btn.nameLabel:SetText(ability.name)
    end

    if ability.warning then
        btn.warningIcon:Show()
    else
        btn.warningIcon:Hide()
    end

    for _, slot in ipairs(btn.roleIconSlots) do
        slot:Hide()
    end

    if ability.roles then
        local anchorTo = btn.warningIconAnchor
        for i, role in ipairs(ability.roles) do
            local slot = btn.roleIconSlots[i]
            if not slot then
                slot = btn:CreateTexture(nil, "ARTWORK")
                slot:SetWidth(16)
                slot:SetHeight(16)
                btn.roleIconSlots[i] = slot
            end
            slot:ClearAllPoints()
            slot:SetPoint("TOPRIGHT", anchorTo, "TOPLEFT", -4, 0)
            ApplyUtilityIcon(slot, role)
            slot:Show()
            anchorTo = slot
        end
    end

    for _, fontStr in ipairs(btn.textLinesPool) do
        fontStr:Hide()
    end

    -- CHANGED: hide any nested sub-ability rows by default; re-shown below if needed
    for _, subBtn in ipairs(btn.subRowPool) do
        subBtn:Hide()
    end

    if ability.expanded and (ability.lines or ability.abilities) then
        local currentYOffset = ABILITY_ROW_TOP_H

        if ability.lines then
            for lineIdx, textContent in ipairs(ability.lines) do
                local lineFS = btn.textLinesPool[lineIdx]
                if not lineFS then
                    lineFS = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                    lineFS:SetJustifyH("LEFT")
                    lineFS:SetJustifyV("TOP")
                    btn.textLinesPool[lineIdx] = lineFS
                end

                lineFS:ClearAllPoints()
                lineFS:SetWidth(textWidth)
                lineFS:SetPoint("TOPLEFT", btn, "TOPLEFT", indent, -currentYOffset)
                lineFS:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -6, -currentYOffset)

                btn:SetHeight(1000)
                lineFS:SetText(textContent)
                lineFS:Show()

                local countedHeight = lineFS:GetHeight()
                if countedHeight == 0 then countedHeight = 12 end

                currentYOffset = currentYOffset + countedHeight + 6
            end
        end

        -- CHANGED: an add can define its own "abilities" list (e.g. Flamewaker
        -- Protector -> Mind Control / Melee Swing). Render those nested, one
        -- level deeper, reusing the very same row widget recursively.
        if ability.abilities then
            local subIndent = indent + 18
            local subTextWidth = textWidth - 18

            for subIdx, subAbility in ipairs(ability.abilities) do
                local subBtn = btn.subRowPool[subIdx]
                if not subBtn then
                    subBtn = CreateAbilityRow(btn, subIdx, subIndent, nil)
                    btn.subRowPool[subIdx] = subBtn
                end

                subBtn:ClearAllPoints()
                subBtn:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, -currentYOffset)
                subBtn:SetPoint("TOPRIGHT", btn, "TOPRIGHT", 0, -currentYOffset)

                ConfigureAbilityRow(subBtn, subAbility, subIndent, subTextWidth)
                subBtn:Show()

                currentYOffset = currentYOffset + subBtn:GetHeight() + 4
            end

            for subIdx = table.getn(ability.abilities) + 1, table.getn(btn.subRowPool) do
                btn.subRowPool[subIdx]:Hide()
            end
        end

        btn:SetHeight(currentYOffset + 4)
    else
        btn:SetHeight(ABILITY_ROW_TOP_H)
    end
end

function RebuildAbilityList(boss)
    if not boss then return end

    local dataSource = boss.abilities
    if activeTab == "adds" and boss.adds then
        dataSource = boss.adds
    end

    local yOffset = 0
    -- CHANGED: separators and abilities are drawn from two different pools, so
    -- each needs its own running index. `phaseVisible` tracks whether the most
    -- recent separator is expanded; abilities under a collapsed phase are
    -- skipped entirely (and therefore contribute no height).
    local rowIndex = 0
    local sepIndex = 0
    local phaseVisible = true

    for i, item in ipairs(dataSource) do
        if item.separator then
            sepIndex = sepIndex + 1
            local sep = separatorRowPool[sepIndex]
            if not sep then
                sep = CreateSeparatorRow(abilityScrollChild, sepIndex)
                separatorRowPool[sepIndex] = sep
            end

            sep:ClearAllPoints()
            sep:SetPoint("TOPLEFT", abilityScrollChild, "TOPLEFT", 0, -yOffset)
            sep:SetPoint("TOPRIGHT", abilityScrollChild, "TOPRIGHT", 0, -yOffset)

            ConfigureSeparatorRow(sep, item)
            sep:Show()

            phaseVisible = item.expanded
            yOffset = yOffset + sep:GetHeight() + 4
        elseif phaseVisible then
            rowIndex = rowIndex + 1
            local btn = abilityRowPool[rowIndex]
            if not btn then
                btn = CreateAbilityRow(abilityScrollChild, rowIndex, 18, "DungeonJournalAbilityRow")
                abilityRowPool[rowIndex] = btn
            end

            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", abilityScrollChild, "TOPLEFT", 0, -yOffset)
            btn:SetPoint("TOPRIGHT", abilityScrollChild, "TOPRIGHT", 0, -yOffset)

            ConfigureAbilityRow(btn, item, 18, RIGHT_CONTENT_WIDTH - 24)
            btn:Show()

            yOffset = yOffset + btn:GetHeight() + 4
        end
    end

    for i = rowIndex + 1, table.getn(abilityRowPool) do
        abilityRowPool[i]:Hide()
    end

    for i = sepIndex + 1, table.getn(separatorRowPool) do
        separatorRowPool[i]:Hide()
    end

    abilityScrollChild:SetHeight(yOffset)
    UpdateScrollBarRange(abilityScrollFrame) -- CHANGED: tell the scrollbar about the new content height
end

local function ShowBossInfo(boss)
    currentBoss = boss
    bossNameText:SetText(boss.name)
    
    -- CHANGED: Dynamically updates the boss portrait icon!
    portrait:SetTexture(boss.icon or DEFAULT_ICON)

    -- CHANGED: Dynamically updates the boss flag icons (tauntable, potions, etc)
    RebuildBossFlags(boss)

    -- CHANGED: show armor/resistance line above "Abilities" when the boss has stats
    if boss.stats then
        bossStatsLabel:SetText(FormatBossStats(boss.stats))
        bossStatsLabel:Show()
        abilitiesHeader:SetPoint("TOPLEFT", portrait, "BOTTOMLEFT", 0, -28)
    else
        bossStatsLabel:Hide()
        abilitiesHeader:SetPoint("TOPLEFT", portrait, "BOTTOMLEFT", 0, -16)
    end

    -- CHANGED: Abilities tab always shown (even with no Adds) so there's
    -- always a way back to it after opening Tactics - only the Adds tab is
    -- conditional on the boss actually having adds.
    tabAbilities:Show()
    broadcastButton:Show()
    if boss.adds and table.getn(boss.adds) > 0 then
        tabAdds:Show()
    else
        tabAdds:Hide()
    end
    SelectTab("abilities")

    -- CHANGED: show the Tactics button only if the optional Tactics addon
    -- has registered data for this specific boss
    if boss.key and DungeonJournal_TacticsData[boss.key] then
        tacticsButton:Show()
    else
        tacticsButton:Hide()
    end

    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99DungeonJournal:|r Selected " .. boss.name)
end

------------------------------------------------------------
-- CHANGED: Trash panel (right side) - deliberately mirrors the boss panel
-- above (portrait, flag row, stats line, accordion ability list with
-- separators) instead of a bespoke layout, so trash and bosses look and
-- behave the same. Trash packs use the exact same data shape as bosses
-- (icon/flags/stats/abilities), just without adds/tabs.
------------------------------------------------------------
-- CHANGED: intentionally NOT `local` - SelectView() above already refers to
-- these by name (as globals, since they didn't exist as locals yet at that
-- point in the file), so they're declared as globals here to match.
trashPortrait = frame:CreateTexture(nil, "ARTWORK")
trashPortrait:SetWidth(64)
trashPortrait:SetHeight(64)
trashPortrait:SetPoint("TOPLEFT", frame, "TOPLEFT", LEFT_WIDTH + 26, -70)
trashPortrait:SetTexture(DEFAULT_ICON)
trashPortrait:Hide()

trashNameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
trashNameText:SetPoint("LEFT", trashPortrait, "RIGHT", 10, 0)
trashNameText:SetText("Select a trash pack")
trashNameText:Hide()

trashStatsLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
trashStatsLabel:SetPoint("TOPLEFT", trashPortrait, "BOTTOMLEFT", 0, -8)
trashStatsLabel:SetJustifyH("LEFT")
trashStatsLabel:Hide()

trashAbilitiesHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
trashAbilitiesHeader:SetPoint("TOPLEFT", trashPortrait, "BOTTOMLEFT", 0, -16)
trashAbilitiesHeader:SetText("Abilities")
trashAbilitiesHeader:Hide()

-- CHANGED: the mob "type" flag row (Caster / Melee / Immune to X / etc) -
-- same slot mechanism as bossFlagAnchor/CreateBossFlagSlot, just its own
-- anchor/pool so the two views don't fight over the same slots.
local trashFlagAnchor = CreateFrame("Frame", "DungeonJournalTrashFlagAnchor", frame)
trashFlagAnchor:SetWidth(1)
trashFlagAnchor:SetHeight(1)
trashFlagAnchor:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -34, -74)

local trashFlagSlots = {}

local function CreateTrashFlagSlot(index)
    local slot = CreateFrame("Button", "DungeonJournalTrashFlag"..index, frame)
    slot:SetWidth(30)
    slot:SetHeight(30)

    local tex = slot:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints(slot)
    slot.texture = tex

    slot:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_TOP")
        GameTooltip:SetText(this.flagDef.name, 1, 1, 1)
        GameTooltip:AddLine(this.flagDef.desc, 0.9, 0.9, 0.9, true)
        GameTooltip:Show()
    end)
    slot:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return slot
end

function RebuildTrashFlags(pack)
    local flags = (pack and pack.flags) or {}

    local anchorTo = trashFlagAnchor
    for i, flagKey in ipairs(flags) do
        local def = BOSS_FLAGS[flagKey]
        if def then
            local slot = trashFlagSlots[i]
            if not slot then
                slot = CreateTrashFlagSlot(i)
                trashFlagSlots[i] = slot
            end

            slot.texture:SetTexture(def.icon or DEFAULT_ICON)
            slot.flagDef = def

            slot:ClearAllPoints()
            slot:SetPoint("TOPRIGHT", anchorTo, "TOPLEFT", -6, 0)
            slot:Show()
            anchorTo = slot
        end
    end

    for i = table.getn(flags) + 1, table.getn(trashFlagSlots) do
        trashFlagSlots[i]:Hide()
    end
end

trashAbilityScrollFrame = CreateFrame("ScrollFrame", "DungeonJournalTrashAbilityScrollFrame", frame, "UIPanelScrollFrameTemplate")
trashAbilityScrollFrame:SetPoint("TOPLEFT", trashAbilitiesHeader, "BOTTOMLEFT", 0, -8)
-- CHANGED: bottom moved up from 15 to 40 to leave room for the Tactics
-- button below, matching the boss panel's ability list.
trashAbilityScrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -34, 40)
trashAbilityScrollFrame:Hide()

local trashAbilityScrollChild = CreateFrame("Frame", "DungeonJournalTrashAbilityScrollChild", trashAbilityScrollFrame)
trashAbilityScrollChild:SetHeight(1)
trashAbilityScrollFrame:SetScrollChild(trashAbilityScrollChild)
trashAbilityScrollChild:SetWidth(RIGHT_CONTENT_WIDTH)

EnableMouseWheelScroll(trashAbilityScrollFrame)

------------------------------------------------------------
-- CHANGED: Tactics button for the Trash panel - mirrors the boss panel's
-- Tactics button/inline panel (see RenderTacticsLines above), but sits at
-- the bottom-left since the trash panel has no Abilities/Adds tabs to sit
-- beside. Looks up the same DungeonJournal_TacticsData registry by the
-- trash pack's key, so a single DungeonJournalTactics entry works whether
-- the key belongs to a boss or a trash pack.
------------------------------------------------------------
-- CHANGED: intentionally NOT local - SelectView() above (defined earlier in
-- the file) needs to Hide() these as part of its view-switch hide-list, the
-- same reason trashPortrait/trashAbilityScrollFrame/etc. aren't local either.
--
-- Mirrors the boss panel's tabAbilities/tacticsButton pair: Abilities always
-- shows (so Tactics is always dismissable) and Tactics is conditional on
-- data being registered for the current pack.
------------------------------------------------------------
trashTabAbilities = CreateFrame("Button", "DungeonJournalTrashTabAbilities", frame)
trashTabAbilities:SetWidth(85)
trashTabAbilities:SetHeight(22)
trashTabAbilities:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", LEFT_WIDTH + 26, 15)
trashTabAbilities:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
trashTabAbilities:SetBackdropColor(0, 0, 0, 0.8)
trashTabAbilities:SetBackdropBorderColor(1, 0.82, 0, 1)

local trashTabAbilitiesText = trashTabAbilities:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
trashTabAbilitiesText:SetPoint("CENTER", trashTabAbilities, "CENTER", 0, 0)
trashTabAbilitiesText:SetTextColor(1, 0.82, 0)
trashTabAbilitiesText:SetText("Abilities")
trashTabAbilities:Hide()

trashTacticsButton = CreateFrame("Button", "DungeonJournalTrashTacticsButton", frame)
trashTacticsButton:SetWidth(85)
trashTacticsButton:SetHeight(22)
trashTacticsButton:SetPoint("LEFT", trashTabAbilities, "RIGHT", 20, 0)
trashTacticsButton:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
trashTacticsButton:SetBackdropColor(0, 0, 0, 0.8)
trashTacticsButton:SetBackdropBorderColor(0.2, 0.8, 1, 1)

local trashTacticsButtonText = trashTacticsButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
trashTacticsButtonText:SetPoint("CENTER", trashTacticsButton, "CENTER", 0, 0)
trashTacticsButtonText:SetTextColor(0.4, 0.9, 1)
trashTacticsButtonText:SetText("Tactics")
trashTacticsButton:Hide()

-- CHANGED: Broadcast button for the Trash panel - mirrors the boss panel's
-- broadcastButton above. Always shown when a pack is selected.
trashBroadcastButton = CreateFrame("Button", "DungeonJournalTrashBroadcastButton", frame)
trashBroadcastButton:SetWidth(85)
trashBroadcastButton:SetHeight(22)
trashBroadcastButton:SetPoint("LEFT", trashTacticsButton, "RIGHT", 8, 0)
trashBroadcastButton:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
trashBroadcastButton:SetBackdropColor(0, 0, 0, 0.8)
trashBroadcastButton:SetBackdropBorderColor(0.4, 0.9, 0.3, 1)

local trashBroadcastButtonText = trashBroadcastButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
trashBroadcastButtonText:SetPoint("CENTER", trashBroadcastButton, "CENTER", 0, 0)
trashBroadcastButtonText:SetTextColor(0.5, 1, 0.4)
trashBroadcastButtonText:SetText("Broadcast")
trashBroadcastButton:Hide()

trashBroadcastButton:SetScript("OnClick", function() BroadcastEntry(currentTrashPack) end)

trashTacticsScrollFrame = CreateFrame("ScrollFrame", "DungeonJournalTrashTacticsScrollFrame", frame, "UIPanelScrollFrameTemplate")
trashTacticsScrollFrame:SetPoint("TOPLEFT", trashAbilitiesHeader, "BOTTOMLEFT", 0, -8)
trashTacticsScrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -34, 40)
trashTacticsScrollFrame:Hide()

local trashTacticsScrollChild = CreateFrame("Frame", "DungeonJournalTrashTacticsScrollChild", trashTacticsScrollFrame)
trashTacticsScrollChild:SetHeight(1)
trashTacticsScrollFrame:SetScrollChild(trashTacticsScrollChild)
trashTacticsScrollChild:SetWidth(RIGHT_CONTENT_WIDTH)

EnableMouseWheelScroll(trashTacticsScrollFrame)

local trashTacticsTextRowPool = {}
local trashTacticsSepRowPool = {}
local trashTacticsShown = false

local function ShowTrashTactics()
    if not currentTrashPack then return end
    local data = DungeonJournal_TacticsData[currentTrashPack.key]
    if not data then return end

    trashTacticsShown = true
    trashAbilitiesHeader:SetText(data.title or "Tactics")

    local previewLines = PrepareTacticsPreview(data.lines, currentTrashPack)
    local height = RenderTacticsLines(previewLines, trashTacticsScrollChild, trashTacticsTextRowPool, trashTacticsSepRowPool, "DungeonJournalTrashTactics")
    trashTacticsScrollChild:SetHeight(height)
    UpdateScrollBarRange(trashTacticsScrollFrame)

    trashAbilityScrollFrame:Hide()
    trashTacticsScrollFrame:Show()
end

local function HideTrashTactics()
    trashTacticsShown = false
    trashTacticsScrollFrame:Hide()
    trashAbilityScrollFrame:Show()
    trashAbilitiesHeader:SetText("Abilities")
end

trashTabAbilities:SetScript("OnClick", function() HideTrashTactics() end)
trashTacticsButton:SetScript("OnClick", function() ShowTrashTactics() end)

-- CHANGED: separate row/separator pools from the boss panel - CreateAbilityRow/
-- ConfigureAbilityRow/CreateSeparatorRow/ConfigureSeparatorRow are all generic
-- (parent passed in), so they're reused as-is here.
local trashAbilityRowPool = {}
local trashSeparatorRowPool = {}

function RebuildTrashAbilityList(pack)
    if not pack then return end

    local dataSource = pack.abilities or {}

    local yOffset = 0
    local rowIndex = 0
    local sepIndex = 0
    local phaseVisible = true

    for i, item in ipairs(dataSource) do
        if item.separator then
            sepIndex = sepIndex + 1
            local sep = trashSeparatorRowPool[sepIndex]
            if not sep then
                sep = CreateSeparatorRow(trashAbilityScrollChild, sepIndex)
                trashSeparatorRowPool[sepIndex] = sep
            end

            sep:ClearAllPoints()
            sep:SetPoint("TOPLEFT", trashAbilityScrollChild, "TOPLEFT", 0, -yOffset)
            sep:SetPoint("TOPRIGHT", trashAbilityScrollChild, "TOPRIGHT", 0, -yOffset)

            ConfigureSeparatorRow(sep, item)
            sep:Show()

            phaseVisible = item.expanded
            yOffset = yOffset + sep:GetHeight() + 4
        elseif phaseVisible then
            rowIndex = rowIndex + 1
            local btn = trashAbilityRowPool[rowIndex]
            if not btn then
                btn = CreateAbilityRow(trashAbilityScrollChild, rowIndex, 18, "DungeonJournalTrashAbilityRow")
                trashAbilityRowPool[rowIndex] = btn
            end

            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", trashAbilityScrollChild, "TOPLEFT", 0, -yOffset)
            btn:SetPoint("TOPRIGHT", trashAbilityScrollChild, "TOPRIGHT", 0, -yOffset)

            ConfigureAbilityRow(btn, item, 18, RIGHT_CONTENT_WIDTH - 24)
            btn:Show()

            yOffset = yOffset + btn:GetHeight() + 4
        end
    end

    for i = rowIndex + 1, table.getn(trashAbilityRowPool) do
        trashAbilityRowPool[i]:Hide()
    end

    for i = sepIndex + 1, table.getn(trashSeparatorRowPool) do
        trashSeparatorRowPool[i]:Hide()
    end

    trashAbilityScrollChild:SetHeight(yOffset)
    UpdateScrollBarRange(trashAbilityScrollFrame)
end

function ShowTrashPack(pack)
    currentTrashPack = pack
    if pack.count then
        trashNameText:SetText(pack.name .. " (" .. pack.count .. ")")
    else
        trashNameText:SetText(pack.name)
    end
    trashPortrait:SetTexture(pack.icon or DEFAULT_ICON)

    RebuildTrashFlags(pack)

    if pack.stats then
        trashStatsLabel:SetText(FormatBossStats(pack.stats))
        trashStatsLabel:Show()
        trashAbilitiesHeader:SetPoint("TOPLEFT", trashPortrait, "BOTTOMLEFT", 0, -28)
    else
        trashStatsLabel:Hide()
        trashAbilitiesHeader:SetPoint("TOPLEFT", trashPortrait, "BOTTOMLEFT", 0, -16)
    end

    -- CHANGED: always land back on the ability list when switching packs.
    -- Abilities tab always shows; Tactics is conditional on data being
    -- registered for this pack.
    HideTrashTactics()
    trashTabAbilities:Show()
    trashBroadcastButton:Show()
    if pack.key and DungeonJournal_TacticsData[pack.key] then
        trashTacticsButton:Show()
    else
        trashTacticsButton:Hide()
    end

    RebuildTrashAbilityList(pack)

    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99DungeonJournal:|r Selected " .. pack.name)
end

------------------------------------------------------------
-- Tree building (left side)
------------------------------------------------------------
local function BuildEntries()
    local entries = {}
    for _, raid in ipairs(RAIDS) do
        table.insert(entries, { entryType = "header", raid = raid })
        if raid.expanded then
            for _, boss in ipairs(raid.bosses) do
                -- CHANGED: a separator entry in the bosses list (e.g. "Edge of
                -- Madness" in ZG) is rendered as a non-clickable label row.
                if boss.separator then
                    table.insert(entries, { entryType = "separator", boss = boss })
                else
                    table.insert(entries, { entryType = "boss", raid = raid, boss = boss })
                end
            end
        end
    end
    return entries
end

local treeButtonPool = {}

local function CreateTreeRow(index)
    local btn = CreateFrame("Button", "DungeonJournalTreeRow"..index, scrollChild)
    btn:SetWidth(LEFT_WIDTH - 10)
    btn:SetHeight(TREE_ROW_HEIGHT)
    btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("LEFT", btn, "LEFT", 4, 0)
    label:SetJustifyH("LEFT")
    btn.label = label

    btn:SetScript("OnClick", function()
        local entry = this.entry
        if entry.entryType == "header" then
            entry.raid.expanded = not entry.raid.expanded
            RebuildTree()
        elseif entry.entryType == "boss" then
            ShowBossInfo(entry.boss)
        end
        -- CHANGED: separators in the boss list are non-clickable (no action)
    end)

    return btn
end

function RebuildTree()
    local entries = BuildEntries()

    for i, entry in ipairs(entries) do
        local btn = treeButtonPool[i]
        if not btn then
            btn = CreateTreeRow(i)
            treeButtonPool[i] = btn
        end

        btn.entry = entry
        if entry.entryType == "header" then
            local prefix = entry.raid.expanded and "- " or "+ "
            btn.label:SetText(prefix .. entry.raid.name)
            btn.label:SetPoint("LEFT", btn, "LEFT", 4, 0)
            btn.label:SetFontObject(GameFontNormalSmall)
        elseif entry.entryType == "separator" then
            -- CHANGED: boss-level separator rendered as a non-clickable label
            if entry.boss.color then
                btn.label:SetText("|c" .. entry.boss.color .. "--- " .. entry.boss.name .. " ---|r")
            else
                btn.label:SetText("|cff888888--- " .. entry.boss.name .. " ---|r")
            end
            btn.label:SetPoint("LEFT", btn, "LEFT", 18, 0)
            btn.label:SetFontObject(GameFontDisableSmall)
        else
            -- CHANGED: a boss may carry an optional `color` (ARGB hex, same
            -- format as ability names) to highlight it in the tree - e.g. gold
            -- for world bosses. Always set the text explicitly either way so a
            -- pooled row never keeps a previous entry's colour codes.
            if entry.boss.color then
                btn.label:SetText("|c" .. entry.boss.color .. entry.boss.name .. "|r")
            else
                btn.label:SetText(entry.boss.name)
            end
            btn.label:SetPoint("LEFT", btn, "LEFT", 18, 0)
            btn.label:SetFontObject(GameFontHighlightSmall)
        end

        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -(i - 1) * TREE_ROW_HEIGHT)
        btn:Show()
    end

    for i = table.getn(entries) + 1, table.getn(treeButtonPool) do
        treeButtonPool[i]:Hide()
    end

    scrollChild:SetHeight(table.getn(entries) * TREE_ROW_HEIGHT)
    UpdateScrollBarRange(scrollFrame)
end

RebuildTree()

-- CHANGED: deferred from earlier in the file - SelectView() touches trash
-- panel globals that only exist once we reach this point.
SelectView("bosses")

frame:Hide()

------------------------------------------------------------
-- Slash command: /clicky toggles the window
------------------------------------------------------------
SLASH_DungeonJournal1 = "/clicky"
SlashCmdList["DungeonJournal"] = function()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99DungeonJournal loaded.|r Type /clicky to open the window.")