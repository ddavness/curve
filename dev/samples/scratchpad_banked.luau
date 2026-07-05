--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Just a placeholder module where random code lives

local curve = require(ReplicatedStorage.curve)
local Curve = require(game:GetService("ReplicatedStorage").curve)
local mkmesh = require(game:GetService("ServerScriptService").mkmesh)

local PTS = 512

for i = 0, 11 do
    local bnk = CFrame.Angles(0, i * math.pi/6, 0) * CFrame.Angles(0, 0, -math.pi/6)
    mkmesh.frompointcloud(curve.toPoints(Curve.Lerp.line(bnk, 600), 2)).Parent = workspace

    mkmesh.frompointcloud(
        Curve.toPoints(Curve.Circle.banked(
            bnk,
            math.pi/2,
            600
        ), PTS)
    ).Parent = workspace

    mkmesh.frompointcloud(
        Curve.toPoints(Curve.Circle.new(
            CFrame.Angles(0, i * math.pi/6, 0),
            math.pi/2,
            600
        ), PTS)
    ).Parent = workspace
end

return nil
