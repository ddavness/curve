--!strict

export type Curve3Surface = {
    startPoint: CFrame, -- Shorthand for .getLocationAt(0)
    endPoint: CFrame, -- Shorthand for .getLocationAt(1)
}

export type Curve3Meta = {
    __index: Curve3Meta,
    locationAt: (self: Curve3, t: number) -> CFrame,
}

export type Curve3 = typeof(setmetatable({} :: Curve3Surface, {} :: Curve3Meta))

export type Curve3ApproximatedMeta = {
    __index: Curve3ApproximatedMeta,
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

export type Curve3Approximated = typeof(setmetatable({} :: Curve3ApproximatedSurface, {} :: Curve3ApproximatedMeta))

return nil
