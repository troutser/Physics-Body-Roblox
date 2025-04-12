local controller = {}
local pi = math.pi

controller.__index = controller

function controller.physicsBody(referenceForPosition, referenceForTarget, f, zeta, r)
	local k1, k2, k3= zeta/(pi * f), 1/(4*pi*pi*f*f), (r * zeta)/(2 * pi * f)

	local body = {}
	body.xvelocity = Vector3.new()
	body.yvelocity = Vector3.new()
	body.yacceleration = Vector3.new()
	body.yposition = Vector3.new()
	body.prevxposition = referenceForPosition.Position
	body._target = referenceForTarget
	body._position = referenceForPosition
	body.k1 = k1
	body.k2 = k2
	body.k3 = k3
	
	setmetatable(body, controller)
	
	return body
end
function controller:getxposition()
	return self._position.Position
end
function controller:getxtarget()
	return self._target.Position
end
function controller:setPosition(p)
	if self._target.CFrame then
		self._position.CFrame = CFrame.new(p) * self._target.CFrame.Rotation
	else
		self._position.Position = p
	end
end
function controller:step(dt)
	local k2_stable = math.max(self.k2, 1.1 * (dt*dt/4 + dt*self.k1/2))
	self.xvelocity += (self:getxtarget() - self.prevxposition) * dt
	self.yposition += self.yvelocity * dt
	self.yacceleration = (self:getxtarget() + self.k3 * self.xvelocity - self.yposition - self.k1 * self.yvelocity)/k2_stable
	self.yvelocity += dt * self.yacceleration
	self.prevxposition = self:getxposition()

	self:setPosition(self.yposition)
end
return controller
