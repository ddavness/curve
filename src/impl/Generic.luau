--!strict

local root = script.Parent.Parent
local argcheck = require(root.utils.argcheck)

type GenericCurve3Surface = {
    _locationAt: (t: number) -> CFrame
}

export type GenericCurve3Static = {
    __index: GenericCurve3Static,
    new: (f: (number) -> CFrame) -> GenericCurve3,
    locationAt: (self: GenericCurve3, at: number) -> (CFrame),
}

export type GenericCurve3 = typeof(setmetatable({} :: GenericCurve3Surface, {} :: GenericCurve3Static))

local GenericCurve3: GenericCurve3Static = {} :: GenericCurve3Static
GenericCurve3.__index = GenericCurve3

function GenericCurve3.new(f: (number) -> CFrame): GenericCurve3
    local self = {}
    self._locationAt = f

    return table.freeze(setmetatable(self, GenericCurve3))
end

function GenericCurve3:locationAt(at: number)
    argcheck.assertWarn(argcheck.between(at), `Curve.locationAt: at should be in [0, 1], got at = {at}`)
    return self._locationAt(at)
end

table.freeze(GenericCurve3)
return GenericCurve3
