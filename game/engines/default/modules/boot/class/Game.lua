-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009 - 2016 Nicolas Casalini
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
require "engine.GameEnergyBased"
require "engine.interface.GameSound"
require "engine.interface.GameMusic"
require "engine.interface.GameTargeting"
require "engine.KeyBind"

local Module = require "engine.Module"
local Dialog = require "engine.ui.Dialog"
local Tooltip = require "engine.Tooltip"
local MainMenu = require "mod.dialogs.MainMenu"
local Downloader = require "engine.dialogs.Downloader"
local FontPackage = require "engine.FontPackage"

local Shader = require "engine.Shader"
local Zone = require "engine.Zone"
local Map = require "engine.Map"
local Level = require "engine.Level"
local LogDisplay = require "engine.LogDisplay"
local FlyingText = require "engine.FlyingText"
local FontPackage = require "engine.FontPackage"

local NicerTiles = require "mod.class.NicerTiles"
local Grid = require "mod.class.Grid"
local Actor = require "mod.class.Actor"
local Player = require "mod.class.Player"
local NPC = require "mod.class.NPC"

module(..., package.seeall, class.inherit(engine.GameEnergyBased, engine.interface.GameMusic, engine.interface.GameSound))

-- Tell the engine that we have a fullscreen shader that supports gamma correction
support_shader_gamma = true

function _M:init()
	engine.interface.GameMusic.init(self)
	engine.interface.GameSound.init(self)
	engine.GameEnergyBased.init(self, engine.KeyBind.new(), 100, 100)
	self.profile_font = FontPackage:get("default")

	self.background = self.__mod_info.keep_background_texture

	if type(self.background) ~= "userdata" then
		local background_name
		if not config.settings.censor_boot then background_name = {"tome","tome2","tome3"}
		else background_name = {"tome3"}
		end
		local value = {name=background_name}
		local hd = {"Boot:loadBackground", value=value}
		if self:triggerHook(hd) then background_name = hd.value.name end
		self.background = core.display.loadImage("/data/gfx/background/"..util.getval(background_name)..".png")
	end

	if self.background then
		self.background_w, self.background_h = self.background:getSize()
		self.background, self.background_tw, self.background_th = self.background:glTexture()
	end
	
	self:handleEvents()
	if not profile.connected then core.webview, core.webview_inactive = nil, core.webview end
	if not core.webview then self.tooltip = Tooltip.new(nil, 14, nil, colors.DARK_GREY, 380) end

--	self.refuse_threads = true
	self.normal_key = self.key
	self.stopped = config.settings.boot_menu_background
	-- self.stopped = true
	if core.display.safeMode() then self.stopped = true end
	if self.stopped then
		core.game.setRealtime(0)
	else
		core.game.setRealtime(8)
	end

	self:loaded()
	profile:currentCharacter("Main Menu", "Main Menu")
end

function _M:loaded()
	engine.GameEnergyBased.loaded(self)
	engine.interface.GameMusic.loaded(self)
	engine.interface.GameSound.loaded(self)
end

function _M:makeWebtooltip()
	self.webtooltip = require("engine.ui.WebView").new{width=380, height=500, has_frame=true, never_clean=true, allow_popup=true,
		url = ("http://te4.org/tooltip-ingame?steam=%d&vM=%d&vm=%d&vp=%d"):format(core.steam and 1 or 0, engine.version[1], engine.version[2], engine.version[3])
	}
	if self.webtooltip.unusable then
		self.webtooltip = nil
		self.tooltip = Tooltip.new(nil, 14, nil, colors.DARK_GREY, 380)
	end
end

