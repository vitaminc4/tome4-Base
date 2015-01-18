-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2015 Nicolas Casalini
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

-- some helpers

local function cooldown_folds(self, t)
	for tid, cd in pairs(self.talents_cd) do
		local tt = self:getTalentFromId(tid)
		if tt.type[1]:find("^chronomancy/manifold") and t ~= tt then
			self:alterTalentCoolingdown(tt, -1)
		end
	end
end

local function do_folds(self, target)
	for tid, _ in pairs(self.talents) do
		local tt = self:getTalentFromId(tid)
		if tt.type[1]:find("^chronomancy/manifold") and self:knowTalent(tid) then
			game.logPlayer(self, "%s", tid)
			self:callTalent(tid, "doFold", target)
		end
	end
end

newTalent{
	name = "Fold Fate",
	type = {"chronomancy/manifold", 1},
	cooldown = 8,
	points = 5,
	mode = "passive",
	range = 10,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t}
	end,
	radius = function(self, t) return self:getTalentLevel(t) >= 4 and 2 or 1 end,
	getChance = function(self, t) return self:callTalent(self.T_WEAPON_MANIFOLD, "getChance") end, 
	getDamage = function(self, t) return self:callTalent(self.T_WEAPON_MANIFOLD, "getDamage") end,
	doFold = function(self, t, target)
		if rng.percent(t.getChance(self, t)) then
			if not self:isTalentCoolingDown(t.id) then
				-- Temporal Burst
				local tgts = 0
				local tg = self:getTalentTarget(t)
				self:project(tg, target.x, target.y, function(px, py, tg, self)
					local target = game.level.map(px, py, Map.ACTOR)
					if target then
						DamageType:get(DamageType.TEMPORAL).projector(self, target.x, target.y, DamageType.TEMPORAL, t.getDamage(self, t))
					end
				end)
				
				self.energy.value = self.energy.value + (tgts*100)
				self:startTalentCooldown(t.id)
			else
				cooldown_folds(self, t)
			end
		end	
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[When you hit with Weapon Folding you have a %d%% chance of dealing an additional %0.2f temporal damage to enemies in a radius of %d.  For each target hit you gain 10%% of a turn.
		This effect has a cooldown.  If it triggers while on cooldown it will reduce the cooldown of Fold Gravity and Fold Warp by one turn.]])
		:format(chance, damDesc(self, DamageType.TEMPORAL, damage), radius)
	end,
}

newTalent{
	name = "Fold Warp",
	type = {"chronomancy/manifold", 1},
	cooldown = 8,
	points = 5,
	mode = "passive",
	range = 10,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t}
	end,
	radius = function(self, t) return self:getTalentLevel(t) >= 4 and 2 or 1 end,
	getChance = function(self, t) return self:callTalent(self.T_WEAPON_MANIFOLD, "getChance") end, 
	getDamage = function(self, t) return self:callTalent(self.T_WEAPON_MANIFOLD, "getDamage") end,
	getDuration = function(self, t) return self:callTalent(self.T_WEAPON_MANIFOLD, "getDuration") end,
	doFold = function(self, t, target)
		if rng.percent(t.getChance(self, t)) then
			if not self:isTalentCoolingDown(t.id) then
				-- Warp Burst
				local tgts = 0
				local tg = self:getTalentTarget(t)
				self:project(tg, target.x, target.y, function(px, py, tg, self)
					local target = game.level.map(px, py, Map.ACTOR)
					if target then
						DamageType:get(DamageType.WARP).projector(self, target.x, target.y, DamageType.WARP, t.getDamage(self, t))
						randomWarpEffect(self, t, target)
					end
				end)
				
				self.energy.value = self.energy.value + (tgts*100)
				self:startTalentCooldown(t.id)
			else
				cooldown_folds(self, t)
			end
		end	
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local duration = t.getDuration(self, t)
		return ([[When you hit with Weapon Folding you have a %d%% chance of dealing an additional %0.2f physical and %0.2f temporal (warp) damage to enemies in a radius of %d.
		Each target hit may be stunned, blinded, pinned, or confused for %d turns.
		This effect has a cooldown.  If it triggers while on cooldown it will reduce the cooldown of Fold Gravity and Fold Fate by one turn.]])
		:format(chance, damDesc(self, DamageType.TEMPORAL, damage/2), damDesc(self, DamageType.PHYSICAL, damage/2), radius, duration)
	end,
}

