-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

newBirthDescriptor{
	type = "class",
	name = "Wilder",
	desc = {
		"Wilders are one with nature, in one manner or another. There are as many different Wilders as there are aspects of nature.",
		"They can take on the aspects of creatures, summon creatures to them, feel the druidic call, ...",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Summoner = function() return profile.mod.allow_build.wilder_summoner and "allow" or "disallow" end,
			Wyrmic = function() return profile.mod.allow_build.wilder_wyrmic and "allow" or "disallow" end,
			["Stone Warden"] = function(birth) return birth.descriptors_by_type.race and birth.descriptors_by_type.race.name == "Dwarf" and profile.mod.allow_build.wilder_stone_warden and "allow" or "disallow" end,
		},
	},
	copy = {
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Summoner",
	desc = {
		"Summoners never fight alone. They are always ready to summon one of their many minions to fight at their side.",
		"Summons can range from a combat hound to a fire drake.",
		"Their most important stats are: Willpower and Cunning",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +1 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +5 Willpower, +3 Cunning",
	},
	stats = { wil=5, cun=3, dex=1, },
	talents_types = {
		["wild-gift/call"]={true, 0.2},
		["wild-gift/harmony"]={true, 0.1},
		["wild-gift/summon-melee"]={true, 0.3},
		["wild-gift/summon-distance"]={true, 0.3},
		["wild-gift/summon-utility"]={true, 0.3},
		["wild-gift/summon-augmentation"]={false, 0.3},
		["cunning/survival"]={true, 0},
		["technique/combat-techniques-active"]={false, 0},
		["technique/combat-techniques-passive"]={false, 0},
		["technique/combat-training"]={true, 0},
	},
	talents = {
		[ActorTalents.T_WAR_HOUND] = 1,
		[ActorTalents.T_RITCH_FLAMESPITTER] = 1,
		[ActorTalents.T_MEDITATION] = 1,
		[ActorTalents.T_TRAP_DETECTION] = 1,
	},
	copy = {
		max_life = 90,
		resolvers.equip{ id=true,
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000}
		},
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Wyrmic",
	desc = {
		"Wyrmics are fighters who have learnt how to mimic some of the aspects of the dragons.",
		"They have access to talents normally belonging to the various kind of drakes.",
		"Their most important stats are: Strength and Willpower",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +5 Strength, +0 Dexterity, +1 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +3 Willpower, +0 Cunning",
	},
	stats = { str=5, wil=3, con=1, },
	talents_types = {
		["wild-gift/call"]={true, 0.2},
		["wild-gift/sand-drake"]={true, 0.3},
		["wild-gift/fire-drake"]={true, 0.3},
		["wild-gift/cold-drake"]={true, 0.3},
		["wild-gift/storm-drake"]={true, 0.3},
		["cunning/survival"]={false, 0},
		["technique/shield-offense"]={false, -0.1},
		["technique/2hweapon-offense"]={true, -0.1},
		["technique/combat-techniques-active"]={false, 0},
		["technique/combat-techniques-passive"]={true, 0},
		["technique/combat-training"]={true, 0},
	},
	talents = {
		[ActorTalents.T_ICE_CLAW] = 1,
		[ActorTalents.T_MEDITATION] = 1,
		[ActorTalents.T_WEAPONS_MASTERY] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
	},
	copy = {
		max_life = 110,
		resolvers.equip{ id=true,
			{type="weapon", subtype="battleaxe", name="iron battleaxe", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000}
		},
	},
	copy_add = {
		life_rating = 2,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Stone Warden",
	desc = {
		"Stone Wardens are dwarves trained in both the eldritch arts and the worship of nature.",
		"While other races are stuck in their belief that arcane forces and natural forces are meant to oppose, dwarves have found a way to combine them in harmony.",
		"Stone Wardens are armoured fighters, using a shield to channel many of their powers.",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +2 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +4 Magic, +3 Willpower, +0 Cunning",
	},
	not_on_random_boss = true,
	stats = { str=2, wil=3, mag=4, },
	talents_types = {
		["wild-gift/call"]={true, 0.2},
		["wild-gift/earthen-stone"]={true, 0.3},
		["wild-gift/earthen-vines"]={true, 0.3},
		["spell/arcane-shield"]={true, 0.3},
		["spell/earth"]={true, 0.2},
		["spell/stone"]={false, 0.2},
		["cunning/survival"]={true, 0},
		["technique/combat-training"]={true, 0},
	},
	talents = {
		[ActorTalents.T_STONE_VINES] = 1,
		[ActorTalents.T_STONESHIELD] = 1,
		[ActorTalents.T_ELDRITCH_BLOW] = 1,
		[ActorTalents.T_ARMOUR_TRAINING] = 3,
		[ActorTalents.T_WEAPONS_MASTERY] = 1,
	},
	copy = {
		max_life = 110,
		resolvers.equip{ id=true,
			{type="weapon", subtype="mace", name="iron mace", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="shield", name="iron shield", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000, ego_chance=-1000}
		},
	},
	copy_add = {
		life_rating = 2,
	},
}
