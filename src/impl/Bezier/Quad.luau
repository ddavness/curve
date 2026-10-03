--!strict

local root = script.Parent.Parent.Parent
local cf64 = require(root.utils.cf64)
local argcheck = require(root.utils.argcheck)
local vector64 = require(root.utils.vector64)
local archyperbolic = require(root.math.archyperbolic)

type Quad3Surface = {
    _A: vector64.Vector3f64,
    _B: vector64.Vector3f64,
    _C: vector64.Vector3f64,
    _AB: vector64.Vector3f64,
    _BC: vector64.Vector3f64,
    _upA: vector64.Vector3f64,
}

export type Quad3Static = {
    __index: Quad3Static,
    -- Constructors
    new: (start: cf64.CFrameInput, b: number, endPoint: vector64.Vector3Input) -> Quad3,
    fromPositions: (
        a: vector64.Vector3Input,
        b: vector64.Vector3Input,
        c: vector64.Vector3Input,
        upA: vector64.Vector3Input?,
        upC: vector64.Vector3Input?
    ) -> Quad3,
    -- Methods
    locationAt: (self: Quad3, at: number) -> cf64.CFrame64,
    positionAt: (self: Quad3, at: number) -> vector64.Vector3f64, -- Same as locationAt but without the rotation component
    d1t: (self: Quad3, at: number) -> vector64.Vector3f64,
    d2t: (self: Quad3, at: number) -> vector64.Vector3f64,
    lengthAt: (self: Quad3, at: number) -> number,
}

export type Quad3 = typeof(setmetatable({} :: Quad3Surface, {} :: Quad3Static))

local Quad3: Quad3Static = {} :: Quad3Static
Quad3.__index = Quad3

function Quad3:d2t(_t: number): vector64.Vector3f64
    return self._BC - self._AB
end

function Quad3:d1t(t: number): vector64.Vector3f64
    argcheck.assertWarn(argcheck.between(t), `BezierQuad.d1t: at should be in [0, 1], got at = {t}`)
    return self._AB:Lerp(self._BC, t)
end

-- Integrates the norm of the linear hodograph in closed form. Derivation:
-- https://members.loria.fr/samuel.hornus/quadratic-arc-length.html
function Quad3:lengthAt(at: number): number
    argcheck.assertWarn(argcheck.between(at), `BezierQuad.lengthAt: at should be in [0, 1], got at = {at}`)

    local velocity = self._AB
    local slope = self._BC - self._AB
    local slopeSquared = slope:Dot(slope)
    if slopeSquared == 0 then
        return velocity.Magnitude * at
    end

    local shift = velocity:Dot(slope) / slopeSquared
    local crossMagnitude = velocity:Cross(slope).Magnitude
    local perpendicularSquared = (crossMagnitude * crossMagnitude) / slopeSquared

    local function primitive(x: number): number
        local shifted = x + shift
        if perpendicularSquared == 0 then
            return 0.5 * math.sqrt(slopeSquared) * shifted * math.abs(shifted)
        end

        local speed = math.sqrt(slopeSquared * shifted * shifted + perpendicularSquared)
        local scaled = math.sqrt(slopeSquared) * shifted / math.sqrt(perpendicularSquared)
        return 0.5 * (shifted * speed + perpendicularSquared / math.sqrt(slopeSquared) * archyperbolic.asinh(scaled))
    end

    return primitive(at) - primitive(0)
end

function Quad3:positionAt(t: number): vector64.Vector3f64
    argcheck.assertWarn(argcheck.between(t), `BezierQuad.positionAt: at should be in [0, 1], got at = {t}`)
    --[[
        Bernstein polynomials for qudratic beziers:
        (1-t)^2
        2(1-t)t
        t^2
    ]]--

    local t1 = 1 - t
    return self._A * (t1 * t1)
        + self._B * (2 * t1 * t)
        + self._C * (t * t)
end

function Quad3:locationAt(t: number): cf64.CFrame64
    argcheck.assertWarn(argcheck.between(t), `BezierCubic.locationAt: at should be in [0, 1], got at = {t}`)
    local d1t = self:d1t(t)
    assert(d1t ~= vector64.zero, `BezierCubic.locationAt: derivative for at = {t} is zero! Cannot compute direction.`)
    argcheck.assertWarn(d1t.Magnitude > 2^-15, `BezierCubic.locationAt: first derivative length for at = {t} is very small ({d1t.Magnitude}). There might be innaccuracies with direction.`)

    return cf64.lookAlong(self:positionAt(t), d1t.Unit, self._upA.Unit):Orthonormalize()
end

function Quad3.new(start: cf64.CFrameInput, b: number, endPoint: vector64.Vector3Input): Quad3
    return Quad3.fromPositions(start.Position, start.Position + start.LookVector * b, endPoint, start.UpVector)
end

function Quad3.fromPositions(a, b, c, upA): Quad3
    local self: Quad3Surface = {
        _A = vector64.fromVector3(a),
        _B = vector64.fromVector3(b),
        _C = vector64.fromVector3(c),
        _AB = 2 * (vector64.fromVector3(b) - vector64.fromVector3(a)),
        _BC = 2 * (vector64.fromVector3(c) - vector64.fromVector3(b)),
        _upA = if upA then vector64.fromVector3(upA) else vector64.yAxis,
    }

    return table.freeze(setmetatable(self, Quad3))
end

table.freeze(Quad3)
return Quad3