newTalent{
	name = "Fold Gravity",
	type = {"chronomancy/manifold", 1},
	cooldown = 8,
	points = 5,
	mode = "passive",
	range = 10,
	radius = function(self, t) return self:getTalentLevel(t) >= 4 and 2 or 1 end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t}
	end,
	getChance = function(self, t) return self:callTalent(self.T_WEAPON_MANIFOLD, "getChance") end, 
	getDamage = function(self, t) return self:callTalent(self.T_WEAPON_MANIFOLD, "getDamage") end,
	getDuration = function(self, t) return self:callTalent(self.T_WEAPON_MANIFOLD, "getDuration") end,
	getSlow = function(self, t) return self:callTalent(self.T_WEAPON_MANIFOLD, "getSlow") end,
	doFold = function(self, t, target)
		if rng.percent(t.getChance(self, t)) then
			if not self:isTalentCoolingDown(t.id) then
				-- Gravity Burst
				local tg = self:getTalentTarget(t)
				self:project(tg, target.x, target.y, function(px, py, tg, self)
					local target = game.level.map(px, py, Map.ACTOR)
					if target then
						target:setEffect(target.EFF_SLOW, t.getDuration(self, t), {power=t.getSlow(self, t), apply_power=getParadoxSpellpower(self, t), no_ct_effect=true})
						DamageType:get(DamageType.GRAVITY).projector(self, target.x, target.y, DamageType.GRAVITY, t.getDamage(self, t))
					end
				end)
				self:startTalentCooldown(t.id)
			else
				cooldown_folds(self, t)
			end
		end	
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local slow = t.getSlow(self, t)
		local duration = t.getDuration(self, t)
		return ([[When you hit with Weapon Folding you have a %d%% chance of dealing an additional %0.2f physical (gravity) damage to enemies in a radius of %d.
		Affected targets may also be slowed, decreasing their global speed speed by %d%% for %d turns
		This effect has a cooldown.  If it triggers while on cooldown it will reduce the cooldown of Fold Fate and Fold Warp by one turn.]])
		:format(chance, damDesc(self, DamageType.PHYSICAL, damage), radius, slow, duration)
	end,
}

newTalent{
	name = "Weapon Folding",
	type = {"chronomancy/temporal-combat", 1},
	mode = "sustained",
	require = chrono_req1,
	sustain_paradox = 12,
	cooldown = 10,
	tactical = { BUFF = 2 },
	points = 5,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 40, getParadoxSpellpower(self, t)) end,
	doWeaponFolding = function(self, t, target)  
		local dam = t.getDamage(self, t)
		do_folds(self, target)
		if not target.dead then
			DamageType:get(DamageType.TEMPORAL).projector(self, target.x, target.y, DamageType.TEMPORAL, dam)
		end
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Folds a single dimension of your weapons (or ammo) upon itself, adding %0.2f temporal damage to your strikes and increasing your armor penetration by %d.
		The armor penetration and damage will increase with your Spellpower.]]):format(damDesc(self, DamageType.TEMPORAL, damage), damage/2)
	end,
}

