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
local socket = require "socket"

module(..., package.seeall, class.make)

function _M:init()
end

function _M:connected()
	if self.sock then return true end
	self.sock = socket.connect("te4.org", 2257)
	if not self.sock then return false end
--	self.sock:settimeout(10)
	print("[PROFILE] Thread connected to te4.org")
	self:login()
	return true
end

--- Connects the second tcp channel to receive data
function _M:connectedPull()
	if self.psock then return true end
	self.psock = socket.connect("te4.org", 2258)
	if not self.psock then return false end
	print("[PROFILE] Pull socket connected to te4.org")
--	self.psock:send("
	return true
end

function _M:write(str, ...)
	self.sock:send(str:format(...))
end

function _M:disconnect()
	self.sock = nil
	self.auth = nil
end

function _M:read(ncode)
	local l, err = self.sock:receive("*l")
	if not l then
		if err == "closed" then
			print("[PROFILE] connection disrupted, trying to reconnect", err)
			self:disconnect()
		end
		return nil
	end
	if ncode and l:sub(1, 3) ~= ncode then
		return nil, "bad code"
	end
	self.last_line = l:sub(5)
	return l
end

function _M:login()
	if self.sock and not self.auth and self.user_login and self.user_pass then
		self:command("AUTH", self.user_login)
		self:read("200")
		self:command("PASS", self.user_pass)
		if self:read("200") then
			print("[PROFILE] logged in!", self.user_login)
			self.auth = self.last_line:unserialize()
			cprofile.pushEvent(string.format("e='Auth' ok=%q", self.last_line))
			return true
		else
			print("[PROFILE] could not log in")
			self.user_login = nil
			self.user_pass = nil
			cprofile.pushEvent("e='Auth' ok=false")
			return false
		end
	end
end

function _M:command(c, ...)
	self.sock:send(("%s %s\n"):format(c, table.concat({...}, " ")))
end

function _M:step()
	if self:connected() then
		local rready = socket.select({self.sock}, nil, 0)
		if rready[self.sock] then
			local l = self:read()
			if l then print("GOT: ", l) end
		end
		return true
	end
	return false
end

function _M:run()
	while true do
		local order = cprofile.popOrder()
		while order do self:handleOrder(order) order = cprofile.popOrder() end

		self:step()
		core.game.sleep(50)
	end
end

--------------------------------------------------------------------
-- Orders comming from the main thread
--------------------------------------------------------------------

function _M:orderNewProfile2(o)
	self:command("NEWP", table.serialize(o))
	if self:read("200") then
		cprofile.pushEvent(string.format("e='NewProfile2' uid=%d", tonumber(self.last_line) or -1))
	else
		cprofile.pushEvent("e='NewProfile2' uid=nil")
	end
end

function _M:orderLogin(o)
	-- Already logged?
	if self.auth and self.auth.login == o.l then
		print("[PROFILE] reusing login", self.auth.name)
		cprofile.pushEvent(string.format("e='Auth' ok=%q", table.serialize(self.auth)))
	else
		self.user_login = o.l
		self.user_pass = o.p
		self:login()
	end
end

function _M:orderLogoff(o)
	-- Already logged?
	if self.auth then
		print("[PROFILE] logoff", self.auth.name)
		cprofile.pushEvent("e='Logoff'")
		self.auth = nil
	end
end

function _M:orderGetNews(o)
	self:command("NEWS")
	if self:read("200") then
		local _, _, size, title = self.last_line:find("^([0-9]+) (.*)")
		size = tonumber(size)
		if not size or size < 1 or not title then cprofile.pushEvent("e='News' news=false") return end

		local body = self.sock:receive(size)
		cprofile.pushEvent(string.format("e='GetNews' news=%q", table.serialize{title=title, body=body}))
	else
		cprofile.pushEvent("e='GetNews' news=false")
	end
end

function _M:orderGetConfigs(o)
	if not self.auth then return end
	self:command("GCFS", o.module)
	if self:read("200") then
		local _, _, size = self.last_line:find("^([0-9]+)")
		size = tonumber(size)
		if not size or size < 1 then return end
		local body = self.sock:receive(size)
		cprofile.pushEvent(string.format("e='GetConfigs' module=%q data=%q", o.module, body))
	end
end

function _M:orderSetConfigs(o)
	if not self.auth then return end
	self:command("SCFS", o.data:len(), o.module)
	if self:read("200") then
		self.sock:send(o.data)
	end
end

function _M:orderSendError(o)
	o = table.serialize(o)
	self:command("ERR_", o:len())
	if self:read("200") then
		self.sock:send(o)
	end
end

function _M:orderCheckModuleHash(o)
	self:command("CMD5", o.md5, o.module)
	if self:read("200") then
		cprofile.pushEvent("e='CheckModuleHash' ok=true")
	else
		cprofile.pushEvent("e='CheckModuleHash' ok=false")
	end
end

function _M:orderRegisterNewCharacter(o)
	self:command("CHAR", "NEW", o.module)
	if self:read("200") then
		cprofile.pushEvent(string.format("e='RegisterNewCharacter' uuid=%q", self.last_line))
	else
		cprofile.pushEvent("e='RegisterNewCharacter' uuid=nil")
	end
end

function _M:orderSaveChardump(o)
	self:command("CHAR", "UPDATE", o.metadata:len(), o.data:len(), o.uuid, o.module)
	if not self:read("200") then return end
	self.sock:send(o.metadata)
	if not self:read("200") then return end
	self.sock:send(o.data)
	cprofile.pushEvent("e='SaveChardump' ok=true")
end

function _M:handleOrder(o)
	o = o:unserialize()
	if not self.sock and o.o ~= "Login" then return end -- Dont do stuff without a connection, unless we try to auth
	if self["order"..o.o] then self["order"..o.o](self, o) end
end
