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

-- Find a random spot
local x, y = game.state:findEventGrid(level)
if not x then return false end

local id = "sub-vault"..game.turn.."-"..rng.range(1,9999)

local changer = function(id)
	local list = {
		"double-t", "crypt", "treasure1", "diggers", "hillbert_curve", "quiet", "lightning-vault", "water-vault",
		"32-chambers", "demon-nest-1", "demon-nest-2", "demon-nest-3", "frost-dragon-lair", "greater-money-vault",
		"trapped-hexagon", "yin-yang", "zigzag-chambers", "paladin-vs-vampire", "orc-hatred", "lich-lair",
		"greater-crypt", "trickvault", "spider-den", "acidic-vault",
	}

	local grid_list = mod.class.Grid:loadList{"/data/general/grids/basic.lua", "/data/general/grids/water.lua", "/data/general/grids/lava.lua"}

	local walltype = "HARDWALL"
	-- if game.level.data.generator and game.level.data.generator.map and game.level.data.generator.map.wall then walltype = game.level.data.generator.map.wall end
	-- if game.level.data.generator and game.level.data.generator.map and game.level.data.generator.map['#'] then walltype = game.level.data.generator.map['#'] end

	local uptype = "UP"
	grid_list.UP_SUB_VAULT_BACK = grid_list[uptype]:cloneFull()
	grid_list.UP_SUB_VAULT_BACK.change_level_shift_back = true
	grid_list.UP_SUB_VAULT_BACK.change_zone_auto_stairs = true

	local zone = mod.class.Zone.new(id, {
		name = "Hidden Vault - "..(game.old_zone_name or "???"),
		level_range = {game.zone:level_adjust_level(game.level, game.zone, "actor"), game.zone:level_adjust_level(game.level, game.zone, "actor")},
		level_scheme = "player",
		max_level = 1,
		actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
		width = 50, height = 50,
		ambient_music = game.zone.ambient_music,
		reload_lists = false,
		persistent = "zone",
		min_material_level = game.zone.min_material_level,
		max_material_level = game.zone.max_material_level,
		generator =  {
			map = {
				class = "mod.class.generator.map.VaultLevel",
				vaultid = rng.table(game.level.data.greater_vaults_list or list),
				["#"] = walltype,
				up = "UP_SUB_VAULT_BACK",
			},
			actor = {
				class = "mod.class.generator.actor.Random",
				nb_npc = {0, 0},
			},
			object = {
				class = "engine.generator.object.Random",
				nb_object = {0, 0},
			},
			trap = {
				class = "engine.generator.trap.Random",
				nb_trap = {0, 0},
			},
		},
		npc_list = table.clone(game.zone.npc_list, false),
		grid_list = grid_list,
		object_list = table.clone(game.zone.object_list, false),
		trap_list = table.clone(game.zone.trap_list, false),
	})
	return zone
end

local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
g.name = "hidden vault"
g.display='>' g.color_r=0 g.color_g=0 g.color_b=255 g.notice = true
g.change_level=1 g.change_zone=id g.glow=true
g:removeAllMOs()
if engine.Map.tiles.nicer_tiles then
	g.add_displays = g.add_displays or {}
	g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/stair_down.png", z=5}
end
g:altered()
g:initGlow()
g.real_change = changer
g.change_level_check = function(self)
	game:changeLevel(1, self.real_change(self.change_zone), {temporary_zone_shift=true, direct_switch=true})
	self.change_level_check = nil
	self.real_change = nil
	return true
end
game.zone:addEntity(game.level, g, "terrain", x, y)

return true
