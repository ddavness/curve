--!strict

local root = script.Parent.Parent
local cf64 = require(root.utils.cf64)
local argcheck = require(root.utils.argcheck)
local vector64 = require(root.utils.vector64)

type Arc3Surface = {
    _start: cf64.CFrame64,
    _angle: number, -- Should be within ]0º, 360º]
    _direction: number,
    _centerOffset: cf64.CFrame64, -- The vector that points to the center. Must be orthogonal to startPoint.lookVector
    _centerRotateOn: vector64.Vector3f64
}

export type Arc3Static = {
    __index: Arc3Static,
    -- Constructors
    new: (start: cf64.CFrameInput, angle: number, radius: number, radiusDirection: vector64.Vector3Input?, rotateOn: vector64.Vector3Input?) -> Arc3,
    ramp: (start: cf64.CFrameInput, angle: number, radius: number) -> Arc3,
    banked: (start: cf64.CFrameInput, angle: number, radius: number, alignTo: vector64.Vector3Input?, rotateOn: vector64.Vector3Input?) -> Arc3,
    -- Methods
    locationAt: (self: Arc3, at: number) -> cf64.CFrame64,
    d1t: (self: Arc3, at: number) -> vector64.Vector3f64,
    d2t: (self: Arc3, at: number) -> vector64.Vector3f64,
    lengthAt: (self: Arc3, at: number) -> number,
}

export type Arc3 = typeof(setmetatable({} :: Arc3Surface, {} :: Arc3Static))

local Arc3: Arc3Static = {} :: Arc3Static
Arc3.__index = Arc3

local function radialVectorAt(self: Arc3, at: number): Vector3
    local centerFrame = self._start * self._centerOffset
    local rotation = cf64.fromAxisAngle(self._centerRotateOn, self._angle * at * self._direction)
    local localRadius = self._centerOffset:Inverse().Position

    return centerFrame:VectorToWorldSpace(rotation:VectorToWorldSpace(localRadius))
end

function Arc3:locationAt(at: number): cf64.CFrame64
    argcheck.assertWarn(argcheck.between(at), `Arc.locationAt: at should be in [0, 1], got at = {at}`)
    return self._start * self._centerOffset * cf64.fromAxisAngle(self._centerRotateOn, self._angle * at * self._direction) * self._centerOffset:Inverse()
end

-- Fixed-axis rotation gives v = ω × r and, for constant ω, a = ω × (ω × r).
-- See https://mechanicsmap.psu.edu/websites/12_rigid_body_kinematics/12-2_fixed_axis_rotation_vector/fixed_axis_rotation_vector.html
function Arc3:d1t(at: number): vector64.Vector3f64
    argcheck.assertWarn(argcheck.between(at), `Arc.d1t: at should be in [0, 1], got at = {at}`)
    local centerFrame = self._start * self._centerOffset
    local axis = centerFrame:VectorToWorldSpace(self._centerRotateOn)
    local angularSpeed = self._angle * self._direction

    return angularSpeed * axis:Cross(radialVectorAt(self, at))
end

function Arc3:d2t(at: number): vector64.Vector3f64
    argcheck.assertWarn(argcheck.between(at), `Arc.d2t: at should be in [0, 1], got at = {at}`)
    local centerFrame = self._start * self._centerOffset
    local axis = centerFrame:VectorToWorldSpace(self._centerRotateOn)
    local angularSpeed = self._angle * self._direction

    return angularSpeed * angularSpeed * axis:Cross(axis:Cross(radialVectorAt(self, at)))
end

--[[
    Perimeter of an arc = (radius * angle)
    Definition-ish of radian: An arc of 1 radian and radius 1 has length 1
]]
function Arc3:lengthAt(at: number): number
    argcheck.assertWarn(argcheck.between(at), `Arc.lengthAt: at should be in [0, 1], got at = {at}`)
    return self._centerOffset.Position.Magnitude * math.abs(self._angle * at)
end

function Arc3.new(
    start: cf64.CFrameInput,
    angle: number,
    radius: number,
    radiusDirection: vector64.Vector3Input?,
    rotateOn: vector64.Vector3Input?
): Arc3
    argcheck.assertWarn(radius ~= 0, `Arc.new: Expected radius to be different than 0`)

    -- direction checks
    local direction = if radiusDirection then vector64.fromVector3(radiusDirection) else vector64.xAxis
    -- Since we're working with local coordinates we can just check if the Z component is null
    argcheck.assertWarn(direction.Z == 0, `Arc.new: radiusDirection vector expected to be orthogonal to Z vector (got z = {direction.Z}). Using the orthogonal projection of this vector`)
    direction = vector64.new(direction.X, direction.Y, 0).Unit
    assert(direction.Magnitude > 2^-15, `Arc.new: radiusDirection vector is too small (length is close to zero), cannot safely normalize! Length: {direction.Magnitude}`)

    -- rotateOn checks
    local rotate = if rotateOn then vector64.fromVector3(rotateOn) else -vector64.yAxis
    assert(rotate.Magnitude > 2^-15, `Arc.new: rotateOn vector is too small (length is close to zero), cannot safely normalize! Length: {rotate.Magnitude}`)

    local self: Arc3Surface = {
        _start = cf64.fromCFrame(start),
        _angle = angle,
        _direction = math.sign(radius),
        _centerOffset = cf64.new(direction * radius),
        _centerRotateOn = rotate.Unit
    }

    return table.freeze(setmetatable(self, Arc3))
end

function Arc3.ramp(start: cf64.CFrameInput, angle: number, radius: number): Arc3
    return Arc3.new(start, angle, radius, Vector3.yAxis, Vector3.xAxis)
end

function Arc3.banked(start: cf64.CFrameInput, angle: number, radius: number, rotateOn: vector64.Vector3Input?): Arc3
    argcheck.assertWarn(radius ~= 0, `Arc.banked: Expected radius to be different than 0`)

    -- rotateOn checks
    local rotate = if rotateOn then vector64.fromVector3(rotateOn) else -vector64.yAxis
    assert(rotate.Magnitude > 2^-15, `Arc.banked: rotateOn vector is too small (length is close to zero), cannot safely normalize! Length: {rotate.Magnitude}`)
    local direction = start:VectorToObjectSpace(rotate:Cross(start.LookVector).Unit)
    -- Make sure local direction is constrained to the XY plane
    direction = vector64.new(direction.X, direction.Y, 0).Unit

    local s = cf64.fromCFrame(start)

    local self: Arc3Surface = {
        _start = s,
        _angle = angle,
        _direction = math.sign(radius),
        _centerOffset = cf64.new(direction * radius) * (s - s.Position):Inverse(),
        _centerRotateOn = rotate.Unit
    }

    return table.freeze(setmetatable(self, Arc3))
end

table.freeze(Arc3)
return Arc3
