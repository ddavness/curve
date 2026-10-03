--!strict

local root = script.Parent.Parent
local cf64 = require(root.utils.cf64)
local argcheck = require(root.utils.argcheck)
local vector64 = require(root.utils.vector64)
local lookupTables = require(root.lookupTables)

type GenericCurve3Surface = {
    _locationAt: (t: number) -> cf64.CFrame64,
    _approximation: lookupTables.Curve3Approximated,
}

export type GenericCurve3Options = lookupTables.ApproximationOptions
export type GenericCurve3Sampling = lookupTables.SamplingMode

export type GenericCurve3Static = {
    __index: GenericCurve3Static,
    new: (f: (number) -> cf64.CFrame64, options: GenericCurve3Options?) -> GenericCurve3,
    locationAt: (self: GenericCurve3, at: number) -> cf64.CFrame64,
    d1t: (self: GenericCurve3, at: number) -> vector64.Vector3f64,
    d2t: (self: GenericCurve3, at: number) -> vector64.Vector3f64,
    lengthAt: (self: GenericCurve3, at: number) -> number,
}

export type GenericCurve3 = typeof(setmetatable({} :: GenericCurve3Surface, {} :: GenericCurve3Static))

local GenericCurve3: GenericCurve3Static = {} :: GenericCurve3Static
GenericCurve3.__index = GenericCurve3

-- Wrap a CFrame-valued function on [0, 1] and build its numerical lookup table.
-- The table supports finite-difference derivatives and approximate arc length;
-- its tolerance and sample cap are configured by `options`.
function GenericCurve3.new(f: (number) -> cf64.CFrame64, options: GenericCurve3Options?): GenericCurve3
    local self: GenericCurve3Surface = {
        _locationAt = f,
        _approximation = lookupTables.computeApproximation(f, options),
    }

    return table.freeze(setmetatable(self, GenericCurve3))
end

-- Evaluate the original CFrame-valued function at parameter `at`.
function GenericCurve3:locationAt(at: number)
    argcheck.assertWarn(argcheck.between(at), `Curve.locationAt: at should be in [0, 1], got at = {at}`)
    return self._locationAt(at)
end

-- Approximate the first derivative of position with respect to parameter t.
-- This uses finite differences of CFrame.Position and ignores frame rotation.
-- Stencil background: https://en.wikipedia.org/wiki/Finite_difference#Higher-order_differences
function GenericCurve3:d1t(at: number): vector64.Vector3f64
    argcheck.assertWarn(argcheck.between(at), `Curve.d1t: at should be in [0, 1], got at = {at}`)
    return lookupTables.firstDerivativeAt(self._locationAt, self._approximation, at)
end

-- Approximate the second derivative of position with respect to parameter t.
-- This uses finite differences of CFrame.Position and ignores frame rotation.
-- Stencil background: https://en.wikipedia.org/wiki/Finite_difference#Higher-order_differences
function GenericCurve3:d2t(at: number): vector64.Vector3f64
    argcheck.assertWarn(argcheck.between(at), `Curve.d2t: at should be in [0, 1], got at = {at}`)
    return lookupTables.secondDerivativeAt(self._locationAt, self._approximation, at)
end

-- Approximate the arc length from t = 0 through `at` by interpolating the
-- cumulative chord-distance lookup table.
-- Background: https://en.wikipedia.org/wiki/Arc_length#As_a_limit
function GenericCurve3:lengthAt(at: number): number
    argcheck.assertWarn(argcheck.between(at), `Curve.lengthAt: at should be in [0, 1], got at = {at}`)
    return self._approximation:approximateLength(0, at)
end

table.freeze(GenericCurve3)
return GenericCurve3
