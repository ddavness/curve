-- Aka: Euler Spiral, Cornu Spiral
--!strict

local root = script.Parent.Parent
local fresnel = require(root.math.fresnel)
local cf64 = require(root.utils.cf64)
local argcheck = require(root.utils.argcheck)
local vector64 = require(root.utils.vector64)

type Clothoid3Surface = {
    _start: cf64.CFrame64,
    -- Parameters strictly needed to compute the clothoid
    _A: number,
    _t0: number,
    _t1: number,
    -- Parameteres that will be stored for performance reasons (memoization)
    _t0sin: number,
    _t0cos: number,
    _t0fs: number,
    _t0fc: number,
    -- Parameters needed to project the clothoid into the 3D space
    -- planeX and planeY are ideally orthogonal to eachother
    _planex: vector64.Vector3f64,
    _planey: vector64.Vector3f64,
    _rotateOn: vector64.Vector3f64,
    _direction: number,
    -- Other parameters
    _tdepth: number,
}

export type Clothoid3Static = {
    __index: Clothoid3Static,
    -- Constructors
    new: (startp: cf64.CFrameInput, startRadius: number, endRadius: number, distance: number, radiusDirection: vector64.Vector3Input?, rotateOn: vector64.Vector3Input?, depth: number?) -> Clothoid3,
    entry: (startp: cf64.CFrameInput, targetRadius: number, distance: number, radiusDirection: vector64.Vector3Input?, rotateOn: vector64.Vector3Input?, depth: number?) -> Clothoid3, -- Enters from a straight line into a circle (curvature 0 -> x)
    exit: (startp: cf64.CFrameInput, startRadius: number, distance: number, radiusDirection: vector64.Vector3Input?, rotateOn: vector64.Vector3Input?, depth: number?) -> Clothoid3, -- From a arc segment into a straight (curvature x -> 0)
    ramp: (startp: cf64.CFrameInput, startRadius: number, endRadius: number, distance: number, depth: number?) -> Clothoid3,
    -- Methods
    locationAt: (self: Clothoid3, at: number) -> cf64.CFrame64,
    d1t: (self: Clothoid3, at: number) -> vector64.Vector3f64,
    d2t: (self: Clothoid3, at: number) -> vector64.Vector3f64,
    lengthAt: (self: Clothoid3, at: number) -> number,
}

export type Clothoid3 = typeof(setmetatable({} :: Clothoid3Surface, {} :: Clothoid3Static))

local Clothoid3: Clothoid3Static = {} :: Clothoid3Static
Clothoid3.__index = Clothoid3

--[[
    The clothoid model we're using is defined on a 2D plane: t -> (x, y) To translate this to the 3D space,
    the curve will be projected on a plane defined by two non-colinear vectors (example: lookVector for x, rightVector for y)

    While the Clothoid has well-defined first and second-order derivatives, the cartesian coordinates (x, y) of a Clothoid
    are given by the Fresnel integrals which do not have a closed-form solution

    There are, however, methods to compute a reasonable approximation of the fresnel integrals for a certain x.
    We'll be using a taylor series approximation for this; See utils/fresnel for the approximation implementation
]]
function Clothoid3:locationAt(at: number)
    argcheck.assertWarn(argcheck.between(at), `Clothoid.locationAt: at should be in [0, 1], got at = {at}`)
    local t = (1 - at) * self._t0 + at * self._t1
    local Ct = self._A * fresnel.C(t/self._A, self._tdepth) - self._t0fc
    local St = self._A * fresnel.S(t/self._A, self._tdepth) - self._t0fs

    local px = Ct * self._t0cos + St * self._t0sin
    local py = St * self._t0cos - Ct * self._t0sin

    return self._start
        * cf64.new(self._planex * px + self._planey * py)
        * cf64.fromAxisAngle(
            self._rotateOn,
            self._direction * (((t * t) - (self._t0 * self._t0)) / (self._A * self._A))
        )
end

--[[
    The tangent of the identity Clothoid C'(t) = (cos(t^2), sin(t^2)),
    and therefore the always has the same magnitude across the entire curve.
    Compute this tangent and apply the necessary transformations
]]
function Clothoid3:d1t(at: number): vector64.Vector3f64
    argcheck.assertWarn(argcheck.between(at), `Clothoid.d1t: at should be in [0, 1], got at = {at}`)
    local t = (1 - at) * self._t0 + at * self._t1
    local phase = (t * t - self._t0 * self._t0) / (self._A * self._A)
    local localTangent = self._planex * math.cos(phase) + self._planey * math.sin(phase)
    local worldTangent = self._start:VectorToWorldSpace(localTangent)
    return worldTangent * (self._t1 - self._t0)
end

--[[
    Apply the derivative to C''(t) = 2t * (-sin(t^2), cos(t^2)), with the
    appropriate transformations
]]
function Clothoid3:d2t(at: number): vector64.Vector3f64
    argcheck.assertWarn(argcheck.between(at), `Clothoid.d2t: at should be in [0, 1], got at = {at}`)
    local t = (1 - at) * self._t0 + at * self._t1
    local phase = (t * t - self._t0 * self._t0) / (self._A * self._A)
    local distance = self._t1 - self._t0
    local localAcceleration = (-self._planex * math.sin(phase) + self._planey * math.cos(phase))
        * (2 * t * distance * distance / (self._A * self._A))

    return self._start:VectorToWorldSpace(localAcceleration)
