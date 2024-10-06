--!strict

local root = script.Parent.Parent.Parent
local argcheck = require(root.utils.argcheck)

type Cubic3Surface = {
    startPoint: CFrame,
    _B: CFrame,
    _C: CFrame,
    _D: CFrame
}

export type Cubic3Static = {
    __index: Cubic3Static,
    -- Constructors
    new: (start: CFrame, b: CFrame, c: CFrame, d: CFrame) -> Cubic3,
    locationAt: (self: Cubic3, at: number) -> CFrame,
}

export type Cubic3 = typeof(setmetatable({} :: Cubic3Surface, {} :: Cubic3Static))

local Cubic3: Cubic3Static = {} :: Cubic3Static
Cubic3.__index = Cubic3

function Cubic3:locationAt(at: number): CFrame
    argcheck.assertWarn(argcheck.between(at), `Arc.locationAt: at should be in [0, 1], got at = {at}`)
    --[[
        Bernstein polynomials for cubic beziers:
        (1-t)^3
        3 (1-t)^2 t
        3 (1-t)t^2
        t^3
    ]]--

    local t = at

    local a_weighted = self.startPoint.Position * ((1-t)^3)
    local b_weighted = self._B.Position * (3*((1-t)^2)*t)
    local c_weighted = self._C.Position * (3*(1-t)*(t^2))
    local d_weighted = self._D.Position * (t^3)

    return CFrame.new(a_weighted + b_weighted + c_weighted + d_weighted)
end

function Cubic3.new(start: CFrame, b: CFrame, c: CFrame, d: CFrame): Cubic3
    local self: Cubic3Surface = {
        startPoint = start,
        _B = b,
        _C = c,
        _D = d
    }

    return table.freeze(setmetatable(self, Cubic3))
end

table.freeze(Cubic3)
return Cubic3