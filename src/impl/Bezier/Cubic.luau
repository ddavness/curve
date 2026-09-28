--!strict

local root = script.Parent.Parent.Parent
local argcheck = require(root.utils.argcheck)
local bQuad = require(root.impl.Bezier.Quad)

type Cubic3Surface = {
    _A: Vector3,
    _B: Vector3,
    _C: Vector3,
    _D: Vector3,
    _upA: Vector3,
    _upD: Vector3,
    _holograph: bQuad.Quad3
}

export type Cubic3Static = {
    __index: Cubic3Static,
    -- Constructors
    new: (startPoint: CFrame, b: number, endPoint: CFrame, d: number) -> Cubic3,
    fromPositions: (a: Vector3, b: Vector3, c: Vector3, d: Vector3, upA: Vector3?, upD: Vector3?) -> Cubic3,
    -- Methods
    locationAt: (self: Cubic3, at: number) -> CFrame,
    positionAt: (self: Cubic3, at: number) -> Vector3, -- Same as locationAt but without the rotation component
    d1t: (self: Cubic3, at: number) -> Vector3,
    d2t: (self: Cubic3, at: number) -> Vector3,
    lengthAt: (self: Cubic3, at: number) -> number,
}

export type Cubic3 = typeof(setmetatable({} :: Cubic3Surface, {} :: Cubic3Static))

local Cubic3: Cubic3Static = {} :: Cubic3Static
Cubic3.__index = Cubic3

function Cubic3:d2t(t: number): Vector3
    argcheck.assertWarn(argcheck.between(t), `BezierCubic.d1t: at should be in [0, 1], got at = {t}`)
    --[[
        ... Therefore, the derivative of C(u) is a Bézier curve of degree n - 1
        defined by n control points n(P1 - P0), n(P2 - P1), n(P3 - P2), ..., n(Pn - Pn-1).
        
        This derivative curve is usually referred to as the hodograph of the original Bézier curve.

        Source: https://pages.mtu.edu/~shene/COURSES/cs3621/NOTES/spline/Bezier/bezier-der.html
    ]]--

    return self._holograph:d1t(t)
end

function Cubic3:d1t(t: number): Vector3
    argcheck.assertWarn(argcheck.between(t), `BezierCubic.d1t: at should be in [0, 1], got at = {t}`)
    --[[
        ... Therefore, the derivative of C(u) is a Bézier curve of degree n - 1
        defined by n control points n(P1 - P0), n(P2 - P1), n(P3 - P2), ..., n(Pn - Pn-1).
        
        This derivative curve is usually referred to as the hodograph of the original Bézier curve.

        Source: https://pages.mtu.edu/~shene/COURSES/cs3621/NOTES/spline/Bezier/bezier-der.html
    ]]--

    return self._holograph:positionAt(t)
end

