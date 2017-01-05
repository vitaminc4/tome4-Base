-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2017 Nicolas Casalini
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

require "engine.class"
local Map = require "engine.Map"
local Tiles = require "engine.Tiles"
local Faction = require "engine.Faction"

module(..., package.seeall, class.make)

local BASE_W, BASE_H = 64, 64

local tacttic_tiles = Tiles.new(BASE_W, BASE_H, nil, nil, true, false)
local assf_self = tacttic_tiles:get(nil, 0,0,0, 0,0,0, "alt_side_"..Map.faction_self)
local assf_powerful = tacttic_tiles:get(nil, 0,0,0, 0,0,0, "alt_side_"..Map.faction_powerful)
local assf_danger2 = tacttic_tiles:get(nil, 0,0,0, 0,0,0, "alt_side_"..Map.faction_danger2)
local assf_danger1 = tacttic_tiles:get(nil, 0,0,0, 0,0,0, "alt_side_"..Map.faction_danger1)
local assf_friend = tacttic_tiles:get(nil, 0,0,0, 0,0,0, "alt_side_"..Map.faction_friend)
local assf_enemy = tacttic_tiles:get(nil, 0,0,0, 0,0,0, "alt_side_"..Map.faction_enemy)
local assf_neutral = tacttic_tiles:get(nil, 0,0,0, 0,0,0, "alt_side_"..Map.faction_neutral)
local ssf_self = tacttic_tiles:get(nil, 0,0,0, 0,0,0, "side_"..Map.faction_self)
local ssf_powerful = tacttic_tiles:get(nil, 0,0,0, 0,0,0, "side_"..Map.faction_powerful)
local ssf_danger2 = tacttic_tiles:get(nil, 0,0,0, 0,0,0, "side_"..Map.faction_danger2)
local ssf_danger1 = tacttic_tiles:get(nil, 0,0,0, 0,0,0, "side_"..Map.faction_danger1)
local ssf_friend = tacttic_tiles:get(nil, 0,0,0, 0,0,0, "side_"..Map.faction_friend)
local ssf_enemy = tacttic_tiles:get(nil, 0,0,0, 0,0,0, "side_"..Map.faction_enemy)
local ssf_neutral = tacttic_tiles:get(nil, 0,0,0, 0,0,0, "side_"..Map.faction_neutral)

function _M:init(actor)
	print("new tactical frame")
	self.actor = actor
	self.DO = core.renderer.renderer():setRendererName("Tactical:UID:"..self.actor.uid)
	-- DGDGDGDG do :scale()

	self.DO_life = core.renderer.colorQuad(0, 0, 1, 1, 1, 1, 1, 1)
	self.DO_life_missing = core.renderer.colorQuad(0, 0, 1, 1, 1, 1, 1, 1)
	self.CO_life = core.renderer.container()
	self.CO_life:add(self.DO_life)
	self.CO_life:add(self.DO_life_missing)
	self.DO:add(self.CO_life)
end

function _M:toScreen(x, y, w, h)
	local map = game.level.map
	local friend = -100
	local lp = math.max(0, self.actor.life) / self.actor.max_life + 0.0001
	if self.actor.faction and map then
		if not map.actor_player then friend = Faction:factionReaction(map.view_faction, self.actor.faction)
		else friend = map.actor_player:reactionToward(self.actor) end
	end

	if self.old_friend ~= friend or self.old_life ~= lp then
		local sx = w * .015625
		local dx = w * .0625 - sx
		local sy = h * .03125
		local dy = h * .953125 - sy
		if friend < 0 then sx = w * .9375 end
		local color, color_missing
		if lp > .75 then -- green
			color_missing = {0.5058, 0.7058, 0.2235}
			color = {0.1916, 0.8627, 0.3019}
		elseif lp > .5 then -- yellow
			color_missing = {0.6862, 0.6862, 0.0392}
			color = {0.9411, 0.9882, 0.1372}
		elseif lp > .25 then -- orange
			color_missing = {0.7254, 0.6450, 0}
			color = {0, 0.6117, 0.0823}
		else -- red
			color_missing = {0.6549, 0.2156, 0.1529}
			color = {0.9215, 0, 0}
		end
		if not self.old_life then
			self.CO_life:translate(sx, sy)
			self.DO_life_missing:translate(0, 0):scale(dx, dy, 1):color(1, 1, 1, 0.5)
			self.DO_life:translate(0, dy):scale(dx, 1, 1):color(1, 1, 1, 1)
		end
		self.DO_life:tween(7, "scale_y", nil, -dy * lp, "inQuad"):tween(7, "r", nil, color[1], "inQuad"):tween(7, "g", nil, color[2], "inQuad"):tween(7, "b", nil, color[3], "inQuad")
		self.DO_life_missing:tween(7, "r", nil, color_missing[1], "inQuad"):tween(7, "g", nil, color_missing[2], "inQuad"):tween(7, "b", nil, color_missing[3], "inQuad")
	end

	self.DO:toScreen(x, y)

	self.old_friend = friend
	self.old_life = lp
end
