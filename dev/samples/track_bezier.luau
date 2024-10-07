--!strict
-- This sample builds a racetrack using only Clothoids and Circle Arcs

local Curve = require(game:GetService("ReplicatedStorage").curve)
local mkmesh = require(game:GetService("ServerScriptService").mkmesh)

local model = Instance.new("Model")

local line = Curve.Lerp.line(CFrame.new(0, 0, 300), 600)
local cb1 = Curve.BezierCubic.new(line:locationAt(1), 330, CFrame.new(200, 40, 100) * CFrame.Angles(0, 3*math.pi/4, 0), 450)
local cb2 = Curve.BezierCubic.new(cb1:locationAt(1), 120, cb1:locationAt(1) * CFrame.new(90, 0, -440), 155)
local qb3 = Curve.BezierQuad.new(cb2:locationAt(1), 155, Vector3.new(-400, 70, 755))
local qb3e = qb3:locationAt(1)
local cb4 = Curve.BezierCubic.new(qb3e, 320, CFrame.new(-550, 70, 400) * CFrame.Angles(0, -3*math.pi/10, 0), 450)
local line_sample = Curve.Lerp.line(cb4:locationAt(1), 890)
local BANKING = math.rad(10)
local RAISE = 40
local line2 = Curve.Generic.new(function(t: number)
    return line_sample:locationAt(t) * CFrame.Angles(0, 0, -t * BANKING) + Vector3.new(0, RAISE * math.sin(t * BANKING), 0)
end)
local arc = Curve.Clothoid.entry(line2:locationAt(1), 150, 850)
local cb5 = Curve.BezierCubic.new(arc:locationAt(1), 600, line:locationAt(0), 600)

-- Rendering the track in the Workspace
local PTS = 2048 -- Points to use for non-straight line curves

mkmesh.frompointcloud(Curve.toPoints(line, 2)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(cb1, PTS)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(cb2, PTS)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(qb3, PTS)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(cb4, PTS)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(line2, PTS)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(arc, PTS)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(cb5, PTS)).Parent = model


for i, p in pairs(model:GetChildren()) do
    (p :: MeshPart).Color = Color3.fromHSV(0, 0, i/#model:GetChildren())
end

return model