-- A cubic Bézier's speed is the norm of its quadratic hodograph; its general
-- arc-length integral leads to elliptic integrals, so integrate numerically.
-- See https://www.heldermann-verlag.de/jgg/jgg01_05/jgg0301.pdf and
-- https://dlmf.nist.gov/19.30 for elliptic-integral arc lengths.
function Cubic3:lengthAt(at: number): number
    argcheck.assertWarn(argcheck.between(at), `BezierCubic.lengthAt: at should be in [0, 1], got at = {at}`)
    if at == 0 then
        return 0
    end

    local first = 3 * (self._B - self._A)
    local second = 3 * (self._C - self._B)
    local third = 3 * (self._D - self._C)
    local maxSpeed = math.max(first.Magnitude, second.Magnitude, third.Magnitude)
    if maxSpeed == 0 then
        return 0
    end

    local function speed(t: number): number
        local inverse = 1 - t
        local derivative = first * (inverse * inverse)
            + second * (2 * inverse * t)
            + third * (t * t)
        return derivative.Magnitude
    end

    local a = 0
    local b = at
    local midpoint = (a + b) / 2
    local fa = speed(a)
    local fm = speed(midpoint)
    local fb = speed(b)
    local whole = (b - a) * (fa + 4 * fm + fb) / 6
    local tolerance = (2^-20) * math.max(math.abs(whole), maxSpeed * math.abs(at))

    local function adaptiveSimpson(
        left: number,
        right: number,
        fLeft: number,
        fMiddle: number,
        fRight: number,
        estimate: number,
        allowedError: number,
        depth: number
    ): number
        -- Compare one Simpson panel with two half-panels, refine where needed,
        -- and use the standard difference/15 error correction:
        -- https://doi.org/10.1007/s00211-014-0684-3
        local middle = (left + right) / 2
        local leftMiddle = (left + middle) / 2
        local rightMiddle = (middle + right) / 2
        local fLeftMiddle = speed(leftMiddle)
        local fRightMiddle = speed(rightMiddle)
        local leftEstimate = (middle - left) * (fLeft + 4 * fLeftMiddle + fMiddle) / 6
        local rightEstimate = (right - middle) * (fMiddle + 4 * fRightMiddle + fRight) / 6
        local combined = leftEstimate + rightEstimate
        local difference = combined - estimate

        if depth == 0 or math.abs(difference) <= 15 * allowedError then
            return combined + difference / 15
        end

        return adaptiveSimpson(left, middle, fLeft, fLeftMiddle, fMiddle, leftEstimate, allowedError / 2, depth - 1)
            + adaptiveSimpson(middle, right, fMiddle, fRightMiddle, fRight, rightEstimate, allowedError / 2, depth - 1)
    end

    return adaptiveSimpson(a, b, fa, fm, fb, whole, tolerance, 20)
end

function Cubic3:positionAt(t: number): Vector3
    argcheck.assertWarn(argcheck.between(t), `BezierCubic.positionAt: at should be in [0, 1], got at = {t}`)
    --[[
        Bernstein polynomials for cubic beziers:
        (1-t)^3
        3 (1-t)^2 t
        3 (1-t)t^2
        t^3
    ]]--

    local t1 = 1 - t
    return self._A * (t1 * t1 * t1)
        + self._B * (3* t1 * t1 * t)
        + self._C * (3* t1 * t * t)
        + self._D * (t * t * t)
end

function Cubic3:locationAt(t: number): CFrame
    argcheck.assertWarn(argcheck.between(t), `BezierCubic.locationAt: at should be in [0, 1], got at = {t}`)
    local t1 = 1 - t
    local d1t = self:d1t(t)
    assert(d1t ~= Vector3.zero, `BezierCubic.locationAt: derivative for at = {t} is zero! Cannot compute direction.`)
    argcheck.assertWarn(d1t.Magnitude > 2^-15, `BezierCubic.locationAt: first derivative length for at = {t} is very small ({d1t.Magnitude}). There might be innaccuracies with direction.`)

    return CFrame.lookAlong(self:positionAt(t), d1t.Unit, (t1 * self._upA.Unit + t * self._upD.Unit).Unit):Orthonormalize()
end

function Cubic3.new(startPoint: CFrame, b: number, endPoint: CFrame, d: number): Cubic3
    return Cubic3.fromPositions(
        startPoint.Position,
        startPoint.Position + startPoint.LookVector * b,
        endPoint.Position - endPoint.LookVector * d,
        endPoint.Position,
        startPoint.UpVector,
        endPoint.UpVector
    )
end

function Cubic3.fromPositions(a: Vector3, b: Vector3, c: Vector3, d: Vector3, upA: Vector3?, upD: Vector3?): Cubic3
    -- Make holograph
    local AB = 3 * (b - a)
    local BC = 3 * (c - b)
    local CD = 3 * (d - c)

    local self: Cubic3Surface = {
        _A = a,
        _B = b,
        _C = c,
        _D = d,
        _upA = upA or Vector3.yAxis,
        _upD = upD or Vector3.yAxis,
        _holograph = bQuad.fromPositions(AB, BC, CD)
    }

    return table.freeze(setmetatable(self, Cubic3))
end

table.freeze(Cubic3)
return Cubic3
