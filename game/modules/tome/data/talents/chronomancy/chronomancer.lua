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

-- Class Trees
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/blade-threading", name = "Blade Threading", description = "A blend of chronomancy and dual-weapon combat." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/bow-threading", name = "Bow Threading", description = "A blend of chronomancy and ranged combat." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/temporal-combat", name = "Temporal Combat", description = "A blend of chronomancy and physical combat." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/guardian", name = "Temporal Guardian", description = "Warden combat training and techniques." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/threaded-combat", name = "Threaded Combat", min_lev = 10, description = "A blend of ranged and dual-weapon combat." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/temporal-hounds", name = "Temporal Hounds", min_lev = 10, description = "Call temporal hounds to aid you in combat." }

newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/flux", name = "flux", description = "Fluctuate spacetime." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/gravity", name = "gravity", description = "Call upon the force of gravity to crush, push, and pull your foes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/matter", name = "matter", description = "Change and shape matter itself." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/spacetime-folding", name = "Spacetime Folding", description = "Mastery of folding points in space." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/speed-control", name = "Speed Control", description = "Control how fast objects and creatures move through spacetime." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/stasis", name = "stasis", description = "Stabilize spacetime." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/timeline-threading", name = "Timeline Threading", min_lev = 10, description = "Examine and alter the timelines that make up the spacetime continuum." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/timetravel", name = "timetravel", description = "Directly manipulate the flow of time" }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/spellbinding", name = "Spellbinding", min_lev = 10, description = "Manipulate chronomantic spells." }

-- Generic Chronomancy
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/chronomancy", name = "Chronomancy", generic = true, description = "Allows you to glimpse the future, or become more aware of the present." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/energy", name = "energy", generic = true, description = "Manipulate raw energy by addition or subtraction." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/fate-weaving", name = "Fate Weaving", generic = true, description = "Weave the threads of fate." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/spacetime-weaving", name = "Spacetime Weaving", generic = true, description = "Weave the threads of spacetime." }

-- Misc and Outdated Trees
newTalentType{ no_silence=true, is_spell=true, type="chronomancy/manifold", name = "Manifold", generic = true, description = "Passive effects that Weapon Folding can trigger." }
newTalentType{ no_silence=true, is_spell=true, type="chronomancy/other", name = "Other", generic = true, description = "Miscellaneous Chronomancy effects." }

