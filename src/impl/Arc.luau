--!strict

local root = script.Parent.Parent
local Curve = require(root.types)
local argcheck = require(root.utils.argcheck)

type Arc3Surface = Curve.Curve3Surface & {
    _angle: number, -- Should be within ]0º, 360º]
    _direction: number,
    _centerOffset: Vector3, -- The vector that points to the center. Must be orthogonal to startPoint.lookVector
}

export type Arc3Static = {
    __index: Arc3Static,
    -- Constructors
    new: (start: CFrame, angle: number, radius: number) -> Arc3,
    -- Methods
    locationAt: (self: Arc3, at: number) -> CFrame,
}

export type Arc3 = typeof(setmetatable({} :: Arc3Surface, {} :: Arc3Static))

local Arc3: Arc3Static = {} :: Arc3Static
Arc3.__index = Arc3

function Arc3:locationAt(at: number): CFrame
    argcheck.assertWarn(argcheck.between(at), `Arc.locationAt: at should be in [0, 1], got at = {at}`)

    return ((self.startPoint + self._centerOffset) * CFrame.Angles(0, self._direction * math.rad(self._angle) * at, 0)) - self._centerOffset
end

function Arc3.new(start: CFrame, angle: number, radius: number): Arc3
    argcheck.assertWarn(radius ~= 0, `Arc.new: Expected radius to be different than 0`)
    argcheck.assertWarn(angle > 0 and angle < 360, `Arc.new: Expected angle to be between ]0, 360[, got {radius}`)

    local proto: Arc3Surface = {
        startPoint = start,
        _angle = angle,
        _direction = math.sign(radius),
        _centerOffset = start.RightVector.Unit * radius
    }

    local curve = setmetatable(proto, Arc3)
    table.freeze(curve)
    return curve
end

table.freeze(Arc3)
return Arc3
