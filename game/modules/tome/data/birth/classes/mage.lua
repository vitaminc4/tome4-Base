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
	name = "Mage",
	desc = {
		"Mages are the wielders of arcane powers, able to cast powerful spells of destruction or to heal their wounds with nothing but a thought.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Alchemist = "allow",
			Archmage = function() return profile.mod.allow_build.mage and "allow" or "disallow" end,
		},
	},
	copy = {
		mana_regen = 0.5,
		mana_rating = 7,
		resolvers.inscription("RUNE:_MANASURGE", {cooldown=25, dur=10, mana=620}),
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Archmage",
	desc = {
		"An Archmage devotes his whole life to the study of magic above anything else.",
		"Most Archmagi lack basic skills that others take for granted (like general fighting sense), but they make up for it by their raw magical power.",
		"Archmagi start knowing all schools of magic but the more intricate (Temporal and Meta). However, they usually refuse to have anything to do with Necromancy.",
		"All Archmagi have been trained in the secret town of Angolwen and possess a unique spell to teleport to it directly.",
		"Their most important stats are: Magic and Willpower",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +5 Magic, +3 Willpower, +1 Cunning",
	},
	stats = { mag=5, wil=3, cun=1, },
	talents_types = {
		["spell/arcane"]={true, 0.3},
		["spell/fire"]={true, 0.3},
		["spell/earth"]={true, 0.3},
		["spell/water"]={true, 0.3},
		["spell/air"]={true, 0.3},
		["spell/phantasm"]={true, 0.3},
		["spell/temporal"]={false, 0.3},
		["spell/meta"]={false, 0.3},
		["spell/divination"]={true, 0.3},
		["spell/conveyance"]={true, 0.3},
		["spell/aegis"]={true, 0.3},
		["cunning/survival"]={false, -0.1},
	},
	talents = {
		[ActorTalents.T_ARCANE_POWER] = 1,
		[ActorTalents.T_FLAME] = 1,
		[ActorTalents.T_LIGHTNING] = 1,
		[ActorTalents.T_PHASE_DOOR] = 1,
		[ActorTalents.T_TELEPORT_ANGOLWEN]=1,
	},
	copy = {
		-- Mages start in angolwen
		class_start_check = function(self)
			if self.descriptor.race == "Human" or self.descriptor.race == "Elf" or self.descriptor.race == "Halfling" then
				self.archmage_race_start_quest = self.starting_quest
				self.default_wilderness = {"zone-pop", "angolwen-portal"}
				self.starting_zone = "town-angolwen"
				self.starting_quest = "start-archmage"
				self.starting_intro = "archmage"
			end
		end,

		-- All mages are of angolwen faction
		faction = "angolwen",
		max_life = 90,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
		},
		resolvers.generic(function(self)
			if profile.mod.allow_build.mage_pyromancer then self:learnTalentType("spell/wildfire", false) self:setTalentTypeMastery("spell/wildfire", 1.3) end
			if profile.mod.allow_build.mage_cryomancer then self:learnTalentType("spell/ice", false) self:setTalentTypeMastery("spell/ice", 1.3) end
			if profile.mod.allow_build.mage_geomancer then self:learnTalentType("spell/stone", false) self:setTalentTypeMastery("spell/stone", 1.3) end
			if profile.mod.allow_build.mage_tempest then self:learnTalentType("spell/storm", false) self:setTalentTypeMastery("spell/storm", 1.3) end
		end),
	},
	copy_add = {
		life_rating = -4,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Alchemist",
	desc = {
		"An Alchemist is a manipulator of materials using magic.",
		"They do not use the forbidden arcane arts practised by the mages of old - such perverters of nature have been shunned or actively hunted down since the Spellblaze.",
		"Alchemists can transmute gems to bring forth elemental effects, turning them into balls of fire, torrents of acid, and other effects.  They can also reinforce armour with magical effects using gems, and channel arcane staffs to produce bolts of energy.",
		"Though normally physically weak, most alchemists are accompanied by magical golems which they construct and use as bodyguards.  These golems are enslaved to their master's will, and can grow in power as their master advances through the arts.",
		"Their most important stats are: Magic and Dexterity",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +3 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +5 Magic, +1 Willpower, +0 Cunning",
	},
	stats = { mag=5, dex=3, wil=1, },
	talents_types = {
		["spell/explosives"]={true, 0.3},
		["spell/infusion"]={true, 0.3},
		["spell/golemancy"]={true, 0.3},
		["spell/advanced-golemancy"]={false, 0.3},
		["spell/stone-alchemy"]={true, 0.3},
		["spell/fire-alchemy"]={false, 0.3},
		["spell/staff-combat"]={true, 0.3},
		["cunning/survival"]={false, -0.1},
		["technique/combat-training"]={false, 0},
	},
	talents = {
		[ActorTalents.T_CREATE_ALCHEMIST_GEMS] = 1,
		[ActorTalents.T_REFIT_GOLEM] = 1,
		[ActorTalents.T_THROW_BOMB] = 1,
		[ActorTalents.T_FIRE_INFUSION] = 1,
		[ActorTalents.T_CHANNEL_STAFF] = 1,
	},
	copy = {
		max_life = 90,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000}
		},
		resolvers.inventory{ id=true,
			{type="gem",},
			{type="gem",},
			{type="gem",},
		},
		resolvers.generic(function(self) self:birth_create_alchemist_golem() end),
		birth_create_alchemist_golem = function(self)
			-- Make and wield some alchemist gems
			local t = self:getTalentFromId(self.T_CREATE_ALCHEMIST_GEMS)
			local gem = t.make_gem(self, t, "GEM_AGATE")
			self:wearObject(gem, true, true)
			self:sortInven()

			-- Invoke the golem
			if not self.alchemy_golem then
				local t = self:getTalentFromId(self.T_REFIT_GOLEM)
				t.action(self, t)
			end
		end,
	},
	copy_add = {
		life_rating = -1,
	},
}
