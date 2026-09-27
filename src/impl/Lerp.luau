--!strict

local root = script.Parent.Parent
local argcheck = require(root.utils.argcheck)

type Lerp3Surface = {
    _start: CFrame,
    _end: CFrame
}

export type Lerp3Static = {
    __index: Lerp3Static,
    -- Constructors
    new: (startp: CFrame, endp: CFrame) -> Lerp3,
    line: (start: CFrame, distance: number) -> Lerp3,
    direction: (startp: CFrame, direction: Vector3, distance: number?) -> Lerp3,
    -- Methods
    locationAt: (self: Lerp3, at: number) -> CFrame,
    d1t: (self: Lerp3, at: number) -> Vector3,
    d2t: (self: Lerp3, at: number) -> Vector3,
    lengthAt: (self: Lerp3, at: number) -> number,
}

export type Lerp3 = typeof(setmetatable({} :: Lerp3Surface, {} :: Lerp3Static))

local Lerp3: Lerp3Static = {} :: Lerp3Static
Lerp3.__index = Lerp3

function Lerp3:locationAt(at: number): CFrame
    argcheck.assertWarn(argcheck.between(at), `Lerp.locationAt: at should be in [0, 1], got at = {at}`)
    return self._start:Lerp(self._end, at)
end

function Lerp3:d1t(_at: number): Vector3
    return self._end.Position - self._start.Position
end

function Lerp3:d2t(_at: number): Vector3
    return Vector3.zero
end

function Lerp3:lengthAt(at: number): number
    return at * (self:d1t(at)).Magnitude
end

function Lerp3.new(startp: CFrame, endp: CFrame): Lerp3
    local self: Lerp3Surface = {
        _start = startp,
        _end = endp
    }

    return table.freeze(setmetatable(self, Lerp3))
end

function Lerp3.line(startp: CFrame, distance: number): Lerp3
    argcheck.assertWarn(distance ~= 0, `Lerp.line: Expected distance different than 0`)
    local self: Lerp3Surface = {
        _start = startp,
        _end = startp + distance * startp.LookVector
    }

    return table.freeze(setmetatable(self, Lerp3))
end

function Lerp3.direction(startp: CFrame, direction: Vector3, distance: number?): Lerp3
    argcheck.assertWarn(distance ~= 0, `Lerp.line: Expected distance different than 0`)
    local self: Lerp3Surface = {
        _start = startp,
        _end = startp + (if distance ~= nil then distance else 1) * direction
    }

    return table.freeze(setmetatable(self, Lerp3))
end

return Lerp3
