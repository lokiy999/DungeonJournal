-- Part of the DungeonJournal RAIDS database (see AGENTS.md "Data model").
-- Loaded via DungeonJournal.toc before DungeonJournal.lua; appends this
-- raid's table to the shared DungeonJournal_Raids list in load order.

DungeonJournal_Raids = DungeonJournal_Raids or {}

------------------------------------------------------------
-- MC order lists - START HERE to reorder/regroup content.
--
-- MC_BOSS_ORDER and MC_TRASH_ORDER are the only two things you should
-- need to touch to change what order bosses/trash appear in their tabs,
-- or which packs are grouped under which separator. Each is just a flat
-- list of keys (+ separator markers for trash) - actual boss/mob data
-- (icon/flags/stats/abilities) lives further down in MC_BOSSES and
-- MC_TRASH_MOBS, defined once per key and looked up from here.
------------------------------------------------------------

-- Boss encounter order (Bosses tab tree, top to bottom).
local MC_BOSS_ORDER = {
    "lucifron",
    "magmadar",
    "gehennas",
    "garr",
    "baron_geddon",
    "shazzrah",
    "golemagg",
    "sulfuron",
    "majordomo",
    "ragnaros",
}

-- Trash pull order (Trash tab tree): separators + mob keys, in tree
-- order. A plain string is a mob key with no count shown; a table
-- { key = ..., count = ... } shows a count for that occurrence. There is
-- deliberately no separate counts table - every count lives right here,
-- next to the pack it belongs to, even when the same mob's count repeats
-- across several occurrences.
local MC_TRASH_ORDER = {
    "molten_giant",
    "molten_destroyer",
    "flameguard",
    "firelord",
    "core_hound",
    "ancient_core_hound",
    "lava_surger",
    "lava_elemental",
    "lava_reaver",
    "lava_annihilator",
    "flame_imp",
    "firewalker",
}

