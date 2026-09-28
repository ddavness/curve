--!strict

--[[
    Compute the hyperbolic arcsin of x in ]-inf, inf[
]]
local function asinh(x: number): number
    local magnitude = math.abs(x)
    local result: number
    if magnitude > 1 then
        result = math.log(magnitude) + math.log(1 + math.sqrt(1 + 1 / (magnitude * magnitude)))
    else
        result = math.log(magnitude + math.sqrt(magnitude * magnitude + 1))
    end
    return if x < 0 then -result else result
end

return table.freeze {
    asinh = asinh
}
