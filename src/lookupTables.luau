--!strict

local Curve = require(script.Parent.types)

local function mkluts<T>(c: Curve.Curve3, resolution: number): Curve.Curve3Approximated
    assert(math.ceil(resolution) == resolution and resolution >= 2, "Curve: Attempted to call computeApproximation with a resolution < 2")
    local _luts: Curve.Curve3ApproximatedSurface = {
        uniform = false,
        resolution = resolution,
        _lutPosition = {c:locationAt(0), c:locationAt(1)},
        _lutDistance = {0},
        _lut1dt = {Vector3.new()},
        _lut2dt = {Vector3.new()}
    }

    -- Stub
end

local function mklutsUniform(c: Curve.Curve3, resolution: number): Curve.Curve3Approximated
    assert(math.ceil(resolution) == resolution and resolution >= 2, "Curve: Attempted to call computeUniformApproximation with a resolution < 2")
    local _luts: Curve.Curve3ApproximatedSurface = {
        uniform = true,
        resolution = resolution,
        _lutPosition = {c:locationAt(0), c:locationAt(1)},
        _lutDistance = {0},
        _lut1dt = {Vector3.new()},
        _lut2dt = {Vector3.new()}
    }

    -- Stub
end

return {
    computeApproximation = mkluts,
    computeUniformApproximation = mklutsUniform
}