------------------------------------------------------------
-- Boss registry - one entry per boss (icon/flags/stats/abilities/adds),
-- referenced by key from MC_BOSS_ORDER above. Defined once each; add a
-- new boss here and add its key to MC_BOSS_ORDER to place it.
------------------------------------------------------------
local MC_BOSSES = {
    lucifron = {
        name = "Lucifron",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Lucifron",
        flags = {"tauntable", "damage_fire"}, -- CHANGED: demo of the new boss flag icons
        stats = {armor = 5120, fire = 293, nature = 98, frost = 98, shadow = 186, arcane = 68},
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
            lines = {"Two of these accompany Lucifron into battle."},
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
    },

    magmadar = {
        name = "Magmadar",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Magmadar",
        flags = {"tauntable", "damage_fire"},
        stats = {armor = 5780, fire = 327, nature = 98, frost = 88, shadow = 85, arcane = 55},
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
    },

    gehennas = {
        name = "Gehennas",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Gehennas",
        flags = {"tauntable"},
        stats = {armor = 5120, fire = 256, nature = 88, frost = 88, shadow = 98, arcane = 68},
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
            lines = {"Two of these accompany Gehennas into battle."},
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
    },

    garr = {
        name = "Garr",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Garr",
        flags = {"tauntable"},
        stats = {armor = 8280, fire = 168, nature = 128, frost = 82, shadow = 82, arcane = 62},
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
                icon = "Interface\\Icons\\spell_fire_fire",
                roles = {"tank", "dps"},
                warning = true,
                lines = {"Explodes on death dealing X Fire damage and heavy knockback to nearby players."}
            }, {
                name = "Immolate",
                icon = "Interface\\Icons\\spell_fire_immolation",
                lines = {"Inflicts 760 to 840 Fire damage to an enemy and scorches it for an additional 680 to 720 damage every 3 sec. for 21 sec."}
            }, {
                name = "Separation Anxiety",
                icon = "Interface\\Icons\\spell_fire_volcano",
                lines = {"Firesworn will deal 300% additional damage if more than X yards away from Garr."}
            }}
        }}
    },

    baron_geddon = {
        name = "Baron Geddon",
        flags = {"tauntable"},
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\BaronGeddon",
        stats = {armor = 4922, fire = "immune", nature = 86, frost = 66, shadow = 84, arcane = 34},
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
    },

    shazzrah = {
        name = "Shazzrah",
        flags = {"tauntable"},
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Shazzrah",
        stats = {armor = 4800, fire = 203, nature = 124, frost = 124, shadow = 124, arcane = 344},
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
    },

    golemagg = {
        name = "Golemagg the Incinerator",
        flags = {"nottauntable"},
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Golemagg",
        stats = {armor = 6200, fire = 422, nature = 137, frost = 98, shadow = 88, arcane = 48},
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
    },

    sulfuron = {
        name = "Sulfuron Harbinger",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Sulfuron",
        flags = {"tauntable"},
        stats = {armor = 5480, fire = 317, nature = 109, frost = 109, shadow = 109, arcane = 69},
        -- NOTE: Sulfuron rotates between three warrior stances, each with its
        -- own abilities. Shared abilities are listed under "All Stances".
        abilities = {{
            separator = true,
            name = "All Stances"
        }, {
            name = "Inspire",
            icon = "Interface\\Icons\\Ability_Warrior_OffensiveStance",
            roles = {"tank"},
            lines = {"Increases the Physical damage dealt by an ally by 50% and speeds its attacks by 100% for 10 sec. 45y range."}
        }, {
            name = "Drain Life",
            icon = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
            roles = {"tank"},
            lines = {"Steals 2000 to 3000 life from target enemy. Shadow damage ability."}
        }, {
            name = "Dark Strike",
            icon = "Interface\\Icons\\Ability_ThunderBolt",
            roles = {"tank"},
            lines = {"Consecrates the caster's weapon, inflicting 570 to 630 additional damage on its next attack. All damage caused is considered Shadow damage."}
        }, {
            name = "Flame Spear",
            icon = "Interface\\Icons\\Ability_Throw",
            lines = {"Tosses a spear of flame, inflicting 1850 to 2450 Fire damage to an enemy, as well as scorching any other enemies in the vicinity of the target."}
        }, {
            separator = true,
            name = "Battle Stance"
        }, {
            name = "Rend",
            icon = "Interface\\Icons\\Ability_Gouge",
            lines = {"Inflicts 75 Physical damage every 3 seconds for 15 seconds. Also reduces healing effects by 1%."}
        }, {
            name = "Retaliation",
            icon = "Interface\\Icons\\Ability_Warrior_Challange",
            warning = true,
            roles = {"melee"},
            lines = {"Instantly counterattacks any enemy that strikes him in melee for 15 seconds."}
        }, {
            name = "Unbalancing Strike",
            icon = "Interface\\Icons\\Ability_Warrior_DecisiveStrike",
            warning = true,
            roles = {"tank"},
            lines = {"Inflicts 350% weapon damage and leaves the target unbalanced, reducing their defense skill by 100 for 6 sec."}
        }, {
            separator = true,
            name = "Defensive Stance"
        }, {
            name = "War Stomp",
            icon = "Interface\\Icons\\Ability_BullRush",
            warning = true,
            roles = {"melee"},
            lines = {"Inflicts normal damage plus 936 to 1064 to nearby enemies and stuns them for 5 seconds."}
        }, {
            name = "Shield Wall",
            icon = "Interface\\Icons\\Ability_Warrior_ShieldWall",
            warning = true,
            lines = {"Reduces Physical and magical damage taken by 75% for 20 seconds."}
        }, {
            name = "Sunder Armor",
            icon = "Interface\\Icons\\Ability_Warrior_Sunder",
            roles = {"tank"},
            lines = {"Reduces the target's armor by 1000 per stack. Can be applied up to 5 times, lasting 30 seconds."}
        }, {
            separator = true,
            name = "Berserker Stance"
        }, {
            name = "Flame Charge",
            icon = "Interface\\Icons\\Ability_Warrior_Charge",
            warning = true,
            roles = {"tank"},
            lines = {"Charges at an enemy, knocking them back and inflicting normal damage plus 300."}
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
                lines = {"Shields an ally, absorbing X damage."}
            }, {
                name = "Greater Heal",
                icon = "Interface\\Icons\\Spell_Holy_GreaterHeal",
                warning = true,
                roles = {"kick"},
                lines = {"Heals an ally for X."}
            }}
        }}
    },

    majordomo = {
        name = "Majordomo",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Majordomo",
        flags = {"tauntable"},
        stats = {armor = 4500, fire = 300, nature = 87, frost = 87, shadow = 87, arcane = 100},
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
            lines = {"Four of these accompany Gehennas into battle."},
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
                roles = {"kick"},
                icon = "Interface\\Icons\\spell_shadow_chilltouch",
                lines = {"Uses dark magic to heal an ally for 127750 to 142250 damage."}
            }}
        }, {
            name = "Flamewaker Elite",
            icon = "Interface\\Icons\\temp",
            roles = {"dps", "dispel"},
            color = "ffffaa00",
            lines = {"Four of these accompany Gehennas into battle."},
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
    },

    ragnaros = {
        name = "Ragnaros",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Ragnaros",
        flags = {"tauntable"},
        stats = {armor = 5350, fire = "immune", nature = 83, frost = 83, shadow = 83, arcane = 68},
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
        }, {
            name = "Intense Heat",
            icon = "Interface\\Icons\\spell_fire_fire",
            warning = true,
            lines = {"Deals 1500-2000 damage to enemies? unknown when"}
        }},
        adds = {{
            name = "Son of Flame",
            icon = "Interface\\Icons\\Spell_Fire_Elemental_Totem",
            roles = {"tank", "dps"},
            color = "ffff4500",
            lines = {"Eight Sons of Flame emerge while Ragnaros is submerged and swarm the raid."},
            abilities = {{
                name = "Lava Shield",
                icon = "Interface\\Icons\\spell_fire_immolation",
                warning = true,
                lines = {"Burns 250 to 350 mana of nearby enemies, and half of the mana burned is dealt as fire damage."}
            }}
        }}
    },
}

