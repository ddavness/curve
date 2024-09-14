--!strict

local Curve = require(script.Parent.types)
local merge = require(script.Parent.utils.mergetable)

local function mkluts<T>(c: Curve.Curve3, resolution: number): Curve.Curve3Approximated
    assert(math.ceil(resolution) == resolution and resolution >= 2, "Curve: Attempted to call computeApproximation with a resolution < 2")
    local _luts: Curve.Curve3ApproximatedMeta = merge(getmetatable(c), {
        _lutPosition = {CFrame.new()},
        _lutDistance = {0},
        _lut1dt = {Vector3.new()},
        _lut2dt = {Vector3.new()}
    })

    -- Stub
end

local function mklutsUniform(c: Curve.Curve3, resolution: number): Curve.Curve3Approximated
    assert(math.ceil(resolution) == resolution and resolution >= 2, "Curve: Attempted to call computeUniformApproximation with a resolution < 2")
    local _luts: Curve.Curve3ApproximatedMeta = merge(getmetatable(c), {
        _lutPosition = {CFrame.new()},
        _lutDistance = {0},
        _lut1dt = {Vector3.new()},
        _lut2dt = {Vector3.new()}
    })

    -- Stub
end

return {
    computeApproximation = mkluts,
    computeUniformApproximation = mklutsUniform
}
