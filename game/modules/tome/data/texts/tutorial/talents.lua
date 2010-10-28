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

if not game.player.tutored_levels then
	game.player:learnTalent(game.player.T_SHIELD_PUMMEL, true, 1)
	game.player:learnTalent(game.player.T_SHIELD_WALL, true, 1)
	game.player.tutored_levels = true
end

return [[You now possess the Shield Pummel and Shield Wall talents.
Talents show up in the lower right part of the screen with their assigned hotkey.
You can right-click on a talent to remove it from the list and you can add talents by pressing 'm' to get the talents list and then pressing a hotkey.
Hotkeys by default are the 1 to 0 keys and can also be used with items.

You can use a talent either by pressing its hotkey, selecting it from the talents list, clicking on it in the lower right corner or right-clicking on the map.
Talents belong to three types:
* #GOLD#Active#WHITE#: A talent that activated when you use it and has an instantaneous effect.
* #GOLD#Sustained#WHITE#: A talent that must be turned on and lasts until it is turned off. Usualy this will reduce your maximum ressource available (stamina in this case).
* #GOLD#Passive#WHITE#: A talent that provides an ever-present benefit.

Some talents require a target, when you use them the interface will chance to let you select the target:
* #GOLD#Using the keyboard#WHITE#: Pressing a direction key will shift between possible targets in the given direction. Pressing shift+direction will move freely to any spot. Enter or space will confirm the target.
* #GOLD#Using the mouse#WHITE#: Moving your mouse will move the target around. Left-click will confirm it.

Now go forward and try using your talents:
* #GOLD#Shield Pummel#WHITE#: This talent will attack the target trying to stun it, redering it unable to harm you for a few turns.
* #GOLD#Shield Wall#WHITE#: This talent will increase your defense and armour but reduce your attack and damage.
]]