------------------------------------------------------------
-- Trash mob registry - one entry per distinct trash mob (icon/flags/
-- stats/abilities), referenced by key from MC_TRASH_ORDER above.
------------------------------------------------------------
local MC_TRASH_MOBS = {
    molten_giant = {
        name = "Molten Giant",
        icon = "Interface\\Icons\\INV_Misc_MonsterClaw_04",
        flags = {"melee"},
        stats = {armor = 4200, fire = 60, nature = 60, frost = 60, shadow = 60, arcane = 60},
        abilities = {{
            -- CHANGED: confirmed via testing - plus 100.
            name = "Knock Away",
            icon = "Interface\\Icons\\INV_Gauntlets_05",
            roles = {"tank"},
            lines = {"Inflicts normal damage plus 100 to an enemy and knocks it back."}
        }, {
            -- CHANGED: confirmed via testing - 1410 to 1890 damage.
            name = "Smash",
            icon = "Interface\\Icons\\Ability_ThunderBolt",
            warning = true,
            lines = {"Smashes the ground, inflicting 1410 to 1890 damage to nearby enemies."}
        }}
    },

    molten_destroyer = {
        name = "Molten Destroyer",
        icon = "Interface\\Icons\\Ability_Smash",
        flags = {"melee"},
        stats = {armor = 4200, fire = 60, nature = 60, frost = 60, shadow = 60, arcane = 60},
        abilities = {{
            -- CHANGED: confirmed via testing - 8000 to 10000 damage.
            name = "Hateful Strike",
            icon = "Interface\\Icons\\Temp",
            warning = true,
            roles = {"tank", "healer"},
            lines = {"Inflicts 8000 to 10000 damage to target - whichever raid member holds second-highest threat, not necessarily the tank."}
        }, {
            -- CHANGED: confirmed via testing - 900 to 1100 damage, 2 second interrupt.
            name = "Massive Tremor",
            icon = "Interface\\Icons\\Ability_Smash",
            warning = true,
            lines = {"Causes a massive ground tremor, inflicting 900 to 1100 damage to nearby enemies and interrupting any spell being cast for 2 seconds."}
        }, {
            -- CHANGED: confirmed via testing - exact numbers/duration.
            name = "Pyroblast",
            icon = "Interface\\Icons\\Spell_Fire_Fireball02",
            warning = true,
            lines = {"Inflicts 3588 to 4512 Fire damage to an enemy and scorches the target for an additional 474 damage every 2 sec. for 12 sec."}
        }}
    },

    flameguard = {
        name = "Flameguard",
        icon = "Interface\\Icons\\Spell_Fire_FireArmor",
        flags = {"melee"},
        -- CHANGED: stats not tested - "X" marks each unknown value rather
        -- than guessing a number.
        stats = {armor = "X", fire = "X", nature = "X", frost = "X", shadow = "X", arcane = "X"},
        abilities = {{
            -- CHANGED: confirmed via testing - 2388 to 3812 damage.
            name = "Cone of Fire",
            icon = "Interface\\Icons\\Spell_Fire_WindsofWoe",
            warning = true,
            lines = {"Inflicts 2388 to 3812 Fire damage to enemies in a cone in front of the caster. Face away from the raid."}
        }, {
            -- CHANGED: confirmed via testing - 2000 armor, 1 min.
            name = "Melt Armor",
            icon = "Interface\\Icons\\Spell_Fire_Immolation",
            warning = true,
            lines = {"Reduces the armor of nearby enemies by 2000 for 1 min."}
        }, {
            -- CHANGED: confirmed via testing - 30 sec DoT and stun.
            name = "Fire Prison",
            icon = "Interface\\Icons\\INV_Ammo_FireTar",
            warning = true,
            lines = {"Imprisons an enemy. DoT and stun for 30 sec."}
        }}
    },

    firelord = {
        name = "Firelord",
        icon = "Interface\\Icons\\Spell_Fire_Elemental_Totem",
        flags = {"caster"},
        stats = {armor = 3600, fire = "immune", nature = 60, frost = 60, shadow = 60, arcane = 60},
        abilities = {{
            -- CHANGED: confirmed via testing - 6000 damage over 16 sec, -75%.
            name = "Soul Burn",
            icon = "Interface\\Icons\\Spell_Fire_SoulBurn",
            warning = true,
            lines = {"Inflicts 6000 Fire damage to an enemy over 16 seconds, preventing it from casting spells and reducing the Physical damage it deals by 75%."}
        }, {
            -- CHANGED: no usable Description_enUS match in Spell.xlsx for
            -- this "Incinerate" (only unrelated talent-passive entries) -
            -- text below is a guess, icon reused from the thematically
            -- matching Spell_Fire_Incinerate.
            name = "Incinerate",
            icon = "Interface\\Icons\\Spell_Fire_Incinerate",
            warning = true,
            lines = {"Burns the target for X Fire damage."}
        }, {
            -- CHANGED: confirmed via testing - 7000 damage over 10 sec,
            -- 500 splash, first applied 15 sec into the fight then every
            -- 12-15 sec afterward.
            name = "Conflagration",
            icon = "Interface\\Icons\\Spell_Fire_Incinerate",
            warning = true,
            lines = {"Sets an enemy aflame, inflicting 7000 Fire damage over 10 seconds and sending it into a state of panic. While affected, the flames periodically scorch nearby allies for 500 damage as well. First applied 15 seconds into the fight, then every 12 to 15 seconds afterward."}
        }, {
            -- CHANGED: confirmed via testing - first cast ~5 sec into the
            -- fight, repeating every 15 sec.
            name = "Spawn Lava Spawn",
            icon = "Interface\\Icons\\Spell_Shadow_SealOfKings",
            warning = true,
            lines = {"Summons a Lava Spawn to aid it in battle. First cast about 5 seconds into the fight, repeating every 15 seconds."},
            abilities = {{
                name = "Fireball",
                icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
                warning = true,
                roles = {"kick"},
                lines = {"Hurls a fiery ball that causes X Fire damage and an additional X Fire damage over X seconds."}
            }, {
                name = "Split",
                icon = "Interface\\Icons\\Spell_Shadow_SealOfKings",
                warning = true,
                lines = {"The Lava Spawn splits into two, each inheriting a portion of its remaining health."}
            }}
        }}
    },

    core_hound = {
        name = "Core Hound",
        icon = "Interface\\Icons\\Ability_Hunter_Pet_Wolf",
        flags = {"melee"},
        stats = {armor = 3400, fire = "immune", nature = 50, frost = 50, shadow = 50, arcane = 50},
        abilities = {{
            name = "Lava Breath",
            icon = "Interface\\Icons\\Spell_Fire_WindsofWoe",
            warning = true,
            lines = {"Inflicts 1557 to 2043 Fire damage to enemies in front of the caster."}
        }, {
            name = "Serrated Bite",
            icon = "Interface\\Icons\\Ability_Gouge",
            lines = {"Inflicts 1500 Physical damage to an enemy over 30 seconds. Stacks to 50."}
        }, {
            name = "Piercing Howl",
            icon = "Interface\\Icons\\Ability_Druid_ChallangingRoar",
            lines = {"Causes all enemies near the hound to be dazed for 20 seconds."}
        }}
    },

    ancient_core_hound = {
        name = "Ancient Core Hound",
        icon = "Interface\\Icons\\Ability_Hunter_Pet_Wolf",
        flags = {"melee"},
        stats = {armor = 3800, fire = "immune", nature = 60, frost = 60, shadow = 60, arcane = 60},
        abilities = {{
            name = "Vicious Bite",
            icon = "Interface\\Icons\\Ability_Racial_Cannibalize",
            lines = {"Bites an enemy, inflicting (weapon damage) Physical damage."}
        }, {
            name = "Cone of Fire",
            icon = "Interface\\Icons\\Spell_Fire_WindsofWoe",
            warning = true,
            lines = {"Inflicts 2388 to 3812 Fire damage to enemies in a cone in front of the caster."}
        }, {
            name = "Serrated Bite",
            icon = "Interface\\Icons\\Ability_Gouge",
            roles = {"tank"},
            lines = {"Inflicts 1500 Physical damage to an enemy over 30 seconds. Stacks to 50."}
        }, {
            separator = true,
            name = "One of Five (fixed per hound)",
        }, {
            name = "Withering Heat",
            icon = "Interface\\Icons\\Spell_Fire_Fire",
            roles = {"dispel"},
            lines = {"Maximum health reduced by 40%. Taking 1% health damage every 1 sec. Stuns and deals heavy damage over 5 seconds on dispel. Each hound only ever casts one of these five abilities, recasting it if not killed in time."}
        }, {
            name = "Ground Stomp",
            icon = "Interface\\Icons\\temp",
            lines = {"Stomps the ground, stunning enemies within 30 yards for 8 seconds. Each hound only ever casts one of these five abilities, recasting it if not killed in time."}
        }, {
            name = "Ancient Dread",
            icon = "Interface\\Icons\\temp",
            roles = {"decurse"},
            lines = {"Attack and casting speed reduced by 100%. Fears on dispel. Each hound only ever casts one of these five abilities, recasting it if not killed in time."}
        }, {
            name = "Cauterizing Flames",
            icon = "Interface\\Icons\\Spell_Fire_Volcano",
            roles = {"dispel"},
            lines = {"Increases Fire damage taken by 50%. Deals 350 to 2075 damage to nearby allies on dispel. Each hound only ever casts one of these five abilities, recasting it if not killed in time."}
        }, {
            name = "Ancient Dispair",
            icon = "Interface\\Icons\\Spell_Fire_Volcano",
            roles = {"dispel"},
            lines = {"Disorients enemies within 45 yards, causing them to stop attacking their targets and wander around for 15 seconds. Each hound only ever casts one of these five abilities, recasting it if not killed in time."}
        }}
    },

    lava_surger = {
        name = "Lava Surger",
        icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
        flags = {"melee"},
        stats = {armor = 3000, fire = "immune", nature = 60, frost = 60, shadow = 60, arcane = 60},
        abilities = {{
            -- CHANGED: confirmed via testing - 500-800 initial hit 10-15 sec
            -- into the fight, plus 3600 over 8 sec.
            name = "Magma Strike",
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            warning = true,
            lines = {"Calls down a pillar of fire 10 to 15 seconds into the fight, burning all enemies within the area for 500 to 800 Fire damage and an additional 3600 Fire damage over 8 seconds."}
        }, {
            -- CHANGED: confirmed via testing - casts at the start of the
            -- fight against the closest enemy, 2000-3000 damage. Only
            -- triggers if an enemy is 10 to 45 yards away.
            name = "Surge",
            icon = "Interface\\Icons\\Ability_Warrior_Charge",
            warning = true,
            lines = {"Charges the closest enemy at the start of the fight, inflicting 2000 to 3000 damage to the target and any of its nearby allies, as well as knocking them all back. Only triggers if an enemy is 10 to 45 yards away."}
        }, {
            -- CHANGED: same ability name as Garr's (see the Garr boss
            -- entry), but confirmed via testing to slow by a different
            -- amount here (40% vs Garr's 60%) - not a copy-paste error.
            name = "Magma Shackles",
            icon = "Interface\\Icons\\spell_nature_earthbind",
            lines = {"Reduces the movement speed of nearby enemies by 40% for 15 seconds."}
        }}
    },

    lava_elemental = {
        name = "Lava Elemental",
        icon = "Interface\\Icons\\Spell_Fire_Fireball02",
        -- CHANGED: confirmed via testing - not tauntable.
        flags = {"nottauntable"},
        stats = {armor = 3600, fire = "immune", nature = 55, frost = 55, shadow = 55, arcane = 55},
        abilities = {{
            -- CHANGED: confirmed via testing - 4410 damage, 7 second stun.
            name = "Pyroclast Barrage",
            icon = "Interface\\Icons\\Spell_Fire_Fireball02",
            warning = true,
            lines = {"Inflicts 4410 Fire damage to enemies in a cone in front of it, stunning them for 7 seconds."}
        }, {
            -- CHANGED: no usable Description_enUS match in Spell.xlsx -
            -- text below is a guess.
            name = "Lava Explosion",
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            warning = true,
            lines = {"An explosive burst dealing X Fire damage to nearby enemies."}
        }}
    },

    lava_reaver = {
        name = "Lava Reaver",
        icon = "Interface\\Icons\\Ability_Rogue_Ambush",
        flags = {"melee"},
        stats = {armor = 3400, fire = "immune", nature = 50, frost = 50, shadow = 50, arcane = 50},
        abilities = {{
            -- CHANGED: confirmed via testing - plus 30.
            name = "Strike",
            icon = "Interface\\Icons\\Ability_Rogue_Ambush",
            roles = {"tank"},
            lines = {"Strikes at an enemy, inflicting weapon damage plus 30."}
        }, {
            -- CHANGED: no usable Description_enUS match in Spell.xlsx (and
            -- the sourced icon, "phoenix", looks like a placeholder rather
            -- than a real match) - text and icon below are both guesses.
            name = "Lava Grasp",
            icon = "Interface\\Icons\\Spell_Nature_StrangleVines",
            warning = true,
            roles = {"tank"},
            lines = {"Grasps an enemy, inflicting X Nature damage and rooting it in place for X seconds."}
        }}
    },

    lava_annihilator = {
        name = "Lava Annihilator",
        icon = "Interface\\Icons\\stoneskinz_3",
        -- CHANGED: confirmed via testing - not tauntable, melee tag removed.
        flags = {"nottauntable"},
        stats = {armor = 4000, fire = "immune", nature = 60, frost = 60, shadow = 60, arcane = 60},
        abilities = {{
            -- CHANGED: confirmed via testing - 100 damage taken, 60 seconds.
            name = "Annihilate",
            icon = "Interface\\Icons\\stoneskinz_3",
            roles = {"tank"},
            lines = {"Increases the Physical damage taken by an enemy by 100 for 60 seconds. Stacks indefinitely."}
        }, {
            -- CHANGED: confirmed via testing - hits twice per swing.
            name = "Double Attack",
            icon = "Interface\\Icons\\Ability_GhoulFrenzy",
            roles = {"tank"},
            lines = {"Gives the caster one extra attack every X seconds."}
        }}
    },

    flame_imp = {
        -- CHANGED: confirmed real trash from a public Chronicle Vanilla+
        -- run log, alongside the packs already sourced from
        -- mob_abilities_summary.txt - see the PR notes.
        name = "Flame Imp",
        icon = "Interface\\Icons\\Spell_Fire_SealOfFire",
        -- CHANGED: confirmed via testing - melee tag replaced with caster.
        flags = {"caster"},
        stats = {armor = 2400, fire = "immune", nature = 40, frost = 40, shadow = 40, arcane = 40},
        abilities = {{
            -- CHANGED: no usable Description_enUS match in Spell.xlsx -
            -- text below is a guess.
            name = "Fire Nova",
            icon = "Interface\\Icons\\Spell_Fire_SealOfFire",
            warning = true,
            lines = {"Inflicts X Fire damage to nearby enemies."}
        }}
    },

    firewalker = {
        name = "Firewalker",
        icon = "Interface\\Icons\\Spell_Fire_Incinerate",
        flags = {"melee"},
        stats = {armor = 3600, fire = "immune", nature = 55, frost = 55, shadow = 55, arcane = 55},
        abilities = {{
            -- CHANGED: confirmed via testing - 3375 to 4325 damage over 6 sec.
            name = "Fire Blossom",
            icon = "Interface\\Icons\\Spell_Fire_Incinerate",
            warning = true,
            lines = {"Immobilizes the caster and periodically inflicts 3375 to 4325 Fire damage to an enemy over 6 seconds."}
        }, {
            -- CHANGED: confirmed via testing - 50 for 60 seconds.
            name = "Incite Flames",
            icon = "Interface\\Icons\\Spell_Fire_FlameBlades",
            lines = {"Reduces the Fire resistance of nearby enemies by 50 for 60 seconds."}
        }}
    },
}

