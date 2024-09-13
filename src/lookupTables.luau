--!strict

local Curve = require(script.Parent.types)

local function mkluts(c: Curve.Curve3, resolution: number): Curve.Curve3Approximated
    -- Stub
    return {
        uniform = false,
        resolution = resolution,
        startPoint = c.startPoint,
        endPoint = c.endPoint,
        getLocationAt = c.getLocationAt,
        approximateLength = function(from: number, to: number): number
            return (c.getLocationAt(to).Position - c.getLocationAt(from).Position).Magnitude
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
    return {
        uniform = true,
        resolution = resolution,
        startPoint = c.startPoint,
        endPoint = c.endPoint,
        getLocationAt = c.getLocationAt,
        approximateLength = function(from: number, to: number): number
            return (c.getLocationAt(to).Position - c.getLocationAt(from).Position).Magnitude
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
