--!strict

local root = script.Parent.Parent
local argcheck = require(root.utils.argcheck)

type Lerp3Surface = {
    startPoint: CFrame,
    _endPoint: CFrame
}

export type Lerp3Static = {
    __index: Lerp3Static,
    -- Constructors
    new: (startp: CFrame, endp: CFrame) -> Lerp3,
    line: (start: CFrame, distance: number) -> Lerp3,
    direction: (startp: CFrame, direction: Vector3, distance: number?) -> Lerp3,
    -- Methods
    locationAt: (self: Lerp3, at: number) -> CFrame,
}

export type Lerp3 = typeof(setmetatable({} :: Lerp3Surface, {} :: Lerp3Static))

local Lerp3: Lerp3Static = {} :: Lerp3Static
Lerp3.__index = Lerp3

function Lerp3:locationAt(at: number)
    argcheck.assertWarn(argcheck.between(at), `Lerp.locationAt: at should be in [0, 1], got at = {at}`)
    return self.startPoint:Lerp(self._endPoint, at)
end

function Lerp3.new(startp: CFrame, endp: CFrame): Lerp3
    local self: Lerp3Surface = {
        startPoint = startp,
        _endPoint = endp
    }

    return table.freeze(setmetatable(self, Lerp3))
end

function Lerp3.line(startp: CFrame, distance: number): Lerp3
    argcheck.assertWarn(distance ~= 0, `Lerp.line: Expected distance different than 0`)
    local self: Lerp3Surface = {
        startPoint = startp,
        _endPoint = startp + distance * startp.LookVector
    }

    return table.freeze(setmetatable(self, Lerp3))
end

function Lerp3.direction(startp: CFrame, direction: Vector3, distance: number?): Lerp3
    argcheck.assertWarn(distance ~= 0, `Lerp.line: Expected distance different than 0`)
    local self: Lerp3Surface = {
        startPoint = startp,
        _endPoint = startp + (if distance ~= nil then distance else 1) * direction
    }

    return table.freeze(setmetatable(self, Lerp3))
end

return Lerp3
