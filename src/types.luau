--!strict

export type Curve3 = {
    startPoint: CFrame, -- Shorthand for .getLocationAt(0)
    endPoint: CFrame, -- Shorthand for .getLocationAt(1)
    locationAt: (t: number) -> CFrame,
}

export type Curve3Approximated = Curve3 & {
    uniform: boolean,
    resolution: number,
    approximateLength: (from: number, to: number) -> number, -- Having section lengths might not make much sense here
    nearestFirstDerivativeAt: (t: number) -> Vector3,
    nearestSecondDerivativeAt: (t: number) -> Vector3,
}

return nil
