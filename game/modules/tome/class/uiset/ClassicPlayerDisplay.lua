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

require "engine.class"
local Mouse = require "engine.Mouse"
local Button = require "engine.ui.Button"
local TooltipsData = require "mod.class.interface.TooltipsData"

module(..., package.seeall, class.inherit(TooltipsData))

function _M:init(x, y, w, h, bgcolor, font, size)
	self.display_x = x
	self.display_y = y
	self.w, self.h = w, h
	self.bgcolor = bgcolor
	self.font = core.display.newFont(font, size)
	self.fontbig = core.display.newFont(font, size * 2)
	self.mouse = Mouse.new()
	self.tex_cache = {textures={}, texture_bars={}}
	self:resize(x, y, w, h)
end

local function glTexFromArgs(tex, tw, th, _, _, w, h)
	return {_tex = tex, _tex_w = tw, _tex_h = th, w=w, h=h}
end

--- Resize the display area
function _M:resize(x, y, w, h)
	self.display_x, self.display_y = x, y
	self.mouse.delegate_offset_x = x
	self.mouse.delegate_offset_y = y
	self.w, self.h = w, h
	self.font_h = self.font:lineSkip()
	self.font_w = self.font:size(" ")
	self.bars_x = self.font_w * 9
	self.bars_w = self.w - self.bars_x - 5

	self.top = glTexFromArgs(core.display.loadImage("/data/gfx/ui/party_end.png"):glTexture())
	self.party = glTexFromArgs(core.display.loadImage("/data/gfx/ui/party_top.png"):glTexture())
	self.bg = glTexFromArgs(core.display.loadImage("/data/gfx/ui/player-display.png"):glTexture())

	self.portrait = glTexFromArgs(core.display.loadImage("/data/gfx/ui/party-portrait.png"):glTexture())
	self.portrait_unsel = glTexFromArgs(core.display.loadImage("/data/gfx/ui/party-portrait-unselect.png"):glTexture())

	self.icon_green = glTexFromArgs( core.display.loadImage("/data/gfx/ui/talent_frame_ok.png"):glTexture() )
	self.icon_yellow = glTexFromArgs( core.display.loadImage("/data/gfx/ui/talent_frame_sustain.png"):glTexture() )
	self.icon_red = glTexFromArgs( core.display.loadImage("/data/gfx/ui/talent_frame_cooldown.png"):glTexture() )

	self.items = {}
end

function _M:mouseTooltip(text, w, h, x, y, click)
	self.mouse:registerZone(x, y, w, h, function(button, mx, my, xrel, yrel, bx, by, event)
		game.tooltip_x, game.tooltip_y = 1, 1; game:tooltipDisplayAtMap(game.w, game.h, text)
		if click and event == "button" and button == "left" then
			click()
		end
	end)
end

