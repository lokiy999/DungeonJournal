-- Part of the DungeonJournal RAIDS database (see AGENTS.md "Data model").
-- Loaded via DungeonJournal.toc before DungeonJournal.lua; appends this
-- raid's table to the shared DungeonJournal_Raids list in load order.

DungeonJournal_Raids = DungeonJournal_Raids or {}

table.insert(DungeonJournal_Raids, {
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
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\BrigitteAbbendis",
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
            lines = {"Charges an enemy, inflicting normal damage plus 500, gaining aggro and stunning them."}
        }, {
            name = "Shield Bash",
            icon = "Interface\\Icons\\INV_Shield_05",
            warning = true,
            lines = {"Slam the target with your shield, causing 1794 to 2170 damage, and dispels 1 magic effect on the target."}
        }, {
            name = "Consecration",
            icon = "Interface\\Icons\\Spell_Holy_InnerFire",
            warning = true,
            lines = {"Consecrates the ground on the closest and furthest target, dealing Holy damage every second to anyone standing in the area. Won't be cast if mana is empty."}
        }, {
            name = "Provocation",
            icon = "Interface\\Icons\\Ability_Warrior_InnerRage",
            lines = {"Taunts and forces all nearby enemies within 10 yards to focus attacks on her for 8 seconds."}
        }, {
            separator = true,
            name = "Phase 2"
        }, {
            name = "Fist of Justice",
            icon = "Interface\\Icons\\Spell_Holy_SealOfMight",
            warning = true,
            lines = {"Casts at 20% health left. Stuns nearby enemies for up to 10 seconds."}
        }, {
            name = "Lay on Hands",
            icon = "Interface\\Icons\\Spell_Holy_LayOnHands",
            warning = true,
            lines = {"Casts at 20% health left. Heals to full health."}
        }, {
            name = "Scarlet Charger",
            icon = "Interface\\Icons\\mount_scarlet_charger",
            lines = {"Casts at 20% health left. She summons her mount, increasing her speed by 100%."}
        }, {
            name = "Stormbolt",
            icon = "Interface\\Icons\\Ability_ThunderClap",
            roles = {"healer", "tank", "reflect"},
            lines = {"Hurls a hammer that strikes an enemy for 1897 to 2327 Holy damage every 1.5 seconds. Reflectable"}
        }, {
            name = "Hoof Kick",
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_05",
            warning = true,
            lines = {"Inflicts 1500 to 2050 damage on enemies in a cone behind the caster, knocking them back."}
        }, {
            name = "Trampling Charge",
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_05",
            warning = true,
            lines = {"Inflicts 1800 to 2298 damage to enemies in a cone in front of the caster, knocking them back."}
        }, {
            name = "Crash",
            icon = "Interface\\Icons\\Ability_WarStomp",
            warning = true,
            lines = {"Inflicts 400% weapon damage to an already wounded enemy and stuns them."}
        }, {
            name = "Consecration (phase 2)",
            icon = "Interface\\Icons\\Spell_Holy_InnerFire",
            lines = {"Consecrates the ground on the closest and furthest target, dealing 1150-1520 Holy damage instantly and 10% health damage per 0.95s to anyone standing in the area. Lasts 8 seconds. Won't be cast if mana is empty."}
        }, {
            name = "Close Quarters Combat Experience",
            icon = "Interface\\Icons\\Ability_Warrior_OffensiveStance",
            warning = true,
            roles = {"tank"},
            lines = {"Increases her attack speed by 100% and the Physical damage she deals by 100% for 10 seconds."}
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
        flags = {"tauntable"},
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
        flags = {"tauntable"},
        -- NOTE: values from Spell.dbc (IDs 35940-35951). Percentages are the
        -- real $s values (DBC stores them as value-1).
        abilities = {{
            name = "Curse of Thorns",
            icon = "Interface\\Icons\\Spell_Shadow_AntiShadow",
            warning = true,
            roles = {"dps", "decurse"},
            lines = {"The target takes twice the damage they deal. Lasts 45 seconds."}
        }, {
            name = "Thorned Roots",
            icon = "Interface\\Icons\\Spell_Nature_StrangleVines",
            warning = true,
            roles = {"healer"},
            lines = {"Roots a player and deals 20% of their maximum health as Nature damage every second for 8 seconds.",
                     "When the roots collapse, thorns explode outward to all targets in Line of Sight dealing 5380-6180 damage and stunning for 2 seconds."}
        }, {
            name = "Fists of Fire",
            icon = "Interface\\Icons\\Spell_Fire_Immolation",
            roles = {"tank"},
            lines = {"90% of Brother Michael's Physical damage becomes Fire damage for 25 seconds."}
        }, {
            name = "Four Finger Death Punch",
            icon = "Interface\\Icons\\Spell_Shadow_CorpseExplode",
            warning = true,
            roles = {"tank"},
            lines = {"Every 10 seconds the tank takes receives a stack of Four Finger Death Punch.", 
                     "Whenever the tank reaches 4 stacks he will explode taking 50000-100000 damage."}
        }, {
            name = "Soulbind",
            icon = "Interface\\Icons\\Spell_Shadow_Haunting",
            warning = true,
            lines = {"Brother Michael casts Soulbind on everyone (including himself) in his line of sight and binds them together for 8 seconds.",
                     "20% of the damage taken is split among the bound."}
        }, {
            name = "Grip Break",
            icon = "Interface\\Icons\\Ability_Warrior_Disarm",
            lines = {"Disarms the target for 6 seconds."}
        }, {
            name = "Kick",
            icon = "Interface\\Icons\\Ability_kick",
            warning = true,
            lines = {"Kicks a player back 50 yards and sends them to the death realm, causing Disembodied."},
            abilities = {{
                name = "Disembodied",
                icon = "Interface\\Icons\\ability_vanish",
                lines = {"The target becomes a ghost and can see mobs that are in the death realm. If caught by the mobs they will die."}
            }}
        }}
    }, {
        key = "doan",
        name = "Doan",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Doan",
        flags = {"tauntable"},
        -- NOTE: values from Spell.dbc (IDs 35954-35989). Doan rotates between
        -- three elemental stances (Arcane, Frost, Fire), each with its own set
        -- of abilities. Shared abilities are listed under "All Phases".
        abilities = {{
            separator = true,
            name = "All Phases"
        }, {
            name = "Brilliance Aura",
            icon = "Interface\\Icons\\Spell_Nature_Brilliance",
            lines = {"Regenerates 550 mana every 5 seconds."}
        }, {
            name = "Arcane Pulse",
            icon = "Interface\\Icons\\Spell_Arcane_ArcaneResilience",
            warning = true,
            lines = {"Magically pulses for 100 Arcane damage and interrupts spellcasting, locking that school for a few seconds."}
        }, {
            name = "Blink",
            icon = "Interface\\Icons\\Spell_Arcane_Blink",
            lines = {"After phase swap, Doan teleports a short distance."}
        }, {
            name = "Evocation",
            icon = "Interface\\Icons\\Spell_Nature_Purge",
            warning = true,
            roles = {"kick"},
            lines = {"Channels to regenerate 5% of his total mana per second. Lasts 10 seconds."}
        }, {
            separator = true,
            name = "Arcane Phase"
        }, {
            name = "Arcanebolt",
            icon = "Interface\\Icons\\Spell_Nature_StarFall",
            lines = {"Blasts an enemy for 1040-1390 Arcane damage every 0.5 seconds while channeling."}
        }, {
            name = "Greater Polymorph",
            icon = "Interface\\Icons\\Spell_Nature_Brilliance",
            roles = {"dispel"},
            lines = {"Transforms an enemy into a sheep for 60 seconds."}
        }, {
            name = "Slow",
            icon = "Interface\\Icons\\Spell_Nature_Slow",
            roles = {"dispel"},
            lines = {"Reduces the target's movement speed by 50% and attack speed by 50% for 20 seconds."}
        }, {
            name = "Siphon Magic",
            icon = "Interface\\Icons\\Spell_Nature_Purge",
            lines = {"Purges all harmful magic effects from himself, restoring mana for each effect removed."}
        }, {
            separator = true,
            name = "Frost Phase"
        }, {
            name = "Icebolt",
            icon = "Interface\\Icons\\Spell_Frost_FrostBolt02",
            roles = {"healer"},
            lines = {"Launches a bolt of frost for 4200-5110 Frost damage and reduces the next healing effect on the target by 90%."}
        }, {
            name = "Ice Blast",
            icon = "Interface\\Icons\\Spell_Frost_Glacier",
            warning = true,
            roles = {"healer"},
            lines = {"Deals 15% of the target's health every second while it lasts."}
        }, {
            name = "Numbing Cold",
            icon = "Interface\\Icons\\Spell_Frost_FrostArmor",
            warning = true,
            lines = {"The ground gets icy. After 3 seconds your attack and movement speed gets reduced by 30%.",
                     "After 6? seconds your attack, movement and casting speed reduced by 40%.",
                     "After 10 seconds of standing applies Chilled to the Bone."},
            abilities = {{
                name = "Chilled to the Bone",
                icon = "Interface\\Icons\\spell_frost_frostnova",
                lines = {"Your unable to move and your attack and casting speed is reduced by 50% and after 5 seconds become Frozen Solid."},
                abilities = {{
                    name = "Frozen Solid",
                    icon = "Interface\\Icons\\spell_frost_frost",
                    lines = {"Your frozen in place for 10 seconds and get X Frost Damage every X seconds."}
                }}
            }}
        }, {
            separator = true,
            name = "Fire Phase"
        }, {
            name = "Flamebolt",
            icon = "Interface\\Icons\\Spell_Fire_FlameBolt",
            lines = {"Hurls a fiery ball for 5750-6800 Fire damage plus 250 Fire damage every 0.5 sec. for 8 seconds."}
        }, {
            name = "Flamestrike",
            icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
            lines = {"Calls down a pillar of fire for 1555-1840 Fire damage on a random target, then 575 Fire damage every second to anyone standing in it for 8 seconds."}
        }, {
            name = "Dragon Breath",
            icon = "Interface\\Icons\\Spell_Fire_Fire",
            warning = true,
            roles = {"tank"},
            lines = {"Inflicts 1850-2230 Fire damage in a cone in front of Doan. This will set any bookshelves ablaze which he hits."},
            abilities = {{
                name = "Searing Heat",
                icon = "Interface\\Icons\\Spell_Fire_Incinerate",
                lines = {"Continually inflicts Fire damage on the raid."}
            }}
        }}
    }, {
        key = "renault_mograine",
        name = "Renault Mograine",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Mograine",
        flags = {"notalwaystauntable"},
        -- NOTE: values from Spell.dbc (IDs 33456-36021). Percentages are the
        -- real $s values (DBC stores them as value-1).
        abilities = {{
            separator = true,
            name = "Renault Mograine"
        }, {
            name = "Eye for an Eye",
            icon = "Interface\\Icons\\Spell_Holy_EyeforanEye",
            warning = true,
            lines = {"All of the damage dealt to him is reflected back at the raid, divided between each member."}
        }, {
            name = "Crusader Strike",
            icon = "Interface\\Icons\\Spell_Holy_CrusaderStrike2",
            roles = {"tank", "dispel"},
            lines = {"Inflicts 800 to 1100 damage to an enemy and increases the Holy damage it takes by 20% per Crusader Strike. Can be applied up to 5 times. Lasts 25 seconds.."}
        }, {
            name = "Pillar of Light",
            icon = "Interface\\Icons\\Spell_Holy_ReviveChampion",
            lines = {"Mograine summons a Pillar of Light every ~15-20 seconds, which disorientates anyone who looks at it for 6 seconds while it's being cast. It deals 500 Holy damage to anyone in its' line of sight every second."}
        }, {
            name = "Purify",
            icon = "Interface\\Icons\\spell_holy_purify",
            lines = {"Mograine purifies a friendly target, removing 1 disease effect and 1 poison effect."}
        }, {
            name = "Aura",
            icon = "Interface\\Icons\\spell_holy_auramastery",
            lines = {"Mograine swaps between 5 auras at random every 20 seconds."},
            abilities = {{
                name = "Retribution Aura",
                icon = "Interface\\Icons\\spell_holy_auraoflight",
                lines = {"Does 125 Holy damage to anyone who hits Mograine and doubles the damage of Eye for an Eye."}
            }, {
                name = "Devotion Aura",
                icon = "Interface\\Icons\\spell_holy_devotionaura",
                lines = {"Increases his armor by 2100."}
            }, {
                name = "Fire Resistance Aura",
                icon = "Interface\\Icons\\spell_fire_sealoffire",
                lines = {"Increases his Fire resistance by 180."}
            }, {
                name = "Frost Resistance Aura",
                icon = "Interface\\Icons\\spell_frost_wizardmark",
                lines = {"Increases his Frost resistance by 180."}
            }, {
                name = "Shadow Resistance Aura",
                icon = "Interface\\Icons\\spell_shadow_sealofkings",
                lines = {"Increases his Shadow resistance by 180."}
            }}
        }, {
            separator = true,
            name = "Sally Whitemane"
        }, {
            name = "Scarlet Resurrection",
            icon = "Interface\\Icons\\spell_holy_resurrection",
            warning = true,
            lines = {"When Mograine dies, Whitemane resurrects him and the fight continues."}
        }, {
            name = "Holy Smite",
            icon = "Interface\\Icons\\Spell_Holy_HolySmite",
            roles = {"kick"},
            lines = {"Whitemane's main cast, smiting a target for 2730-3030 Holy damage."}
        }, {
            name = "Holy Fire",
            icon = "Interface\\Icons\\Spell_Holy_SearingLight",
            warning = true,
            roles = {"kick"},
            lines = {"Inflicts 1275-1650 Holy damage plus 830 Holy damage every 3 seconds, and dispels a positive effect from the target on each periodic damage tick."}
        }, {
            name = "Absolution",
            icon = "Interface\\Icons\\Spell_Holy_RighteousFury",
            warning = true,
            roles = {"tank"},
            lines = {"Smites an enemy, inflicting 4000-5000 Holy damage."}
        }, {
            name = "Eradication",
            icon = "Interface\\Icons\\spell_holy_righteousfury",
            warning = true,
            roles = {"tank"},
            lines = {"Smites an enemy, inflicting 10000-12000 Holy damage."}
        }, {
            name = "Heal",
            icon = "Interface\\Icons\\Spell_Holy_Heal",
            warning = true,
            roles = {"kick"},
            lines = {"Whitemane heals herself (or Mograine) for 90000-100000."}
        }, {
            name = "Dispel Magic",
            icon = "Interface\\Icons\\Spell_Holy_DispelMagic",
            lines = {"Whitemane dispels 2 magic spells from herself."}
        }, {
            name = "Power Word: Shield",
            icon = "Interface\\Icons\\Spell_Holy_PowerWordShield",
            roles = {"dispel"},
            lines = {"Shields herself, absorbing 15000 damage."}
        }, {
            name = "Dominate Mind",
            icon = "Interface\\Icons\\spell_shadow_shadowworddominate",
            warning = true,
            roles = {"cc"},
            lines = {"Mind controls a player."}
        }}
    }, {
        key = "fairbanks",
        name = "Fairbanks",
        icon = "Interface\\AddOns\\DungeonJournal\\Icons\\Fairbanks",
        flags = {"tauntable"},
        -- NOTE: values from Spell.dbc (IDs 36024-36213). Percentages are the
        -- real $s values (DBC stores them as value-1).
        abilities = {{
            name = "Bile Vomit",
            icon = "Interface\\Icons\\Spell_Shadow_PlagueCloud",
            roles = {"tank"},
            lines = {"Shoots a cloud of bile in a cone in front of him, reducing armor by 650 and inflicting 1280-1620 Nature damage and 330 Nature damage every 5 seconds for 30 seconds. Stacks up to 10 times."}
        }, {
            name = "Claustrophobia",
            icon = "Interface\\Icons\\Spell_Shadow_Shadesofdarkness",
            warning = true,
            lines = {"The walls press inward, increasing all players in size."}
        }, {
            name = "Blasphemous Vitality",
            icon = "Interface\\Icons\\spell_shadow_unholystrength",
            lines = {"Regenerates 1% of total Health every 5 seconds."}
        }, {
            name = "Power Word: Barrier",
            icon = "Interface\\Icons\\spell_holy_powerwordshield",
            lines = {"Shields himself for 9260-9460 seconds for 15 seconds."}
        }, {
            name = "All-Consuming Hatred",
            icon = "Interface\\Icons\\spell_shadow_sacrificialshield",
            lines = {"Damage done increased by 50%. Immune to Taunt effects. Not sure when he does this."}
        }, {
            name = "Stomp",
            icon = "Interface\\Icons\\ability_kick",
            lines = {"Whenever players are too close to each other triggers Stomp, interrupting spellcasting and prevents any spell in that school from being cast for 0.5 seconds."}
        }, {
            name = "Panic",
            icon = "Interface\\Icons\\spell_shadow_auraofdarkness",
            lines = {"Weakens your spirit, causing Panic to accumulate over time. Upon reaching 10 stacks, triggers Fear."},
            abilities = {{
                name = "Fear",
                icon = "Interface\\Icons\\spell_shadow_possession",
                roles = {"dispel"},
                lines = {"Become feared for 8 seconds."}
            }}
        }}
    }}

})