newTalentType{ no_silence=true, is_spell=true, type="chronomancy/age-manipulation", name = "Age Manipulation", description = "Manipulate the age of creatures you encounter." }
newTalentType{ no_silence=true, is_spell=true, type="chronomancy/temporal-archery", name = "Temporal Archery", description = "A blend of chronomancy and ranged combat." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/paradox", name = "paradox", description = "Break the laws of spacetime." }

-- Anomalies are not learnable but can occur instead of an intended spell when paradox gets to high.
newTalentType{ no_silence=true, is_spell=true, type="chronomancy/anomalies", name = "anomalies", description = "Spacetime anomalies that can randomly occur when paradox is to high." }

-- Generic requires for chronomancy spells based on talent level
chrono_req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
chrono_req2 = {
	stat = { mag=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
chrono_req3 = {
	stat = { mag=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
chrono_req4 = {
	stat = { mag=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
chrono_req5 = {
	stat = { mag=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

chrono_req_high1 = {
	stat = { mag=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
chrono_req_high2 = {
	stat = { mag=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
chrono_req_high3 = {
	stat = { mag=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
chrono_req_high4 = {
	stat = { mag=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
chrono_req_high5 = {
	stat = { mag=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

-- Generic requires for non-spell temporal effects based on talent level
temporal_req1 = {
	stat = { wil=function(level) return 12 + (level-1)*2 end},
	level = function(level) return 0 + (level-1) end,
}
temporal_req2 = {
	stat = { wil=function(level) return 20 + (level-1)*2 end},
	level = function(level) return 4 + (level-1) end,
}
temporal_req3 = {
	stat = { wil=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
temporal_req4 = {
	stat = { wil=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
temporal_req5 = {
	stat = { wil=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

load("/data/talents/chronomancy/age-manipulation.lua")
load("/data/talents/chronomancy/blade-threading.lua")
load("/data/talents/chronomancy/bow-threading.lua")
load("/data/talents/chronomancy/chronomancy.lua")
load("/data/talents/chronomancy/energy.lua")
load("/data/talents/chronomancy/fate-weaving.lua")
load("/data/talents/chronomancy/flux.lua")
load("/data/talents/chronomancy/gravity.lua")
load("/data/talents/chronomancy/guardian.lua")
load("/data/talents/chronomancy/matter.lua")
load("/data/talents/chronomancy/paradox.lua")
load("/data/talents/chronomancy/spacetime-folding.lua")
load("/data/talents/chronomancy/spacetime-weaving.lua")
load("/data/talents/chronomancy/speed-control.lua")
load("/data/talents/chronomancy/spellbinding.lua")
load("/data/talents/chronomancy/stasis.lua")
load("/data/talents/chronomancy/temporal-archery.lua")
load("/data/talents/chronomancy/temporal-combat.lua")
load("/data/talents/chronomancy/temporal-hounds.lua")
load("/data/talents/chronomancy/threaded-combat.lua")
load("/data/talents/chronomancy/timeline-threading.lua")
load("/data/talents/chronomancy/timetravel.lua")

-- Loads many functions and misc. talents
load("/data/talents/chronomancy/other.lua")

-- Anomalies, not learnable talents that may be cast instead of the intended spell when paradox gets to high
load("/data/talents/chronomancy/anomalies.lua")

-- Paradox Functions

-- Paradox modifier.  This dictates paradox cost and spellpower scaling
-- Note that 300 is the optimal balance
-- Caps at -50% and +50%
getParadoxModifier = function (self)
	local paradox = self:getParadox()
	local pm = math.sqrt(paradox / 300)
	if paradox < 300 then pm = paradox/300 end
	pm = util.bound(pm, 0.5, 1.5)
	return pm
end

-- Paradox cost (regulates the cost of paradox talents)
getParadoxCost = function (self, t, value)
	local pm = getParadoxModifier(self)
	local multi = 1
	if self:attr("paradox_cost_multiplier") then
		multi = 1 - self:attr("paradox_cost_multiplier")
	end
	return (value * pm) * multi
end

-- Paradox Spellpower (regulates spellpower for chronomancy)
getParadoxSpellpower = function(self, t, mod, add)
	local pm = getParadoxModifier(self)
	local mod = mod or 1

	-- Empower?
	local p = self:isTalentActive(self.T_EMPOWER)
	if p and p.talent == t.id then
		pm = pm + self:callTalent(self.T_EMPOWER, "getPower")
	end

	local spellpower = self:combatSpellpower(mod * pm, add)
	return spellpower
end

-- Extension Spellbinding
getExtensionModifier = function(self, t, value)
	local pm = getParadoxModifier(self)
	local mod = 1
	
	local p = self:isTalentActive(self.T_EXTENSION)
	if p and p.talent == t.id then
		mod = mod + self:callTalent(self.T_EXTENSION, "getPower")
	end
	
	-- paradox modifier rounds down
	value = math.floor(value * pm)
	-- extension modifier rounds up
	value = math.ceil(value * mod)
	
	return math.max(1, value)
end

-- Tunes paradox
tuneParadox = function(self, t, value)
	local dox = self:getParadox() - (self.preferred_paradox or 300)
	local fix = math.min( math.abs(dox), value )
	if dox > 0 then
		self:incParadox( -fix )
	elseif dox < 0 then
		self:incParadox( fix )
	end
end

--- Warden weapon functions
-- Checks for weapons in main and quickslot
doWardenPreUse = function(self, weapon, silent)
	if weapon == "bow" then
		if not self:hasArcheryWeapon("bow") and not self:hasArcheryWeaponQS("bow") then
			return false
		end
	end
	if weapon == "dual" then
		if not self:hasDualWeapon() and not self:hasDualWeaponQS() then
			return false
		end
	end
	return true
end

-- Swaps weapons if needed
doWardenWeaponSwap = function(self, t, type, silent)
	local swap = false
	local warden_weapon

	if type == "blade" then
		local mainhand, offhand = self:hasDualWeapon()
		if not mainhand or self:hasArcheryWeapon("bow") then  -- weird but this is lets ogers offhanding daggers still swap
			swap = true
			warden_weapon = "blade"
		end
	end
	if type == "bow" then
		if not self:hasArcheryWeapon("bow") then
			swap = true
			warden_weapon = "bow"
		end
	end
	
	if swap == true then
		local old_inv_access = self.no_inventory_access				-- Make sure clones can swap
		self.no_inventory_access = nil
		self:attr("no_sound", 1)
		self:quickSwitchWeapons(true, "warden", silent)
		self:attr("no_sound", -1)
		self.no_inventory_access = old_inv_access
	end
	
	return swap, dam
end

-- Target helper function for focus fire
checkWardenFocus = function(self)
	local target
	local eff = self:hasEffect(self.EFF_WARDEN_S_FOCUS)
	if eff then
		target = eff.target
	end
	return target
end

-- Spell functions

-- Automatically called by makeParadoxClone()
-- Based on engine/class.lua : clonerecursfull(), with added functionality to skip/replace specified nodes.
local function makeParadoxCloneRecurs(clonetable, d, noclonecall, use_saveinstead, alt_nodes)
	if use_saveinstead and (d.__ATOMIC or d.__CLASSNAME) and d.__SAVEINSTEAD then
		d = d.__SAVEINSTEAD
		if clonetable[d] then return d, 1 end
	end

	local nb = 0
	local add
	local n = {}
	clonetable[d] = n

	local k, e = next(d)
	while k do
		local skip = false
		local nk_alt, ne_alt = nil, nil
		if alt_nodes then
			for node, alt in pairs(alt_nodes) do
				if node == k or node == e then
					if alt.k == nil and alt.v == nil then 
						skip = true
						break
					else
						if alt.k ~= nil then nk_alt = alt.k end
						if alt.v ~= nil then ne_alt = alt.v end
						break
					end
				end
			end
		end
		if not skip then
			local nk, ne
			if nk_alt ~= nil then nk = nk_alt else nk = k end
			if ne_alt ~= nil then ne = ne_alt else ne = e end
			
			if clonetable[nk] then nk = clonetable[nk]
			elseif type(nk) == "table" then nk, add = makeParadoxCloneRecurs(clonetable, nk, noclonecall, use_saveinstead, alt_nodes) nb = nb + add
			end

			if clonetable[ne] then ne = clonetable[ne]
			elseif type(ne) == "table" and (type(nk) ~= "string" or nk ~= "__threads") then ne, add = makeParadoxCloneRecurs(clonetable, ne, noclonecall, use_saveinstead, alt_nodes) nb = nb + add
			end
			
			n[nk] = ne
		end
		k, e = next(d, k)
	end
	setmetatable(n, getmetatable(d))
	if not noclonecall and n.cloned and (n.__ATOMIC or n.__CLASSNAME) then n:cloned(d) end
	if n.__ATOMIC or n.__CLASSNAME then nb = nb + 1 end
	return n, nb
end

-- Create a temporal clone
-- @param[type=table] self  Actor doing the cloning. Not currently used.
-- @param[type=table] target  Actor to be cloned.
-- @param[type=int] duration  How many turns the clone lasts. Zero is allowed.
-- @param[type=table] alt_nodes  Optional, these nodes will use a specified key/value on the clone instead of copying from the target.
-- @  Table keys should be the nodes to skip (field name or table reference).
-- @  Each key should be set to a table with up to two nodes:
-- @    k = a name/ref to substitute for instances of this field,
-- @      or nil to use the default name/ref as keys on the clone
-- @    v = the value to assign for instances of this node,
-- @      or nil to use the default value
-- @  If both k and v are nil, assigment for that node will be skipped entirely.
-- @return a reference to the clone on success, or nil on failure
makeParadoxClone = function(self, target, duration, alt_nodes)
	if not target or not duration then return nil end

	-- Don't clone particles or inventory on short-lived clones
	if duration == 0 then
		alt_nodes = alt_nodes or {}
		alt_nodes.__particles = {v = {} }
		alt_nodes[target:getInven("INVEN")] = {}
	end

	-- Clone the target
	local m = makeParadoxCloneRecurs({}, target, nil, nil, alt_nodes)

	-- Basic setup
	m.no_drops = true
	m.keep_inven_on_death = false
	m.faction = target.faction
	m.summoner = target
	m.summoner_gain_exp = true
	m.summon_time = duration
	m.ai_target = {actor = nil}
	m.ai = "summoned"
	m.ai_real = "tactical"
	m.name = "" .. target.name .. "'s temporal clone"
	m.desc = [[A creature from another timeline.]]
	
	-- Remove some values
	m:removeAllMOs()
	m.make_escort = nil
	m.on_added_to_level = nil
	m.on_added = nil

	mod.class.NPC.castAs(m)
	engine.interface.ActorAI.init(m, m)

	-- Change some values
	m.exp_worth = 0
	m.energy.value = 0
	m.player = nil
	m.max_life = m.max_life
	m.life = util.bound(m.life, 0, m.max_life)
	m.forceLevelup = function() end
	m.on_die = nil
	m.die = nil
	m.puuid = nil
	m.on_acquire_target = nil
	m.no_inventory_access = true
	m.no_levelup_access = true
	m.on_takehit = nil
	m.seen_by = nil
	m.can_talk = nil
	m.clone_on_hit = nil
	m.escort_quest = nil
	m.unused_talents = 0
	m.unused_generics = 0
	if m.talents.T_SUMMON then m.talents.T_SUMMON = nil end
	if m.talents.T_MULTIPLY then m.talents.T_MULTIPLY = nil end
	
	-- Clones never flee because they're awesome
	m.ai_tactic = m.ai_tactic or {}
	m.ai_tactic.escape = 0

	-- Remove some talents
	local tids = {}
	for tid, _ in pairs(m.talents) do
		local t = m:getTalentFromId(tid)
		if (t.no_npc_use and not t.allow_temporal_clones) or t.remove_on_clone then tids[#tids+1] = t end
	end
	for i, t in ipairs(tids) do
		if t.mode == "sustained" and m:isTalentActive(t.id) then m:forceUseTalent(t.id, {ignore_energy=true, silent=true}) end
		m:unlearnTalentFull(t.id)
	end

	-- Remove timed effects
	m:removeTimedEffectsOnClone()
	
	-- Reset folds for our Warden clones
	for tid, cd in pairs(m.talents_cd) do
		local t = m:getTalentFromId(tid)
		if t.type[1]:find("^chronomancy/manifold") and m:knowTalent(tid) then
			m:alterTalentCoolingdown(t, -cd)
		end
	end
	
	-- And finally, a bit of sanity in case anyone decides they should blow up the world..
	if m.preferred_paradox and m.preferred_paradox > 600 then m.preferred_paradox = 600 end

	m.self_resurrect = nil
	
	return m
end

-- Make sure we don't run concurrent chronoworlds; to prevent lag and possible game breaking bugs or exploits
checkTimeline = function(self)
	if game._chronoworlds  == nil then
		return false
	else
		return true
	end
end