function _M:run()
	self:triggerHook{"Boot:run"}

	-- Web Tooltip?
	if core.webview then
		self:makeWebtooltip()
	end

	local flyfont, flysize = FontPackage:getFont("flyer")
	self.flyers = FlyingText.new(flyfont, flysize, flyfont, flysize + 3)
	self.flyers:enableShadow(0.6)
	self:setFlyingText(self.flyers)
	self.log = function(style, ...) end
	self.logSeen = function(e, style, ...) end
	self.logPlayer = function(e, style, ...) end
	self.nicer_tiles = NicerTiles.new()

	-- Starting from here we create a new game
	self:newGame()

	-- Ok everything is good to go, activate the game in the engine!
	self:setCurrent()

	self.logdisplay = LogDisplay.new(self.w / 2, self.h - 200, self.w / 2, 200, 90, nil, 16, nil, nil)
	self.logdisplay.resizeToLines = function() end
	self.logdisplay:enableShadow(1)
	self.logdisplay:enableFading(5)

	game.logChat = function(style, ...)
		if type(style) == "number" then self.logdisplay(...) else self.logdisplay(style, ...) end
	end

	-- Setup display
	self:registerDialog(MainMenu.new())

	-- Run the current music if any
	self:playMusic("The saga begins.ogg")

	-- Get news
	if not self.news then
		self.news = {
			title = "Welcome to T-Engine and the Tales of Maj'Eyal",
			text = [[#GOLD#"Tales of Maj'Eyal"#WHITE# is the main game, you can also install more addons or modules by by going to http://te4.org/

When inside a module remember you can press Escape to bring up a menu to change keybindings, resolution and other module specific options.

Remember that in most roguelikes death is usually permanent so be careful!

Now go and have some fun!]]
		}

		if self.tooltip then
			self:serverNews()
			self:updateNews()
		end
	end

--	self:installNewEngine()

	if not self.firstrunchecked then
		-- Check first time run for online profile
		self.firstrunchecked = true
		self:checkFirstTime()
	end

	if self.s_log then
		local w, h = self.s_log:getSize()
		self.mouse:registerZone(self.w - w, self.h - h, w, h, function(button)
			if button == "left" then util.browserOpenUrl(self.logged_url, {is_external=true}) end
		end, {button=true})
	end

	-- Setup FPS
	core.game.setFPS(config.settings.display_fps)
	self:triggerHook{"Boot:runEnd"}

	if not config.settings.upgrades or not config.settings.upgrades.v1_0_5 then
		if not config.settings.background_saves or (config.settings.tome and config.settings.tome.save_zone_levels) then
			Dialog:simpleLongPopup("Upgrade to 1.0.5", [[The way the engine manages saving has been reworked for v1.0.5.

The background saves should no longer lag horribly and as such it is highly recommended that you use the option. The upgrade turned it on for you.

For the same reason the save per level option should not be used unless you have severe memory problems. The upgrade turned it off for you.
]], 400)
		end
		self:saveSettings("upgrades", "upgrades.v1_0_5 = true\n")
		self:saveSettings("background_saves", "background_saves = true\n")
		self:saveSettings("tome.save_zone_levels", "tome.save_zone_levels = false\n")
		config.settings.background_saves = true
		config.settings.tome = {}
		config.settings.tome.save_zone_levels = false
	end

	self:grabAddons()

	-- We are running fine, remove the flag so that if we crash we will not restart into safe mode
	util.removeForceSafeBoot()

	if core.display.safeMode() then
		Dialog:simpleLongPopup("Safe Mode", [[Oops! Either you activated safe mode manually or the game detected it did not start correctly last time and thus you are in #LIGHT_GREEN#safe mode#WHITE#.
Safe Mode disabled all graphical options and sets a low FPS. It is not advisable to play this way (as it will be very painful and ugly).

Please go to the Video Options and try enabling/disabling options and then restarting until you do not get this message.
A usual problem is shaders and thus should be your first target to disable.]], 700)
	end

	local reboot_message = core.game.getRebootMessage()
	if reboot_message then
		Dialog:simpleLongPopup("Message", reboot_message, 700)
	end
end

