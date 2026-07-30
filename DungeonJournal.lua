-- DungeonJournal.lua
-- WoW 1.12.1 addon: an "Adventure Guide"-style window.
-- Left side  = collapsible tree (Raid -> Bosses)
-- Right side = boss header + tabbed accordion list of abilities and adds.

------------------------------------------------------------
-- Config
------------------------------------------------------------
local WINDOW_WIDTH        = 520
local WINDOW_HEIGHT       = 504  -- CHANGED: +24 to make room for the top nav bar
local LEFT_WIDTH          = WINDOW_WIDTH * 0.2   -- 20% of the window
local RIGHT_CONTENT_WIDTH = WINDOW_WIDTH - LEFT_WIDTH - 60
local TREE_ROW_HEIGHT     = 22
local ABILITY_ROW_TOP_H   = 26   -- height of the icon/name/icons line
local ABILITY_ICON_SIZE   = 20
local SEPARATOR_ROW_H     = 20   -- CHANGED: height of a phase separator bar

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
-- CHANGED: Boss "flag" icons - shown in a row to the right of the boss
-- portrait/name, for quick-glance encounter notes like "this boss can/can't
-- be taunted" or "bring Fire Protection Potions". Tag a boss in the RAIDS
-- database with e.g. flags = { "nottauntable", "potion_fire" } and the
-- matching icons will appear automatically - see RebuildBossFlags() below.
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
        icon = "Interface\\Icons\\spell_nature_reincarnation",
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
    potion_fire = {
        icon = "Interface\\Icons\\INV_Potion_24",
        name = "Fire Protection Potion",
        desc = "Consider bringing Fire Protection Potions for this encounter.",
    },
    potion_nature = {
        icon = "Interface\\Icons\\INV_Potion_22",
        name = "Nature Protection Potion",
        desc = "Consider bringing Nature Protection Potions for this encounter.",
    },
    potion_frost = {
        icon = "Interface\\Icons\\INV_Potion_20",
        name = "Frost Protection Potion",
        desc = "Consider bringing Frost Protection Potions for this encounter.",
    },
    potion_shadow = {
        icon = "Interface\\Icons\\INV_Potion_23",
        name = "Shadow Protection Potion",
        desc = "Consider bringing Shadow Protection Potions for this encounter.",
    },
    potion_arcane = {
        icon = "Interface\\Icons\\INV_Potion_83",
        name = "Arcane Protection Potion",
        desc = "Consider bringing Arcane Protection Potions for this encounter.",
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
    icon = BOSS_FLAGS.potion_fire.icon,
    name = BOSS_FLAGS.potion_fire.name,
    desc = BOSS_FLAGS.potion_fire.desc
}, {
    icon = BOSS_FLAGS.potion_nature.icon,
    name = BOSS_FLAGS.potion_nature.name,
    desc = BOSS_FLAGS.potion_nature.desc
}, {
    icon = BOSS_FLAGS.potion_frost.icon,
    name = BOSS_FLAGS.potion_frost.name,
    desc = BOSS_FLAGS.potion_frost.desc
}, {
    icon = BOSS_FLAGS.potion_shadow.icon,
    name = BOSS_FLAGS.potion_shadow.name,
    desc = BOSS_FLAGS.potion_shadow.desc
}, {
    icon = BOSS_FLAGS.potion_arcane.icon,
    name = BOSS_FLAGS.potion_arcane.name,
    desc = BOSS_FLAGS.potion_arcane.desc
}}

