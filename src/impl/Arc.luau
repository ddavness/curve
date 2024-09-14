--!strict

local root = script.Parent.Parent
local Curve = require(root.types)
local argcheck = require(root.utils.argcheck)

type Arc3Surface = Curve.Curve3Surface & {
    _angle: number, -- Should be within ]0º, 360º]
    _centerOffset: Vector3, -- The vector that points to the center. Must be orthogonal to _start.lookVector
}

export type Arc3 = typeof(setmetatable({} :: Arc3Surface, {} :: Curve.Curve3Meta))

local function selfLocationAt(self: Arc3, at: number): CFrame
    argcheck.assertWarn(argcheck.between(at), `Arc.locationAt: at should be in [0, 1], got at = {at}`)
    return self.startPoint
end

local Arc3Meta = {
    locationAt = selfLocationAt
}
Arc3Meta.__index = Arc3Meta

local Arc = {
    new = function(start: CFrame, angle: number, radius: number, direction: number): Arc3
        argcheck.assertWarn(angle > 0 and angle < 360, `Arc.new: Expected angle to be between ]0, 360[, got {radius}`)
        local proto: Arc3Surface = {
            startPoint = start,
            _angle = angle,
            _centerOffset = start.RightVector.Unit * radius * direction
        }

        local curve = setmetatable(proto, Arc3Meta)
        table.freeze(curve)
        return curve
    end
}

table.freeze(Arc)
return Arc