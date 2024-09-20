--!strict

-- Utilities to help approximate the Fresnel Integrals
-- The approximations are computed iteratively by computing each term individually and then summing all the terms
-- The n+1 term is computed from the n term and a ratio determined by hand(TM) (just divide the taylor terms for n+1/n)
-- It's both cheaper and less likely to face floating point issues down the line if we use the ratio instead of computing and dividing factorials

-- More info: https://en.wikipedia.org/wiki/Fresnel_integral

local function taylorApproxC(x: number, depth: number)
    local dn = {}
    dn[0] = x^5 / 5 -- First term of the series
    if depth ~= 0 then
        for i = 0, depth - 1, 1 do
            dn[i + 1] = -(x^4) * ((4 * i + 1)/((2 * i + 2) * (2 * i + 1) * (4 * i + 5))) * dn[i]
        end
    end

    local approx = 0
    for _, d in pairs(dn) do
        approx += d
    end
    return approx
end

local function taylorApproxS(x: number, depth: number)
    local dn = {}
    dn[0] = x^7 / 7 -- First term of the series
    if depth ~= 0 then
        for i = 0, depth - 1, 1 do
            dn[i + 1] = -(x^4) * ((4 * i + 3)/((2 * i + 3) * (2 * i + 2) * (4 * i + 7))) * dn[i]
        end
    end

    local approx = 0
    for _, d in pairs(dn) do
        approx += d
    end
    return approx
end

return {
    C = taylorApproxC,
    S = taylorApproxS
}
