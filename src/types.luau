--!strict

local root = script.Parent

local cf64 = require(root.utils.cf64)
local vector64 = require(root.utils.vector64)

export type Curve3Surface = {
}

export type Curve3Static = {
    __index: Curve3Static,
    locationAt: (self: Curve3, t: number) -> cf64.CFrame64,
    d1t: (self: Curve3, at: number) -> vector64.Vector3f64,
    d2t: (self: Curve3, at: number) -> vector64.Vector3f64,
    lengthAt: (self: Curve3, at: number) -> number,
}

export type Curve3 = typeof(setmetatable({} :: Curve3Surface, {} :: Curve3Static))

return nil