function _M:grabAddons()
	if config.settings.no_auto_update_addons then return end

	if core.steam then
		self.updating_addons = {}
		self.logdisplay("#{italic}##ROYAL_BLUE#Retrieving addons to update/download from Steam...#{normal}#")
		core.steam.grabSubscribedAddons(function(mode, teaa, title)
			if mode == "end" then
				self.updating_addons = nil
				self.logdisplay("#{italic}##ROYAL_BLUE#Addons update finished.#{normal}#")
				return
			end

			if title then
				self.updating_addons[teaa] = title
				self.logdisplay("#{italic}#Starting download of #LIGHT_GREEN#%s#LAST# (%s)...#{normal}#", title, mode)
			elseif mode == "success" then
				self.logdisplay("#{italic}#Download of #LIGHT_GREEN#%s#LAST# finished.#{normal}#", self.updating_addons[teaa] or "???")
			else
				self.logdisplay("#{italic}#Download of #LIGHT_RED#%s#LAST# failed.#{normal}#", self.updating_addons[teaa] or "???")
			end
		end)
	else
		if not core.webview then return end
		self.logdisplay("#{italic}##ROYAL_BLUE#Retrieving addons to update/download from te4.org...#{normal}#")
		local mlist = Module:listModules(true)
		list = {}
		for i = 1, #mlist do
			for j, mod in ipairs(mlist[i].versions) do
				if j > 1 then break end
				if not mod.is_boot then
					local adds = Module:listAddons(mod, true)
					for k, add in ipairs(adds) do
						if add.addon_version and add.teaa then
							local a = {
								long_name = add.long_name,
								name = add.for_module..'-'..add.short_name,
								version = add.addon_version,
								id_dlc = add.id_dlc and add.id_dlc[1],
								file = add.teaa,
							}
							table.insert(list, a)
							list[a.name] = a
						end
					end
				end
			end
		end
		table.print(list)
		local update_list = profile:checkAddonUpdates(list)
		if update_list then
			local co co = coroutine.create(function()
			for i, add in ipairs(update_list) do
				if core.webview then
					local d = Downloader.new{title="Updating addon: #LIGHT_GREEN#"..list[add.name].long_name, co=co, dest=add.file..".tmp", url=add.download_url, allow_downloads={addons=true}}
					local ok = d:start()
					if ok then
						local wdir = fs.getWritePath()
						local _, _, dir, name = add.file:find("(.+)/([^/]+)$")
						if dir then
							fs.setWritePath(fs.getRealPath(dir))
							fs.delete(name)
							fs.rename(name..".tmp", name)
							fs.setWritePath(wdir)
							self.logdisplay("#{italic}#Download of #LIGHT_GREEN#%s#LAST# finished.#{normal}#", list[add.name].long_name)
						end
					end
				end
			end
			self.logdisplay("#{italic}##ROYAL_BLUE#Addons update finished.#{normal}#")
			end)
			coroutine.resume(co)
		end
	end
end

function _M:newGame()
	self.player = Player.new{name=self.player_name, game_ender=true}
	Map:setViewerActor(self.player)
	self:setupDisplayMode()
	self:setGamma(config.settings.gamma_correction / 100)

	self.player:resolve()
	self.player:resolve(nil, true)
	self.player.energy.value = self.energy_to_act

	Zone:setup{npc_class="mod.class.NPC", grid_class="mod.class.Grid", }
	self:changeLevel(rng.range(1, 3), "dungeon")
end
--[[
function _M:onResolutionChange()
	local oldw, oldh = self.w, self.h
	engine.Game.onResolutionChange(self)
	if oldw == self.w and oldh == self.h then return end
	print("[RESOLUTION] changed to ", self.w, self.h)
	if not self.change_res_dialog then
		self.change_res_dialog = Dialog:yesnoPopup("Resolution changed", "Accept the new resolution?", function(ret)
			self.change_res_dialog = nil
			if ret then
				util.showMainMenu(false, nil, nil, "boot", "boot", false)
			else
				self:setResolution(oldw.."x"..oldh, true)
			end
		end, "Accept", "Revert")
	end
end
]]
--- Called when screen resolution changes
function _M:checkResolutionChange(w, h, ow, oh)
	self:resizeMapViewport(w, h)

	return true
end

function _M:resizeMapViewport(w, h)
	w = math.floor(w)
	h = math.floor(h)

	Map.viewport.width = w
	Map.viewport.height = h
	Map.viewport.mwidth = math.floor(w / Map.tile_w)
	Map.viewport.mheight = math.floor(h / Map.tile_h)

	self:createFBOs()

	if self.level then
		self.level.map:makeCMap()
		self.level.map:redisplay()
	end
end

function _M:setupDisplayMode()
	Map:setViewPort(0, 0, self.w, self.h, 48, 48, nil, 22, true, true)
	Map:resetTiles()
	Map.tiles.use_images = true

	self:createFBOs()
end

