--!strict

local root = script.Parent.Parent
local Curve = require(root.types)
local argcheck = require(root.utils.argcheck)

type GenericCurve3Surface = Curve.Curve3Surface & {
    _locationAt: (t: number) -> CFrame
}

export type GenericCurve3 = typeof(setmetatable({} :: GenericCurve3Surface, {} :: Curve.Curve3Meta))

local function selfLocationAt(self: GenericCurve3, at: number):  CFrame
    argcheck.assertWarn(argcheck.between(at), `Curve.locationAt: at should be in [0, 1], got at = {at}`)
    return self._locationAt(at)
end

local GenericCurve3Meta = {
    locationAt = selfLocationAt
}
GenericCurve3Meta.__index = GenericCurve3Meta

local function Generic(f: (number) -> CFrame): GenericCurve3
    local curveProto: GenericCurve3Surface = {
        _locationAt = f,
        startPoint = f(0),
        endPoint = f(1)
    }

    local curve = setmetatable(curveProto, GenericCurve3Meta)
    table.freeze(curve)
    return curve
end

return Generic