end

--[[
    Clothoids have the property that their length scales linearly with t
]]
function Clothoid3:lengthAt(at: number): number
    argcheck.assertWarn(argcheck.between(at), `Clothoid.lengthAt: at should be in [0, 1], got at = {at}`)
    return (self._t1 - self._t0) * at
end

function Clothoid3.new(
    startp: cf64.CFrameInput,
    startRadius: number,
    endRadius: number,
    distance: number,
    radiusDirection: vector64.Vector3Input?,
    rotateOn: vector64.Vector3Input?,
    depth: number?
): Clothoid3
    assert(startRadius ~= endRadius, `Clothoid.new: startRadius and endRadius must be different from eachother, got startRadius = endRadius = {startRadius} (you might want to use Arc.new instead)`)
    assert(startRadius ~= 0, `Clothoid.new: startRadius must be different than zero!`)
    assert(endRadius ~= 0, `Clothoid.new: endRadius must be different than zero!`)
    assert(distance > 0, `Clothoid.new: distance must be >0, got {distance}`)

    local d = if depth then depth else 15
    assert(d > 0 and math.floor(d) == d, `Clothoid.new: Expected depth to be positive integer, got {d}`)

    -- direction checks
    local direction = if radiusDirection then vector64.fromVector3(radiusDirection) else vector64.xAxis
    -- Since we're working with local coordinates we can just check if the Z component is null
    argcheck.assertWarn(direction.Z == 0, `Clothoid.new: radiusDirection vector expected to be orthogonal to Z vector (got z = {direction.Z}). Using the orthogonal projection of this vector`)
    direction = vector64.new(direction.X, direction.Y, 0)
    assert(direction.Magnitude > 2^-15, `Clothoid.new: radiusDirection vector is too small (length is close to zero), cannot safely normalize! Length: {direction.Magnitude}`)

    -- rotateOn checks
    local rotate = if rotateOn then vector64.fromVector3(rotateOn) else -vector64.yAxis
    assert(rotate.Magnitude > 2^-15, `Arc.new: rotateOn vector is too small (length is close to zero), cannot safely normalize! Length: {rotate.Magnitude}`)

    -- At least one of the radiuses must be finite
    assert(math.abs(startRadius) ~= math.huge or math.abs(endRadius) ~= math.huge, `Clothoid.new: At least one of the radiuses must be finite, but startRadius = {startRadius}, endRadius = {endRadius}`)
    local r0 = if startRadius == -math.huge then math.huge else startRadius
    local r1 = if endRadius == -math.huge then math.huge else endRadius

    -- Needs to be positive because otherwise A will be NaN
    local det = math.sign(r0 * r1 * (r0 - r1))
    if det == -1 then
        r0 = -r0
        r1 = -r1
        direction = -direction
    elseif det == 0 then
        error("Clothoid.new: A determinant is zero! (Critical, this block should never be reached!)")
    end

    local t0: number, t1: number, A: number
    if math.abs(startRadius) == math.huge then
        t0 = 0
        t1 = distance
        A = math.sqrt(2 * t1 * r1)
    elseif math.abs(endRadius) == math.huge then
        t0 = -distance
        t1 = 0
        A = math.sqrt(2 * t0 * r0)
    else
        t0 = (distance * endRadius) / (startRadius - endRadius)
        t1 = t0 + distance
        A = math.sqrt(2 * t0 * r0)
    end

    local t02A = (t0) / A
    local t02A2 = (t0 * t0) / (A * A)
    local self: Clothoid3Surface = {
        _start = cf64.fromCFrame(startp),
        _A = A,
        _t0 = t0,
        _t1 = t1,
        _t0sin = math.sin(t02A2),
        _t0cos = math.cos(t02A2),
        _t0fs = A * fresnel.S(t02A, d),
        _t0fc = A * fresnel.C(t02A, d),
        _planex = -vector64.zAxis,
        _planey = direction.Unit,
        _rotateOn = rotate.Unit,
        _tdepth = d,
        _direction = det
    }

    return table.freeze(setmetatable(self, Clothoid3))
end

function Clothoid3.entry(
    startp: cf64.CFrameInput,
    targetRadius: number,
    distance: number,
    radiusDirection: vector64.Vector3Input?,
    rotateOn: vector64.Vector3Input?,
    depth: number?
): Clothoid3
    return Clothoid3.new(startp, math.huge, targetRadius, distance, radiusDirection, rotateOn, depth)
end

function Clothoid3.exit(
    startp: cf64.CFrameInput,
    startRadius: number,
    distance: number,
    radiusDirection: vector64.Vector3Input?,
    rotateOn: vector64.Vector3Input?,
    depth: number?
): Clothoid3
    return Clothoid3.new(startp, startRadius, math.huge, distance, radiusDirection, rotateOn, depth)
end

function Clothoid3.ramp(
    startp: cf64.CFrameInput,
    startRadius: number,
    endRadius: number,
    distance: number,
    depth: number?
): Clothoid3
    return Clothoid3.new(startp, startRadius, endRadius, distance, Vector3.yAxis, -Vector3.xAxis, depth)
end

table.freeze(Clothoid3)
return Clothoid3