function _M:createFBOs()
	-- Create the framebuffer
	-- self.fbo = core.display.newFBO(game.w, game.h)
	-- if self.fbo then
	-- 	self.fbo_shader = Shader.new("main_fbo")
	-- 	if not self.fbo_shader.shad then
	-- 		self.fbo = nil self.fbo_shader = nil
	-- 	else
	-- 		self.fbo_shader:setUniform("colorize", {1,1,1,0.9})
	-- 	end
	-- end

	-- self.full_fbo = core.display.newFBO(self.w, self.h)
	-- if self.full_fbo then self.full_fbo_shader = Shader.new("full_fbo") if not self.full_fbo_shader.shad then self.full_fbo = nil self.full_fbo_shader = nil end end

	self.fbo = core.renderer.target()
	self.fbo:displaySize(game.w, game.h)
	self.fborenderer = core.renderer.renderer()
	self.fborenderer:add(self.fbo)

	self.full_fbo = core.renderer.target()
	self.full_fbo:displaySize(game.w, game.h)
	self.full_fborenderer = core.renderer.renderer()
	self.full_fborenderer:add(self.full_fbo)
end

function _M:changeLevel(lev, zone)
	local old_lev = (self.level and not zone) and self.level.level or -1000
	if zone then
		if self.zone then
			self.zone:leaveLevel(false, lev, old_lev)
			self.zone:leave()
		end
		if type(zone) == "string" then
			self.zone = Zone.new(zone)
		else
			self.zone = zone
		end
	end
	self.zone:getLevel(self, lev, old_lev)
	self.nicer_tiles:postProcessLevelTiles(self.level)

	if lev > old_lev then
		self.player:move(self.level.default_up.x, self.level.default_up.y, true)
	else
		self.player:move(self.level.default_down.x, self.level.default_down.y, true)
	end
	self.level:addEntity(self.player)
end

function _M:getPlayer()
	return self.player
end

function _M:updateNews()
	if not self.tooltip then return end

	if self.news.link then
		self.tooltip:set("#AQUAMARINE#%s#WHITE#\n---\n%s\n---\n#LIGHT_BLUE##{underline}#%s#LAST##{normal}#", self.news.title, self.news.text, self.news.link)
	else
		self.tooltip:set("#AQUAMARINE#%s#WHITE#\n---\n%s", self.news.title, self.news.text)
	end

	if self.news.link then
		self.mouse:registerZone(5, self.tooltip.h - 30, self.tooltip.w, 30, function(button)
			if button == "left" then util.browserOpenUrl(self.news.link, {is_external=true}) end
		end, {button=true})
	end
end

