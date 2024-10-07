--!strict

local root = script.Parent.Parent.Parent
local argcheck = require(root.utils.argcheck)

type Cubic3Surface = {
    startPoint: CFrame,
    _A: Vector3,
    _B: Vector3,
    _C: Vector3,
    _D: Vector3,
    _upA: Vector3,
    _upD: Vector3
}

export type Cubic3Static = {
    __index: Cubic3Static,
    -- Constructors
    new: (startPoint: CFrame, b: number, endPoint: CFrame, d: number) -> Cubic3,
    fromPositions: (a: Vector3, b: Vector3, c: Vector3, d: Vector3, upA: Vector3?, upD: Vector3?) -> Cubic3,
    -- Methods
    locationAt: (self: Cubic3, at: number) -> CFrame,
    d1t: (self: Cubic3, at: number) -> Vector3,
    d2t: (self: Cubic3, at: number) -> Vector3,
}

export type Cubic3 = typeof(setmetatable({} :: Cubic3Surface, {} :: Cubic3Static))

local Cubic3: Cubic3Static = {} :: Cubic3Static
Cubic3.__index = Cubic3

function Cubic3:d1t(t: number): Vector3
    argcheck.assertWarn(argcheck.between(t), `Cubic3.d1t: at should be in [0, 1], got at = {t}`)
    --[[
        Bernstein polynomial dt1 for cubic beziers:
        -3(1-t)^2
        3(t-1)(3t-1)
        3(2-3t)t
        3t^2
    ]]--

    local t1 = 1 - t
    return self._A * -3 * (t1 * t1)
        + self._B * -3 * t1 * (3*t - 1)
        + self._C * 3 * (2 - 3 * t1) * t
        + self._D * 3 * (t * t)
end

function Cubic3:locationAt(t: number): CFrame
    argcheck.assertWarn(argcheck.between(t), `Cubic3.locationAt: at should be in [0, 1], got at = {t}`)
    --[[
        Bernstein polynomials for cubic beziers:
        (1-t)^3
        3 (1-t)^2 t
        3 (1-t)t^2
        t^3
    ]]--

    local t1 = 1 - t
    local pos = self._A * (t1 * t1 * t1)
        + self._B * (3* t1 * t1 * t)
        + self._C * (3* t1 * t * t)
        + self._D * (t * t * t)

    local d1t = self:d1t(t)
    assert(d1t ~= Vector3.zero, `Cubic3.locationAt: derivative for at = {t} is zero! Cannot compute direction.`)
    argcheck.assertWarn(d1t.Magnitude > 2^-15, `Cubic3.locationAt: first derivative length for at = {t} is very small ({d1t.Magnitude}). There might be innaccuracies with direction.`)

    return CFrame.lookAlong(pos, d1t, t1 * self._upA + t * self._upD):Orthonormalize()
end

function Cubic3.new(startPoint: CFrame, b: number, endPoint: CFrame, d: number): Cubic3
    local self: Cubic3Surface = {
        startPoint = startPoint,
        _A = startPoint.Position,
        _B = startPoint.Position + startPoint.LookVector * b,
        _C = endPoint.Position - endPoint.LookVector * d,
        _D = endPoint.Position,
        _upA = startPoint.UpVector,
        _upD = endPoint.UpVector
    }

    return table.freeze(setmetatable(self, Cubic3))
end

function Cubic3.fromPositions(a: Vector3, b: Vector3, c: Vector3, d: Vector3, upA: Vector3?, upD: Vector3?): Cubic3
    local self: Cubic3Surface = {
        startPoint = CFrame.lookAlong(a, b - a, upA or Vector3.yAxis),
        _A = a,
        _B = b,
        _C = c,
        _D = d,
        _upA = upA or Vector3.yAxis,
        _upD = upD or Vector3.yAxis
    }

    return table.freeze(setmetatable(self, Cubic3))
end

table.freeze(Cubic3)
return Cubic3