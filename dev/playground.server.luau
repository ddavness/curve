--!strict

local Curve = require(game:GetService("ReplicatedStorage").curve)
local mkmesh = require(game:GetService("ServerScriptService").mkmesh)

local a1 = Curve.Arc.new(CFrame.new(0, 0, 0), 3 * math.pi/2.4, 200)
local a2 = Curve.Arc.new(CFrame.new(0, 10, 0) * CFrame.Angles(0, math.pi/2, 0), 5*math.pi/6, -240)

local b1 = Curve.Arc.new(CFrame.new(0, 20, 0), 5 * math.pi, -100)
local b2 = Curve.Generic.new(function(t: number): CFrame
    return b1:locationAt(t) + Vector3.new(0, t * 50, 0)
end)

local c1 = Curve.Arc.new(b2:locationAt(1), 7 * math.pi, 100)
local c2 = Curve.Generic.new(function(t: number): CFrame
    return c1:locationAt(t) + Vector3.new(0, t * 70, 0)
end)

-- mkmesh.frompointcloud(Curve.toPoints(a1, 1024)).Parent = workspace
-- mkmesh.frompointcloud(Curve.toPoints(a2, 1024)).Parent = workspace
-- mkmesh.frompointcloud(Curve.toPoints(b2, 1024)).Parent = workspace
-- mkmesh.frompointcloud(Curve.toPoints(c2, 1024)).Parent = workspace

local tilted = Curve.Arc.new(CFrame.Angles(0, 0, math.rad(5)), math.pi, 60)
local tilted2 = Curve.Arc.new(CFrame.Angles(0, 0, -math.rad(5)), math.pi, -60)

-- mkmesh.frompointcloud(Curve.toPoints(tilted, 1024)).Parent = workspace
-- mkmesh.frompointcloud(Curve.toPoints(tilted2, 1024)).Parent = workspace

local up = Curve.Arc.ramp(CFrame.new(0, -20, 0), math.pi/12, 400)
local down = Curve.Arc.ramp(up:locationAt(1), math.pi/6, -400)

mkmesh.frompointcloud(Curve.toPoints(up, 1024)).Parent = workspace
mkmesh.frompointcloud(Curve.toPoints(down, 1024)).Parent = workspace