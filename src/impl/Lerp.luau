--!strict

local root = script.Parent.Parent
local cf64 = require(root.utils.cf64)
local argcheck = require(root.utils.argcheck)
local vector64 = require(root.utils.vector64)

type Lerp3Surface = {
    _start: cf64.CFrame64,
    _end: cf64.CFrame64
}

export type Lerp3Static = {
    __index: Lerp3Static,
    -- Constructors
    new: (startp: cf64.CFrameInput, endp: cf64.CFrameInput) -> Lerp3,
    line: (start: cf64.CFrameInput, distance: number) -> Lerp3,
    direction: (startp: cf64.CFrameInput, direction: vector64.Vector3Input, distance: number?) -> Lerp3,
    -- Methods
    locationAt: (self: Lerp3, at: number) -> cf64.CFrame64,
    d1t: (self: Lerp3, at: number) -> vector64.Vector3f64,
    d2t: (self: Lerp3, at: number) -> vector64.Vector3f64,
    lengthAt: (self: Lerp3, at: number) -> number,
}

export type Lerp3 = typeof(setmetatable({} :: Lerp3Surface, {} :: Lerp3Static))

local Lerp3: Lerp3Static = {} :: Lerp3Static
Lerp3.__index = Lerp3

function Lerp3:locationAt(at: number): cf64.CFrame64
    argcheck.assertWarn(argcheck.between(at), `Lerp.locationAt: at should be in [0, 1], got at = {at}`)
    return self._start:Lerp(self._end, at)
end

function Lerp3:d1t(_at: number): vector64.Vector3f64
    return self._end.Position - self._start.Position
end

function Lerp3:d2t(_at: number): vector64.Vector3f64
    return vector64.zero
end

function Lerp3:lengthAt(at: number): number
    return at * (self:d1t(at)).Magnitude
end

function Lerp3.new(startp: cf64.CFrameInput, endp: cf64.CFrameInput): Lerp3
    local self: Lerp3Surface = {
        _start = cf64.fromCFrame(startp),
        _end = cf64.fromCFrame(endp)
    }

    return table.freeze(setmetatable(self, Lerp3))
end

function Lerp3.line(startp: cf64.CFrameInput, distance: number): Lerp3
    argcheck.assertWarn(distance ~= 0, `Lerp.line: Expected distance different than 0`)
    local sp = cf64.fromCFrame(startp)
    local self: Lerp3Surface = {
        _start = sp,
        _end = sp + distance * sp.LookVector
    }

    return table.freeze(setmetatable(self, Lerp3))
end

function Lerp3.direction(startp: cf64.CFrameInput, direction: vector64.Vector3Input, distance: number?): Lerp3
    argcheck.assertWarn(distance ~= 0, `Lerp.line: Expected distance different than 0`)
    local sp = cf64.fromCFrame(startp)
    local self: Lerp3Surface = {
        _start = sp,
        _end = sp + (if distance ~= nil then distance else 1) * vector64.fromVector3(direction)
    }

    return table.freeze(setmetatable(self, Lerp3))
end

return Lerp3
