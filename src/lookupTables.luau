--!strict

local Curve = require(script.Parent.types)

local function toPoints(c: Curve.Curve3, resolution: number): {CFrame}
    assert(math.ceil(resolution) == resolution and resolution >= 2, "Curve.toPoints: Resolution must be integer >= 2")
    local pts: {CFrame} = {}
    for i = 0, resolution - 1 do
        table.insert(pts, c:locationAt(i/(resolution - 1)))
    end

    return pts
end

local function mkluts(c: Curve.Curve3, resolution: number): Curve.Curve3Approximated
    assert(math.ceil(resolution) == resolution and resolution >= 2, "Curve.computeApproximation: Resolution must be integer >= 2")
    local _luts: Curve.Curve3ApproximatedSurface = {
        uniform = false,
        resolution = resolution,
        _lutPosition = toPoints(c, resolution),
        _lutDistance = {0},
        _lut1dt = {Vector3.new()},
        _lut2dt = {Vector3.new()}
    }

    -- Stub
end

local function mklutsUniform(c: Curve.Curve3, resolution: number): Curve.Curve3Approximated
    assert(math.ceil(resolution) == resolution and resolution >= 2, "Curve.computeApproximationUniform: Resolution must be integer >= 2")
    local _luts: Curve.Curve3ApproximatedSurface = {
        uniform = true,
        resolution = resolution,
        _lutPosition = toPoints(c, resolution),
        _lutDistance = {0},
        _lut1dt = {Vector3.new()},
        _lut2dt = {Vector3.new()}
    }

    -- Stub
end

return {
    toPoints = toPoints,
    computeApproximation = mkluts,
    computeUniformApproximation = mklutsUniform
}
