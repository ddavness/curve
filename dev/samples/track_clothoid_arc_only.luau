--!strict
-- This sample builds a racetrack using only Clothoids and Circle Arcs

local Curve = require(game:GetService("ReplicatedStorage").curve)
local mkmesh = require(game:GetService("ServerScriptService").mkmesh)

local model = Instance.new("Model")

local line = Curve.Lerp.line(CFrame.new(0, 0, -400), 800)
local e1 = Curve.Clothoid.entry(line:locationAt(1), -160, 150)
local ec = Curve.Arc.new(e1:locationAt(1), 7.1*math.pi/8, -160)
local e2 = Curve.Clothoid.exit(ec:locationAt(1), -160, 75)
local line2 = Curve.Lerp.line(e2:locationAt(1), 150)
local e120 = Curve.Clothoid.entry(line2:locationAt(1), 120, 600)
local e200 = Curve.Clothoid.new(e120:locationAt(1), 120, -80, 300)
local a80 = Curve.Arc.new(e200:locationAt(1), 2*math.pi/4, -80)
local e80 = Curve.Clothoid.exit(a80:locationAt(1), -80, 140)
local line3 = Curve.Lerp.line(e80:locationAt(1), 350)
local en250 = Curve.Clothoid.entry(line3:locationAt(1), 200, 240)
local ex250 = Curve.Clothoid.new(en250:locationAt(1), 200, 500, 300)
local a400 = Curve.Arc.new(ex250:locationAt(1), math.pi/12, 500)
local ft = Curve.Clothoid.new(a400:locationAt(1), 500, -150, 360)
local e150 = Curve.Clothoid.exit(ft:locationAt(1), -150, 160)

-- Now we have the track almost done, but there's one problem
-- We still need to connect the last point we have to the start-finish straight!
-- We can do this with Bezier curves, but we can also do this with a clothoid-arc-clothoid
-- segment.

-- The algorithm was adapted from this paper:
-- Vázquez-Méndez, Miguel & Casal Urcera, Gerardo. (2016). The Clothoid Computation: A Simple and Efficient Numerical Algorithm.
-- Journal of Surveying Engineering. 142. 04016005:1-9 
-- doi.org/10.1061/(ASCE)SU.1943-5428.0000177

-- Also available for free at: https://www.researchgate.net/publication/292669884

local R = 250 -- Radius of the middle arc
local omega = 2.5*math.pi/6 -- Angle of the middle arc

local p0 = e150:locationAt(1)
local p1 = line.startPoint

local beta = math.acos((p0.LookVector):Dot(-p1.LookVector))
print(math.deg(beta))
local tau = (math.pi - (omega + beta))/2

-- We use -R instead of R here because we specifically know we're turning right
local _k0 = Curve.Clothoid.entry(e150:locationAt(1), -R, 2 * R * tau)
local _kx = Curve.Arc.new(_k0:locationAt(1), omega, -R)
local _k1 = Curve.Clothoid.exit(_kx:locationAt(1), -R, 2 * R * tau)

-- Align c0 so that the end of c1 is "colinear" with the start of line
local c1f = _k1:locationAt(1).Position
local r1 = Ray.new(p1.Position, p1.LookVector)
local tp1 = r1:ClosestPoint(c1f)
local dv1 = tp1 - c1f

-- Project dv1 into p0's LookVector
local dv0 = (1/((dv1.Unit):Dot(p0.LookVector.Unit))^2) * dv1:Dot(p0.LookVector.Unit) * p0.LookVector.Unit

local k0 = Curve.Clothoid.entry(e150:locationAt(1) + dv0, -R, 2 * R * tau)
local kx = Curve.Arc.new(k0:locationAt(1), omega, -R)
local k1 = Curve.Clothoid.exit(kx:locationAt(1), -R, 2 * R * tau)

local BANKING = math.pi/12 -- 10 degrees
local THICKNESS = 40 -- To keep top edge aligned with the rest of the track

local bk0 = Curve.Generic.new(function(at: number)
    local ats = (0.5 + 0.5 * math.sin(math.pi * (at - 0.5)))
    return k0:locationAt(at) * CFrame.new(0, math.sin(BANKING * ats) * THICKNESS, 0) * CFrame.Angles(0, 0, BANKING * ats)
end)
local bkx = Curve.Generic.new(function(at: number)
    return kx:locationAt(at) * CFrame.new(0, math.sin(BANKING) * THICKNESS, 0) * CFrame.Angles(0, 0, BANKING)
end)
local bk1 = Curve.Generic.new(function(at: number)
    local ats = (0.5 + 0.5 * math.sin(math.pi * (0.5 - at)))
    return k1:locationAt(at) * CFrame.new(0, math.sin(BANKING * ats) * THICKNESS, 0) * CFrame.Angles(0, 0, BANKING * ats)
end)

local ck0 = Curve.Lerp.direction(e150:locationAt(1), dv0)

-- Instead of making two different lines for the start-finish straight, we'll just
-- merge both the new section and the old one into a new line. Saves points and it's
-- one less junction!
local ck1 = Curve.Lerp.new(k1:locationAt(1), line:locationAt(1))

-- Rendering the track in the Workspace
local PTS = 256 -- Points to use for non-straight line curves

mkmesh.frompointcloud(Curve.toPoints(ck1, 2)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(e1, PTS)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(ec, PTS)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(e2, PTS)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(line2, 2)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(e120, PTS)).Parent = model
local pts = Curve.toPoints(e200, PTS)
mkmesh.frompointcloud(pts).Parent = model
mkmesh.frompointcloud(Curve.toPoints(a80, PTS)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(e80, PTS)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(line3, PTS)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(en250, PTS)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(ex250, PTS)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(a400, PTS)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(ft, PTS)).Parent = model
--mkmesh.frompointcloud(Curve.toPoints(a150, PTS)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(e150, PTS)).Parent = model

mkmesh.frompointcloud(Curve.toPoints(ck0, 2)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(bk0, PTS)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(bkx, PTS)).Parent = model
mkmesh.frompointcloud(Curve.toPoints(bk1, PTS)).Parent = model

for i, p in pairs(model:GetChildren()) do
    (p :: MeshPart).Color = Color3.fromHSV(0, 0, i/#model:GetChildren())
end

return model
