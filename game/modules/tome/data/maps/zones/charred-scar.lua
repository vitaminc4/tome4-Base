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

defineTile("'", "LAVA_FLOOR")
defineTile('~', "LAVA")
defineTile('#', "LAVA_WALL")
defineTile(' ', "FLOOR")
defineTile('p', "FLOOR", nil, "SUN_PALADIN_DEFENDER")
defineTile('@', "FLOOR", nil, "SUN_PALADIN_DEFENDER_RODMOUR")
defineTile('o', "FLOOR", nil, "URUK-HAI_ATTACK")

defineTile('1', "LAVA_FLOOR", nil, "ELANDAR")
defineTile('2', "LAVA_FLOOR", nil, "ARGONIEL")

subGenerator{
	x = 0, y = 23, w = 12, h = 401,
	generator = "mod.class.generator.map.CharredScar",
	data = {
		start = 6,
		stop = 6,
		['.'] = "LAVA_FLOOR",
		['#'] = "LAVA_WALL",
	},
}

startx = 5
starty = 12

return [[
#        ###
##oooooo ###
##o      ###
##      ####
##     o# ##
#   o      #
#    o     #
#          #
##         #
###       ##
###pp@pp# ##
##      ####
###     ####
##      ####
###      ###
###     ####
####   #####
#####'######
####'#'#####
#####'######
####'''#####
####'#######
####'''#####
#####'''####
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
............
#####'''~###
####~'''~###
###~~'''~~##
###~~'''~~##
###~~'''~~##
##~~~'''~~~#
##~~~'''~~~#
##~~~'''~~~~
~~~~~'''~~~~
~~~~~'''~~~~
~~~~~'''~~~~
~~~~~'''~~~~
~~~~~'''~~~~
~~~~~'''~~~~
~~~~~'''~~~~
~~~~~'''~~~~
~~~~~'''~~~~
~~~~~'''~~~~
~~~~~'''~~~~
~~~~~'''~~~~
~~~~~'''~~~~
~~~~~'''~~~~
~~~~~'#'~~~~
~~~~~#'#~~~~
~~~~~'#'~~~~
~~~~~'''~~~~
~~~~~'''~~~~
~~~~~'''~~~~
~~~~~'''~~~~
~~~~~'''~~~~
~~~~~'''~~~~
~~~~~1'2~~~~
~~~~~~~~~~~~
~~~~~~~~~~~~
~~~~~~~~~~~~
~~~~~~~~~~~~
~~~~~~~~~~~~
~~~~~~~~~~~~
~~~~~~~~~~~~
~~~~~~~~~~~~
~~~~~~~~~~~~
~~~~~~~~~~~~
~~~~~~~~~~~~
~~~~~~~~~~~~
~~~~~~~~~~~~
~~~~~~~~~~~~
~~~~~~~~~~~~
~~~~~~~~~~~~
~~~~~~~~~~~~]]
