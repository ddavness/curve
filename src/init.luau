--!strict

local lookupTables = require(script.lookupTables)
local types = require(script.types)

-- Curve implementation
local Generic = require(script.impl.Generic)
local Lerp = require(script.impl.Lerp)
local Arc = require(script.impl.Arc)
local Clothoid = require(script.impl.Clothoid)

-- Export types
export type Curve3 = types.Curve3
export type GenericCurve3 = Generic.GenericCurve3
export type Arc3 = Arc.Arc3
export type Lerp3 = Lerp.Lerp3
export type Clothoid3 = Clothoid.Clothoid3

type Curve = {
    toPoints: typeof(lookupTables.toPoints),
    Generic: Generic.GenericCurve3Static,

    Lerp: Lerp.Lerp3Static,

    Arc: Arc.Arc3Static,
    Circle: Arc.Arc3Static,

    Clothoid: Clothoid.Clothoid3Static,
    CornuSpiral: Clothoid.Clothoid3Static,
    EulerSpiral: Clothoid.Clothoid3Static
}

local Curve: Curve = {
    toPoints = lookupTables.toPoints,
    Generic = Generic,
    Lerp = Lerp,
    Arc = Arc,
    Circle = Arc,
    Clothoid = Clothoid,
    CornuSpiral = Clothoid,
    EulerSpiral = Clothoid
}

table.freeze(Curve)
return Curve