function _M:tick()
	if self.stopped then engine.Game.tick(self) return true end
	if self.level then
		engine.GameEnergyBased.tick(self)
		-- Fun stuff: this can make the game realtime, although calling it in display() will make it work better
		-- (since display is on a set FPS while tick() ticks as much as possible
		-- engine.GameEnergyBased.tick(self)
	end
	return false
end

--- Called every game turns
-- Does nothing, you can override it
function _M:onTurn()
	if self.turn % 600 == 0 then self:changeLevel(util.boundWrap(self.level.level + 1, 1, 3)) end

	-- The following happens only every 10 game turns (once for every turn of 1 mod speed actors)
	if self.turn % 10 ~= 0 then return end

	-- Process overlay effects
	self.level.map:processEffects()
end

function _M:display(nb_keyframes)
	-- If switching resolution, blank everything but the dialog
	if self.change_res_dialog then engine.GameEnergyBased.display(self, nb_keyframes) return end

	if self.full_fbo then self.full_fbo:use(true) end

	-- If background anim is stopped, things are greatly simplified
	if self.stopped then
		if self.background then
			local x, y = 0, 0
			local w, h = self.w, self.h
			if w > h then
				h = w * self.background_h / self.background_w
				y = (self.h - h) / 2
				if h < self.h then
					h = self.h
					w = h * self.background_w / self.background_h
					x = (self.w - w) / 2
					y = 0
				end
			else
				w = h * self.background_w / self.background_h
				x = (self.w - w) / 2
			end
			self.background:toScreenFull(x, y, w, h, w * self.background_tw / self.background_w, h * self.background_th / self.background_h)
		end
		if self.tooltip then
			if #self.dialogs == 0 or not self.dialogs[#self.dialogs].__show_only then
				self.tooltip:display()
				self.tooltip:toScreen(5, 5)
			end
		end
		self.logdisplay:toScreen()
		engine.GameEnergyBased.display(self, nb_keyframes)
		if self.full_fbo then self.full_fbo:use(false) self.full_fborenderer:toScreen(0, 0, 1, 1, 1, 1) end
		return
	end

	-- Display using Framebuffer, so that we can use shaders and all
	if self.fbo then self.fbo:use(true) end

	-- Now the map, if any
	if self.level and self.level.map and self.level.map.finished then
		-- Display the map and compute FOV for the player if needed
		if self.level.map.changed then
			self.player:playerFOV()
		end

		self.level.map:display(nil, nil, nb_keyframes, true)
		self.level.map._map:drawSeensTexture(0, 0, nb_keyframes)
	end

	-- Draw it here, inside the FBO
	if self.flyers then self.flyers:display(nb_keyframes) end

	-- Display using Framebuffer, so that we can use shaders and all
	if self.fbo then
		self.fbo:use(false, self.full_fbo)
		_2DNoise:bind(1, false)
		self.fbo:toScreen(
			self.level.map.display_x, self.level.map.display_y,
			self.level.map.viewport.width, self.level.map.viewport.height,
			self.fbo_shader.shad
		)
	else
--		core.display.drawQuad(0, 0, game.w, game.h, 128, 128, 128, 128)
	end

	if self.tooltip then
		if #self.dialogs == 0 or not self.dialogs[#self.dialogs].__show_only then
			self.tooltip:display()
			self.tooltip:toScreen(5, 5)
		end
	end

	self.logdisplay:toScreen()

	local old = self.flyers
	self.flyers = nil
	engine.GameEnergyBased.display(self, nb_keyframes)
	self.flyers = old

	if self.full_fbo then self.full_fbo:use(false) self.full_fborenderer:toScreen(0, 0, 1, 1, 1, 1) end
end

local renderer = core.renderer.renderer()
renderer:zSort(true)
local UIBase = require "engine.ui.Base"
local f = UIBase:makeFrameDO("ui/dialogframe_", 400, 400, nil, nil, true)
f.container:translate(400, 400)
local f2 = UIBase:makeFrameDO("ui/button", 100, 40, nil, nil, true)
-- f2.container:translate(100, 150)
local f3 = UIBase:makeFrameDO("ui/textbox", 25, 25, nil, nil, true)
-- f3.container:translate(20, 10)
-- f3.container:rotate(0, 0, math.rad(45))
-- f2.container:add(core.renderer.redPoint())
-- f3.container:add(core.renderer.redPoint())
f3.container:scale(3, 2, 1)
-- f.container:scale(0.1, 0.1, 1)

local i = core.renderer.image("/data/gfx/background/tome.png")
i:translate(0, 0, -1)
i:scale(0.4, 0.2, 1)
f.container:add(i)

local t0 = core.renderer.text(UIBase.font_bold)
t0:text("MELTOPAL")
t0:translate(50, 20, 100)
f.container:add(t0)

local t1 = core.renderer.text(UIBase.font)
t1:text("Coco l'asticot!")
t1:translate(50, 50, 100)
t1:rotate(0, 0, math.rad(45))
f.container:add(t1)

local t2 = core.renderer.text(UIBase.font_bold)
t2:text("MELTOPAL")
t2:translate(50, 90, 100)
f.container:add(t2)

f.container:add(f2.container)
f2.container:add(f3.container)
renderer:add(f.container)

local fbo = core.renderer.target()
-- fbo:scale(1, 0.4, 1)
fbo:clearColor(0, 1, 0, 1)
fbo:displaySize(400, 400)
fbo:translate(400, 400)
fbo:rotate(math.rad(45), 0, 0)
local fborenderer = core.renderer.renderer()
fborenderer:add(fbo)

local nb = 0
local z = false
-- function _M:display()
-- 	-- fbo:use(true)
-- 		renderer:toScreen(0, 0, 1, 1, 1, 1)
-- 		-- f3.container:scale(1, 2 + math.sin(core.game.getTime()/500), 1)
-- 		-- t1:rotate(0, 0, math.rad(2), true)
-- 	-- fbo:use(false)

-- 	-- fborenderer:toScreen(0, 0, 1, 1, 1, 1)
-- 	-- fbo:rotate(0, math.rad(2), 0, true)
-- end

--- Ask if we really want to close, if so, save the game first
function _M:onQuit()
	if self.is_quitting then return end
	self.is_quitting = Dialog:yesnoPopup("Quit", "Really exit T-Engine/ToME?", function(ok)
		self.is_quitting = false
		if ok then core.game.exit_engine() end
	end, "Quit", "Continue")
end

profile_help_text = [[#LIGHT_GREEN#T-Engine4#LAST# allows you to sync your player profile with the website #LIGHT_BLUE#http://te4.org/#LAST#

This allows you to:
* Play from several computers without having to copy unlocks and achievements.
* Keep track of your modules progression, kill count, ...
* Talk ingame to other fellow players
* Cool statistics for each module to help sharpen your gameplay style
* Help the game developers balance and refine the game

You will also have a user page on http://te4.org/ where you can show off your achievements to your friends.
This is all optional, you are not forced to use this feature at all, but the developers would thank you if you did as it will make balancing easier.
Online profile requires an internet connection, if not available it will wait and sync when it finds one.]]

function _M:checkFirstTime()
	if not profile.generic.firstrun and not core.steam then
		profile:checkFirstRun()
		local text = "Thanks for downloading T-Engine/ToME.\n\n"..profile_help_text
		Dialog:yesnocancelLongPopup("Welcome to T-Engine", text, 600, function(ret, cancel)
			if cancel then return end
			if not ret then
				local dialogdef = {}
				dialogdef.fct = function(login) self:setPlayerLogin(login) end
				dialogdef.name = "login"
				dialogdef.justlogin = true
				game:registerDialog(require('mod.dialogs.ProfileLogin').new(dialogdef, game.profile_help_text))
			else
				local dialogdef = {}
				dialogdef.fct = function(login) self:setPlayerLogin(login) end
				dialogdef.name = "creation"
				dialogdef.justlogin = false
				game:registerDialog(require('mod.dialogs.ProfileLogin').new(dialogdef, game.profile_help_text))
			end
		end, "Register new account", "Log in existing account", "Maybe later")
	end
end

function _M:newSteamAccount()
	self:registerDialog(require("mod.dialogs.ProfileSteamRegister").new())
end

function _M:createProfile(loginItem)
	if not loginItem.create then
		self.auth_tried = nil
		local d = Dialog:simpleWaiter("Login in...", "Please wait...") core.display.forceRedraw()
		profile:performlogin(loginItem.login, loginItem.pass)
		profile:waitFirstAuth()
		d:done()
		if profile.auth then
			Dialog:simplePopup("Profile logged in!", "Your online profile is now active. Have fun!", function() end )
		else
			Dialog:simplePopup("Login failed!", "Check your login and password or try again in in a few moments.", function() end )
		end
	else
		self.auth_tried = nil
		local d = Dialog:simpleWaiter("Registering...", "Registering on http://te4.org/, please wait...") core.display.forceRedraw()
		local ok, err = profile:newProfile(loginItem.login, loginItem.name, loginItem.pass, loginItem.email)
		profile:waitFirstAuth()
		d:done()
		if profile.auth then
			Dialog:simplePopup(self.justlogin and "Logged in!" or "Profile created!", "Your online profile is now active. Have fun!", function() end )
		else
			if err ~= "unknown" and err then
				Dialog:simplePopup("Profile creation failed!", "Creation failed: "..err.." (you may also register on http://te4.org/)", function() end )
			else
				Dialog:simplePopup("Profile creation failed!", "Try again in in a few moments, or try online at http://te4.org/", function() end )
			end
		end
	end
end

function _M:serverNews()
	local co = coroutine.create(function()
		local stop = false
		profile:getNews(function(news)
			stop = true
			if news and news.body then
				local title = news.title
				news = news.body:unserialize()
				news.title = title
				self.news = news
				self:updateNews()
			end
		end, core.steam and true or false)

		while not stop do coroutine.yield() end
	end)
	game:registerCoroutine("getnews", co)
end

--- Receives a profile event
-- Overloads to detect auth
function _M:handleProfileEvent(evt)
	evt = engine.GameEnergyBased.handleProfileEvent(self, evt)
	if evt and evt.e == "Auth" then
		local d = self.dialogs[#self.dialogs]
		if d and d.__CLASSNAME == "mod.dialogs.MainMenu" then
			d:on_recover_focus()
		end
	end
	if evt and evt.e == "Connected" then
		if core.webview_inactive then
			core.webview, core.webview_inactive = core.webview_inactive, nil
			self.tooltip = nil
			self:makeWebtooltip()

			local d = self.dialogs[#self.dialogs]
			if d and d.__CLASSNAME == "mod.dialogs.MainMenu" then
				d:on_recover_focus()
			end
		end
	end
	return evt
end
