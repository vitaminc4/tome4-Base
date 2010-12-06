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

--local Object = require "engine.Object"

newTalent{
	name = "Twilight",
	type = {"divine/twilight", 1},
	require = divi_req1,
	points = 5,
	cooldown = 6,
	positive = 15,
	tactical = {
		BUFF = 10,
	},
	range = 20,
	action = function(self, t)
		if self:isTalentActive(self.T_DARKEST_LIGHT) then
			game.logPlayer(self, "You can't use Twilight while Darkest Light is active.")
			return
		end
		self:incNegative(20 + self:getTalentLevel(t) * self:getCun(40))
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[You stand between the darkness and the light, allowing you to convert 15 positive energy into %d negative energy.
		The effect will increase with the Cunning stat.]]):
		format(20 + self:getTalentLevel(t) * self:getCun(40))
	end,
}

newTalent{
	name = "Jumpgate: Teleport To", short_name = "JUMPGATE_TELEPORT",
	type = {"divine/other", 1},
	points = 1,
	cooldown = 7,
	negative = 14,
	type_no_req = true,
	tactical = {
		MOVE = 10,
	},
	no_npc_use = true,
	action = function(self, t)
		local eff = self.sustain_talents[self.T_JUMPGATE]
		if not eff then
			game.logPlayer(self, "You must sustain the Jumpgate spell to be able to teleport.")
			return
		end
		if eff.jumpgate_level ~= game.zone.short_name .. "-" .. game.level.level then
			game.logPlayer(self, "The destination is too far away.")
			return
		end
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:teleportRandom(eff.jumpgate_x, eff.jumpgate_y, 1)
		game.level.map:particleEmitter(eff.jumpgate_x, eff.jumpgate_y, 1, "teleport")
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		return ([[Instantly travel to your jumpgate.]])
	end,
}

