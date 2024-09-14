--!strict

export type Curve3Meta = {
    __index: Curve3Meta,
    _locationAt: (t: number) -> CFrame
}

export type Curve3Impl = {
    startPoint: CFrame, -- Shorthand for .getLocationAt(0)
    endPoint: CFrame, -- Shorthand for .getLocationAt(1)
    locationAt: (self: Curve3, t: number) -> CFrame,
}

export type Curve3 = typeof(setmetatable({} :: Curve3Impl, {} :: Curve3Meta))

export type Curve3ApproximatedMeta = Curve3Meta & {
    __index: Curve3ApproximatedMeta,
    _lutPosition: {CFrame},
    _lutDistance: {number},
    _lut1dt: {Vector3},
    _lut2dt: {Vector3}
}

export type Curve3ApproximatedImpl = Curve3Impl & {
    uniform: boolean,
    resolution: number,
    approximateLength: (self: Curve3ApproximatedImpl, from: number, to: number) -> number,
    nearestFirstDerivativeAt: (Curve3ApproximatedImpl, t: number) -> Vector3,
    nearestSecondDerivativeAt: (Curve3ApproximatedImpl, t: number) -> Vector3,
}

export type Curve3Approximated = typeof(setmetatable({} :: Curve3ApproximatedImpl, {} :: Curve3ApproximatedMeta))

return nil