newTalent{
	name = "Invigorate",
	type = {"chronomancy/temporal-combat", 2},
	require = chrono_req2,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 20) end,
	cooldown = 24,
	fixed_cooldown = true,
	tactical = { HEAL = 1 },
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentLimit(t, 14, 4, 8))) end, -- Limit < 14
	getPower = function(self, t) return self:combatTalentSpellDamage(t, 10, 50, getParadoxSpellpower(self, t)) end,
	action = function(self, t)
		self:setEffect(self.EFF_INVIGORATE, t.getDuration(self,t), {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		local duration = t.getDuration(self, t)
		return ([[For the next %d turns, you recover %0.1f life and %0.1f stamina per turn, and most other talents on cooldown will refresh twice as fast as usual.
		The life and stamina regeneration will increase with your Spellpower.]]):format(duration, power, power/2)
	end,
}

newTalent{
	name = "Weapon Manifold",
	type = {"chronomancy/temporal-combat", 3},
	require = chrono_req3,
	mode = "passive",
	points = 5,
	cooldown = 8,
	on_learn = function(self, t)
		local lev = self:getTalentLevelRaw(t)
		if lev == 1 then
			self:learnTalent(Talents.T_FOLD_FATE, true, nil, {no_unlearn=true})
			self:learnTalent(Talents.T_FOLD_GRAVITY, true, nil, {no_unlearn=true})
			self:learnTalent(Talents.T_FOLD_WARP, true, nil, {no_unlearn=true})
		end
	end,
	on_unlearn = function(self, t)
		local lev = self:getTalentLevelRaw(t)
		if lev == 0 then
			self:unlearnTalent(Talents.T_FOLD_FATE)
			self:unlearnTalent(Talents.T_FOLD_GRAVITY)
			self:unlearnTalent(Talents.T_FOLD_WARP)
		end
	end,
	radius = function(self, t) return self:getTalentLevel(t) >= 4 and 2 or 1 end,
	getDuration = function(self, t) return 4 end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 40, getParadoxSpellpower(self, t)) end,
	getChance = function(self, t) return self:combatTalentLimit(t, 40, 10, 30) end,
	getSlow = function(self, t) return 30 end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local slow = t.getSlow(self, t)
		local duration = t.getDuration(self, t)
		return ([[You now have a %d%% chance to Fold Fate, Gravity, or Warp into your Weapon Folding damage.
		
		Fold Fate: Deals %0.2f temporal damage to enemies in a radius of %d.  For each enemy hit you gain 10%% of a turn.
		Fold Warp: Deals %0.2f physical and %0.2f temporal damage to enemies in a radius of %d.  Affected targets may be stunned, blinded, confused, or pinned for %d turns.
		Fold Gravity: Deals %0.2f physical damage to enemies in a radius of %d.  Affected targets will be slowed (%d%%) for %d turns.
		
		Each Fold has an eight turn cooldown.  If an effect is triggered while on cooldown it will reduce the cooldown of the other two folds by one turn.]]
		):format(chance, damDesc(self, DamageType.TEMPORAL, damage), radius, damDesc(self, DamageType.PHYSICAL, damage/2), damDesc(self, DamageType.TEMPORAL, damage/2), radius,
		duration, damDesc(self, DamageType.PHYSICAL, damage), radius, slow, duration)
	end,
}

newTalent{
	name = "Breach",
	type = {"chronomancy/temporal-combat", 4},
	require = chrono_req4,
	points = 5,
	cooldown = 8,
	paradox = function (self, t) return getParadoxCost(self, t, 15) end,
	tactical = { ATTACK = {weapon = 2}, DISABLE = 3 },
	requires_target = true,
	range = function(self, t)
		if self:hasArcheryWeapon("bow") then return util.getval(archery_range, self, t) end
		return 1
	end,
	is_melee = function(self, t) return not self:hasArcheryWeapon("bow") end,
	speed = function(self, t) return self:hasArcheryWeapon("bow") and "archery" or "weapon" end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.5) end,
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentScale(t, 3, 7))) end,
	on_pre_use = function(self, t, silent) if self:attr("disarmed") then if not silent then game.logPlayer(self, "You require a weapon to use this talent.") end return false end return true end,
	archery_onhit = function(self, t, target, x, y)
		target:setEffect(target.EFF_BREACH, t.getDuration(self, t), {})
	end,
	action = function(self, t)
		local mainhand, offhand = self:hasDualWeapon()

		if self:hasArcheryWeapon("bow") then
			-- Ranged attack
			local targets = self:archeryAcquireTargets({type="bolt"}, {one_shot=true, no_energy = true})
			if not targets then return end
			self:archeryShoot(targets, t, {type="bolt"}, {mult=t.getDamage(self, t)})
		elseif mainhand then
			-- Melee attack
			local tg = {type="hit", range=self:getTalentRange(t), talent=t}
			local x, y, target = self:getTarget(tg)
			if not target or not self:canProject(tg, x, y) then return nil end
			local hitted = self:attackTarget(target, nil, t.getDamage(self, t), true)

			if hitted then
				target:setEffect(target.EFF_BREACH, t.getDuration(self, t), {apply_power=getParadoxSpellpower(self, t)})
			end
		else
			game.logPlayer(self, "You cannot use Breach without an appropriate weapon!")
			return nil
		end

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local damage = t.getDamage(self, t) * 100
		return ([[Attack the target with either your bow or melee weapons for %d%% damage.
		If the attack hits you'll breach the target's immunities, reducing armor hardiness, stun, pin, blindness, and confusion immunity by 50%% for %d turns.
		Breach chance scales with your Spellpower.]])
		:format(damage, duration)
	end
}