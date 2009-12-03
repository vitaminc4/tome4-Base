-- Defines a simple AI building blocks
-- Target nearest and move/attack it

newAI("move_simple", function(self)
	if self.ai_target.actor then
		local act = self.ai_target.actor
		local l = line.new(self.x, self.y, act.x, act.y)
		local lx, ly = l()
		if lx and ly then
			self:move(lx, ly)
		end
	elseif self.ai_target.x and self.ai_target.y then
		local l = line.new(self.x, self.y, self.ai_target.x, self.ai_target.y)
		local lx, ly = l()
		if lx and ly then
			self:move(lx, ly)
		end
	end
end)

newAI("target_simple", function(self)
	if self.ai_target.actor and not self.ai_target.actor.dead and rng.percent(90) then return end

	-- Find closer ennemy and target it
	-- Get list of actors ordered by distance
	local arr = game.level:getDistances(self)
	local act
	if not arr or #arr == 0 then
		-- No target? Ask the distancer to find one
		game.level:idleProcessActor(self)
		return
	end
	for i = 1, #arr do
		act = __uids[arr[i].uid]
		-- find the closest ennemy
		if act and self:reactionToward(act) < 0 then
			self.ai_target.actor = act
			break
		end
	end
end)

newAI("target_player", function(self)
	self.ai_target.actor = game.player
end)

newAI("simple", function(self)
	self:runAI("target_simple")
	self:runAI("move_simple")
end)
