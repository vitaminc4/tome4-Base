-- TE4 - T-Engine 4
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

require "engine.class"
require "engine.Mouse"
require "engine.DebugConsole"
require "engine.dialogs.ShowErrorStack"

--- Represent a game
-- A module should subclass it and initialize anything it needs to play inside
module(..., package.seeall, class.make)

--- Constructor
-- Sets up the default keyhandler.
-- Also requests the display size and stores it in "w" and "h" properties
function _M:init(keyhandler)
	self.key = keyhandler
	self.level = nil
	self.log = function() end
	self.logSeen = function() end
	self.w, self.h = core.display.size()
	self.dialogs = {}
	self.save_name = "player"
	self.player_name = "player"

	self.mouse = engine.Mouse.new()
	self.mouse:setCurrent()

	self.uniques = {}

	self.__savefile_version_tokens = {}

	self.__threads = {}

	-- Default mouse
	self:setMouseCursor("/data/gfx/ui/mouse.png", "/data/gfx/ui/mouse-down.png", -4, -4)
end

function _M:setMouseCursor(up, down, offsetx, offsety)
	local mouse = core.display.loadImage(up)
	local mouse_down = core.display.loadImage(down)
	if mouse then
		self.__cursor = { up=mouse:glTexture(), down=(mouse_down or mouse):glTexture(), ox=offsetx, oy=offsety }
		if config.settings.mouse_cursor then
			core.display.setMouseCursor(self.__cursor.ox, self.__cursor.oy, self.__cursor.up, self.__cursor.down)
		else
			core.display.setMouseCursor(0, 0, nil, nil)
		end
	end
end

function _M:updateMouseCursor()
	if self.__cursor then
		if config.settings.mouse_cursor then
			core.display.setMouseCursor(self.__cursor.ox, self.__cursor.oy, self.__cursor.up, self.__cursor.down)
		else
			core.display.setMouseCursor(0, 0, nil, nil)
		end
	end
end

function _M:loaded()
	self.w, self.h = core.display.size()
	self.dialogs = {}
	self.key = engine.Key.current
	self.mouse = engine.Mouse.new()
	self.mouse:setCurrent()

	self.__threads = self.__threads or {}
	self.__coroutines = self.__coroutines or {}
end

--- Defines the default fields to be saved by the savefile code
function _M:defaultSavedFields(t)
	local def = {
		w=true, h=true, zone=true, player=true, level=true, entities=true,
		energy_to_act=true, energy_per_tick=true, turn=true, paused=true, save_name=true,
		always_target=true, gfxmode=true, uniques=true, object_known_types=true,
		current_music=true, memory_levels=true, achievement_data=true, factions=true,
		state=true,
		__savefile_version_tokens = true,
	}
	table.merge(def, t)
	return def
end

--- Sets the player name
function _M:setPlayerName(name)
	self.save_name = name
	self.player_name = name
end

--- Starts the game
-- Modules should reimplement it to do whatever their game needs
function _M:run()
end

--- Checks if the current character is "tainted" by cheating
function _M:isTainted()
	return false
end

--- Sets the current level
-- @param level an engine.Level (or subclass) object
function _M:setLevel(level)
	self.level = level
end

--- Tells the game engine to play this game
function _M:setCurrent()
	core.game.set_current_game(self)
	_M.current = self
end

--- Displays the screen
-- Called by the engine core to redraw the screen every frame
-- @param nb_keyframes The number of elapsed keyframes since last draw (this can be 0). This is set by the engine
function _M:display(nb_keyframes)
	nb_keyframes = nb_keyframes or 1
	if self.flyers then
		self.flyers:display(nb_keyframes)
	end

	for i, d in ipairs(self.dialogs) do
		d:display()
		d:toScreen(d.display_x, d.display_y, nb_keyframes)
	end
end

--- Returns the player
-- Reimplement it in your module, this can just return nil if you dont want/need
-- the engine adjusting stuff to the player or if you have many players or whatever
function _M:getPlayer()
	return nil
end

--- Gets/increment the savefile version
-- @param token if "new" this will create a new allowed save token and return it. Otherwise this checks the token against the allowed ones and returns true if it is allowed
function _M:saveVersion(token)
	if token == "new" then
		token = util.uuid()
		self.__savefile_version_tokens[token] = true
		return token
	end
	return self.__savefile_version_tokens[token]
end

