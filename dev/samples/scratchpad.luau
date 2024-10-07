--!strict
-- Just a placeholder module where random code lives

local Curve = require(game:GetService("ReplicatedStorage").curve)
local mkmesh = require(game:GetService("ServerScriptService").mkmesh)

local PTS = 512
local base = CFrame.new()

mkmesh.frompointcloud(Curve.toPoints(Curve.Lerp.line(base, 500), 2)).Parent = workspace
mkmesh.frompointcloud(Curve.toPoints(Curve.Circle.new(base, math.pi/2, 400), PTS)).Parent = workspace
mkmesh.frompointcloud(Curve.toPoints(Curve.Circle.new(base, math.pi/3, -400), PTS)).Parent = workspace

mkmesh.frompointcloud(Curve.toPoints(Curve.Clothoid.new(base, -math.huge, 400, 1000), PTS)).Parent = workspace

mkmesh.frompointcloud(Curve.toPoints(Curve.Circle.ramp(base, math.pi/3, 400), PTS)).Parent = workspace
mkmesh.frompointcloud(Curve.toPoints(Curve.Clothoid.ramp(base, -math.huge, -400, 300), PTS)).Parent = workspace

return nil
