--!strict

local root = script.Parent
local Curve = require(root.types)
local cf64 = require(root.utils.cf64)
local vector64 = require(root.utils.vector64)

export type Curve3ApproximatedStatic = {
    __index: Curve3ApproximatedStatic,
    approximateLength: (self: Curve3Approximated, from: number, to: number) -> number,
}

export type Curve3ApproximatedSurface = {
    sampling: "uniformT" | "uniformDistance",
    resolution: number,
    _lutParameter: {number},
    _lutPosition: {vector64.Vector3f64},
    _lutDistance: {number},
}

export type Curve3Approximated = typeof(setmetatable({} :: Curve3ApproximatedSurface, {} :: Curve3ApproximatedStatic))

-- `uniformT` stores knots at equal parameter intervals. `uniformDistance`
-- approximately spaces knots evenly by accumulated curve distance.
export type SamplingMode = "uniformT" | "uniformDistance"

export type ApproximationOptions = {
	-- Relative refinement estimated target measured against estimated total length. The
	-- midpoint checks below are estimates, not formal error bounds.
	tolerance: number?,
	-- Uniform parameter spacing or approximately equal arc-length spacing.
	-- Defaults to `uniformT`.
	sampling: SamplingMode?,
	-- Maximum number of stored knots. A warning is emitted if refinement reaches
	-- this limit before the tolerance checks pass.
	maxSamples: number?,
}

local DEFAULT_TOLERANCE = 2^-20
local DEFAULT_MAX_SAMPLES = 2^16
local DEFAULT_DIFFERENCE_STEP = 2^-5

local Approximation = {} :: Curve3ApproximatedStatic
Approximation.__index = Approximation

local function validateOptions(options: ApproximationOptions?): (number, SamplingMode, number)
	local tolerance = if options and options.tolerance ~= nil then options.tolerance else DEFAULT_TOLERANCE
	local sampling = if options and options.sampling ~= nil then options.sampling else "uniformT"
	local maxSamples = if options and options.maxSamples ~= nil then options.maxSamples else DEFAULT_MAX_SAMPLES

	assert(tolerance == tolerance and tolerance > 0 and tolerance < math.huge, "Curve.Generic: tolerance must be a finite positive number")
	assert(sampling == "uniformT" or sampling == "uniformDistance", "Curve.Generic: sampling must be 'uniformT' or 'uniformDistance'")
	assert(math.floor(maxSamples) == maxSamples and maxSamples >= 3, "Curve.Generic: maxSamples must be an integer >= 3")

	return tolerance, sampling, maxSamples
end

local function toPoints(c: Curve.Curve3, resolution: number): {CFrame}
	assert(math.ceil(resolution) == resolution and resolution >= 2, "Curve.toPoints: Resolution must be integer >= 2")
	local pts: {CFrame} = {}
	for i = 0, resolution - 1 do
		table.insert(pts, c:locationAt(i / (resolution - 1)):toCFrame())
	end

	return pts
end

-- Numerical curve calculations use only the translational component of each CFrame.
local function positionAt(locationAt: (number) -> cf64.CFrame64, t: number): vector64.Vector3f64
	return locationAt(t).Position :: vector64.Vector3f64
end

-- Compare the curve midpoint with the chord midpoint to estimate positional
-- deviation. The difference between the two half-chords and the full chord
-- estimates the arc length missed by this polygonal approximation.
-- See https://en.wikipedia.org/wiki/Arc_length#As_a_limit
local function chordErrors(p0: vector64.Vector3f64, pm: vector64.Vector3f64, p1: vector64.Vector3f64): (number, number)
	local positionError = (pm - (p0 + p1) * 0.5).Magnitude
	local chordLength = (p1 - p0).Magnitude
	local splitLength = (pm - p0).Magnitude + (p1 - pm).Magnitude
	return positionError, math.max(0, splitLength - chordLength)
end

