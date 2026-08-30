-- Part of the DungeonJournal RAIDS database (see AGENTS.md "Data model").
-- Loaded via DungeonJournal.toc before DungeonJournal.lua; appends this
-- raid's table to the shared DungeonJournal_Raids list in load order.

DungeonJournal_Raids = DungeonJournal_Raids or {}

------------------------------------------------------------
-- GREEN order list - START HERE to reorder bosses.
--
-- GREEN_BOSS_ORDER is the only thing you should need to touch to change
-- what order bosses appear in the Bosses tab. Just a flat list of keys -
-- actual boss data (icon/flags/stats/abilities) lives further down in
-- GREEN_BOSSES, defined once per key and looked up from here.
------------------------------------------------------------

-- Boss encounter order (Bosses tab tree, top to bottom).
local GREEN_BOSS_ORDER = {
    "emeriss",
    "lethon",
    "taerar",
    "ysondre",
}

------------------------------------------------------------
-- Boss registry - one entry per boss (icon/flags/stats/abilities/adds),
-- referenced by key from GREEN_BOSS_ORDER above. Defined once each; add a
-- new boss here and add its key to GREEN_BOSS_ORDER to place it.
--
-- CHANGED: ability numbers filled from Classic references
-- (warcraft.wiki.gg's "<dragon> (Classic)" pages, cross-checked against
-- the Warcraft Tavern "Dragons of Nightmare" guide) - user confirmed the
-- V+ versions are still identical to Classic. The four shared abilities
-- (Noxious Breath, Tail Sweep, Seeping Fog, Mark of Nature / Aura of
-- Nature) are repeated per dragon on purpose, matching this project's
-- one-entry-per-boss data shape. Each dragon's signature summon fires
-- once per 25% health lost, i.e. at 75%, 50% and 25%.
------------------------------------------------------------
local GREEN_BOSSES = {
    emeriss = {
        name = "Emeriss",
        icon = "Interface\\Icons\\temp",
        flags = {"damage_nature"},
        abilities = {{
            name = "Volatile Infection",
            icon = "Interface\\Icons\\Spell_Holy_HarmUndeadAura",
            warning = true,
            roles = {"dispel", "healer"},
            lines = {"A dispellable disease on a random player for 2 minutes. Deals 875 to 1125 Nature damage every 5 seconds to that player AND everyone around them - the infected player must move out of the raid.",
                     "Emeriss' most frequent ability."},
            abilities = {{
                name = "Putrid Mushroom",
                icon = "Interface\\Icons\\Spell_Nature_NullifyPoison",
                warning = true,
                lines = {"Spawns at the corpse of a player who dies while infected, dealing 600 Nature damage per second to anyone nearby. Do not release or run through it."}
            }}
        }, {
            name = "Corruption of the Earth",
            icon = "Interface\\Icons\\Ability_Creature_Cursed_03",
            warning = true,
            roles = {"healer"},
            lines = {"Fired at 75%, 50% and 25% health. An undispellable raid-wide Shadow DoT dealing 20% of each player's maximum health every 2 seconds for 10 seconds (100 yard range - nobody escapes it)."}
        }, {
            name = "Noxious Breath",
            icon = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
            warning = true,
            roles = {"tank"},
            lines = {"Frontal breath: 3000 Nature damage up front, then a 30 second DoT dealing 350 to 450 Nature damage every 3 seconds and adding 10 seconds to all of the target's ability cooldowns. Stacks up to 6 times - do not stand in front."}
        }, {
            name = "Tail Sweep",
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_05",
            warning = true,
            lines = {"Inflicts 925 to 1075 damage to enemies in a 30 yard cone behind her and knocks them back. Do not stand behind her."}
        }, {
            name = "Seeping Fog",
            icon = "Interface\\Icons\\Spell_Nature_NullifyDisease",
            warning = true,
            lines = {"Summons two clouds of Dream Fog that slowly chase random players; touching one puts you to sleep for 4 seconds. Keep moving."}
        }, {
            name = "Mark of Nature / Aura of Nature",
            icon = "Interface\\Icons\\Spell_Nature_SpiritArmor",
            warning = true,
            roles = {"healer"},
            lines = {"Aura of Nature is a pulsing effect that interrupts eating, drinking and bandaging near her.",
                     "Mark of Nature is a 15 minute debuff placed on any player she kills. While it is up, re-engaging her (or being caught by her aura) sleeps you for 2 minutes instead of 4 seconds - run well away before releasing.",
                     "She also teleports the highest-threat player back in front of her if they try to leave melee."}
        }}
    },

    lethon = {
        name = "Lethon",
        icon = "Interface\\Icons\\temp",
        flags = {"damage_shadow"},
        abilities = {{
            name = "Shadow Bolt Whirl",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            warning = true,
            lines = {"Fires rotating waves of shadow bolts at one side of him at a time for 800 to 1200 damage each, then alternates to the other side. His most frequent ability by a wide margin - keep moving."}
        }, {
            name = "Draw Spirit",
            icon = "Interface\\Icons\\Spell_Shadow_SummonInfernal",
            warning = true,
            roles = {"dps"},
            lines = {"Fired at 75%, 50% and 25% health. Stuns everyone within 100 yards for 5 seconds and deals 657 to 843 Shadow damage every 2 seconds during it, then pulls green Spirit Shades out of the raid.",
                     "The shades travel back toward Lethon - each one that reaches him heals him for 15,000. Intercept and kill them."},
            abilities = {{
                name = "Spirit Shade",
                icon = "Interface\\Icons\\Spell_Shadow_GatherShadows",
                color = "ffcc0000",
                lines = {"500 HP, immune to AoE. Kill each one before it reaches Lethon (15,000 heal per shade). Players can also run into their own shade to soak it."}
            }}
        }, {
            name = "Noxious Breath",
            icon = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
            warning = true,
            roles = {"tank"},
            lines = {"Frontal breath: 3000 Nature damage up front, then a 30 second DoT dealing 350 to 450 Nature damage every 3 seconds and adding 10 seconds to all of the target's ability cooldowns. Stacks up to 6 times - do not stand in front."}
        }, {
            name = "Tail Sweep",
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_05",
            warning = true,
            lines = {"Inflicts 925 to 1075 damage to enemies in a 30 yard cone behind him and knocks them back. Do not stand behind him."}
        }, {
            name = "Seeping Fog",
            icon = "Interface\\Icons\\Spell_Nature_NullifyDisease",
            warning = true,
            lines = {"Summons two clouds of Dream Fog that slowly chase random players; touching one puts you to sleep for 4 seconds. Keep moving."}
        }, {
            name = "Mark of Nature / Aura of Nature",
            icon = "Interface\\Icons\\Spell_Nature_SpiritArmor",
            warning = true,
            roles = {"healer"},
            lines = {"Aura of Nature is a pulsing effect that interrupts eating, drinking and bandaging near him.",
                     "Mark of Nature is a 15 minute debuff placed on any player he kills. While it is up, re-engaging him (or being caught by his aura) sleeps you for 2 minutes instead of 4 seconds - run well away before releasing.",
                     "He also teleports the highest-threat player back in front of him if they try to leave melee."}
        }}
    },

    taerar = {
        name = "Taerar",
        icon = "Interface\\Icons\\temp",
        flags = {"damage_arcane"},
        abilities = {{
            name = "Arcane Blast",
            icon = "Interface\\Icons\\Spell_Shadow_DeathPact",
            warning = true,
            lines = {"Blasts an enemy for normal damage plus 1050 to 1350 Arcane damage and knocks them back."}
        }, {
            name = "Bellowing Roar",
            icon = "Interface\\Icons\\Spell_Shadow_Charm",
            warning = true,
            roles = {"shaman"},
            lines = {"Fears all enemies within 35 yards for 4 seconds. Keep a Tremor Totem down for the tanks."}
        }, {
            name = "Summon Shades of Taerar",
            icon = "Interface\\Icons\\Spell_Shadow_SummonInfernal",
            warning = true,
            roles = {"tank"},
            lines = {"Fired at 75%, 50% and 25% health. Taerar banishes himself - untargetable and invulnerable - and summons three Shades of Taerar. He does not return until all three are dead, so this is a hard DPS check with multiple tanks.",
                     "Note: while banished he is not losing health, so the three summons always happen (they don't overlap)."},
            abilities = {{
                name = "Shade of Taerar",
                icon = "Interface\\Icons\\Spell_Shadow_ShadeTrueSight",
                color = "ffcc0000",
                lines = {"66,620 HP each, full melee strength - tank all three separately."},
                abilities = {{
                    name = "Acid Breath",
                    icon = "Interface\\Icons\\Spell_Nature_Acid_01",
                    warning = true,
                    lines = {"Frontal cone: 875 to 1125 Nature damage plus 150 Nature damage every 3 seconds for 45 seconds."}
                }, {
                    name = "Poison Cloud",
                    icon = "Interface\\Icons\\Spell_Nature_CorrosiveBreath",
                    warning = true,
                    lines = {"Drops a stationary poison cloud at the shade's feet that deals 350 Nature damage every second for 10 seconds. Move out of it."}
                }}
            }}
        }, {
            name = "Noxious Breath",
            icon = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
            warning = true,
            roles = {"tank"},
            lines = {"Frontal breath: 3000 Nature damage up front, then a 30 second DoT dealing 350 to 450 Nature damage every 3 seconds and adding 10 seconds to all of the target's ability cooldowns. Stacks up to 6 times - do not stand in front."}
        }, {
            name = "Tail Sweep",
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_05",
            warning = true,
            lines = {"Inflicts 925 to 1075 damage to enemies in a 30 yard cone behind him and knocks them back. His most frequent ability - do not stand behind him."}
        }, {
            name = "Seeping Fog",
            icon = "Interface\\Icons\\Spell_Nature_NullifyDisease",
            warning = true,
            lines = {"Summons two clouds of Dream Fog that slowly chase random players; touching one puts you to sleep for 4 seconds. Keep moving."}
        }, {
            name = "Mark of Nature / Aura of Nature",
            icon = "Interface\\Icons\\Spell_Nature_SpiritArmor",
            warning = true,
            roles = {"healer"},
            lines = {"Aura of Nature is a pulsing effect that interrupts eating, drinking and bandaging near him.",
                     "Mark of Nature is a 15 minute debuff placed on any player he kills. While it is up, re-engaging him (or being caught by his aura) sleeps you for 2 minutes instead of 4 seconds - run well away before releasing.",
                     "He also teleports the highest-threat player back in front of him if they try to leave melee."}
        }}
    },

    ysondre = {
        name = "Ysondre",
        icon = "Interface\\Icons\\temp",
        flags = {"damage_nature"},
        stats = {armor = 4691, fire = 126, nature = 126, frost = 126, shadow = 126, arcane = 126},
        abilities = {{
            name = "Lightning Wave",
            icon = "Interface\\Icons\\Spell_Nature_ChainLightning",
            warning = true,
            lines = {"Strikes a random player for 463 to 537 Nature damage, then arcs to up to 10 nearby players, dealing more to each successive target. Her most frequent ability - spread out."}
        }, {
            name = "Summon Demented Druid Spirits",
            icon = "Interface\\Icons\\Spell_Nature_ForceOfNature",
            warning = true,
            roles = {"kick", "tank"},
            lines = {"Fired at 75%, 50% and 25% health. Summons several Demented Druid Spirits (2,442 HP each) that last 10 minutes. Interrupt and kill them quickly.",
                     "Unlike the other three dragons, Ysondre is NOT banished during her summon - the fight continues."},
            abilities = {{
                name = "Demented Druid Spirit",
                icon = "Interface\\Icons\\Spell_Nature_ForceOfNature",
                color = "ffcc0000",
                lines = {"2,442 HP each."},
                abilities = {{
                    name = "Moonfire",
                    icon = "Interface\\Icons\\Spell_Nature_StarFall",
                    warning = true,
                    roles = {"kick"},
                    lines = {"219 to 281 Arcane damage plus 88 to 112 Arcane damage every 3 seconds for 12 seconds."}
                }, {
                    name = "Curse of Thorns",
                    icon = "Interface\\Icons\\Spell_Nature_Thorns",
                    roles = {"decurse"},
                    lines = {"Curses a player for 3 minutes with a 50% chance to take 38 to 82 damage per melee attack they make."}
                }, {
                    name = "Silence",
                    icon = "Interface\\Icons\\Spell_Shadow_ImpPhaseShift",
                    warning = true,
                    lines = {"Prevents the target from casting spells for 5 seconds."}
                }}
            }}
        }, {
            name = "Noxious Breath",
            icon = "Interface\\Icons\\Spell_Shadow_LifeDrain02",
            warning = true,
            roles = {"tank"},
            lines = {"Frontal breath: 3000 Nature damage up front, then a 30 second DoT dealing 350 to 450 Nature damage every 3 seconds and adding 10 seconds to all of the target's ability cooldowns. Stacks up to 6 times - do not stand in front."}
        }, {
            name = "Tail Sweep",
            icon = "Interface\\Icons\\INV_Misc_MonsterScales_05",
            warning = true,
            lines = {"Inflicts 925 to 1075 damage to enemies in a 30 yard cone behind her and knocks them back. Do not stand behind her."}
        }, {
            name = "Seeping Fog",
            icon = "Interface\\Icons\\Spell_Nature_NullifyDisease",
            warning = true,
            lines = {"Summons two clouds of Dream Fog that slowly chase random players; touching one puts you to sleep for 4 seconds. Keep moving."}
        }, {
            name = "Mark of Nature / Aura of Nature",
            icon = "Interface\\Icons\\Spell_Nature_SpiritArmor",
            warning = true,
            roles = {"healer"},
            lines = {"Aura of Nature is a pulsing effect that interrupts eating, drinking and bandaging near her.",
                     "Mark of Nature is a 15 minute debuff placed on any player she kills. While it is up, re-engaging her (or being caught by her aura) sleeps you for 2 minutes instead of 4 seconds - run well away before releasing.",
                     "She also teleports the highest-threat player back in front of her if they try to leave melee."}
        }}
    },
}

------------------------------------------------------------
-- Builder: expands the order list + registry above into the flat table
-- shape the Bosses view expects (see AGENTS.md "Data model"). Nothing
-- below this point encodes raid content - only edit it if the addon's
-- expected data shape changes.
------------------------------------------------------------

local function BuildGREENBosses()
    local bosses = {}
    for _, key in ipairs(GREEN_BOSS_ORDER) do
        local boss = { key = key }
        for field, value in pairs(GREEN_BOSSES[key]) do
            boss[field] = value
        end
        table.insert(bosses, boss)
    end
    return bosses
end

table.insert(DungeonJournal_Raids, {
    -- CHANGED: the four Dragons of Nightmare. They share four abilities
    -- (Noxious Breath, Tail Sweep, Seeping Fog, Mark of Nature / Aura of
    -- Nature) plus one signature summon each, fired at 75% / 50% / 25% HP.
    key = "GREEN",
    name = "Green Dragons",
    expanded = false,
    bosses = BuildGREENBosses(),
})
