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

setStatusAll{lite=true}

defineTile('.', "FLOOR")
defineTile('#', "WALL")
defineTile('+', "DOOR")
defineTile("!", "LOCK")
defineTile("*", "PENTAGRAM")
defineTile('@', "PENTAGRAM", nil, "MELINDA")
defineTile('A', "FLOOR", nil, "ACOLYTE")

subGenerator{
	x = 26, y = 0, w = 60, h = 50,
	generator = "engine.generator.map.Roomer",
	data = {
		edge_entrances = {4,6},
		nb_rooms = 15,
		rooms = {"random_room"},
		['.'] = "FLOOR",
		['#'] = "WALL",
		up = "FLOOR",
		down = "UP_WILDERNESS",
		door = "DOOR",
		force_last_stair = true,
		force_tunnels = {
			{"random", {26, 17}, id=-500},
		},
	},
	define_down = true,
}

checkConnectivity({25,17}, "exit", "boss-area", "boss-area")

addSpot({24, 17}, "locked-door", "locked-door")

startx = 2
starty = 21

return [[
##########################################################################################
##########################################################################################
##########################################################################################
##########################################################################################
##########################################################################################
##########################################################################################
##########################################################################################
##########################################################################################
##########################################################################################
##########################################################################################
##########################################################################################
##........################################################################################
##..........######....####################################################################
#..##........####......###################################################################
#..##...................##################################################################
#......A...........A....##################################################################
#.................****..##################################################################
#.................*@**..!.################################################################
#.................****..##################################################################
#..................A....##################################################################
#......A................##################################################################
#..##...................##################################################################
#..##........####......###################################################################
##..........######....####################################################################
##........################################################################################
##########################################################################################
##########################################################################################
##########################################################################################
##########################################################################################
##########################################################################################
##########################################################################################
##########################################################################################
##########################################################################################
##########################################################################################
##########################################################################################
##########################################################################################
##########################################################################################
##########################################################################################
##########################################################################################
##########################################################################################]]
