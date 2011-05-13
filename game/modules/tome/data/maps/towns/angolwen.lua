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

defineTile('^', "HARDMOUNTAIN_WALL")
defineTile('#', "HARDWALL")
quickEntity('<', {show_tooltip=true, name='portal back', display='<', color=colors.WHITE, change_level=1, change_zone=game.player.last_wilderness, image="terrain/stone_road1.png", add_displays = {mod.class.Grid.new{image="terrain/worldmap.png"}},}, nil, {type="portal", subtype="back"})
defineTile(".", "GRASS")
defineTile("t", {"TREE","TREE2","TREE3","TREE4","TREE5","TREE6","TREE7","TREE8","TREE9","TREE10","TREE11","TREE12","TREE13","TREE14","TREE15","TREE16","TREE17","TREE18","TREE19","TREE20"})
defineTile('*', "ROCK")
defineTile('~', "FOUNTAIN")
defineTile('-', "FIELDS")
defineTile('_', "COBBLESTONE")

defineTile('2', "HARDWALL", nil, nil, "JEWELRY")
defineTile('4', "HARDWALL", nil, nil, "ALCHEMIST")
defineTile('5', "HARDWALL", nil, nil, "LIBRARY")
defineTile('6', "HARDWALL", nil, nil, "STAVES")

defineTile('@', "GRASS", nil, "SUPREME_ARCHMAGE_LINANIIL")
defineTile('T', "GRASS", nil, "TARELION")

startx = 24
starty = 46

return [[
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^.............^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^.._____________..^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^.._..t._._.t.._..^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^.#2#..#4#5#..#6#.^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^.._...._._...._..^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^.._____________..^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^....t.._..tT...^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^...._....^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^.t_t.^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^t_t^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^...^...^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^...^...^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^...^...^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^_^^^_^^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^_^^^_^^^^^^^^t_t^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^_^^^_^^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^.^^^^_^^^_^^^^^^..._...^^^^^^^^^^^^^^^^^^^^^^
^^^^...^^^_^^^_^^^^^...___...^^^^^^^^^^^^^^^^^^^^^
^^^.....^^_^^^_^^^^^..__~__..^^^^^^^^^^^^^^^^^^^^^
^^.*....____________.__~~~__.___________^^^^^^^^^^
^^.@_____^^^^^^^^^^___~~t~~___^^^^^^^^^_^^^^^^^^^^
^^.*....____________.__~~~__.___________^^^^^^^^^^
^^^.....^^_^^^_^^^^^..__~__..^^^^^^^^^^_^^^^^^^^^^
^^^^...^^^_^^^_^^^^^...___...^^^^^^^^^^_^^^^^^^^^^
^^^^^.^^^^_^^^_^^^^^^..._...^^^^^^^^^^^_^^^^^^^^^^
^^^^^^^^^^_^^^_^^^^^^^^._.^^^^^^^^^.........^^^^^^
^^^^^^^^^^_^^^_^^^^^^^^._.^^^^^^^^^.-------.^^^^^^
^^^^^^^^^^_^^^_^^^^^^^^t_t^^^^^^^^^.-------.^^^^^^
^^^^^^^^^...^...^^^^^^^._.^^^^^^^^^.-------.^^^^^^
^^^^^^^^^...^...^^^^^^^._.^^^^^^^^^.---*---.^^^^^^
^^^^^^^^^...^...^^^^^^^._.^^^^^^^^^.-------.^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^._.^^^^^^^^^.-------.^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^t_t^^^^^^^^^.-------.^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^._.^^^^^^^^^.........^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^._.^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^t_t^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^.___.^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^t._<_.t^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^.___.^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^...^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^]]