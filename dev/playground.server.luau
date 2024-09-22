--!strict

local Curve = require(game:GetService("ReplicatedStorage").curve)
local mkmesh = require(game:GetService("ServerScriptService").mkmesh)

local samples = game.ServerScriptService.samples
require(samples.track_clothoid_arc_only).Parent = workspace
