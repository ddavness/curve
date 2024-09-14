--!strict

local function assertWarn(condition: boolean, msg: string)
    if not condition then
        warn(msg)
    end
end

local function numBetween(test: number, min: number?, max: number?): boolean
    return test >= (min or 0) and test <= (max or 1)
end

local function numBetweenOpen(test: number, min: number?, max: number?): boolean
    return test > (min or 0) and test < (max or 1)
end

return {
    assertWarn = assertWarn,
    between = numBetween,
    betweenEx = numBetweenOpen
}
