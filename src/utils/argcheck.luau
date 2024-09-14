--!strict

local function numBetween(test: number, min: number?, max: number?): boolean
    local mn = min or 0
    local mx = max or 1
    if test < mn or test > mx then
        warn(`curve.locationAt: t should be in [{mn} (start), {mx} (end)], got {test}`)
        return false
    end

    return true
end

return {
    numTest = numBetween
}