--- This is the "main game loop", do something here
function _M:tick()
	-- Check out any possible errors
	local errs = core.game.checkError()
	if errs then
		self:registerDialog(engine.dialogs.ShowErrorStack.new(errs))
	end

	local stop = {}
	local id, co = next(self.__coroutines)
	while id do
		local ok, err = coroutine.resume(co)
		if not ok then
			print(debug.traceback(co))
			print("[COROUTINE] error", err)
		end
		if coroutine.status(co) == "dead" then
			stop[#stop+1] = id
		end
		id, co = next(self.__coroutines, id)
	end
	if #stop > 0 then
		for i = 1, #stop do
			self.__coroutines[stop[i]] = nil
			print("[COROUTINE] dead", stop[i])
		end
	end
end

--- Called when a zone leaves a level
-- Going from "old_lev" to "lev", leaving level "level"
function _M:leaveLevel(level, lev, old_lev)
end

--- Called by the engine when the user tries to close the window
function _M:onQuit()
end

--- Sets up a text flyers
function _M:setFlyingText(fl)
	self.flyers = fl
end

--- Registers a dialog to display
function _M:registerDialog(d)
	table.insert(self.dialogs, d)
	self.dialogs[d] = #self.dialogs
	d.__stack_id = #self.dialogs
	if d.key then d.key:setCurrent() end
	if d.mouse then d.mouse:setCurrent() end
	if d.on_register then d:on_register() end
	if self.onRegisterDialog then self:onRegisterDialog(d) end
end

--- Registers a dialog to display somewher in the stack
-- @param d the dialog
-- @param pos the stack position (1=top, 2=second, ...)
function _M:registerDialogAt(d, pos)
	if pos == 1 then return self:registerDialog(d) end

	table.insert(self.dialogs, #self.dialogs - (pos - 2), d)
	for i = 1, #self.dialogs do
		local dd = self.dialogs[i]
		self.dialogs[d] = i
		d.__stack_id = i
	end
	if d.on_register then d:on_register() end
	if self.onRegisterDialog then self:onRegisterDialog(d) end
end

--- Replaces a dialog to display with an other
function _M:replaceDialog(src, dest)
	local id = src.__stack_id

	-- Remove old one
	self.dialogs[src] = nil

	-- Update
	self.dialogs[id] = dest
	self.dialogs[dest] = id
	dest.__stack_id = id

	-- Give focus
	if id == #self.dialogs then
		if dest.key then dest.key:setCurrent() end
		if dest.mouse then dest.mouse:setCurrent() end
	end
	if dest.on_register then dest:on_register(src) end
end

--- Undisplay a dialog, removing its own keyhandler if needed
function _M:unregisterDialog(d)
	if not self.dialogs[d] then return end
	table.remove(self.dialogs, self.dialogs[d])
	self.dialogs[d] = nil
	d:unload()
	-- Update positions
	for i, id in ipairs(self.dialogs) do id.__stack_id = i self.dialogs[id] = i end

	local last = self.dialogs[#self.dialogs] or self
	if last.key then last.key:setCurrent() end
	if last.mouse then last.mouse:setCurrent() end
	if last.on_recover_focus then last:on_recover_focus() end
	if self.onUnregisterDialog then self:onUnregisterDialog(d) end
end

--- Do we have a dialog running
function _M:hasDialogUp()
	return #self.dialogs > 0
end

--- The C core gives us command line arguments
function _M:commandLineArgs(args)
	for i, a in ipairs(args) do
		print("Command line: ", a)
	end
end

--- Called by savefile code to describe the current game
function _M:getSaveDescription()
	return {
		name = "player",
		description = [[Busy adventuring!]],
	}
end

--- Save a settings file
function _M:saveSettings(file, data)
	local restore = fs.getWritePath()
	fs.setWritePath(engine.homepath)
	local f = fs.open("/settings/"..file..".cfg", "w")
	if f then
		f:write(data)
		f:close()
	else
		print("WARNING: could not save settings in ", file, "::", data)
	end
	if restore then fs.setWritePath(restore) end
end

available_resolutions =
{
	["800x600"] = {800, 600, false},
	["1024x768"] = {1024, 768, false},
	["1200x1024"] = {1200, 1024, false},
	["1600x1200"] = {1600, 1200, false},
--	["800x600 Fullscreen"] = {800, 600, true},
--	["1024x768 Fullscreen"] = {1024, 768, true},
--	["1200x1024 Fullscreen"] = {1200, 1024, true},
--	["1600x1200 Fullscreen"] = {1600, 1200, true},
}
local list = core.display.getModesList()
for _, m in ipairs(list) do
	local ms = m.w.."x"..m.h.." Fullscreen"
	if m.w >= 800 and m.h >= 600 and not available_resolutions[ms] then
		available_resolutions[ms] = {m.w, m.h, true}
	end
end

--- Change screen resolution
function _M:setResolution(res, force)
	local r = available_resolutions[res]
	if force and not r then
		local _, _, w, h = res:find("([0-9][0-9][0-9]+)x([0-9][0-9][0-9]+)")
		w = tonumber(w)
		h = tonumber(h)
		if w and h then r = {w, h, false} end
	end
	if not r then return false, "unknown resolution" end

	local old_w, old_h = self.w, self.h
	core.display.setWindowSize(r[1], r[2], r[3])
	self.w, self.h = core.display.size()

	if self.w ~= old_w or self.h ~= old_h then
		self:onResolutionChange()

		self:saveSettings("resolution", ("window.size = %q\n"):format(res))
	end
end

--- Called when screen resolution changes
function _M:onResolutionChange()
	if game and not self.change_res_dialog_oldw then
		self.change_res_dialog_oldw, self.change_res_dialog_oldh = self.w, self.h
	end

	self.w, self.h = core.display.size()
	config.settings.window.size = ("%dx%d"):format(self.w, self.h)
	self:saveSettings("resolution", ("window.size = '%s'\n"):format(config.settings.window.size))
	print("[RESOLUTION] changed to ", self.w, self.h)

	-- We do not even have a game yet
	if not game then return end

	-- Do not repop if we just revert back
	if self.change_res_dialog and type(self.change_res_dialog) == "string" and self.change_res_dialog == "revert" then return end
	-- Unregister old dialog if there was one
	if self.change_res_dialog and type(self.change_res_dialog) == "table" then self:unregisterDialog(self.change_res_dialog) end
	-- Ask if we want to switch
	self.change_res_dialog = require("engine.ui.Dialog"):yesnoPopup("Resolution changed", "Accept the new resolution?", function(ret)
		if ret then
			if not self.creating_player then self:saveGame() end
			util.showMainMenu(false, nil, nil, self.__mod_info.short_name, self.save_name, false)
		else
			self.change_res_dialog = "revert"
			self:setResolution(self.change_res_dialog_oldw.."x"..self.change_res_dialog_oldh, true)
			self.change_res_dialog = nil
			self.change_res_dialog_oldw, self.change_res_dialog_oldh = nil, nil
		end
	end, "Accept", "Revert")
end

--- Requests the game to save
function _M:saveGame()
end

--- Add a coroutine to the pool
-- Coroutines registered will be run each game tick
function _M:registerCoroutine(id, co)
	print("[COROUTINE] registering", id, co)
	self.__coroutines[id] = co
end

--- Get the coroutine corresponding to the id
function _M:getCoroutine(id)
	return self.__coroutines[id]
end

--- Ask a registered coroutine to cancel
-- The coroutine must accept a "cancel" action
function _M:cancelCoroutine(id)
	local co = self.__coroutines[id]
	if not co then return end
	local ok, err = coroutine.resume(co, "cancel")
	if not ok then
		print(debug.traceback(co))
		print("[COROUTINE] error", err)
	end
	if coroutine.status(co) == "dead" then
		self.__coroutines[id] = nil
	else
		error("Told coroutine "..id.." to cancel, but it is not dead!")
	end
end

--- Save a thread into the thread pool
-- Threads will be auto joined when the module exits or when it can
-- ALL THREADS registered *MUST* return true when they exit
function _M:registerThread(th, linda)
	print("[THREAD] registering", th, linda, #self.__threads+1)
	self.__threads[#self.__threads+1] = {th=th, linda=linda}
	return #self.__threads
end

--- Try to join all registered threads
-- @param timeout the time in seconds to wait for each thread
function _M:joinThreads(timeout)
	for i = #self.__threads, 1, -1 do
		local th = self.__threads[i].th
		print("[THREAD] Thread join", i, th)
		local v, err = th:join(timeout)
		if err then print("[THREAD] error", th) error(err) end
		if v then
			print("[THREAD] Thread result", i, th, "=>", v)
			table.remove(self.__threads, i)
		end
	end
end
