--!strict

local Curve = require(game:GetService("ReplicatedStorage").curve)

local function mkpartsAt(cf: CFrame)
    local p = Instance.new("Part")
    p.CFrame = cf
    p.Size = Vector3.new(80, 0.4, 0.4)
    p.Anchored = true

    local q = Instance.new("Part")
    q.CFrame = cf - 0.2 * cf.LookVector.Unit
    q.Size = Vector3.new(60, 0.15, 0.15)
    q.Color = Color3.new(1, 0, 0)
    q.Material = Enum.Material.Neon
    q.Anchored = true
    
    p.Parent = workspace
    q.Parent = workspace
end

local a1 = Curve.Arc.new(CFrame.new(0, 0, 0), 3 * math.pi/2.4, 200)
local a2 = Curve.Arc.new(CFrame.new(0, 10, 0), 5*math.pi/6, -240)

local b1 = Curve.Arc.new(CFrame.new(0, 20, 0), 5 * math.pi, -100)
local b2 = Curve.Generic.new(function(t: number): CFrame
    return b1:locationAt(t) + Vector3.new(0, t * 50, 0)
end)

local c1 = Curve.Arc.new(b2:locationAt(1), 7 * math.pi, 100)
local c2 = Curve.Generic.new(function(t: number): CFrame
    return c1:locationAt(t) + Vector3.new(0, t * 70, 0)
end)

for _, c in pairs(Curve.toPoints(a1, 1024)) do
    mkpartsAt(c)
end

for _, c in pairs(Curve.toPoints(a2, 1024)) do
    mkpartsAt(c)
end

for _, c in pairs(Curve.toPoints(b2, 2560)) do
    mkpartsAt(c)
end

for _, c in pairs(Curve.toPoints(c2, 3584)) do
    mkpartsAt(c)
end