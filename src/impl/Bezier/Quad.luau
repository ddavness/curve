--!strict

local root = script.Parent.Parent.Parent
local argcheck = require(root.utils.argcheck)

type Quad3Surface = {
    startPoint: CFrame,
    _B: CFrame,
    _C: CFrame
}

export type Quad3Static = {
    __index: Quad3Static,
    -- Constructors
    new: (start: CFrame, b: CFrame, c: CFrame) -> Quad3,
    locationAt: (self: Quad3, at: number) -> CFrame,
}

export type Quad3 = typeof(setmetatable({} :: Quad3Surface, {} :: Quad3Static))

local Quad3: Quad3Static = {} :: Quad3Static
Quad3.__index = Quad3

function Quad3:locationAt(at: number): CFrame
    argcheck.assertWarn(argcheck.between(at), `Arc.locationAt: at should be in [0, 1], got at = {at}`)
    --[[
        Bernstein polynomials for qudratic beziers:
        (1-t)^2
        2(1-t)t
        t^2
    ]]--

    local t = at

    local a_weighted = self.startPoint.Position * ((1-t)^2)
    local b_weighted = self._B.Position * (2 * (1-t)*t)
    local c_weighted = self._C.Position * (t^2)

    return CFrame.new(a_weighted + b_weighted + c_weighted)
end

function Quad3.new(start: CFrame, b: CFrame, c: CFrame): Quad3
    local self: Quad3Surface = {
        startPoint = start,
        _B = b,
        _C = c,
    }

    return table.freeze(setmetatable(self, Quad3))
end

table.freeze(Quad3)
return Quad3