------------------------------------------------------------
-- Database: raids -> bosses -> abilities & adds
-- CHANGED: Added 'icon' field to the bosses!
------------------------------------------------------------
local RAIDS = {{
    key = "MC",
    name = "Molten Core",
    expanded = false,
    bosses = {{
        key = "lucifron",
        name = "Lucifron",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Lucifron",
        flags = {"nottauntable", "potion_fire"}, -- CHANGED: demo of the new boss flag icons
        abilities = {{
            name = "Lucifron's Curse",
            icon = "Interface\\Icons\\Spell_Shadow_BlackPlague",
            roles = {"decurse"},
            color = "ffa335ee",
            lines = {"Afflicts an enemy with a curse that doubles the cost of any spell."}
        }, {
            name = "Impending Doom",
            icon = "Interface\\Icons\\Spell_Shadow_AntiShadow",
            roles = {"dispel"},
            color = "ffff7d0a",
            lines = {"This ability inflicts 2000 Shadow damage to the target after 10 seconds."}
        }, {
            name = "Shadow Shock",
            icon = "Interface\\Icons\\spell_shadow_shadowbolt",
            roles = {},
            color = "ffff7d0a",
            lines = {"Instantly lashes an enemy with dark magic, inflicting 2000-3000(?) Shadow damage."}
        }, {
            name = "Tortures",
            icon = "Interface\\Icons\\spell_shadow_shadowwordpain",
            roles = {"tank"},
            color = "ffff7d0a",
            lines = {"Inflicts 239 to 1039 Shadow damage to an enemy and increases the damage it takes by 20% for 60 seconds. This effect stacks."}
        }},
        adds = {{
            name = "Flamewaker Protector",
            icon = "Interface\\Icons\\Spell_Shadow_SummonFelguard",
            roles = {},
            color = "ffcc0000",
            lines = {"Two of these accompany Lucifron into battle.",
                     "They mind control random raid members and must be kept tanked away from Lucifron."},
            abilities = {{
                name = "Mind Control",
                icon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
                roles = {"dispel"},
                color = "ff00ccff",
                lines = {"Randomly mind controls a raid member. Dispel or kill the add to break the effect."}
            }, {
                name = "Cleave",
                icon = "Interface\\Icons\\ability_warrior_cleave",
                roles = {"tank", "melee"},
                color = "ff00ccff",
                lines = {"Inflicts weapon damage plus 30 to an enemy and its nearest allies, affecting up to 3 targets."}
            }}
        }}
    }, {
        key = "magmadar",
        name = "Magmadar",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Magmadar",
        flags = {"tauntable", "potion_fire"},
        abilities = {{
            name = "Frenzy",
            icon = "Interface\\Icons\\ability_druid_challangingroar",
            roles = {"hunter"},
            lines = {"Magmadar enters a frenzy, dramatically increasing his attack speed until removed by Tranquilizing Shot."}
        }, {
            name = "Lava Breath",
            icon = "Interface\\Icons\\spell_fire_windsofwoe",
            roles = {"tank"},
            lines = {"Magmadar breaths lava in a frontal cone in front of him dealing 2857-3743 Fire damage."}
        }, {
            name = "Panic",
            icon = "Interface\\Icons\\spell_shadow_deathscream",
            roles = {},
            lines = {"Magmadar fears everyone in the raid for 8 seconds."}
        }, {
            name = "Lava Bomb",
            icon = "Interface\\Icons\\spell_fire_selfdestruct",
            warning = true,
            roles = {"healer"},
            lines = {"Magmadar launches a Lava Bomb on a random player.",
                     "This ability creates a flame patch on the floor for 60? seconds which applies a debuff causing 4000 Fire damage over 8 seconds."}
        }, {
            name = "Magma Spit",
            icon = "Interface\\Icons\\spell_fire_meteorstorm",
            roles = {"healer"},
            lines = {"Magmadar spits fire at nearby players, dealing 75 Fire damage every 3 seconds. Lasts 30 seconds and stacks up 3? times."}
        }, {
            name = "Double Bite",
            icon = "Interface\\Icons\\ability_racial_cannibalize",
            roles = {"tank"},
            lines = {"Magmadar bites the target second in threat."}
        }}
    }, {
        key = "gehennas",
        name = "Gehennas",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Gehennas",
        abilities = {{
            name = "Rain of Fire",
            icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
            warning = true,
            lines = {"Gehennas rains down fire on a random area, dealing 925-1075 Fire damage every 2 seconds to anyone standing in it."}
        }, {
            name = "Gehennas' Curse",
            icon = "Interface\\Icons\\Spell_Shadow_ChillTouch",
            roles = {"decurse"},
            lines = {"Gehennas curses all players, reducing the effectiveness of healing spells cast on them by 75% for 60 seconds."}
        }, {
            name = "Shadow Bolt",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            roles = {"kick"},
            lines = {"Gehennas fires a Shadow Bolt at a random player dealing 2250-2750 Shadow damage."}
        }},
        adds = {{
            name = "Flamewaker",
            icon = "Interface\\Icons\\temp",
            roles = {},
            color = "ffcc0000",
            lines = {"Two of these accompany Gehennas into battle.",
                     "They stun random raid members and must be kept tanked away from Gehennas."},
            abilities = {{
                name = "Strike",
                icon = "Interface\\Icons\\ability_rogue_ambush",
                roles = {"tank"},
                lines = {"Strikes at an enemy, inflicting normal damage plus 25."}
            }, {
                name = "Sunder Armor",
                icon = "Interface\\Icons\\ability_warrior_sunder",
                roles = {"tank"},
                lines = {"Hacks at nearby enemies, reducing their armor by X per Sunder Armor. Can be applied up to 5 times. Lasts 30 sec."}
            }, {
                name = "Fist of Ragnaros",
                icon = "Interface\\Icons\\spell_holy_sealofwrath",
                roles = {"tank", "dps"},
                lines = {"Stuns nearby enemies, rendering them unable to move or attack for 5 sec."}
            }}
        }}
    }, {
        key = "garr",
        name = "Garr",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Garr",
        abilities = {{
            name = "Magma Shackles",
            icon = "Interface\\Icons\\spell_nature_earthbind",
            roles = {"dispel"},
            lines = {"Reduces the movement speed of nearby enemies by 60% for 15 sec."}
        }, {
            name = "Antimagic Pulse",
            icon = "Interface\\Icons\\spell_holy_dispelmagic",
            roles = {"healer", "dispel"},
            lines = {"Dispels magic on nearby enemies, removing 2 beneficial spell effects."}
        }, {
            name = "Annihilate",
            icon = "INTERFACE\\ICONS\\stoneskinz_3",
            roles = {"tank"},
            lines = {"Increases the Physical damage taken by an enemy by 100 for 1 min. Stacks indefinitely."}
        }, {
            name = "Magnetize",
            icon = "Interface\\Icons\\Spell_Nature_GroundingTotem",
            roles = {"healer"},
            warning = true,
            lines = {"Garr magnetizes a random raid member. After 5 seconds the Magnetized player takes 200-300 Nature damage every 0.5 seconds for 25 seconds.",
                     "If the Magnetized player is within 8 yards of another player, that player will also become Magnetized."}
        }},
        adds = {{
            name = "Firesworn",
            icon = "Interface\\Icons\\Spell_Fire_Volcano",
            roles = {"tank"},
            color = "ffffaa00",
            lines = {"Garr starts with 8 Firesworn adds around him.",
                     "For each Firesworn that dies, Garr gains 10% attack speed and loses 300 armor."},
            abilities = {{
                name = "Eruption",
                icon = "Interface\\Icons\\temp",
                roles = {"tank", "dps"},
                warning = true,
                lines = {"Explodes on death dealing X Fire damage and heavy knockback to nearby players."}
            }, {
                name = "Immolate",
                icon = "Interface\\Icons\\temp",
                lines = {"Inflicts 760 to 840 Fire damage to an enemy and scorches it for an additional 680 to 720 damage every 3 sec. for 21 sec."}
            }, {
                name = "Separation Anxiety",
                icon = "Interface\\Icons\\temp",
                lines = {"Firesworn will deal 300% additional damage if more than X yards away from Garr."}
            }}
        }}
    }, {
        key = "baron_geddon",
        name = "Baron Geddon",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\BaronGeddon",
        abilities = {{
            name = "Living Bomb",
            icon = "Interface\\Icons\\inv_enchant_essenceastralsmall",
            warning = true,
            lines = {"Baron Geddon throws a bomb at a random raid member. After 6 sec. the bomb explodes, inflicting 3800 to 4300 Fire damage to the target and its nearby allies."}
        }, {
            name = "Spreading Flames",
            icon = "Interface\\Icons\\spell_fire_selfdestruct",
            roles = { "dps", "healer" },
            warning = true,
            lines = {"Baron Geddon ignites a player dealing X damage after 6? seconds divided evenly with all players nearby."},
            abilities = {{
                name = "Molten Ground",
                icon = "Interface\\Icons\\spell_fire_selfdestruct",
                lines = {"Spreading Flames leaves Molten Ground on the floor for 2 minutes, dealing 54000 Fire damage over 2 minutes to anyone standing in it. (Hits every second?)"}
            }}
        }, {
            name = "Inferno",
            icon = "Interface\\Icons\\spell_fire_incinerate",
            roles = {"dps", "healer"},
            lines = {"Baron Geddon channels a raging inferno beneath him for 8 sec, dealing increasing (1000+?) Fire damage to nearby players."}
        }, {
            name = "Ignite Mana",
            icon = "Interface\\Icons\\Spell_Fire_Immolation",
            roles = {"dispel"},
            lines = {"Baron Geddon casts Ignite Mana on all players, burning 400 mana every 3(?) sec. for 1 min. Each point of mana that is destroyed also damages the target from which it is consumed."},
            abilities = {{
                name = "Scald",
                icon = "Interface\\Icons\\spell_fire_incinerate",
                lines = {"Applied whenever Ignite Mana is dispelled - the target becomes silenced for 10 sec."}
            }}
        }, {
            name = "Armageddon",
            icon = "Interface\\Icons\\spell_fire_selfdestruct",
            warning = true,
            lines = {"Baron Geddon performs one last service for Ragnaros when he reaches 5% health. If Baron Geddon is not killed within 8 seconds he explodes dealing 8000(?) Fire Damage to all players in line of sight."},
        }}
    }, {
        key = "shazzrah",
        name = "Shazzrah",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Shazzrah",
        abilities = {{
            name = "Arcane Explosion",
            icon = "Interface\\Icons\\spell_nature_wispsplode",
            roles = {"dps"},
            lines = {"Sends out a blast wave of magic, inflicting 925 to 1400 Arcane damage to nearby enemies."}
        }, {
            name = "Arcane Volley",
            icon = "Interface\\Icons\\spell_nature_starfall",
            roles = {"ranged"},
            lines = {"Shazzrah throws arcanebolts at all enemies between 20 and 100 yards, dealing X Arcane Damage."}
        }, {
            name = "Arcane Blast",
            icon = "Interface\\Icons\\spell_shadow_deathpact",
            warning = true,
            roles = {"tank"},
            lines = {"Blasts an enemy with Arcane magic, inflicting normal damage plus 1050 to 1350 and knocking the enemy back 50? yards."}
        }, {
            name = "Deaden Magic",
            icon = "Interface\\Icons\\spell_holy_sealofsalvation",
            roles = {"dispel"},
            lines = {"Reduces the magical damage taken by Shazzrah by 75% for 30 sec until dispelled."}
        }, {
            name = "Shazzrah's Curse",
            icon = "Interface\\Icons\\Spell_shadow_antishadow",
            roles = {"decurse"},
            lines = {"Curses all players, increasing the magical damage taken by 100% for 1 min."}
        }, {
            name = "Blink",
            icon = "Interface\\Icons\\spell_arcane_blink",
            roles = {"tank"},
            lines = {"Shazzrah teleports on top of a random player every ~30 seconds, clearing all threat in the process."}
        }, {
            name = "Counterspell",
            icon = "Interface\\Icons\\spell_frost_iceshock",
            roles = {"caster"},
            lines = {"Counters the spellcasting of nearby enemies, preventing any spell from that school of magic from being cast for 10 sec."}
        }, {
            name = "Polymorph: Core Hound",
            icon = "Interface\\Icons\\ability_druid_challangingroar",
            roles = {"tank"},
            lines = {"Transforms the highest threat target into a Core Hound, forcing it to wander around for up to 15 sec."}
        }, {
            name = "Gate of Shazzrah",
            icon = "Interface\\Icons\\spell_arcane_portalironforge",
            warning = true,
            lines = {"Shazzrah summons an Arcane Rune at a target location. After 5 seconds, the rune erupts into an Arcane Dome. Anyone trapped within it is unable to take any actions for 30 seconds."}
        }}
    }, {
        key = "golemagg",
        name = "Golemagg the Incinerator",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Golemagg",
        abilities = {{
            name = "Magma Splash",
            icon = "Interface\\Icons\\spell_fire_immolation",
            roles = {"tank", "melee"},
            lines = {"Golemagg splashes magma at his attackers, dealing 50 Fire damage every 3 sec. and reducing their armor by 250? per stack. Stacks indefinitely."}
        }, {
            name = "Hateful Strike",
            icon = "Interface\\Icons\\trade_engineering",
            roles = {"tank", "healer"},
            warning = true,
            lines = {"Inflicts 8000 to 10000 damage to the target with 2nd threat."}
        },{
            name = "Pyroblast",
            icon = "Interface\\Icons\\spell_fire_fireball02",
            roles = {"healer"},
            warning = true,
            lines = {"Inflicts 3588 to 4512 Fire damage to an enemy and scorches the target for an additional 474 damage every 2 sec. for 12 sec."}
        }, {
            name = "Implosion // Chain Reaction",
            icon = "Interface\\Icons\\inv_elemental_primal_fire",
            roles = {"healer"},
            warning = true,
            lines = {"Golemagg encases an enemy in molten fire for 8 sec and is stunned. After 8 sec. the target explodes, dealing 2910 to 3710 Fire damage to all nearby enemies."}
        },{
            name = "Enrage",
            icon = "Interface\\Icons\\spell_shadow_unholyfrenzy",
            warning = true,
            lines = {"Whenever Golemagg reaches 20% health he enrages growing bigger and gaining damage/attack speed and casting his abilities faster?."},
            abilities = {{
                name = "Earthquake",
                icon = "Interface\\Icons\\Spell_Nature_Earthquake",
                lines = {"Golemagg causes an earthquake every 4 seconds, inflicting ~2000+ damage to nearby enemies.)"}
            }}
        }},
        adds = {{
            name = "Core Rager",
            icon = "Interface\\Icons\\INV_Misc_Gem_Bloodstone_01",
            roles = {"tank", "dps"},
            color = "ffcc6600",
            lines = {"Golemagg is accompanied by two Core Ragers which cannot die while Golemagg is alive and will run off ."},
            abilities = {{
                name = "Golemagg's Trust",
                icon = "Interface\\Icons\\ability_hunter_beasttaming",
                warning = true,
                roles = {"tank"},
                lines = {"They will deal increased damage and have 50% increased attack speed if tanked too close to Golemagg.",
                       "They will be bigger and glowing red if tanked too close to Golemagg."}
            }, {
                name = "Mangle",
                icon = "Interface\\Icons\\ability_druid_disembowel",
                lines = {"Inflicts 500 damage to an enemy every 2 sec. and slows its movement by 60% for 30 sec."}
            }, {
                name = "Serrated Bite",
                icon = "Interface\\Icons\\ability_gouge",
                roles = {"healer", "tank"},
                lines = {"Inflicts a bleed of 1500 Physical damage to an enemy over 30 sec. Stacks indefinitely."}
            }, {
                name = "Mark of Golemagg",
                icon = "Interface\\Icons\\ability_hunter_snipershot",
                lines = {"Cast on tanks"}
            }}
        }}
    }, {
        key = "sulfuron",
        name = "Sulfuron Harbinger",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Sulfuron",
        abilities = {{
            name = "Battle Stance",
            icon = "Interface\\Icons\\ability_warrior_offensivestance",
            lines = {"Sulfuron goes into Battle Stance, gaining new abilties."},
            abilities = {{
                name = "Rend",
                icon = "Interface\\Icons\\ability_gouge",
                lines = {"Inflicts 129 Physical damage to an enemy every 3 sec. for 15 sec."}
            }, {
                name = "Retaliation",
                icon = "Interface\\Icons\\ability_warrior_challange",
                roles = {"melee"},
                lines = {"Instantly counterattack any enemy that strikes you in melee for 15 sec."}
            }, {
                name = "Unbalancing Strike",
                icon = "Interface\\Icons\\ability_warrior_decisivestrike",
                roles = {"tank"},
                lines = {"Inflicts 350% weapon damage and leaves the target unbalanced, reducing their defense skill by 100 for 6 sec."}
            }}
        }, {
            name = "Defensive Stance",
            icon = "Interface\\Icons\\ability_warrior_defensivestance",
            lines = {"Sulfuron goes into Defensive Stance, gaining new abilties."},
            abilities = {{
                name = "War Stomp",
                icon = "Interface\\Icons\\ability_bullrush",
                roles = {"melee"},
                lines = {"Inflicts normal damage plus 936 to 1064 to nearby enemies and stunning them for 5 sec. (sometimes more damage; only during defensive stance?)"}
            }, {
                name = "Shield Wall",
                icon = "Interface\\Icons\\ability_warrior_shieldwall",
                lines = {"Reduces the Physical and magical damage taken by Sulfuron by 75% for 20 sec."}
            }, {
                name = "Sunder Armor",
                icon = "Interface\\Icons\\ability_warrior_sunder",
                roles = {"tank"},
                lines = {"Hacks at an enemy's armor, reducing it by X per Sunder Armor. Can be applied up to 5 times. Lasts 30 sec."}
            }}
        }, {
            name = "Berserker Stance",
            icon = "Interface\\Icons\\ability_racial_avatar",
            lines = {"Sulfuron goes into Berserker Stance, gaining new abilties."},
            abilities = {{
                name = "Flame Charge",
                icon = "Interface\\Icons\\ability_warrior_charge",
                roles = {"tank"},
                lines = {"Charges at an enemy, knocking it back and inflicting normal damage plus 300."}
            }}
        }, {
            name = "Inspire",
            icon = "Interface\\Icons\\ability_warrior_offensivestance",
            roles = {"tank"},
            lines = {"Increases the Physical damage dealt by an ally by 50% and speeds its attacks by 100% for 10 sec. 45y range."}
        }, {
            name = "Drain Life",
            icon = "Interface\\Icons\\spell_shadow_lifedrain02",
            roles = {"tank"},
            lines = {"Steals 2000 to 3000 life from target enemy. Shadow damage ability."}
        }, {
            name = "Dark Strike",
            icon = "Interface\\Icons\\ability_thunderbolt",
            roles = {"tank"},
            lines = {"Consecrates the caster's weapon, inflicting 570 to 630 additional damage on its next attack. All damage caused is considered Shadow damage."}
        }, {
            name = "Flame Spear",
            icon = "Interface\\Icons\\ability_throw",
            lines = {"Tosses a spear of flame, inflicting 1850 to 2450 Fire damage to an enemy, as well as scorching any other enemies in the vicinity of the target."}
        }},
        adds = {{
            name = "Flamewaker Priest",
            icon = "Interface\\Icons\\Spell_Holy_GuardianSpirit",
            roles = {"tank", "dps"},
            color = "ffcc0000",
            lines = {"Four Flamewaker Priests accompany Sulfuron and continually shield and heal him.",
                     "Kill these before focusing Sulfuron himself, or the fight will drag on far too long."},
            abilities = {{
                name = "Power Word: Shield",
                icon = "Interface\\Icons\\Spell_Holy_PowerWordShield",
                warning = true,
                lines = {"Shields Sulfuron, absorbing a large amount of damage. Interrupt or kill the priests quickly."}
            }, {
                name = "Greater Heal",
                icon = "Interface\\Icons\\Spell_Holy_GreaterHeal",
                lines = {"Heals Sulfuron for a significant amount; interrupt this cast when possible."}
            }}
        }}
    }, {
        key = "majordomo",
        name = "Majordomo",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Majordomo",
        abilities = {{
            name = "Blast Wave",
            icon = "Interface\\Icons\\spell_holy_excorcism_02",
            lines = {"Inflicts 994 to 1406 Fire damage to nearby enemies and reduces their movement speed by 50% for 12 sec."}
        }, {
            name = "Magic Reflection",
            icon = "Interface\\Icons\\spell_frost_frostshock",
            lines = {"Causes all nearby allies to reflect 100% of harmful spells for 10 sec."}
        }, {
            name = "Damage Shield",
            icon = "Interface\\Icons\\spell_shadow_antishadow",
            roles = {"melee"},
            lines = {"Causes 300 arcane damage to any creature that strikes a nearby minion."}
        }, {
            name = "Polymorph: Core Hound",
            icon = "Interface\\Icons\\ability_druid_challangingroar",
            lines = {"Transforms a random non-tank? into a Core Hound, forcing it to wander around for up to 15 sec."}
        }, {
            name = "Teleport // Grilling",
            icon = "Interface\\Icons\\spell_arcane_blink",
            lines = {"Teleports an enemy into the midst of burning coals."}
        }, {
            name = "Defensive/Offensive Action Order",
            icon = "Interface\\Icons\\inv_shield_10",
            lines = {"Majordomo adds either take defensive or offensive action orders every 60 seconds.",
                     "Defensive action orders cause the adds to take 50% less damage.",
                     "Offensive action orders cause the adds to take 50% more damage."}
        }, {
            name = "Teleport // Grilling",
            icon = "Interface\\Icons\\spell_arcane_blink",
            lines = {"Teleports an enemy into the midst of burning coals."}
        }},
        adds = {{
            name = "Flamewaker Healer",
            icon = "Interface\\Icons\\temp",
            roles = {"tank", "dps"},
            color = "ffcc0000",
            lines = {"Waves of Flamewaker Elites spawn and must be tanked and killed before Majordomo can be damaged.",
                     "Focus these down as a priority - Majordomo cannot be hurt while any remain."},
            abilities = {{
                name = "Silence",
                icon = "Interface\\Icons\\spell_holy_silence",
                lines = {"Silences nearby enemies, preventing them from casting spells for 8 sec."}
            }, {
                name = "Shadow Bolt",
                icon = "Interface\\Icons\\spell_shadow_shadowbolt",
                lines = {"Hurls a bolt of dark magic at an enemy, inflicting 2000 to 2450 Shadow damage."}
            }, {
                name = "Dark Mending",
                icon = "Interface\\Icons\\spell_shadow_chilltouch",
                lines = {"Uses dark magic to heal an ally for 127750 to 142250 damage."}
            }}
        }, {
            name = "Flamewaker Elite",
            icon = "Interface\\Icons\\temp",
            roles = {"dps", "dispel"},
            color = "ffffaa00",
            lines = {"Accompanies the Flamewaker Elites and heals them.",
                     "Kill or interrupt these first so the Elites go down faster."},
            abilities = {{
                name = "Fireball",
                icon = "Interface\\Icons\\spell_fire_flamebolt",
                lines = {"Inflicts 2000 to 2450 Fire damage to an enemy."}
            }, {
                name = "Blast Wave",
                icon = "Interface\\Icons\\spell_holy_excorcism_02",
                lines = {"Inflicts 994 to 1406 Fire damage to nearby enemies and reduces their movement speed by 50% for 12 sec."}
            }}
        }}
    }, {
        key = "ragnaros",
        name = "Ragnaros",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Ragnaros",
        abilities = {{
            name = "Wrath of Ragnaros",
            icon = "Interface\\Icons\\Spell_Fire_FlameShock",
            roles = {"melee", "tank"},
            warning = true,
            lines = {"Inflicts 1000 Fire damage to nearby enemies, knocking them back."}
        }, {
            name = "Magma Blast",
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            roles = {"healer"},
            lines = {"Inflicts 6000 Fire damage to an enemy."}
        }, {
            name = "Decimate",
            icon = "Interface\\Icons\\inv_hammer_unique_sulfuras",
            roles = {"healer", "tank"},
            lines = {"Increases a target's chance to be a victim of a critical strike by 100% for 20 sec."}
        }, {
            name = "Melt Weapon",
            icon = "Interface\\Icons\\spell_fire_meteorstorm",
            roles = {"melee"},
            lines = {"Decreases the weapons durability by 1 every X seconds. (% chance?)"}
        }, {
            name = "Fireboll Volley",
            icon = "Interface\\Icons\\spell_fire_flamebolt",
            roles = {"melee"},
            lines = {"Inflicts 1500 to 2050 Fire damage to all enemies."}
        }, {
            name = "Elemental Fire",
            icon = "Interface\\Icons\\spell_fire_flametounge",
            roles = {"melee"},
            lines = {""}
        }, {
            name = "Might of Ragnaros",
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            roles = {"melee"},
            lines = {""}
        }, {
            name = "Submerge",
            icon = "Interface\\Icons\\Spell_Fire_SealOfFire",
            warning = true,
            lines = {"Every 3 minutes Ragnaros submerges into the lava, becoming untargetable and summoning 8 Sons of Flame to attack the raid.",
                     "Ragnaros will resurface after 90 seconds or until all Sons of Flame are dead, whichever comes first.",
                     "Ragnaros heals 1% of his maximum health every 2 seconds while submerged."}
        }},
        adds = {{
            name = "Sons of Flame",
            icon = "Interface\\Icons\\Spell_Fire_Elemental_Totem",
            roles = {"tank", "dps"},
            color = "ffff4500",
            lines = {"Eight Sons of Flame emerge while Ragnaros is submerged and swarm the raid.",
                     "Tanks should pick these up quickly while the raid focuses them down before Ragnaros resurfaces."},
            abilities = {{
                name = "Melee Swing",
                icon = "Interface\\Icons\\Ability_MeleeDamage",
                roles = {"tank"},
                lines = {"Deals moderate melee damage; keep them controlled and away from squishy players."}
            }, {
                name = "Intense Heat",
                icon = "Interface\\Icons\\spell_fire_selfdestruct",
                lines = {"Mana burn nearby enemies? 2000 damage? (not confirmed)"}
            }}
        }}
    }}
}, {
    key = "BWL",
    name = "Blackwing Lair",
    expanded = false,
    bosses = {{
        key = "razorgore",
        name = "Razorgore the Untamed",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Razorgore",
        abilities = {{
            name = "Razorgore's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }, {
        key = "elementium_decapitator",
        name = "Elementium Decapitator Mk III",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\ElementiumDecapitator",
        abilities = {{
            name = "Elementium Decapitator Mk III's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }, {
        key = "broodlord",
        name = "Broodlord Lashlayer",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Broodlord",
        abilities = {{
            name = "Broodlord Lashlayer's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }, {
        key = "firemaw",
        name = "Firemaw",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Firemaw",
        abilities = {{
            name = "Firemaw's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }, {
        key = "krixix",
        name = "Master Elemental Shaper Krixix",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Krixix",
        abilities = {{
            name = "Master Elemental Shaper Krixix's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }, {
        key = "ebonroc",
        name = "Ebonroc",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Ebonroc",
        abilities = {{
            name = "Ebonroc's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }, {
        key = "flamegor",
        name = "Flamegor",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Flamegor",
        abilities = {{
            name = "Flamegor's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }, {
        key = "chromaggus",
        name = "Chromaggus",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Chromaggus",
        abilities = {{
            name = "Chromaggus' Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }, {
        key = "nefarian",
        name = "Neferian",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Neferian",
        abilities = {{
            name = "Neferian's Ability",
            icon = "Interface\\Icons\\temp",
            lines = {"Placeholder. Abilities not yet documented."}
        }}
    }}
}, {
    key = "SM",
    name = "Scarlet Monastery",
    expanded = false,
    bosses = {{
        key = "loksey",
        name = "Loksey",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Loksey",
        flags = {"tauntable"},
        abilities = {{
            name = "Aspect of the Monkey",
            icon = "Interface\\Icons\\ability_hunter_aspectofthemonkey",
            color = "ffa335ee",
            lines = {"Loksey has +25% dodge and melee critical strike chance. This effect is lost when Loksey is sleeping."}
        }, {
            name = "Bloodlust",
            icon = "Interface\\Icons\\spell_nature_bloodlust",
            roles = {"dispel"},
            color = "ffff7d0a",
            lines = {"Loksey gains +30% attack speed for 1 minute. Recast every 20s if removed."}
        }, {
            name = "Freezing Trap",
            icon = "Interface\\Icons\\spell_frost_chainsofice",
            warning = true,
            roles = {"rogue"},
            color = "ffff7d0a",
            lines = {"Loksey places a frost trap near/below a random player that freezes the first entity that approaches, preventing all action for 10 seconds. Trap will exist for 300 seconds until Disarmed. Triggers Deep Freeze to the target that gets frozen. His own dogs can trigger this trap."},
            abilities = {{
                name = "Deep Freeze",
                icon = "Interface\\Icons\\ability_mage_coldasice",
                warning = true,
                roles = {"healer"},
                color = "ffff7d0a",
                lines = {"The target becomes Frozen and being unable to take any actions and takes 20% health Frost damage per second for 10 seconds."}
            }}
        }, {
            name = "Tranquilizing Poison",
            icon = "Interface\\Icons\\spell_nature_slowpoison",
            roles = {"poison"},
            color = "ffff7d0a",
            lines = {"Loksey casts Tranquilizing Poison on a player who gains a Frenzy effect. It removes all Frenzy effects, reduces movement speed by 50% and drains 10 rage per second and prevents its generation.",
                     "After 5 seconds the player gets slept for 20 seconds."}
        }, {
            name = "Paralyzing Poison",
            icon = "Interface\\Icons\\ability_creature_poison_04",
            warning = true,
            roles = {"poison"},
            color = "ffff7d0a",
            lines = {"Loksey throws out a poison volley at all enemies. The poison inflicts X Nature damage every 2 sec (per stack?).",
                     "At 5 stacks it stuns the user for 10/11 seconds and removes all stacks."}
        }, {
            name = "Power Shot",
            icon = "Interface\\Icons\\inv_spear_07",
            warning = true,
            color = "ffff7d0a",
            lines = {"Loksey fires a powerful ranged shot dealing (Loksey weapon damage?)X damage that pierces through all enemies in its path, ignoring armor."}
        }, {
            name = "Scare Beast",
            icon = "Interface\\Icons\\ability_druid_cower",
            color = "ffff7d0a",
            lines = {"Loksey casts this whenever there is a 'beast' in the raid, fearing it for 8 seconds.",
                     "This can also fear his own dogs."}
        }, {
            name = "Summon Beast",
            icon = "Interface\\Icons\\ability_mount_whitedirewolf",
            color = "ffff7d0a",
            lines = {"Loksey summons a Scarlet Tracking Hound every 40? seconds to aid him in battle. This dog will not respawn if killed unlike his other dogs."}
        }},
        adds = {{
            name = "Scarlet Tracking Hound",
            icon = "Interface\\Icons\\temp",
            roles = {},
            color = "ffcc0000",
            lines = {"Four of these accompany Loksey into battle.",
                     "They respawn if killed."},
            abilities = {{
                name = "Infected Wound",
                icon = "Interface\\Icons\\spell_nature_nullifydisease",
                roles = {"dispel"},
                color = "ff00ccff",
                lines = {"Hounds apply a stacking debuff which increases physical damage taken by 3 per stack up to 99 stacks."}
            }}
        }}
    }, {
        key = "brigitte",
        name = "Brigitte Abbendis",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Brigitte",
        flags = {"tauntable"},
        -- NOTE: values from Spell.dbc (IDs 35848-35877). Percentages are the
        -- real $s values (DBC stores them as value-1). Phase 2 is the mounted
        -- phase - she summons the Scarlet Charger and swaps to its abilities.
        abilities = {{
            separator = true,
            name = "Phase 1"
        }, {
            name = "Command Gesture",
            icon = "Interface\\Icons\\Ability_Hunter_KillCommand",
            lines = {"Used at the pull while she is still at range. No damage or debuff recorded in logs - it appears to be the flavour cast before she closes to melee."}
        }, {
            name = "Righteous Charge",
            icon = "Interface\\Icons\\Ability_Warrior_VictoryRush",
            warning = true,
            roles = {"tank"},
            lines = {"Charges an enemy, inflicting normal damage plus 500 and stunning them."}
        }, {
            name = "Shield Bash",
            icon = "Interface\\Icons\\INV_Shield_05",
            warning = true,
            lines = {"Slams the target for up to 3160 damage and dispels one magic effect from them - your buffs will be stripped."}
        }, {
            name = "Consecration",
            icon = "Interface\\Icons\\Spell_Holy_InnerFire",
            lines = {"Consecrates the ground beneath her, dealing Holy damage every second to anyone standing in the area. Logs show 6-9 players ticking at once for up to 2290.",
                     "Move out of the patch rather than tanking the damage."}
        }, {
            name = "Provocation (taunt)",
            icon = "Interface\\Icons\\Ability_Warrior_InnerRage",
            lines = {"Forces all nearby enemies to attack her, overriding your current target."}
        }, {
            separator = true,
            name = "Phase 2"
        }, {
            name = "Fist of Justice",
            icon = "Interface\\Icons\\Spell_Holy_SealOfMight",
            warning = true,
            lines = {"Stuns nearby enemies. Marks the transition into her mounted phase."}
        }, {
            name = "Lay on Hands",
            icon = "Interface\\Icons\\Spell_Holy_LayOnHands",
            warning = true,
            roles = {"kick"},
            lines = {"Heals for an amount equal to her maximum health. Interrupt or stop this cast or the phase resets."}
        }, {
            name = "Scarlet Charger",
            icon = "Interface\\Icons\\mount_scarlet_charger",
            lines = {"She summons her mount, increasing her speed by 100%. This is what enables the charge and trample abilities below."}
        }, {
            name = "Stormbolt",
            icon = "Interface\\Icons\\Ability_ThunderClap",
            roles = {"healer"},
            lines = {"Hurls a hammer at an enemy for around 1900 Holy damage. Her most frequent phase 2 cast, seen hitting for 440-2560."}
        }, {
            name = "Hoof Kick",
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_05",
            warning = true,
            lines = {"Inflicts up to 1500 damage to enemies in a cone behind her and knocks them back. Do not stand behind the mount."}
        }, {
            name = "Trampling Charge",
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_05",
            warning = true,
            lines = {"Inflicts 1800 damage to enemies in a cone in front of her and knocks them back."}
        }, {
            name = "Crash",
            icon = "Interface\\Icons\\Ability_WarStomp",
            warning = true,
            lines = {"Inflicts 400% weapon damage to an already wounded enemy and stuns them."}
        }, {
            name = "Consecration (phase 2)",
            icon = "Interface\\Icons\\Spell_Holy_InnerFire",
            lines = {"The same ground-based Holy damage patch, still used while mounted."}
        }, {
            name = "Close Quarters Combat Experience",
            icon = "Interface\\Icons\\Ability_Warrior_OffensiveStance",
            warning = true,
            roles = {"tank"},
            lines = {"A buff she gains during the fight, increasing her Physical damage by 100% and attack speed by 100%.",
                     "Watch for this - tank damage taken roughly doubles while it is up."}
        }},
        adds = {{
            name = "Scarlet Sharpshooter",
            icon = "Interface\\Icons\\temp",
            color = "ffcc0000",
            lines = {"Four of these accompany Brigitte Abbendis into battle."},
            abilities = {{
                name = "Longshot",
                icon = "Interface\\Icons\\inv_spear_07",
                color = "ff00ccff",
                lines = {"Shoots an enemy, inflicting an additional 100 ranged damage and slowing its movement speed by 60% for 3 seconds."}
            }, {
                name = "Explosive Shot",
                icon = "Interface\\Icons\\inv_musket_03",
                color = "ff00ccff",
                lines = {"Inflicts X Fire damage and knocks the target back, applying Concussed, Dazed and Silenced."}
            }, {
                name = "Volley",
                icon = "Interface\\Icons\\ability_marksmanship",
                color = "ff00ccff",
                lines = {"Continuously fires a volley of ammo at the target area, inflicting 500 to 550 Arcane damage every second to enemies within 8 yards for 12 seconds."}
            }}
        }}
    }, {
        key = "vishas",
        name = "Vishas",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Vishas",
        -- NOTE: values below come from Spell.dbc (IDs 35880-35900). Percentages
        -- are the real $s values (DBC stores them as value-1) and tick rates are
        -- EffectAmplitude in milliseconds. Damage ranges seen in combat logs are
        -- noted where they add context.
        abilities = {{
            name = "Sear",
            icon = "Interface\\Icons\\Spell_Fire_FlameShock",
            roles = {"tank"},
            lines = {"Vishas' main attack on his current target - a Flame Lash for 550-650 Fire damage."}
        }, {
            name = "Shadow Word: Pain",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
            warning = true,
            roles = {"dispel"},
            lines = {"A raid-wide curse dealing 5% of a player's health every 3 seconds. Applied every 5-10 seconds."}
        }, {
            name = "Impending Sentence",
            icon = "Interface\\Icons\\Spell_Holy_RetributionAura",
            warning = true,
            lines = {"Every 15-20 seconds Vishas sentences a player and after 3 seconds Shared Sentence is applied to that player. Applied every 20 seconds."},
            abilities = {{
                name = "Shared Sentence",
                icon = "Interface\\Icons\\Spell_Holy_RighteousFury",
                warning = true,
                roles = {"healer"},
                lines = {"Deals ~2000-8000 damage. Pass it by touching another player. Reflectable.",
                         "If passed EARLY (High time): HIGH damage to YOU / LOW damage to ALLY.",
                         "If passed LATE (Low time): LOW damage to YOU / HIGH damage to ALLY.",
                         "If NOT passed (0s left): YOU take MAX damage (8000)."},
                abilities = {{
                    name = "Recidivism",
                    icon = "Interface\\Icons\\Spell_Holy_FistOfJustice",
                    lines = {"Increase damage taken from Shared Sentence by 50%. Acquired by being dealt damage by Shared Sentence. Stacks up to 10. Lasts for 30 seconds."}
                }}
            }}
        }, {
            name = "Atonement",
            icon = "Interface\\Icons\\INV_Belt_18",
            warning = true,
            roles = {"healer"},
            lines = {"Teleports a raid member to one of three 'sacrifice' benches and stuns them, dealing 20% of their health every 2 seconds for 12 seconds. Applied every 20 seconds."}
        }, {
            name = "Ordeal Grip",
            icon = "Interface\\Icons\\INV_Gauntlets_04",
            roles = {"dispel"},
            lines = {"Slows movement by 60% and increases all damage taken by 50%. Lasts 8 seconds.",
                     "Can be reflected back onto Vishas? Applied every 12-15 seconds."}
        }, {
            name = "Pummel",
            icon = "Interface\\Icons\\INV_Gauntlets_04",
            lines = {"Pummel the target for 1150 to 1450 damage. It also interrupts spellcasting and prevents any spell in that school from being cast for 5 seconds."}
        }}
    }, {
        key = "herod",
        name = "Herod",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Herod",
        flags = {"notalwaystauntable"},
        abilities = {{
            name = "Rushing Charge",
            icon = "Interface\\Icons\\ability_warstomp",
            lines = {"At the start of the fight and after each Bladestorm, Herod charges towards the highest threat target.",
                     "Increasing his movement speed by 50% for 4 sec. and causes it to inflict an additional 1? damage on its first attack."}
        }, {
            name = "Deep Wound",
            icon = "Interface\\Icons\\ability_backstab",
            lines = {"Bleeding for 10% health damage every 3 sec. Healing effects reduced by 10%. Lasts for 21 seconds. Stacks up to 5 times."}
        }, {
            name = "Cleaving Blow",
            icon = "Interface\\Icons\\ability_warrior_cleave",
            roles = {"melee"},
            lines = {"Herod sometimes cleaves in a 90 degree frontal arc."}
        }, {
            name = "Wound",
            icon = "Interface\\Icons\\ability_backstab",
            lines = {"Bleeding for 550 damage every 3 sec. Lasts 21 seconds."}
        }, {
            name = "Echo Clap",
            icon = "Interface\\Icons\\spell_nature_thunderclap",
            warning = true,
            lines = {"Herod interrupts all cast casting within 30? yards every ~10 seconds and prevent spells cast from that school for 5 seconds. Also dealing 300-500 damage."}
        }, {
            name = "Death Wish",
            icon = "Interface\\Icons\\spell_shadow_deathpact",
            lines = {"After 3 minutes Herod cast Death Wish Increasing his attack speed by 50% and crit chance by 15% for 3 min, but also taking 15% more damage."}
        }, {
            name = "Bladestorm",
            icon = "Interface\\Icons\\ability_whirlwind",
            warning = true,
            lines = {"Attacks nearby enemies in a whirlwind of steel that lasts 10 sec., inflicting 50%? weapon damage every 0.5 sec. Herod is immune during this time."}
        }, {
            name = "Blades of Light",
            icon = "Interface\\Icons\\ability_whirlwind",
            lines = {"Every 10-15 seconds Herod yells 'Blades of Light' and after 2 seconds deals 125% weapon damage (and a bleed?) to all enemies within 8 yards."}
        }, {
            name = "Enrage",
            icon = "Interface\\Icons\\spell_shadow_unholyfrenzy",
            lines = {"Frenzy effect. Melee damage increased by 5%. Stacks to 20."}
        }, {
            name = "Demoralized",
            icon = "Interface\\Icons\\spell_shadow_deathscream",
            warning = true,
            lines = {"Reduces damage and healing done by 10% for 1 minute. Triggers Cowardice at 5 stacks.",
                     "Stacks are removable by doing 4000? damage within 5? seconds."},
            abilities = {{
                name = "Cowardice",
                icon = "Interface\\Icons\\ability_cheapshot",
                lines = {"Feared for 8 seconds and gains aggro of the boss during that time. Boss also becomes untauntable?"}
            }}
        }}
    }, {
        key = "brother_michael",
        name = "Brother Michael",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\BrotherMichael",
        -- NOTE: values from Spell.dbc (IDs 35940-35951). Percentages are the
        -- real $s values (DBC stores them as value-1).
        abilities = {{
            name = "Curse of Thorns",
            icon = "Interface\\Icons\\Spell_Shadow_AntiShadow",
            warning = true,
            roles = {"decurse"},
            lines = {"The target takes back a portion of the damage they deal. Decurse it or stop attacking until it is removed."}
        }, {
            name = "Thorned Roots",
            icon = "Interface\\Icons\\Spell_Nature_StrangleVines",
            warning = true,
            roles = {"healer"},
            lines = {"Roots a player and deals 20% of their maximum health as Nature damage every second.",
                     "When the roots collapse, thorns explode outward from the target - spread out before that happens."}
        }, {
            name = "Fists of Fire",
            icon = "Interface\\Icons\\Spell_Fire_Immolation",
            roles = {"tank"},
            lines = {"90% of Brother Michael's Physical damage becomes Fire damage, so armour stops mitigating most of his melee."}
        }, {
            name = "Four Finger Death Punch",
            icon = "Interface\\Icons\\Spell_Shadow_CorpseExplode",
            warning = true,
            lines = {"Inflicts one of four wounds on the target. Taking all four hits causes the victim's heart to explode."}
        }, {
            name = "Soulbind",
            icon = "Interface\\Icons\\Spell_Shadow_Haunting",
            lines = {"Splits 20% of the damage Brother Michael takes onto the bound player."}
        }, {
            name = "Grip Break",
            icon = "Interface\\Icons\\Ability_Warrior_Disarm",
            roles = {"tank"},
            lines = {"Disarms the target."}
        }, {
            name = "Kick",
            icon = "Interface\\Icons\\Ability_Kick",
            lines = {"Interrupts the target's spellcast."}
        }}
    }, {
        key = "doan",
        name = "Doan",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Doan",
        -- NOTE: values from Spell.dbc (IDs 35954-35989). Percentages are the
        -- real $s values (DBC stores them as value-1).
        abilities = {{
            name = "Arcane Pulse",
            icon = "Interface\\Icons\\Spell_Arcane_ArcaneResilience",
            warning = true,
            lines = {"Doan's most frequent ability - pulses the raid for 100 Arcane damage and interrupts spellcasting, locking that school for a few seconds.",
                     "Logs show 8-12 players hit at once, so casters should expect regular lockouts."}
        }, {
            name = "Arcanebolt",
            icon = "Interface\\Icons\\Spell_Nature_StarFall",
            lines = {"Blasts an enemy for 1040 Arcane damage."}
        }, {
            name = "Flamebolt",
            icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
            lines = {"Hurls a fiery ball for 5750 Fire damage plus 250 Fire damage every 0.5 seconds afterwards."}
        }, {
            name = "Flamestrike",
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            warning = true,
            lines = {"Calls down a pillar of fire for 1555 Fire damage, then 575 Fire damage every second to anyone standing in it. Move out."}
        }, {
            name = "Dragon Breath",
            icon = "Interface\\Icons\\Spell_Fire_Fire",
            warning = true,
            roles = {"tank"},
            lines = {"Inflicts 1850 Fire damage in a cone in front of Doan. Keep him faced away from the raid."}
        }, {
            name = "Ice Blast",
            icon = "Interface\\Icons\\Spell_Frost_Glacier",
            warning = true,
            roles = {"healer"},
            lines = {"Deals 15% of the target's health every second while it lasts."}
        }, {
            name = "Searing Heat",
            icon = "Interface\\Icons\\Spell_Fire_Incinerate",
            lines = {"Continually inflicts Fire damage on the raid."}
        }}
    }, {
        key = "renault_mograine_sally_whitemane",
        name = "Renault Mograine & Sally Whitemane",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\RenaultMograineSallyWhitemane",
        -- NOTE: values from Spell.dbc (IDs 33456-36021). Percentages are the
        -- real $s values (DBC stores them as value-1).
        abilities = {{
            separator = true,
            name = "Renault Mograine"
        }, {
            name = "Eye for an Eye",
            icon = "Interface\\Icons\\Spell_Holy_EyeforanEye",
            warning = true,
            lines = {"Mograine's signature effect and by far his most common log entry - a portion of the damage dealt to him is reflected back at the attacker."}
        }, {
            name = "Crusader Strike",
            icon = "Interface\\Icons\\Spell_Holy_CrusaderStrike2",
            roles = {"tank"},
            lines = {"A weapon strike that also increases his attack speed."}
        }, {
            name = "Searing Light",
            icon = "Interface\\Icons\\Spell_Holy_ReviveChampion",
            lines = {"Increases Holy damage dealt but reduces healing done."}
        }, {
            separator = true,
            name = "Sally Whitemane"
        }, {
            name = "Scarlet Resurrection",
            icon = "Interface\\Icons\\Spell_Holy_RighteousFury",
            warning = true,
            lines = {"When Mograine dies, Whitemane resurrects him and the fight continues. Interrupting or racing this cast is the core of the encounter."}
        }, {
            name = "Holy Smite",
            icon = "Interface\\Icons\\Spell_Holy_HolySmite",
            roles = {"kick"},
            lines = {"Whitemane's main cast, smiting a target for 2730 Holy damage."}
        }, {
            name = "Holy Fire",
            icon = "Interface\\Icons\\Spell_Holy_SearingLight",
            warning = true,
            roles = {"kick"},
            lines = {"Inflicts 1275 Holy damage plus 830 Holy damage every 3 seconds, and dispels a beneficial effect from the target on each tick."}
        }, {
            name = "Absolution",
            icon = "Interface\\Icons\\Spell_Holy_RighteousFury",
            warning = true,
            roles = {"kick"},
            lines = {"A heavy Holy nuke for 4000 damage."}
        }, {
            name = "Heal",
            icon = "Interface\\Icons\\Spell_Holy_Heal",
            roles = {"kick"},
            lines = {"Whitemane heals herself or Mograine. Interrupt it where possible."}
        }, {
            name = "Dispel Magic",
            icon = "Interface\\Icons\\Spell_Holy_DispelMagic",
            lines = {"Whitemane repeatedly dispels magic from herself and Mograine, removing your debuffs."}
        }, {
            name = "Power Word: Shield",
            icon = "Interface\\Icons\\Spell_Holy_PowerWordShield",
            lines = {"Shields herself, absorbing incoming damage."}
        }}
    }, {
        key = "fairbanks",
        name = "Fairbanks",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Fairbanks",
        -- NOTE: values from Spell.dbc (IDs 36024-36213). Percentages are the
        -- real $s values (DBC stores them as value-1).
        abilities = {{
            name = "Stomp",
            icon = "Interface\\Icons\\Ability_Kick",
            warning = true,
            lines = {"Fairbanks' most frequent ability - stomps the ground, damaging everyone nearby and interrupting spellcasting, locking that school for a few seconds.",
                     "Logs show 7-12 players hit at once."}
        }, {
            name = "Bile Vomit",
            icon = "Interface\\Icons\\Spell_Shadow_PlagueCloud",
            warning = true,
            roles = {"tank"},
            lines = {"Shoots a cloud of bile in a cone in front of him, reducing armour by 650 and inflicting Nature damage every 5 seconds.",
                     "Keep him faced away from the raid."}
        }, {
            name = "Claustrophobia",
            icon = "Interface\\Icons\\temp",
            warning = true,
            lines = {"The walls press inward, increasing the damage and radius of Stomp. Rarely seen in logs - likely a soft enrage."}
        }}
    }}
}}

-- Setup accordion initial states
for _, raid in ipairs(RAIDS) do
    for _, boss in ipairs(raid.bosses) do
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
local activeTab = "abilities"
local abilityRowPool = {}

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

local navExplaination = CreateFrame("Button", "DungeonJournalNavExplaination", frame)
navExplaination:SetWidth(130)
navExplaination:SetHeight(NAV_BAR_HEIGHT)
navExplaination:SetPoint("LEFT", navBosses, "RIGHT", 6, 0)
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
-- CHANGED: SelectView() toggles between the "Bosses" view (tree + boss
-- detail, the window's original content) and the new "Explaination" view.
------------------------------------------------------------
local function SelectView(view)
    currentView = view

    if view == "bosses" then
        navBosses:SetBackdropColor(0, 0, 0, 0.8)
        navBosses:SetBackdropBorderColor(1, 0.82, 0, 1)
        navBossesText:SetTextColor(1, 0.82, 0)

        navExplaination:SetBackdropColor(0, 0, 0, 0.5)
        navExplaination:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.5)
        navExplainationText:SetTextColor(0.8, 0.8, 0.8)

        ExplainationHeader:Hide()
        ExplainationScrollFrame:Hide()

        scrollFrame:Show()
        vSeparator:Show()
        portrait:Show()
        bossNameText:Show()
        abilitiesHeader:Show()
        abilityScrollFrame:Show()
        RebuildBossFlags(currentBoss) -- CHANGED: re-show the flag icon row for the current boss
        if currentBoss and currentBoss.adds and table.getn(currentBoss.adds) > 0 then
            tabAbilities:Show()
            tabAdds:Show()
        end
    else
        navExplaination:SetBackdropColor(0, 0, 0, 0.8)
        navExplaination:SetBackdropBorderColor(1, 0.82, 0, 1)
        navExplainationText:SetTextColor(1, 0.82, 0)

        navBosses:SetBackdropColor(0, 0, 0, 0.5)
        navBosses:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.5)
        navBossesText:SetTextColor(0.8, 0.8, 0.8)

        scrollFrame:Hide()
        vSeparator:Hide()
        portrait:Hide()
        bossNameText:Hide()
        abilitiesHeader:Hide()
        abilityScrollFrame:Hide()
        tabAbilities:Hide()
        tabAdds:Hide()
        RebuildBossFlags(nil) -- CHANGED: clear the flag icon row while on the Explanation view

        ExplainationHeader:Show()
        ExplainationScrollFrame:Show()
        RebuildExplainationList()
    end
end

navBosses:SetScript("OnClick", function() SelectView("bosses") end)
navExplaination:SetScript("OnClick", function() SelectView("Explaination") end)

SelectView("bosses")

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
        RebuildAbilityList(currentBoss)
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
        RebuildAbilityList(currentBoss)
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

    if boss.adds and table.getn(boss.adds) > 0 then
        tabAbilities:Show()
        tabAdds:Show()
        SelectTab("abilities")
    else
        tabAbilities:Hide()
        tabAdds:Hide()
        SelectTab("abilities")
    end

    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99DungeonJournal:|r Selected " .. boss.name)
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
                table.insert(entries, { entryType = "boss", raid = raid, boss = boss })
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
        else
            ShowBossInfo(entry.boss)
        end
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
        else
            btn.label:SetText(entry.boss.name)
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