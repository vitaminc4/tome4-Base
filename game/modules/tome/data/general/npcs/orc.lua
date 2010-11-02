-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_ORC",
	type = "humanoid", subtype = "orc",
	display = "o", color=colors.UMBER,
	faction = "orc-pride",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 20,
	lite = 2,

	life_rating = 11,
	rank = 2,
	size_category = 3,

	open_door = true,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=3, },
	energy = { mod=1 },
	stats = { str=20, dex=8, mag=6, con=16 },
}

newEntity{ base = "BASE_NPC_ORC",
	define_as = "HILL_ORC_WARRIOR",
	name = "orc warrior", color=colors.LIGHT_UMBER,
	desc = [[He is a hardy, well-weathered survivor.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(70,80),
	resolvers.equip{
		{type="weapon", subtype="waraxe", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,
	resolvers.talents{ [Talents.T_SHIELD_PUMMEL]=1, },
}

newEntity{ base = "BASE_NPC_ORC",
	define_as = "HILL_ORC_ARCHER",
	name = "orc archer", color=colors.UMBER,
	desc = [[He is a hardy, well-weathered survivor.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	combat_armor = 5, combat_def = 1,
	resolvers.talents{ [Talents.T_SHOOT]=1, },
	ai_state = { talent_in=1, },

	autolevel = "archer",
	resolvers.equip{
		{type="weapon", subtype="longbow", autoreq=true},
		{type="ammo", subtype="arrow", autoreq=true},
	},
}

newEntity{ base = "BASE_NPC_ORC", define_as = "ORC",
	name = "orc soldier", color=colors.DARK_RED,
	desc = [[A fierce soldier-orc.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(120,140),
	life_rating = 11,
	resolvers.equip{
		{type="weapon", subtype="battleaxe", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,
	resolvers.talents{ [Talents.T_SUNDER_ARMOUR]=2, [Talents.T_CRUSH]=2, },
}

newEntity{ base = "BASE_NPC_ORC", define_as = "ORC_FIRE_WYRMIC",
	name = "fiery orc wyrmic", color=colors.RED,
	desc = [[A fierce soldier-orc trained in the discipline of dragons.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 6,
	rank = 3,
	max_life = resolvers.rngavg(100,110),
	life_rating = 10,
	resolvers.equip{
		{type="weapon", subtype="battleaxe", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,

	make_escort = {
		{type="humanoid", subtype="orc", name="orc soldier", number=resolvers.mbonus(3, 2)},
	},

	resolvers.talents{
		[Talents.T_BELLOWING_ROAR]=2,
		[Talents.T_WING_BUFFET]=2,
		[Talents.T_FIRE_BREATH]=2,
	},
}

newEntity{ base = "BASE_NPC_ORC",
	name = "icy orc wyrmic", color=colors.BLUE, define_as = "ORC_ICE_WYRMIC",
	desc = [[A fierce soldier-orc trained in the discipline of dragons.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 6,
	rank = 3,
	max_life = resolvers.rngavg(100,110),
	life_rating = 10,
	resolvers.equip{
		{type="weapon", subtype="battleaxe", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,

	make_escort = {
		{type="humanoid", subtype="orc", name="orc soldier", number=resolvers.mbonus(3, 2)},
	},

	resolvers.talents{
		[Talents.T_ICE_CLAW]=2,
		[Talents.T_ICY_SKIN]=2,
		[Talents.T_ICE_BREATH]=2,
	},
}

newEntity{ base = "BASE_NPC_ORC",
	name = "orc assassin", color_r=0, color_g=0, color_b=resolvers.rngrange(175, 195),
	desc = [[An orc trained in the secret ways of assasination, as stealthy as deadly.]],
	level_range = {5, nil}, exp_worth = 1,
	rarity = 3,
	infravision = 10,
	combat_armor = 2, combat_def = 12,
	resolvers.equip{
		{type="weapon", subtype="dagger", autoreq=true},
		{type="weapon", subtype="dagger", autoreq=true},
		{type="armor", subtype="light", autoreq=true}
	},
	resolvers.talents{
		[Talents.T_STEALTH]=5,
		[Talents.T_LETHALITY]=4,
		[Talents.T_SHADOWSTRIKE]=3,
	},
	max_life = resolvers.rngavg(80,100),

	resolvers.sustains_at_birth(),
	autolevel = "rogue",
}

newEntity{ base = "BASE_NPC_ORC",
	name = "orc master assassin", color_r=0, color_g=70, color_b=resolvers.rngrange(175, 195),
	desc = [[An orc trained in the secret ways of assasination, as stealthy as deadly.]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 4,
	rank = 3,
	infravision = 10,
	combat_armor = 2, combat_def = 18,
	resolvers.equip{
		{type="weapon", subtype="dagger", ego_chance=20, autoreq=true},
		{type="weapon", subtype="dagger", ego_chance=20, autoreq=true},
		{type="armor", subtype="light", autoreq=true}
	},
	resolvers.talents{
		[Talents.T_STEALTH]=5,
		[Talents.T_LETHALITY]=4,
		[Talents.T_SHADOWSTRIKE]=5,
		[Talents.T_HIDE_IN_PLAIN_SIGHT]=2,
	},
	max_life = resolvers.rngavg(80,100),

	resolvers.sustains_at_birth(),
	autolevel = "rogue",
}

newEntity{ base = "BASE_NPC_ORC",
	name = "orc grand master assassin", color_r=0, color_g=70, color_b=resolvers.rngrange(175, 195),
	desc = [[An orc trained in the secret ways of assasination, as stealthy as deadly.]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 5,
	rank = 3,
	infravision = 10,
	combat_armor = 2, combat_def = 18,
	resolvers.equip{
		{type="weapon", subtype="dagger", ego_chance=20, autoreq=true},
		{type="weapon", subtype="dagger", ego_chance=20, autoreq=true},
		{type="armor", subtype="light", autoreq=true}
	},
	resolvers.talents{
		[Talents.T_STEALTH]=5,
		[Talents.T_LETHALITY]=4,
		[Talents.T_SHADOWSTRIKE]=5,
		[Talents.T_HIDE_IN_PLAIN_SIGHT]=3,
		[Talents.T_UNSEEN_ACTIONS]=3,
	},
	max_life = resolvers.rngavg(80,100),

	resolvers.sustains_at_birth(),
	autolevel = "rogue",
}
