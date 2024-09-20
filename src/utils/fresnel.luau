--!strict

-- Utilities to help approximate the Fresnel Integrals
-- The approximations are computed iteratively by computing each term individually and then summing all the terms
-- The n+1 term is computed from the n term and a ratio determined by hand(TM) (just divide the taylor terms for n+1/n)
-- It's both cheaper and less likely to face floating point issues down the line if we use the ratio instead of computing and dividing factorials

-- More info: https://en.wikipedia.org/wiki/Fresnel_integral

local function taylorApproxC(x: number, depth: number)
    local approx = (x * x * x * x * x) / 5 -- First term of the series
    local dcurrent = approx
    if depth ~= 0 then
        for i = 0, depth - 1, 1 do
            dcurrent *= -(x * x * x * x) * ((4 * i + 1)/((2 * i + 2) * (2 * i + 1) * (4 * i + 5)))
            approx += dcurrent
        end
    end

    return approx
end

local function taylorApproxS(x: number, depth: number)
    local approx = (x * x * x * x * x * x * x) / 7 -- First term of the series
    local dcurrent = approx
    if depth ~= 0 then
        for i = 0, depth - 1, 1 do
            dcurrent *= -(x * x * x * x) * ((4 * i + 3)/((2 * i + 3) * (2 * i + 2) * (4 * i + 7)))
            approx += dcurrent
        end
    end

    return approx
end

return {
    C = taylorApproxC,
    S = taylorApproxS
}
