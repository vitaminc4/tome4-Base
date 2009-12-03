require "engine.class"
local ActorAI = require "engine.interface.ActorAI"
require "mod.class.Actor"

module(..., package.seeall, class.inherit(mod.class.Actor, engine.interface.ActorAI))

function _M:init(t)
	mod.class.Actor.init(self, t)
	ActorAI.init(self, t)
end

function _M:act()
	-- Do basic actor stuff
	mod.class.Actor.act(self)

	-- Let the AI think .... beware of Shub !
	self:doAI()
end

--- Called by ActorLife interface
-- We use it to pass aggression values to the AIs
function _M:onTakeHit(value, src)
	print("took hit from", src.name, "::", self.ai_target.actor)
	if not self.ai_target.actor then
		self.ai_target.actor = src
	end
end

function _M:tooltip()
	local str = mod.class.Actor.tooltip(self)
	return str..("\nTarget: %s\nUID: %d"):format(self.ai_target.actor and self.ai_target.actor.name or "none", self.uid)
end
