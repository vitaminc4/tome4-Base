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

local newInscription = function(t)
	for i = 1, 10 do
		local tt = table.clone(t)
		tt.short_name = tt.name:upper():gsub("[ ]", "_").."_"..i
		newTalent(tt)
	end
end

-----------------------------------------------------------------------
-- Infusions
-----------------------------------------------------------------------
newInscription{
	name = "Infusion: Healing",
	type = {"inscriptions/infusions", 1},
	points = 1,
	cooldown = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.cooldown
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:heal(data.heal + data.inc_stat)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the infusion to heal yourself for %d life.]]):format(data.heal + data.inc_stat)
	end,
}

newInscription{
	name = "Infusion: Cure",
	type = {"inscriptions/infusions", 1},
	points = 1,
	cooldown = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.cooldown
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)

		local target = self
		local effs = {}
		local known = false

		-- Go through all spell effects
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if data.what[e.type] then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		for i = 1, 1 do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				target:removeEffect(eff[2])
				known = true
			end
		end
		if known then
			game.logSeen(self, "%s is cured!", self.name:capitalize())
		end
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local what = table.concat(table.keys(data.what), ", ")
		return ([[Activate the infusion to cure yourself of %s effects.]]):format(what)
	end,
}

newInscription{
	name = "Infusion: Movement",
	type = {"inscriptions/infusions", 1},
	points = 1,
	cooldown = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.cooldown
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_FREE_ACTION, data.dur + data.inc_stat, {power=1})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the infusion to prevent stuns, dazes and pinning effects for %d turns.]]):format(data.dur + data.inc_stat)
	end,
}

-----------------------------------------------------------------------
-- Runes
-----------------------------------------------------------------------
newInscription{
	name = "Rune: Phase Door",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	cooldown = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.cooldown
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:teleportRandom(self.x, self.y, data.range + data.inc_stat)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to teleport randomly in a range of %d.]]):format(data.range + data.inc_stat)
	end,
}

newInscription{
	name = "Rune: Teleportation",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	cooldown = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.cooldown
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:teleportRandom(self.x, self.y, data.range + data.inc_stat, 15)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to teleport randomly in a range of %d with a minimun range of 15.]]):format(data.range + data.inc_stat)
	end,
}

newInscription{
	name = "Rune: Shielding",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	cooldown = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.cooldown
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_DAMAGE_SHIELD, data.dur, {power=data.power + data.inc_stat})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to create a protective shield at most absorbing %d damage for %d turns.]]):format(data.power + data.inc_stat, data.dur)
	end,
}

newInscription{
	name = "Rune: Invisibility",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	cooldown = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.cooldown
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_INVISIBILITY, data.dur, {power=data.power + data.inc_stat})
		self:usedInscription(t.short_name)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to become invisible (power %d) for %d turns.]]):format(data.power + data.inc_stat, data.dur)
	end,
}

newInscription{
	name = "Rune: Speed",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	cooldown = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.cooldown
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_SPEED, data.dur, {power=(data.power + data.inc_stat) / 100})
		self:usedInscription(t.short_name)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to increase your global speed by %d%% for %d turns.]]):format(data.power + data.inc_stat, data.dur)
	end,
}
