--!strict

local root = script.Parent.Parent
local argcheck = require(root.utils.argcheck)

type Arc3Surface = {
    _start: CFrame,
    _angle: number, -- Should be within ]0º, 360º]
    _direction: number,
    _centerOffset: CFrame, -- The vector that points to the center. Must be orthogonal to startPoint.lookVector
    _centerRotateOn: Vector3
}

export type Arc3Static = {
    __index: Arc3Static,
    -- Constructors
    new: (start: CFrame, angle: number, radius: number, radiusDirection: Vector3?, rotateOn: Vector3?) -> Arc3,
    ramp: (start: CFrame, angle: number, radius: number) -> Arc3,
    banked: (start: CFrame, angle: number, radius: number, alignTo: Vector3?, rotateOn: Vector3?) -> Arc3,
    -- Methods
    locationAt: (self: Arc3, at: number) -> CFrame,
    d1t: (self: Arc3, at: number) -> Vector3,
    d2t: (self: Arc3, at: number) -> Vector3,
    lengthAt: (self: Arc3, at: number) -> number,
}

export type Arc3 = typeof(setmetatable({} :: Arc3Surface, {} :: Arc3Static))

local Arc3: Arc3Static = {} :: Arc3Static
Arc3.__index = Arc3

local function radialVectorAt(self: Arc3, at: number): Vector3
    local centerFrame = self._start * self._centerOffset
    local rotation = CFrame.fromAxisAngle(self._centerRotateOn, self._angle * at * self._direction)
    local localRadius = self._centerOffset:Inverse().Position

    return centerFrame:VectorToWorldSpace(rotation:VectorToWorldSpace(localRadius))
end

function Arc3:locationAt(at: number): CFrame
    argcheck.assertWarn(argcheck.between(at), `Arc.locationAt: at should be in [0, 1], got at = {at}`)
    return self._start * self._centerOffset * CFrame.fromAxisAngle(self._centerRotateOn, self._angle * at * self._direction) * self._centerOffset:Inverse()
end

-- Fixed-axis rotation gives v = ω × r and, for constant ω, a = ω × (ω × r).
-- See https://mechanicsmap.psu.edu/websites/12_rigid_body_kinematics/12-2_fixed_axis_rotation_vector/fixed_axis_rotation_vector.html
function Arc3:d1t(at: number): Vector3
    argcheck.assertWarn(argcheck.between(at), `Arc.d1t: at should be in [0, 1], got at = {at}`)
    local centerFrame = self._start * self._centerOffset
    local axis = centerFrame:VectorToWorldSpace(self._centerRotateOn)
    local angularSpeed = self._angle * self._direction

    return angularSpeed * axis:Cross(radialVectorAt(self, at))
end

function Arc3:d2t(at: number): Vector3
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

function Arc3.new(start: CFrame, angle: number, radius: number, radiusDirection: Vector3?, rotateOn: Vector3?): Arc3
    argcheck.assertWarn(radius ~= 0, `Arc.new: Expected radius to be different than 0`)

    -- direction checks
    local direction = if radiusDirection then radiusDirection else Vector3.xAxis
    -- Since we're working with local coordinates we can just check if the Z component is null
    argcheck.assertWarn(direction.Z == 0, `Arc.new: radiusDirection vector expected to be orthogonal to Z vector (got z = {direction.Z}). Using the orthogonal projection of this vector`)
    direction = Vector3.new(direction.X, direction.Y, 0).Unit
    assert(direction.Magnitude > 2^-15, `Arc.new: radiusDirection vector is too small (length is close to zero), cannot safely normalize! Length: {direction.Magnitude}`)

    -- rotateOn checks
    local rotate = if rotateOn then rotateOn else -Vector3.yAxis
    assert(rotate.Magnitude > 2^-15, `Arc.new: rotateOn vector is too small (length is close to zero), cannot safely normalize! Length: {rotate.Magnitude}`)

    local self: Arc3Surface = {
        _start = start,
        _angle = angle,
        _direction = math.sign(radius),
        _centerOffset = CFrame.new(direction * radius),
        _centerRotateOn = rotate.Unit
    }

    return table.freeze(setmetatable(self, Arc3))
end

function Arc3.ramp(start: CFrame, angle: number, radius: number): Arc3
    return Arc3.new(start, angle, radius, Vector3.yAxis, Vector3.xAxis)
end

function Arc3.banked(start: CFrame, angle: number, radius: number, rotateOn: Vector3?): Arc3
    argcheck.assertWarn(radius ~= 0, `Arc.banked: Expected radius to be different than 0`)

    -- rotateOn checks
    local rotate = if rotateOn then rotateOn else -Vector3.yAxis
    assert(rotate.Magnitude > 2^-15, `Arc.banked: rotateOn vector is too small (length is close to zero), cannot safely normalize! Length: {rotate.Magnitude}`)
    local direction = start:VectorToObjectSpace(rotate:Cross(start.LookVector).Unit)
    -- Make sure local direction is constrained to the XY plane
    direction = Vector3.new(direction.X, direction.Y, 0).Unit

    local self: Arc3Surface = {
        _start = start,
        _angle = angle,
        _direction = math.sign(radius),
        _centerOffset = CFrame.new(direction * radius) * (start - start.Position):Inverse(),
        _centerRotateOn = rotate.Unit
    }

    return table.freeze(setmetatable(self, Arc3))
end

table.freeze(Arc3)
return Arc3
