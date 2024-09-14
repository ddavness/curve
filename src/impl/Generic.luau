--!strict

local root = script.Parent.Parent
local Curve = require(root.types)
local argcheck = require(root.utils.argcheck)

local function selfLocationAt(self: Curve.Curve3, at: number):  CFrame
    argcheck.assertWarn(argcheck.between(at), `Curve.locationAt: at should be in [0, 1], got at = {at}`)
    return self._locationAt(at)
end

local function Generic(f: (number) -> CFrame): Curve.Curve3
    local curveProto = {
        locationAt = selfLocationAt,
        startPoint = f(0),
        endPoint = f(1)
    }
    
    local curveMeta = {
        _locationAt = f
    }
    curveMeta.__index = curveMeta

    local curve = setmetatable(curveProto, curveMeta)
    table.freeze(curve)
    return curve
end

return Generic
