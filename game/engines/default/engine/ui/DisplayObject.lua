-- TE4 - T-Engine 4
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
local Base = require "engine.ui.Base"
local Focusable = require "engine.ui.Focusable"

--- An empty space that contains a DO
-- @classmod engine.ui.DisplayObject
module(..., package.seeall, class.inherit(Base, Focusable))

function _M:init(t)
	self.DO = assert(t.DO, "no do DO")
	self.w = assert(t.width, "no do width")
	self.h = assert(t.height, "no do height")
	self.fct = t.fct
	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()
	self.do_container:clear()

	self.do_container:add(self.DO)

	self.mouse:registerZone(0, 0, self.w, self.h, function(button) if button == "left" then
		if self.fct then self.fct() end
	end end)
end