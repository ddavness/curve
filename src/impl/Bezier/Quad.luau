--!strict

local root = script.Parent.Parent.Parent
local argcheck = require(root.utils.argcheck)

type Quad3Surface = {
    _A: Vector3,
    _B: Vector3,
    _C: Vector3,
    _AB: Vector3,
    _BC: Vector3,
    _upA: Vector3,
}

export type Quad3Static = {
    __index: Quad3Static,
    -- Constructors
    new: (start: CFrame, b: number, endPoint: Vector3) -> Quad3,
    fromPositions: (a: Vector3, b: Vector3, c: Vector3, upA: Vector3?, upC: Vector3?) -> Quad3,
    -- Methods
    locationAt: (self: Quad3, at: number) -> CFrame,
    positionAt: (self: Quad3, at: number) -> Vector3, -- Same as locationAt but without the rotation component
    d1t: (self: Quad3, at: number) -> Vector3,
    d2t: (self: Quad3, at: number) -> Vector3,
}

export type Quad3 = typeof(setmetatable({} :: Quad3Surface, {} :: Quad3Static))

local Quad3: Quad3Static = {} :: Quad3Static
Quad3.__index = Quad3

function Quad3:d2t(_t: number): Vector3
    return self._BC - self._AB
end

function Quad3:d1t(t: number): Vector3
    argcheck.assertWarn(argcheck.between(t), `BezierQuad.d1t: at should be in [0, 1], got at = {t}`)
    return self._AB:Lerp(self._BC, t)
end

function Quad3:positionAt(t: number): Vector3
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

function Quad3:locationAt(t: number): CFrame
    argcheck.assertWarn(argcheck.between(t), `BezierCubic.locationAt: at should be in [0, 1], got at = {t}`)
    local d1t = self:d1t(t)
    assert(d1t ~= Vector3.zero, `BezierCubic.locationAt: derivative for at = {t} is zero! Cannot compute direction.`)
    argcheck.assertWarn(d1t.Magnitude > 2^-15, `BezierCubic.locationAt: first derivative length for at = {t} is very small ({d1t.Magnitude}). There might be innaccuracies with direction.`)

    return CFrame.lookAlong(self:positionAt(t), d1t.Unit, self._upA.Unit):Orthonormalize()
end

function Quad3.new(start: CFrame, b: number, endPoint: Vector3): Quad3
    return Quad3.fromPositions(start.Position, start.Position + start.LookVector * b, endPoint, start.UpVector)
end

function Quad3.fromPositions(a: Vector3, b: Vector3, c: Vector3, upA: Vector3?): Quad3
    local self: Quad3Surface = {
        _A = a,
        _B = b,
        _C = c,
        _AB = 2 * (b - a),
        _BC = 2 * (c - b),
        _upA = upA or Vector3.yAxis,
    }

    return table.freeze(setmetatable(self, Quad3))
end

table.freeze(Quad3)
return Quad3