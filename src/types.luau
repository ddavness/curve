--!strict

export type Curve3Surface = {
    startPoint: CFrame, -- Shorthand for .getLocationAt(0)
}

export type Curve3Static = {
    __index: Curve3Static,
    locationAt: (self: Curve3, t: number) -> CFrame,
}

export type Curve3 = typeof(setmetatable({} :: Curve3Surface, {} :: Curve3Static))

export type Curve3ApproximatedStatic = {
    __index: Curve3ApproximatedStatic,
    approximateLength: (self: Curve3Approximated, from: number, to: number) -> number,
    nearestFirstDerivativeAt: (self: Curve3Approximated, t: number) -> Vector3,
    nearestSecondDerivativeAt: (self: Curve3Approximated, t: number) -> Vector3,
}

export type Curve3ApproximatedSurface = {
    uniform: boolean,
    resolution: number,
    _lutPosition: {CFrame},
    _lutDistance: {number},
    _lut1dt: {Vector3},
    _lut2dt: {Vector3}
}

export type Curve3Approximated = typeof(setmetatable({} :: Curve3ApproximatedSurface, {} :: Curve3ApproximatedStatic))

return nil
