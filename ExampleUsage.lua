--[[
Combined with my FABRIK IK implementation. Made in 2023, definitely not good code. Either way, it works.
]]

local PhysicsController = require(script.Parent.PhysicsController)
local IKController = require(script.Parent.IKController)
task.wait(3)
local RunService = game:GetService("RunService")

local Target =workspace.Target 
local Head = workspace.Head

local TargetsForLegs = {Vector3.new(0,0,0),Vector3.new(0,0,0),Vector3.new(0,0,0),Vector3.new(0,0,0)}

local RaycastParams_ = RaycastParams.new()
RaycastParams_.FilterType = Enum.RaycastFilterType.Include
RaycastParams_.FilterDescendantsInstances = {workspace.Collidables}

local f, zeta, r = 1,0.35,0.1
local f2,zeta2, r2 = 2,0.5,0
local Body = PhysicsController.physicsBody(Head,Target, f, zeta, r)

local Endpoints = {
	PhysicsController.physicsBody({Position = Vector3.new()}, {Position = Vector3.new()}, f2,zeta2,r2),
	PhysicsController.physicsBody({Position = Vector3.new()}, {Position = Vector3.new()}, f2,zeta2,r2),
	PhysicsController.physicsBody({Position = Vector3.new()}, {Position = Vector3.new()}, f2,zeta2,r2),
	PhysicsController.physicsBody({Position = Vector3.new()}, {Position = Vector3.new()}, f2,zeta2,r2)
}

local Points = {
	{Vector3.new(), Vector3.new(1), Vector3.new(2), Vector3.new(3), Vector3.new(4)},
	{Vector3.new(), Vector3.new(1), Vector3.new(2), Vector3.new(3), Vector3.new(4)},
	{Vector3.new(), Vector3.new(1), Vector3.new(2), Vector3.new(3), Vector3.new(4)},
	{Vector3.new(), Vector3.new(1), Vector3.new(2), Vector3.new(3), Vector3.new(4)},
}
local Systems = {
	IKController.system(Points[1], {8,8,8,32,100}),
	IKController.system(Points[2], {8,8,8,32,100}),
	IKController.system(Points[3], {8,8,8,32,100}),
	IKController.system(Points[4], {8,8,8,32,100})
}

local grounded = {
	false,
	false,
	false,
	false
}

RunService.Heartbeat:Connect(function(dt)
	--[[workspace.Target.CFrame = workspace.troutser.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,-20))
	workspace.Target.CFrame = CFrame.new(workspace.Target.Position, workspace.troutser.HumanoidRootPart.Position)]]
	--Body.yvelocity += Vector3.new(0, math.sin(time()*10)*3,0)
	Body:step(dt)
	local offsetsT = {
		Head.CFrame.RightVector * Head.Size.X *2 + Head.CFrame.LookVector * Head.Size.Z*2,
		-Head.CFrame.RightVector * Head.Size.X * 2 + Head.CFrame.LookVector * Head.Size.Z*2,
		Head.CFrame.RightVector * Head.Size.X*2 - Head.CFrame.LookVector * Head.Size.Z *2,
		-Head.CFrame.RightVector * Head.Size.X *2- Head.CFrame.LookVector * Head.Size.Z*2
	}
	local offsetsP = {
		Head.CFrame.RightVector * Head.Size.X * 0.5 + Head.CFrame.LookVector * Head.Size.Z * 0.5,
		-Head.CFrame.RightVector * Head.Size.X * 0.5 + Head.CFrame.LookVector * Head.Size.Z * 0.5,
		Head.CFrame.RightVector * Head.Size.X * 0.5 - Head.CFrame.LookVector * Head.Size.Z * 0.5,
		-Head.CFrame.RightVector * Head.Size.X * 0.5 - Head.CFrame.LookVector * Head.Size.Z * 0.5,
	}
	for i, System in pairs(Systems) do
		local raycast = workspace:Raycast(Head.Position + offsetsT[i] * 3 + Body.yvelocity * 0.5, Vector3.new(0,-100,0), RaycastParams_)
		local jumpV = Vector3.new()
		if raycast then
			if (raycast.Position-TargetsForLegs[i]).Magnitude > 8*2 and grounded[1+i%3] then
				workspace[i].Position = raycast.Position
				workspace[i].Color = Color3.new(math.random(), math.random(), math.random())
				TargetsForLegs[i] = raycast.Position
				grounded[i] = false
				jumpV = Vector3.new(0,75,0) * 3
			end
		end
		Endpoints[i]._target = {Position = TargetsForLegs[i]}
		if (Endpoints[i]:getxposition()-Endpoints[i]:getxtarget()).Magnitude < 1 then
			grounded[i] = true
		end
		
		Endpoints[i]._position = {Position = System.points[#System.points]}
		Endpoints[i].yvelocity += jumpV
		Endpoints[i]:step(dt)
		
		System.points[2] = Head.Position + offsetsT[i] * 1.4 + Vector3.new(0,4,0)
		System.points[3] = Head.Position + offsetsT[i] * 1.8 + Vector3.new(0,4,0)
		System.points[4] = Head.Position + offsetsT[i] * 2.2 + Vector3.new(0,4,0)
		System:solve(5, Endpoints[i]:getxposition(), Head.Position + offsetsP[i])
		System:represent()
	end
end)
