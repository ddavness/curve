--!nonstrict

local function mergeTable<A, B>(a: A & {}, b: B & {}): A & B & {}
    local c = table.clone(a)
    for i, v in pairs(b) do
        if not c[i] then
            c[i] = v
        end
    end

    return setmetatable(getmetatable(c), c)
end

return mergeTable
