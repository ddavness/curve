-- Aka: Euler Spiral, Cornu Spiral
--!strict

local root = script.Parent.Parent
local argcheck = require(root.utils.argcheck)

type Clothoid3Surface = {
    startPoint: CFrame,
    -- Parameters needed to compute?
}

export type Clothoid3Static = {
    __index: Clothoid3Static,
    -- Constructors
    new: (startp: CFrame, startCurvature: number, endCurvature: number, radiusDirection: Vector3?, rotateOn: Vector3?, depth: number?) -> Clothoid3,
    fromRadius: (start: CFrame, startRadius: number, endRadius: number, radiusDirection: Vector3?, rotateOn: Vector3?, depth: number?) -> Clothoid3,
    entry: (startp: CFrame, targetRadius: number, radiusDirection: Vector3?, rotateOn: Vector3?, depth: number?) -> Clothoid3, -- Enters from a straight line into a circle (curvature 0 -> x)
    exit: (startp: CFrame, startRadius: number, radiusDirection: Vector3?, rotateOn: Vector3?, depth: number?) -> Clothoid3, -- From a arc segment into a straight (curvature x -> 0)
    -- Methods
    locationAt: (self: Clothoid3, at: number) -> CFrame,
}

export type Clothoid3 = typeof(setmetatable({} :: Clothoid3Surface, {} :: Clothoid3Static))

local Clothoid3: Clothoid3Static = {} :: Clothoid3Static
Clothoid3.__index = Clothoid3

--[[
    While the Clothoid has well-defined first and second-order derivatives, the cartesian coordinates (x, y) of a Clothoid
    are given by the Fresnel integrals which do not have an analytic solution

    There are, however, methods to compute a reasonable approximation of the fresnel integrals for a certain x.
    We'll be using a taylor series approximation for this
]]

function Clothoid3:locationAt(at: number)
    argcheck.assertWarn(argcheck.between(at), `Clothoid.locationAt: at should be in [0, 1], got at = {at}`)
    return CFrame.new()
end

table.freeze(Clothoid3)
return Clothoid3
