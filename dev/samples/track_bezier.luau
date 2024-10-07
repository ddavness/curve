--!strict
-- This sample builds a racetrack using only Clothoids and Circle Arcs

local Curve = require(game:GetService("ReplicatedStorage").curve)
local mkmesh = require(game:GetService("ServerScriptService").mkmesh)

local model = Instance.new("Model")

local line = Curve.Lerp.line(CFrame.new(0, 0, 300), 600)
local cb1 = Curve.BezierCubic.new(line:locationAt(1), 330, CFrame.new(200, 40, 100) * CFrame.Angles(0, 3*math.pi/4, 0), 450)
local cb2 = Curve.BezierCubic.new(cb1:locationAt(1), 120, cb1:locationAt(1) * CFrame.new(90, 0, -440), 155)
local cb3 = Curve.BezierCubic.new(cb2:locationAt(1), 1000, line:locationAt(0), 1000)
--local cb = Curve.BezierCubic.new(CFrame.new(-300, 0, 0), 500, CFrame.new(300, 0, 0) * CFrame.Angles(0, math.pi, 0) * CFrame.Angles(math.pi/36, 0, 0), 500)

-- Rendering the track in the Workspace
local PTS = 256 -- Points to use for non-straight line curves

mkmesh.frompointcloud(Curve.toPoints(line, 2)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(cb1, PTS)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(cb2, PTS)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(cb3, PTS)).Parent = model
-- mkmesh.frompointcloud(Curve.toPoints(cb, PTS)).Parent = model


for i, p in pairs(model:GetChildren()) do
    (p :: MeshPart).Color = Color3.fromHSV(0, 0, i/#model:GetChildren())
end

return model