------------------------------------------------------------
-- Builders: expand the order lists + registries above into the flat
-- table shapes the Trash/Bosses views expect (see AGENTS.md "Data
-- model"). Nothing below this point encodes raid content - only edit it
-- if the addon's expected data shape changes.
------------------------------------------------------------

local function BuildMCBosses()
    local bosses = {}
    for _, key in ipairs(MC_BOSS_ORDER) do
        local boss = { key = key }
        for field, value in pairs(MC_BOSSES[key]) do
            boss[field] = value
        end
        table.insert(bosses, boss)
    end
    return bosses
end

local function BuildMCTrash()
    local trash = {}
    for _, entry in ipairs(MC_TRASH_ORDER) do
        if type(entry) == "table" and entry.separator then
            table.insert(trash, entry)
        else
            local key, count
            if type(entry) == "table" then
                key, count = entry.key, entry.count
            else
                key = entry
            end
            local mob = MC_TRASH_MOBS[key]
            local pack = { key = key, grouped = true, count = count }
            for field, value in pairs(mob) do
                pack[field] = value
            end
            table.insert(trash, pack)
        end
    end
    return trash
end

table.insert(DungeonJournal_Raids, {
    key = "MC",
    name = "Molten Core",
    expanded = false,
    trashExpanded = false,
    trash = BuildMCTrash(),
    bosses = BuildMCBosses(),
})