-- Double a uniform parameter grid until every interval's midpoint checks pass,
-- or the table reaches maxSamples.
local function makeUniformTParameters(
	locationAt: (number) -> cf64.CFrame64,
	tolerance: number,
	maxSamples: number
): ({number}, {vector64.Vector3f64}, boolean)
	local positionCache: {[number]: vector64.Vector3f64?} = {}
	local function sample(t: number): vector64.Vector3f64
		local existing = positionCache[t]
		if existing ~= nil then
			return existing
		end

		local result = positionAt(locationAt, t)
		positionCache[t] = result
		return result
	end

	local p0 = sample(0)
	local pm = sample(0.5)
	local p1 = sample(1)
	local initialLength = (pm - p0).Magnitude + (p1 - pm).Magnitude
	local scale = if initialLength > 0 then initialLength else 1
	local absoluteTolerance = tolerance * scale
	local intervalCount = 1
	local converged = false

	while true do
		local intervalPasses = true
		for i = 0, intervalCount - 1 do
			local t0 = i / intervalCount
			local t1 = (i + 1) / intervalCount
			local tm = (t0 + t1) * 0.5
			local errorPosition, errorLength = chordErrors(sample(t0), sample(tm), sample(t1))
			if errorPosition > absoluteTolerance or errorLength > absoluteTolerance / intervalCount then
				intervalPasses = false
				break
			end
		end

		if intervalPasses then
			converged = true
			break
		end

		local maximumIntervals = maxSamples - 1
		if intervalCount >= maximumIntervals then
			break
		end
		intervalCount = math.min(intervalCount * 2, maximumIntervals)
	end

	local parameters: {number} = {}
	local positions: {vector64.Vector3f64} = {}
	for i = 0, intervalCount do
		local t = i / intervalCount
		table.insert(parameters, t)
		table.insert(positions, sample(t))
	end

	return parameters, positions, converged
end

-- Split only intervals that fail the midpoint checks. Allocate the arc-length
-- error budget in proportion to each interval's parameter width, so local
-- budgets sum to the requested total budget.
local function makeAdaptiveParameters(
	locationAt: (number) -> cf64.CFrame64,
	tolerance: number,
	maxSamples: number
): ({number}, {vector64.Vector3f64}, boolean)
	local positionCache: {[number]: vector64.Vector3f64?} = {}
	local function sample(t: number): vector64.Vector3f64
		local existing = positionCache[t]
		if existing ~= nil then
			return existing
		end

		local result = positionAt(locationAt, t)
		positionCache[t] = result
		return result
	end

	local p0 = sample(0)
	local pm = sample(0.5)
	local p1 = sample(1)
	local initialLength = (pm - p0).Magnitude + (p1 - pm).Magnitude
	local absoluteTolerance = tolerance * (if initialLength > 0 then initialLength else 1)
	local parameters: {number} = {0, 1}
	local converged = false
	local maximumBaseSamples = maxSamples

	while true do
		local refined: {number} = {parameters[1]}
		local splitCount = 0
		local limitReached = false

		for i = 1, #parameters - 1 do
			local t0 = parameters[i]
			local t1 = parameters[i + 1]
			local tm = (t0 + t1) * 0.5
			local errorPosition, errorLength = chordErrors(sample(t0), sample(tm), sample(t1))
			local intervalTolerance = absoluteTolerance * (t1 - t0)
			local needsSplit = errorPosition > absoluteTolerance or errorLength > intervalTolerance

			if needsSplit and #parameters + splitCount < maximumBaseSamples then
				table.insert(refined, tm)
				splitCount += 1
			elseif needsSplit then
				limitReached = true
			end

			table.insert(refined, t1)
		end

		if splitCount == 0 then
			converged = not limitReached
			break
		end

		parameters = refined
	end

	local positions: {vector64.Vector3f64} = {}
	for _, t in parameters do
		table.insert(positions, sample(t))
	end
	return parameters, positions, converged
end

