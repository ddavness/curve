--!strict

local root = script.Parent.Parent
local argcheck = require(root.utils.argcheck)

type Arc3Surface = {
    startPoint: CFrame,
    _angle: number, -- Should be within ]0º, 360º]
    _direction: number,
    _centerOffset: Vector3, -- The vector that points to the center. Must be orthogonal to startPoint.lookVector
    _centerRotateOn: Vector3
}

export type Arc3Static = {
    __index: Arc3Static,
    -- Constructors
    new: (start: CFrame, angle: number, radius: number, radiusDirection: Vector3?, rotateOn: Vector3?) -> Arc3,
    ramp: (start: CFrame, angle: number, radius: number) -> Arc3,
    -- Methods
    locationAt: (self: Arc3, at: number) -> CFrame,
}

export type Arc3 = typeof(setmetatable({} :: Arc3Surface, {} :: Arc3Static))

local Arc3: Arc3Static = {} :: Arc3Static
Arc3.__index = Arc3

function Arc3:locationAt(at: number)
    argcheck.assertWarn(argcheck.between(at), `Arc.locationAt: at should be in [0, 1], got at = {at}`)
    return self.startPoint * CFrame.new(self._centerOffset) * CFrame.fromAxisAngle(self._centerRotateOn, self._angle * at * self._direction) * CFrame.new(-self._centerOffset)
end

function Arc3.new(start: CFrame, angle: number, radius: number, radiusDirection: Vector3?, rotateOn: Vector3?): Arc3
    argcheck.assertWarn(radius ~= 0, `Arc.new: Expected radius to be different than 0`)
    argcheck.assertWarn(angle > 0 and angle < 2 * math.pi, `Arc.new: Expected angle to be between ]0, 2\u{03c0}[, got {angle}. Remember to use radians!`)

    -- direction checks
    local direction = if radiusDirection then radiusDirection else Vector3.xAxis
    -- Since we're working with local coordinates we can just check if the Z component is null
    argcheck.assertWarn(direction.Z ~= 0, `Arc.new: radiusDirection vector expected to be orthogonal to Z vector (got z = {direction.Z}). Using the orthogonal projection of this vector`)
    direction = Vector3.new(direction.X, direction.Y, 0)
    assert(direction.Magnitude > 2^-5, `Arc.new: radiusDirection vector is too small (or almost zero)! Length: {direction.Magnitude}`)

    -- rotateOn checks
    local rotate = if rotateOn then rotateOn else Vector3.yAxis
    assert(rotate.Magnitude > 2^-5, `Arc.new: rotateOn vector is too small (or almost zero)! Length: {rotate.Magnitude}`)

    local self: Arc3Surface = {
        startPoint = start,
        _angle = angle,
        _direction = math.sign(radius),
        _centerOffset = direction * radius,
        _centerRotateOn = rotate.Unit
    }

    return table.freeze(setmetatable(self, Arc3))
end

function Arc3.ramp(start: CFrame, angle: number, radius: number): Arc3
    return Arc3.new(start, angle, radius, Vector3.yAxis, -Vector3.xAxis)
end

table.freeze(Arc3)
return Arc3
