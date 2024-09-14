--!strict

local Curve = require(script.Parent.types)

local function mkluts(c: Curve.Curve3, resolution: number): Curve.Curve3Approximated
    assert(math.ceil(resolution) == resolution and resolution >= 2, "Curve: Attempted to call computeApproximation with a resolution < 2")
    return {
        uniform = false,
        resolution = resolution,
        startPoint = c.startPoint,
        endPoint = c.endPoint,
        locationAt = c.locationAt,
        approximateLength = function(from: number, to: number): number
            return (c.locationAt(to).Position - c.locationAt(from).Position).Magnitude
        end,
        nearestFirstDerivativeAt = function(_t: number)
            return Vector3.new(0, 0, 0)
        end,
        nearestSecondDerivativeAt = function(_t: number)
            return Vector3.new(0, 0, 0)
        end,
    }
end

local function mklutsUniform(c: Curve.Curve3, resolution: number): Curve.Curve3Approximated
    assert(math.ceil(resolution) == resolution and resolution >= 2, "Curve: Attempted to call computeUniformApproximation with a resolution < 2")
    return {
        uniform = true,
        resolution = resolution,
        startPoint = c.startPoint,
        endPoint = c.endPoint,
        locationAt = c.locationAt,
        approximateLength = function(from: number, to: number): number
            return (c.locationAt(to).Position - c.locationAt(from).Position).Magnitude
        end,
        nearestFirstDerivativeAt = function(_t: number)
            return Vector3.new(0, 0, 0)
        end,
        nearestSecondDerivativeAt = function(_t: number)
            return Vector3.new(0, 0, 0)
        end,
    }
end

return {
    computeApproximation = mkluts,
    computeUniformApproximation = mklutsUniform
}
