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

newTalent{
	name = "Bellowing Roar",
	type = {"wild-gift/fire-drake", 1},
	require = gifts_req1,
	points = 5,
	random_ego = "attack",
	message = "@Source@ roars!",
	equilibrium = 3,
	cooldown = 20,
	range = 0,
	radius = function(self, t)
		return 2 + self:getTalentLevelRaw(t)
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	tactical = { DEFEND = 1, DISABLE = 3 },
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.CONFUSION, {dur=3, dam=40 + 6 * self:getTalentLevel(t)}, {type="flame"})
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		return ([[You let out a powerful roar that sends your foes into utter confusion for 3 turns in a radius of %d.]]):format(radius)
	end,
}

newTalent{
	name = "Wing Buffet",
	type = {"wild-gift/fire-drake", 2},
	require = gifts_req2,
	points = 5,
	random_ego = "attack",
	equilibrium = 7,
	cooldown = 10,
	range = 0,
	radius = function(self, t)
		return 4 + self:getTalentLevelRaw(t)
	end,
	direct_hit = true,
	tactical = { DEFEND = 1, DISABLE = 2, ESCAPE = 1 },
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.PHYSKNOCKBACK, {dam=self:combatTalentStatDamage(t, "str", 15, 90), dist=4})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[You summon a powerful gust of wind, knocking back your foes up to 4 titles away and damaging them for %d.
		The damage will increase with the Strength stat]]):format(self:combatTalentStatDamage(t, "str", 15, 90))
	end,
}

newTalent{
	name = "Devouring Flame",
	type = {"wild-gift/fire-drake", 3},
	require = gifts_req3,
	points = 5,
	random_ego = "attack",
	equilibrium = 10,
	cooldown = 35,
	tactical = { ATTACKAREA = 2 },
	range = 10,
	radius = 2,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getDamage = function(self, t)
		return self:combatTalentStatDamage(t, "wil", 15, 120)
	end,
	getDuration = function(self, t)
		return 2 + self:getTalentLevelRaw(t)
	end,
	action = function(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		local dam = t.getDamage(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, duration,
			DamageType.FIRE, dam,
			radius,
			5, nil,
			{type="inferno"},
			nil, true
		)
		game:playSoundNear(self, "talents/devouringflame")
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local duration = t.getDuration(self, t)
		return ([[Spit a cloud of flames doing %0.2f fire damage in a radius of %d each turn for %d turns.
		The damage will increase with the Willpower stat]]):format(damDesc(self, DamageType.FIRE, dam), radius, duration)
	end,
}

newTalent{
	name = "Fire Breath",
	type = {"wild-gift/fire-drake", 4},
	require = gifts_req4,
	points = 5,
	random_ego = "attack",
	equilibrium = 12,
	cooldown = 12,
	message = "@Source@ breathes fire!",
	tactical = { ATTACKAREA = {[DamageType.FIRE] = 2} },
	range = 0,
	radius = function(self, t) return 4 + self:getTalentLevelRaw(t) end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIREBURN, {dam=self:combatTalentStatDamage(t, "str", 30, 550), dur=3, initial=70})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_fire", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[You breathe fire in a frontal cone. Any target caught in the area will take %0.2f fire damage over 3 turns.
		The damage will increase with the Strength stat]]):format(damDesc(self, DamageType.FIRE, self:combatTalentStatDamage(t, "str", 30, 550)))
	end,
}