newTalent{
	name = "Jumpgate",
	type = {"divine/twilight", 2},
	require = divi_req2,
	mode = "sustained", no_sustain_autoreset = true,
	points = 5,
	cooldown = function(self, t) return 24 - 4 * self:getTalentLevelRaw(t) end,
	sustain_negative = 20,
	no_npc_use = true,
	tactical = {
		MOVE = 10,
	},
	on_learn = function(self, t)
		if self:getTalentLevel(t) >= 4 then
			if not self:knowTalent(self.T_JUMPGATE_TWO) then
				self:learnTalent(self.T_JUMPGATE_TWO)
			end
		elseif not self:knowTalent(self.T_JUMPGATE_TELEPORT) then
			self:learnTalent(self.T_JUMPGATE_TELEPORT)
		end
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self:unlearnTalent(self.T_JUMPGATE_TELEPORT)
		elseif self:getTalentLevel(t) < 4 and self:knowTalent(self.T_JUMPGATE_TWO) then
			self:unlearnTalent(self.T_JUMPGATE_TWO)
		end
	end,
	activate = function(self, t)
		local terrain = game.level.map(game.player.x, game.player.y, engine.Map.TERRAIN)
		local jumpgate = mod.class.Object.new(terrain)
		-- Force the tile to be remembered
	--	jumpgate.always_remember = true
		jumpgate.old_feat = terrain
		local jumpgate_overlay = engine.Entity.new{
			image = "terrain/wormhole.png",
			display = '&', color=colors.PURPLE,
			display_on_seen = true,
			display_on_remember = true,
		}
		if not jumpgate.add_displays then
			jumpgate.add_displays = {jumpgate_overlay}
		else
			table.append(jumpgate.add_displays, jumpgate_overlay)
		end
		game.level.map(game.player.x, game.player.y, engine.Map.TERRAIN, jumpgate)
		local ret = {
			jumpgate = jumpgate,
			jumpgate_x = game.player.x,
			jumpgate_y = game.player.y,
			jumpgate_level = game.zone.short_name .. "-" .. game.level.level,
			particle = self:addParticles(Particles.new("time_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		-- Reset the terrain tile
		game.level.map(p.jumpgate_x, p.jumpgate_y, engine.Map.TERRAIN, p.jumpgate.old_feat)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		return ([[Create a shadow jumpgate at your location. As long as you sustain this spell you can use 'Jumpgate: Teleport' to instantly travel to the jumpgate.
		At talent level 4 you learn to create and sustain a second jumpgate.]])
	end,
}

newTalent{
	name = "Mind Blast",
	type = {"divine/twilight",3},
	require = divi_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 15,
	negative = 15,
	tactical = {
		ATTACKAREA = 10,
	},
	range = 3,
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="ball", range=0, radius=self:getTalentRange(t), talent=t, friendlyfire=false}
		self:project(tg, self.x, self.y, DamageType.CONFUSION, {
			dur = math.floor(self:getTalentLevel(t) + self:getCun(5)) + 2,
			dam = 50 + self:getTalentLevelRaw(t)*10
		})
		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		return ([[Let out a mental cry that shatters the will of your targets, confusing them for %d turns.
		The duration will improve with the Cunning stat.]]):
		format(math.floor(self:getTalentLevel(t) + self:getCun(5)) + 2)
	end,
}

newTalent{
	name = "Shadow Simulacrum",
	type = {"divine/twilight", 4},
	require = divi_req4,
	random_ego = "attack",
	points = 5,
	cooldown = 30,
	negative = 10,
	tactical = {
		ATTACK = 10,
	},
	requires_target = true,
	range = 10,
	no_npc_use = true,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		local target = game.level.map(tx, ty, Map.ACTOR)
		if not target or self:reactionToward(target) >= 0 then return end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 1, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		allowed = 2 + math.ceil(self:getTalentLevelRaw(t) / 2 )

		if target.rank >= 3.5 or -- No boss
			target:reactionToward(self) >= 0 or -- No friends
			target.size_category > allowed
			then
			game.logPlayer(self, "%s resists!", target.name:capitalize())
			return true
		end

		modifier = self:getCun(10) * self:getTalentLevel(t)

		local m = target:clone{
			no_drops = true,
			faction = self.faction,
			summoner = self, summoner_gain_exp=true,
			summon_time = math.ceil(self:getTalentLevel(t)+self:getCun(10)) + 3,
			ai_target = {actor=target},
			ai = "summoned", ai_real = target.ai,
			resists = { all = modifier, [DamageType.DARKNESS] = 50, [DamageType.LIGHT] = - 50, },
			desc = [[A dark shadowy shape who's form resembles the creature it was taken from.]],
		}

		m.energy.value = 0
		m.life = m.life / (2 - (modifier / 50))
		m.forceLevelup = false
		-- Handle special things
		m.on_die = nil
		m.on_acquire_target = nil
		m.seen_by = nil
		m.can_talk = nil
		m.clone_on_hit = nil
		if m.talents.T_SUMMON then m.talents.T_SUMMON = nil end
		if m.talents.T_MULTIPLY then m.talents.T_MULTIPLY = nil end

		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "shadow")

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local allowed = 2 + math.ceil(self:getTalentLevelRaw(t) / 2 )
		if allowed < 4 then
			size = "medium"
		elseif allowed < 5 then
			size = "big"
		else
			size = "huge"
		end
		return ([[Creates a shadowy copy of a target up to size %s. The copy will attack its progenitor immediately.
		It stays for %d turns and its duration, life, and resistances scale with the Cunning stat.]]):format(size, math.ceil(self:getTalentLevel(t)+self:getCun(10)) + 3)
	end,
}

-- Extra Jumpgates

newTalent{
	name = "Jumpgate Two",
	type = {"divine/other", 1},
	mode = "sustained", no_sustain_autoreset = true,
	points = 1,
	cooldown = 20,
	sustain_negative = 20,
	no_npc_use = true,
	type_no_req = true,
	tactical = {
		MOVE = 10,
	},
	on_learn = function(self, t)
		if not self:knowTalent(self.T_JUMPGATE_TELEPORT_TWO) then
			self:learnTalent(self.T_JUMPGATE_TELEPORT_TWO)
		end
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self:unlearnTalent(self.T_JUMPGATE_TELEPORT_TWO)
		end
	end,
	activate = function(self, t)
		local terrain = game.level.map(game.player.x, game.player.y, engine.Map.TERRAIN)
		local jumpgate2 = mod.class.Object.new(terrain)
		-- Force the tile to be remembered
	--	jumpgate2.always_remember = true
		jumpgate2.old_feat = terrain
		local jumpgate2_overlay = engine.Entity.new{
			display = '&', color=colors.PURPLE,
			image = "terrain/wormhole.png",
			display_on_seen = true,
			display_on_remember = true,
		}
		if not jumpgate2.add_displays then
			jumpgate2.add_displays = {jumpgate2_overlay}
		else
			table.append(jumpgate2.add_displays, jumpgate2_overlay)
		end
		game.level.map(game.player.x, game.player.y, engine.Map.TERRAIN, jumpgate2)
		local ret = {
			jumpgate2 = jumpgate2,
			jumpgate2_x = game.player.x,
			jumpgate2_y = game.player.y,
			jumpgate2_level = game.zone.short_name .. "-" .. game.level.level,
			particle = self:addParticles(Particles.new("time_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		-- Reset the terrain tile
		game.level.map(p.jumpgate2_x, p.jumpgate2_y, engine.Map.TERRAIN, p.jumpgate2.old_feat)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		return ([[Create a shadow jumpgate at your location. As long as you sustain this spell you can use 'Jumpgate Two: Teleport' to instantly travel to the jumpgate.]])
	end,
}

newTalent{
	name = "Jumpgate Two: Teleport To", short_name = "JUMPGATE_TELEPORT_TWO",
	type = {"divine/other", 1},
	points = 1,
	cooldown = 7,
	negative = 14,
	type_no_req = true,
	tactical = {
		MOVE = 10,
	},
	no_npc_use = true,
	action = function(self, t)
		local eff = self.sustain_talents[self.T_JUMPGATE_TWO]
		if not eff then
			game.logPlayer(self, "You must sustain the Jumpgate Two spell to be able to teleport.")
			return
		end
		if eff.jumpgate2_level ~= game.zone.short_name .. "-" .. game.level.level then
			game.logPlayer(self, "The destination is too far away.")
			return
		end
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:teleportRandom(eff.jumpgate2_x, eff.jumpgate2_y, 1)
		game.level.map:particleEmitter(eff.jumpgate2_x, eff.jumpgate2_y, 1, "teleport")
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		return ([[Instantly travel to your second jumpgate.]])
	end,
}