-- Invert cumulative chord distance on the refined parameter samples to place
-- knots at approximately equal distances, then recheck the resulting chords.
local function resampleUniformDistance(
	locationAt: (number) -> cf64.CFrame64,
	baseParameters: {number},
	basePositions: {vector64.Vector3f64},
	tolerance: number,
	maxSamples: number
): ({number}, {vector64.Vector3f64}, boolean)
	local baseDistances: {number} = {0}
	for i = 2, #basePositions do
		baseDistances[i] = baseDistances[i - 1] + (basePositions[i] - basePositions[i - 1]).Magnitude
	end

	local totalLength = baseDistances[#baseDistances]
	local absoluteTolerance = tolerance * (if totalLength > 0 then totalLength else 1)
	if totalLength == 0 then
		return {0, 1}, {basePositions[1], basePositions[#basePositions]}, true
	end

	local function parametersAtDistance(sampleCount: number): {number}
		local result: {number} = {}
		for i = 0, sampleCount - 1 do
			local targetDistance = totalLength * i / (sampleCount - 1)
			local segment = 1
			while segment < #baseDistances - 1 and baseDistances[segment + 1] < targetDistance do
				segment += 1
			end

			local segmentLength = baseDistances[segment + 1] - baseDistances[segment]
			local alpha = if segmentLength > 0 then (targetDistance - baseDistances[segment]) / segmentLength else 0
			local t = baseParameters[segment] + (baseParameters[segment + 1] - baseParameters[segment]) * alpha
			if #result == 0 or t - result[#result] > 1e-12 then
				table.insert(result, t)
			end
		end
		return result
	end

	local sampleCount = math.min(#baseParameters, maxSamples)
	while true do
		local parameters = parametersAtDistance(sampleCount)
		local positions: {vector64.Vector3f64} = {}
		for _, t in parameters do
			table.insert(positions, positionAt(locationAt, t))
		end

		local passes = true
		for i = 1, #parameters - 1 do
			local t0 = parameters[i]
			local t1 = parameters[i + 1]
			local errorPosition, errorLength = chordErrors(
				positions[i],
				positionAt(locationAt, (t0 + t1) * 0.5),
				positions[i + 1]
			)
			if errorPosition > absoluteTolerance or errorLength > absoluteTolerance / (#parameters - 1) then
				passes = false
				break
			end
		end

		if passes then
			return parameters, positions, true
		end
		if sampleCount >= maxSamples then
			return parameters, positions, false
		end
		sampleCount = math.min(math.max(sampleCount + 1, sampleCount * 2), maxSamples)
	end
end

-- Sum sampled chord lengths to form cumulative distance, then linearly
-- interpolate that distance in parameter space. This is polygonal arc-length
-- approximation; see https://en.wikipedia.org/wiki/Arc_length#As_a_limit.
function Approximation:approximateLength(from: number, to: number): number
	local function distanceAt(t: number): number
		t = math.clamp(t, 0, 1)
		local parameters = self._lutParameter
		local distances = self._lutDistance
		local low = 1
		local high = #parameters

		while low < high do
			local middle = math.floor((low + high) * 0.5)
			if parameters[middle] < t then
				low = middle + 1
			else
				high = middle
			end
		end

		local right = low
		if parameters[right] == t or right == 1 then
			return distances[right]
		end

		local left = right - 1
		local span = parameters[right] - parameters[left]
		local alpha = if span > 0 then (t - parameters[left]) / span else 0
		return distances[left] + (distances[right] - distances[left]) * alpha
	end

	return math.abs(distanceAt(to) - distanceAt(from))
end

local function computeApproximation(locationAt: (number) -> cf64.CFrame64, options: ApproximationOptions?): Curve3Approximated
	local tolerance, sampling, maxSamples = validateOptions(options)
	local parameters: {number}
	local positions: {vector64.Vector3f64}
	local converged: boolean

	if sampling == "uniformT" then
		parameters, positions, converged = makeUniformTParameters(locationAt, tolerance, maxSamples)
	else
		parameters, positions, converged = makeAdaptiveParameters(locationAt, tolerance, maxSamples)
		local distanceParameters, distancePositions, distanceConverged = resampleUniformDistance(
			locationAt,
			parameters,
			positions,
			tolerance,
			maxSamples
		)
		parameters, positions = distanceParameters, distancePositions
		converged = converged and distanceConverged
	end

	local distances: {number} = {0}
	for i = 2, #positions do
		distances[i] = distances[i - 1] + (positions[i] - positions[i - 1]).Magnitude
	end

	if not converged then
		warn(`Curve.Generic: maximum sample count ({maxSamples}) reached before tolerance ({tolerance}) was met`)
	end

	local surface: Curve3ApproximatedSurface = {
		sampling = sampling :: SamplingMode,
		resolution = #parameters,
		_lutParameter = table.freeze(parameters),
		_lutPosition = table.freeze(positions),
		_lutDistance = table.freeze(distances),
	}
	return table.freeze(setmetatable(surface, Approximation))
end

-- Limit h by both a fixed upper step and half the nearby table interval so a
-- finite-difference stencil stays local to the sampled parameterization.
local function differenceStep(approximation: Curve3Approximated, t: number): number
	local parameters = approximation._lutParameter
	local low = 1
	local high = #parameters
	while low < high do
		local middle = math.floor((low + high) / 2)
		if parameters[middle] < t then
			low = middle + 1
		else
			high = middle
		end
	end

	local right = low
	local interval = if right == 1 then parameters[2] - parameters[1]
		else if right == #parameters then parameters[#parameters] - parameters[#parameters - 1]
		else math.min(parameters[right] - parameters[right - 1], parameters[right + 1] - parameters[right])
	return math.min(DEFAULT_DIFFERENCE_STEP, interval * 0.5)
end

-- Finite differences approximate derivatives from function position samples.
-- The centered stencil is (p(t+h)-p(t-h))/(2h); within h of an endpoint, use
-- the three-point, forward/backward stencil instead, which is O(h^2). See
-- https://en.wikipedia.org/wiki/Finite_difference.
local function firstDerivativeAt(
	locationAt: (number) -> cf64.CFrame64,
	approximation: Curve3Approximated,
	t: number
):vector64.Vector3f64
	t = math.clamp(t, 0, 1)
	local h = differenceStep(approximation, t)
	if t >= h and t <= 1 - h then
		return (positionAt(locationAt, t + h) - positionAt(locationAt, t - h)) / (2 * h)
	elseif t < h then
		h = math.min(h, (1 - t) / 2)
		local p0 = positionAt(locationAt, t)
		local p1 = positionAt(locationAt, t + h)
		local p2 = positionAt(locationAt, t + 2 * h)
		return (-3 * p0 + 4 * p1 - p2) / (2 * h)
	else
		h = math.min(h, t / 2)
		local p0 = positionAt(locationAt, t)
		local p1 = positionAt(locationAt, t - h)
		local p2 = positionAt(locationAt, t - 2 * h)
		return (3 * p0 - 4 * p1 + p2) / (2 * h)
	end
end

-- The interior stencil is (p(t-h)-2p(t)+p(t+h))/h^2. Near an endpoint, use
-- the four-point one-sided stencil (2p0-5p1+4p2-p3)/h^2, O(h^2) accurate.
-- These are finite-difference approximations; see
-- https://en.wikipedia.org/wiki/Finite_difference#Higher-order_differences.
local function secondDerivativeAt(
	locationAt: (number) -> cf64.CFrame64,
	approximation: Curve3Approximated,
	t: number
): vector64.Vector3f64
	t = math.clamp(t, 0, 1)
	local h = differenceStep(approximation, t)
	if t >= h and t <= 1 - h then
		local pl = positionAt(locationAt, t - h)
		local p0 = positionAt(locationAt, t)
		local pr = positionAt(locationAt, t + h)
		return (pl + pr - 2 * p0) / (h * h)
	elseif t < h then
		h = math.min(h, (1 - t) / 3)
		local p0 = positionAt(locationAt, t)
		local p1 = positionAt(locationAt, t + h)
		local p2 = positionAt(locationAt, t + 2 * h)
		local p3 = positionAt(locationAt, t + 3 * h)
		return (2 * p0 - 5 * p1 + 4 * p2 - p3) / (h * h)
	else
		h = math.min(h, t / 3)
		local p0 = positionAt(locationAt, t)
		local p1 = positionAt(locationAt, t - h)
		local p2 = positionAt(locationAt, t - 2 * h)
		local p3 = positionAt(locationAt, t - 3 * h)
		return (2 * p0 - 5 * p1 + 4 * p2 - p3) / (h * h)
	end
end

return {
	toPoints = toPoints,
	computeApproximation = computeApproximation,
	firstDerivativeAt = firstDerivativeAt,
	secondDerivativeAt = secondDerivativeAt,
}
