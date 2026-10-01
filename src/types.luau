--!strict

export type Curve3Surface = {
}

export type Curve3Static = {
    __index: Curve3Static,
    locationAt: (self: Curve3, t: number) -> CFrame,
}

export type Curve3 = typeof(setmetatable({} :: Curve3Surface, {} :: Curve3Static))

export type Curve3ApproximatedStatic = {
    __index: Curve3ApproximatedStatic,
    approximateLength: (self: Curve3Approximated, from: number, to: number) -> number,
}

export type Curve3ApproximatedSurface = {
    sampling: "uniformT" | "uniformDistance",
    resolution: number,
    _lutParameter: {number},
    _lutPosition: {Vector3},
    _lutDistance: {number},
}

export type Curve3Approximated = typeof(setmetatable({} :: Curve3ApproximatedSurface, {} :: Curve3ApproximatedStatic))

return nil