function _M:makeTexture(text, x, y, r, g, b, max_w)
	max_w = max_w or self.w
	-- Check for cache
	local cached = self.tex_cache.textures[text]
	local cached_ok = cached and cached.r == r and cached.g == g and cached.b == b and cached.max_w == max_w
	if not cached_ok then
		local item = self.font:draw(text, max_w, r, g, b, true)[1]
		item = {r=r, g=g, b=b, max_w = max_w, item}
		self.tex_cache.textures[text] = item 
		cached = item
	end
	self.items[#self.items+1] = {cached[1], x=x, y=y}

	return self.w, self.font_h, x, y
end

local function samecolor(c1, c2)
	return (c1 == c2) or (c1.r == c2.r and c1.g == c2.g and c1.b == c2.b)
end

function _M:makeTextureBar(text, nfmt, val, max, reg, x, y, r, g, b, bar_col, bar_bgcol)
	local cached = self.tex_cache.texture_bars[text]
	-- it's a bunch of number comparisons so it's sufficiently fast for jit
	local cached_ok = cached and (nfmt == cached.nfmt) and (val == cached.val) and (max == cached.max) and (reg == cached.reg) and
		(r == cached.r) and (g == cached.g) and (b == cached.b) and samecolor(bar_col, cached.bar_col) and samecolor(bar_bgcol, cached.bar_bgcol)
	if not cached_ok then
		local items = {}
		items[#items+1] = function(disp_x, disp_y)
			core.display.drawQuad(disp_x + self.bars_x, disp_y, self.bars_w, self.font_h, bar_bgcol.r, bar_bgcol.g, bar_bgcol.b, 255)
		end
		items[#items+1] = function(disp_x, disp_y)
			core.display.drawQuad(disp_x + self.bars_x, disp_y, self.bars_w * val / max, self.font_h, bar_col.r, bar_col.g, bar_col.b, 255)
		end
		items[#items+1] = {self.font:draw(text, self.w, r, g, b, true)[1], x=0, y=0}
		items[#items+1] = {self.font:draw((nfmt or "%d/%d"):format(val, max), self.w, r, g, b, true)[1], x=self.bars_x + 5, y=0}

		if reg and reg ~= 0 then
			local reg_txt = (" (%s%.2f)"):format((reg > 0 and "+") or "",reg)
			local tex = self.font:draw(reg_txt, self.w, r, g, b, true)[1]
			items[#items+1] = {tex, x = self.bars_x + self.bars_w - self.font:size(reg_txt) - 3, y=0}
		end
		cached = {nfmt=nfmt, val=val, max=max, reg=reg, r=r, g=g, b=b, bar_col=bar_col, bar_bgcol=bar_bgcol, items}
		self.tex_cache.texture_bars[text] = cached
	end
	local items = cached[1]
	for i = 1,#items do
		if type(items[i]) == "table" then
			self.items[#self.items+1] = {items[i][1], x=x+items[i].x, y=y+items[i].y}
		else
			self.items[#self.items+1] = function(dx, dy) return items[i](dx + x, dy + y) end
		end
	end

	return self.w, self.font_h, x, y
end

function _M:makePortrait(a, current, x, y)
	local def = game.party.members[a]

	self:mouseTooltip("#GOLD##{bold}#"..a.name.."\n#WHITE##{normal}#Life: "..math.floor(100 * a.life / a.max_life).."%\nLevel: "..a.level.."\n"..def.title, 40, 40, x, y, function()
		if def.control == "full" then
			game.party:select(a)
		end
	end)

	local hl = 32 * math.max(0, a.life) / a.max_life
	self.items[#self.items+1] = function(disp_x, disp_y)
		core.display.drawQuad(disp_x + x + 4, disp_y + y + 4, 32, 32, 0, 0, 0, 255)
		core.display.drawQuad(disp_x + x + 4, disp_y + y + (40 - 4) - hl, 32, hl, 255 * 0.7, 0, 0, 255)
		a:toScreen(nil, disp_x+x+4, disp_y+y+1, 32, 32)
	end

	local p = current and self.portrait or self.portrait_unsel

	self.items[#self.items+1] = {p, x=x, y=y}
end

function _M:makeEntityIcon(e, tiles, x, y, desc, gtxt, frame)
	self:mouseTooltip(desc, 40, 40, x, y)

	local item = function(dx, dy)
		e:toScreen(tiles, dx+x+4, dy+y+4, 32, 32)
		if gtxt then
			gtxt._tex:toScreenFull(dx+x+4+2 + (40 - gtxt.fw)/2, dy+y+4+2 + (40 - gtxt.fh)/2, gtxt.w, gtxt.h, gtxt._tex_w, gtxt._tex_h, 0, 0, 0, 0.7)
			gtxt._tex:toScreenFull(dx+x+4 + (40 - gtxt.fw)/2, dy+y+4 + (40 - gtxt.fh)/2, gtxt.w, gtxt.h, gtxt._tex_w, gtxt._tex_h)
		end
		frame._tex:toScreenFull(dx+x, dy+y, 40, 40, frame._tex_w * 40 / frame.w, frame._tex_h * 40 / frame.h, 255, 255, 255, 255)
	end
	self.items[#self.items+1] = item
end

function _M:handleEffect(eff_id, e, p, ex, h)
	local player = game.player
	local dur = p.dur + 1
	local name = e.desc
	local desc = nil
	local eff_subtype = table.concat(table.keys(e.subtype), "/")
	if e.display_desc then name = e.display_desc(self, p) end
	if p.save_string and p.amount_decreased and p.maximum and p.total_dur then
		desc = ("#{bold}##GOLD#%s\n(%s: %s)#WHITE##{normal}#\n"):format(name, e.type, eff_subtype)..e.long_desc(player, p).." "..("%s reduced the duration of this effect by %d turns, from %d to %d."):format(p.save_string, p.amount_decreased, p.maximum, p.total_dur)
	else
		desc = ("#{bold}##GOLD#%s\n(%s: %s)#WHITE##{normal}#\n"):format(name, e.type, eff_subtype)..e.long_desc(player, p)
	end

	if config.settings.tome.effects_icons and e.display_entity then
		local txt = nil
		if e.decrease > 0 then
			dur = tostring(dur)
			txt = self.fontbig:draw(dur, 40, colors.WHITE.r, colors.WHITE.g, colors.WHITE.b, true)[1]
			txt.fw, txt.fh = self.fontbig:size(dur)
		end
		self:makeEntityIcon(e.display_entity, game.uiset.hotkeys_display_icons.tiles, ex, h, desc, txt, e.status ~= "detrimental" and self.icon_green or self.icon_red)

		ex = ex + 40
		if ex + 40 >= self.w then ex = 0 h = h + 40 end
	else
		ex = 0
		if e.status == "detrimental" then
			self:mouseTooltip(desc, self:makeTexture((e.decrease > 0) and ("#LIGHT_RED#%s(%d)"):format(name, dur) or ("#LIGHT_RED#%s"):format(name), ex, h, 255, 255, 255)) h = h + self.font_h
		else
			self:mouseTooltip(desc, self:makeTexture((e.decrease > 0) and ("#LIGHT_GREEN#%s(%d)"):format(name, dur) or ("#LIGHT_GREEN#%s"):format(name), ex, h, 255, 255, 255)) h = h + self.font_h
		end
	end
	return ex, h
end

-- Displays the stats
function _M:display()
	local player = game.player
	if not player or not player.changed or not game.level then return end

	self.mouse:reset()
	self.items = {}

	local cur_exp, max_exp = player.exp, player:getExpChart(player.level+1)
	local h = 6
	local x = 2

	-- Party members
	if #game.party.m_list >= 2 and game.level then
		self.items[#self.items+1] = {self.party, x=0, y=h}
		h = h + self.party.h + 3

		local nb = math.floor(self.w / 42)
		local off = (self.w - nb * 42) /2

		local w = (1 + nb > #game.party.m_list) and ((self.w - (#game.party.m_list - 0.5) * 42) / 2) or off
		h = h  + 42
		for i = 1, #game.party.m_list do
			local a = game.party.m_list[i]
			self:makePortrait(a, a == player, w, h - 42)
			w = w + 42
			if w + 42 > self.w and i < #game.party.m_list then
				w = (i + nb > #game.party.m_list) and ((self.w - (#game.party.m_list - i - 0.5) * 42) / 2) or off
				h = h + 42
			end
		end
		h = h + 2
	end

	self.items[#self.items+1] = {self.top, x=0, y=h}
	h = h + self.top.h + 5

	-- Player
	if player.unused_stats > 0 or player.unused_talents > 0 or player.unused_generics > 0 or player.unused_talents_types > 0 then
		self.font:setStyle("bold")
		local fw = self.font:size("LEVELUP!")
		self:makeTexture("LEVELUP!", self.w - fw, h, colors.VIOLET.r, colors.VIOLET.g, colors.VIOLET.b, fw)
		self.items[#self.items].glow = true
		self:mouseTooltip(("#GOLD##{bold}#%s\n#WHITE##{normal}#Unused stats: %d\nUnused class talents: %d\nUnused generic talents: %d\nUnused categories: %d"):format(player.name, player.unused_stats, player.unused_talents, player.unused_generics, player.unused_talents_types), self.w, self.font_h, 0, h, function()
			player:playerLevelup()
		end)
		h = h + self.font_h
	end

	self.font:setStyle("bold")
	self:makeTexture(("%s#{normal}#"):format(player.name), 0, h, colors.GOLD.r, colors.GOLD.g, colors.GOLD.b, self.w) h = h + self.font_h
	self.font:setStyle("normal")

	self:mouseTooltip(self.TOOLTIP_LEVEL, self:makeTexture(("Level / Exp: #00ff00#%s / %2d%%"):format(player.level, 100 * cur_exp / max_exp), x, h, 255, 255, 255)) h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_GOLD, self:makeTexture(("Gold: #00ff00#%0.2f"):format(player.money or 0), x, h, 255, 255, 255)) h = h + self.font_h

	--Display attack, defense, spellpower, mindpower, and saves.
	local attack_stats = {{"combatAttack", "TOOLTIP_COMBAT_ATTACK", "Accuracy:"}, {"combatPhysicalpower", "TOOLTIP_COMBAT_PHYSICAL_POWER", "P. power:"}, {"combatSpellpower", "TOOLTIP_SPELL_POWER", "S. power:"}, {"combatMindpower", "TOOLTIP_MINDPOWER", "M. power:"}, {"combatDefense", "TOOLTIP_DEFENSE", "Defense:"}, {"combatPhysicalResist", "TOOLTIP_PHYS_SAVE", "P. save:"}, {"combatSpellResist", "TOOLTIP_SPELL_SAVE", "S. save:"}, {"combatMentalResist", "TOOLTIP_MENTAL_SAVE", "M. save:"}}

	local attack_stat_color = "#FFD700#"
	local defense_stat_color = "#0080FF#"
	for i = 1, 4 do
		text = ("%s"):format(player:colorStats(attack_stats[i][1]))
		self:mouseTooltip(self[attack_stats[i][2]], self:makeTexture((attack_stat_color.."%s"):format(attack_stats[i][3]), x, h, 255, 255, 255))
		self:mouseTooltip(self[attack_stats[i][2]], self:makeTexture(("%s"):format(text), x+75, h, 255, 255, 255))
		text = ("%s"):format(player:colorStats(attack_stats[i+4][1]))
		self:mouseTooltip(self[attack_stats[i+4][2]], self:makeTexture((defense_stat_color.."%s"):format(attack_stats[i+4][3]), x+110, h, 255, 255, 255))
		self:mouseTooltip(self[attack_stats[i+4][2]], self:makeTexture(("%s"):format(text), x+180, h, 255, 255, 255)) h = h + self.font_h
	end
	h = h + self.font_h

	if game.level and game.level.turn_counter then
		self:makeTexture(("Turns remaining: %d"):format(game.level.turn_counter / 10), x, h, 255, 0, 0) h = h + self.font_h
		h = h + self.font_h
	end

	if player:getAir() < player.max_air then
		self:mouseTooltip(self.TOOLTIP_AIR, self:makeTexture(("Air level: %d/%d"):format(player:getAir(), player.max_air), x, h, 255, 0, 0)) h = h + self.font_h
		h = h + self.font_h
	end

	if player:attr("encumbered") then
		self:mouseTooltip(self.TOOLTIP_ENCUMBERED, self:makeTexture("Encumbered!", x, h, 255, 0, 0)) h = h + self.font_h
		h = h + self.font_h
	end

	self:mouseTooltip(self.TOOLTIP_STRDEXCON, self:makeTexture(("Str/Dex/Con: #00ff00#%3d/%3d/%3d"):format(player:getStr(), player:getDex(), player:getCon()), x, h, 255, 255, 255)) h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_MAGWILCUN, self:makeTexture(("Mag/Wil/Cun: #00ff00#%3d/%3d/%3d"):format(player:getMag(), player:getWil(), player:getCun()), x, h, 255, 255, 255)) h = h + self.font_h
	h = h + self.font_h

	if player.life < 0 then
		--self:mouseTooltip(self.TOOLTIP_LIFE, self:makeTextureBar("#c00000#Life:", "???", 0, player.max_life, player.life_regen * util.bound((player.healing_factor or 1), 0, 2.5), x, h, 255, 255, 255, colors.DARK_RED, colors.VERY_DARK_RED)) h = h + self.font_h
		self:mouseTooltip(self.TOOLTIP_LIFE, self:makeTextureBar("#c00000#Life:", nil, player.life, player.max_life, player.life_regen * util.bound((player.healing_factor or 1), 0, 2.5), x, h, 255, 255, 255, colors.DARK_RED, colors.VERY_DARK_RED)) h = h + self.font_h	
	else
		self:mouseTooltip(self.TOOLTIP_LIFE, self:makeTextureBar("#c00000#Life:", nil, player.life, player.max_life, player.life_regen * util.bound((player.healing_factor or 1), 0, 2.5), x, h, 255, 255, 255, colors.DARK_RED, colors.VERY_DARK_RED)) h = h + self.font_h
	end

	local shield, max_shield = 0, 0
	if player:attr("time_shield") then shield = shield + player.time_shield_absorb max_shield = max_shield + player.time_shield_absorb_max end
	if player:attr("damage_shield") then shield = shield + player.damage_shield_absorb max_shield = max_shield + player.damage_shield_absorb_max end
	if player:attr("displacement_shield") then shield = shield + player.displacement_shield max_shield = max_shield + player.displacement_shield_max end
	if max_shield > 0 then
		self:mouseTooltip(self.TOOLTIP_DAMAGE_SHIELD, self:makeTextureBar("#WHITE#Shield:", nil, shield, max_shield, nil, x, h, 255, 255, 255, {r=colors.GREY.r / 3, g=colors.GREY.g / 3, b=colors.GREY.b / 3}, {r=colors.GREY.r / 6, g=colors.GREY.g / 6, b=colors.GREY.b / 6})) h = h + self.font_h
	end

	if player:knowTalent(player.T_STAMINA_POOL) then
		self:mouseTooltip(self.TOOLTIP_STAMINA, self:makeTextureBar("#ffcc80#Stamina:", nil, player:getStamina(), player.max_stamina, player.stamina_regen, x, h, 255, 255, 255, {r=0xff / 3, g=0xcc / 3, b=0x80 / 3}, {r=0xff / 6, g=0xcc / 6, b=0x80 / 6})) h = h + self.font_h
	end
	if player:knowTalent(player.T_MANA_POOL) then
		self:mouseTooltip(self.TOOLTIP_MANA, self:makeTextureBar("#7fffd4#Mana:", nil, player:getMana(), player.max_mana, player.mana_regen, x, h, 255, 255, 255,
			{r=0x7f / 2, g=0xff / 2, b=0xd4 / 2},
			{r=0x7f / 5, g=0xff / 5, b=0xd4 / 5}
		)) h = h + self.font_h
	end
	if player:knowTalent(player.T_SOUL_POOL) then
		self:mouseTooltip(self.TOOLTIP_NECROTIC_AURA, self:makeTextureBar("#7fffd4#Necrotic", "%d", player:getSoul(), player.max_soul, nil, x, h, 255, 255, 255,
			{r=colors.GREY.r / 2, g=colors.GREY.g / 2, b=colors.GREY.b / 2},
			{r=colors.GREY.r / 5, g=colors.GREY.g / 5, b=colors.GREY.b / 5}
		)) h = h + self.font_h
	end
	if player:knowTalent(player.T_EQUILIBRIUM_POOL) then
		local _, chance = player:equilibriumChance()
		self:mouseTooltip(self.TOOLTIP_EQUILIBRIUM, self:makeTextureBar("#00ff74#Equi:", ("%d (%d%s)"):format(player:getEquilibrium(),100 - chance, "%%"), 100 - chance, 100, player.equilibrium_regen, x, h, 255, 255, 255,
			{r=0x00 / 2, g=0xff / 2, b=0x74 / 2},
			{r=0x00 / 5, g=0xff / 5, b=0x74 / 5}
		)) h = h + self.font_h
	end
	if player:knowTalent(player.T_POSITIVE_POOL) then
		self:mouseTooltip(self.TOOLTIP_POSITIVE, self:makeTextureBar("#7fffd4#Positive:", nil, player:getPositive(), player.max_positive, player.positive_regen, x, h, 255, 255, 255,
			{r=colors.GOLD.r / 2, g=colors.GOLD.g / 2, b=colors.GOLD.b / 2},
			{r=colors.GOLD.r / 5, g=colors.GOLD.g / 5, b=colors.GOLD.b / 5}
		)) h = h + self.font_h
	end
	if player:knowTalent(player.T_NEGATIVE_POOL) then
		self:mouseTooltip(self.TOOLTIP_NEGATIVE, self:makeTextureBar("#7fffd4#Negative:", nil, player:getNegative(), player.max_negative, player.negative_regen, x, h, 255, 255, 255,
			{r=colors.GREY.r / 2, g=colors.GREY.g / 2, b=colors.GREY.b / 2},
			{r=colors.GREY.r / 5, g=colors.GREY.g / 5, b=colors.GREY.b / 5}
		)) h = h + self.font_h
	end
	if player:knowTalent(player.T_VIM_POOL) then
		self:mouseTooltip(self.TOOLTIP_VIM, self:makeTextureBar("#904010#Vim:", nil, player:getVim(), player.max_vim, player.vim_regen, x, h, 255, 255, 255,
			{r=0x90 / 3, g=0x40 / 3, b=0x10 / 3},
			{r=0x90 / 6, g=0x40 / 6, b=0x10 / 6}
		)) h = h + self.font_h
	end
	if player:knowTalent(player.T_HATE_POOL) then
		self:mouseTooltip(self.TOOLTIP_HATE, self:makeTextureBar("#F53CBE#Hate:", "%d/%d", player:getHate(), player.max_hate, player.hate_regen, x, h, 255, 255, 255,
			{r=0xF5 / 2, g=0x3C / 2, b=0xBE / 2},
			{r=0xF5 / 5, g=0x3C / 5, b=0xBE / 5}
		)) h = h + self.font_h
	end
	if (player.unnatural_body_heal  or 0) > 0 and player:knowTalent(player.T_UNNATURAL_BODY) then
		local t = player:getTalentFromId(player.T_UNNATURAL_BODY)
		local regen = t.getRegenRate(player, t)
		self:mouseTooltip(self.TOOLTIP_UNNATURAL_BODY, self:makeTextureBar("#c00000#Un.body:", ("%0.1f (%0.1f/turn)"):format(player.unnatural_body_heal, math.min(regen, player.unnatural_body_heal)), regen, player.unnatural_body_heal, nil, x, h, 255, 255, 255, colors.DARK_RED, colors.VERY_DARK_RED)) h = h + self.font_h
	end
	if player:knowTalent(player.T_PARADOX_POOL) then
		local chance = player:paradoxFailChance()
		self:mouseTooltip(self.TOOLTIP_PARADOX, self:makeTextureBar("#LIGHT_STEEL_BLUE#Paradox:", ("%d/%d (%d%s)"):format(player:getModifiedParadox(), player:getParadox(), chance, "%%"), chance, 100, chance, x, h, 255, 255, 255,
			{r=176 / 2, g=196 / 2, b=222 / 2},
			{r=176 / 5, g=196 / 5, b=222 / 5}
		)) h = h + self.font_h
	end
	if player:knowTalent(player.T_PSI_POOL) then
		self:mouseTooltip(self.TOOLTIP_PSI, self:makeTextureBar("#7fffd4#Psi:", nil, player:getPsi(), player.max_psi, player.psi_regen, x, h, 255, 255, 255,
			{r=colors.BLUE.r / 2, g=colors.BLUE.g / 2, b=colors.BLUE.b / 2},
			{r=colors.BLUE.r / 5, g=colors.BLUE.g / 5, b=colors.BLUE.b / 5}
		)) h = h + self.font_h
	end
	
	if player:knowTalent(player.T_FEEDBACK_POOL) then
		self:mouseTooltip(self.TOOLTIP_FEEDBACK, self:makeTextureBar("#7fffd4#Feedback:", nil, player:getFeedback(), player:getMaxFeedback(), player:getFeedbackDecay(), x, h, 255, 255, 255,
			{r=colors.YELLOW.r / 2, g=colors.YELLOW.g / 2, b=colors.YELLOW.b / 2},
			{r=colors.YELLOW.r / 5, g=colors.YELLOW.g / 5, b=colors.YELLOW.b / 5}
		)) h = h + self.font_h
	end

	-- Any hooks
	local hd = {"UISet:Classic:Resources", player=player, x=x, h=h}
	if self:triggerHook(hd) then 
		x, h = hd.x, hd.h
	end

	local quiver = player:getInven("QUIVER")
	local ammo = quiver and quiver[1]
	if ammo then
		if ammo.type == "alchemist-gem" then
			self:mouseTooltip(self.TOOLTIP_COMBAT_AMMO, self:makeTexture(("#ANTIQUE_WHITE#Ammo:       #ffffff#%d"):format(ammo:getNumber()), 0, h, 255, 255, 255)) h = h + self.font_h
		else
			self:mouseTooltip(self.TOOLTIP_COMBAT_AMMO, self:makeTexture(("#ANTIQUE_WHITE#Ammo:       #ffffff#%d/%d"):format(ammo.combat.shots_left, ammo.combat.capacity), 0, h, 255, 255, 255)) h = h + self.font_h
		end
	end

	if savefile_pipe.saving then
		h = h + self.font_h
		self:makeTextureBar("Saving:", "%d%%", 100 * savefile_pipe.current_nb / savefile_pipe.total_nb, 100, nil, x, h, colors.YELLOW.r, colors.YELLOW.g, colors.YELLOW.b,
			{r=0x95 / 3, g=0xa2 / 3,b= 0x80 / 3},
			{r=0x68 / 6, g=0x72 / 6, b=0x00 / 6}
		)

		h = h + self.font_h
	end

	h = h + self.font_h
	local ex = 0
	for tid, act in pairs(player.sustain_talents) do
		if act then
			local t = player:getTalentFromId(tid)
			local displayName = t.name
			if t.getDisplayName then displayName = t.getDisplayName(player, t, player:isTalentActive(tid)) end
			local desc = "#GOLD##{bold}#"..displayName.."#{normal}##WHITE#\n"..tostring(player:getTalentFullDescription(t))

			if config.settings.tome.effects_icons and t.display_entity then
				self:makeEntityIcon(t.display_entity, game.uiset.hotkeys_display_icons.tiles, ex, h, desc, nil, self.icon_yellow)
				ex = ex + 40
				if ex + 40 >= self.w then ex = 0 h = h + 40 end
			else
				self:mouseTooltip(desc, self:makeTexture(("#LIGHT_GREEN#%s"):format(displayName), x, h, 255, 255, 255)) h = h + self.font_h
				ex = 0
			end
		end
	end
	if config.settings.tome.effects_icons then h = h + 40 ex = 0 end
	local good_e, bad_e = {}, {}
	for eff_id, p in pairs(player.tmp) do
		local e = player.tempeffect_def[eff_id]
		if e.status == "detrimental" then bad_e[eff_id] = p else good_e[eff_id] = p end
	end

	for eff_id, p in pairs(good_e) do
		local e = player.tempeffect_def[eff_id]
		ex, h = self:handleEffect(eff_id, e, p, ex, h)
	end
	if config.settings.tome.effects_icons then h = h + 40 ex = 0 end
	for eff_id, p in pairs(bad_e) do
		local e = player.tempeffect_def[eff_id]
		ex, h = self:handleEffect(eff_id, e, p, ex, h)
	end

	if game.level and game.level.arena then
		h = h + self.font_h
		local arena = game.level.arena
		if arena.score > world.arena.scores[1].score then
			self:makeTexture(("Score(TOP): %d"):format(arena.score), x, h, 255, 255, 100) h = h + self.font_h
		else
			self:makeTexture(("Score: %d"):format(arena.score), x, h, 255, 255, 255) h = h + self.font_h
		end
		if arena.currentWave > world.arena.bestWave then
			self:makeTexture(("Wave(TOP) %d"):format(arena.currentWave), x, h, 255, 255, 100)
		elseif arena.currentWave > world.arena.lastScore.wave then
			self:makeTexture(("Wave %d"):format(arena.currentWave), x, h, 100, 100, 255)
		else
			self:makeTexture(("Wave %d"):format(arena.currentWave), x, h, 255, 255, 255)
		end
		if arena.event > 0 then
			if arena.event == 1 then
				self:makeTexture((" [MiniBoss]"), x + (self.font_w * 13), h, 255, 255, 100)
			elseif arena.event == 2 then
				self:makeTexture((" [Boss]"), x + (self.font_w * 13), h, 255, 0, 255)
			elseif arena.event == 3 then
				self:makeTexture((" [Final]"), x + (self.font_w * 13), h, 255, 10, 15)
			end
		end
		h = h + self.font_h
		if arena.pinch == true then
			self:makeTexture(("Bonus: %d (x%.1f)"):format(arena.bonus, arena.bonusMultiplier), x, h, 255, 50, 50) h = h + self.font_h
		else
			self:makeTexture(("Bonus: %d (x%.1f)"):format(arena.bonus, arena.bonusMultiplier), x, h, 255, 255, 255) h = h + self.font_h
		end
		if arena.display then
			h = h + self.font_h
			self:makeTexture(arena.display[1], x, h, 255, 0, 255) h = h + self.font_h
			self:makeTexture(" VS", x, h, 255, 0, 255) h = h + self.font_h
			self:makeTexture(arena.display[2], x, h, 255, 0, 255) h = h + self.font_h
		else
			self:makeTexture("Rank: "..arena.printRank(arena.rank, arena.ranks), x, h, 255, 255, 255) h = h + self.font_h
		end
		h = h + self.font_h
	end

end

function _M:toScreen(nb_keyframes)
	self:display()

	self.bg._tex:toScreen(self.display_x, self.display_y, self.w, self.h)
	for i = 1, #self.items do
		local item = self.items[i]
		if type(item) == "table" then
			local glow = 255
			if item.glow then
				glow = (1+math.sin(core.game.getTime() / 500)) / 2 * 100 + 120
			end
			local tex = item[1]
			tex._tex:toScreenFull(self.display_x + item.x, self.display_y + item.y, tex.w, tex.h, tex._tex_w, tex._tex_h, 1, 1, 1, glow / 255)
		else
			item(self.display_x, self.display_y)
		end
	end
end
