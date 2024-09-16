--!strict

local lookupTables = require(script.lookupTables)
local types = require(script.types)

-- Curve implementation
local Generic = require(script.impl.Generic)
local Lerp = require(script.impl.Lerp)
local Arc = require(script.impl.Arc)

-- Export types
export type Curve3 = types.Curve3
export type GenericCurve3 = Generic.GenericCurve3
export type Arc3 = Arc.Arc3
export type Lerp3 = Lerp.Lerp3

type Curve = {
    toPoints: typeof(lookupTables.toPoints),
    Generic: Generic.GenericCurve3Static,
    Arc: Arc.Arc3Static,
    Lerp: Lerp.Lerp3Static,
    Circle: Arc.Arc3Static
}

local Curve: Curve = {
    toPoints = lookupTables.toPoints,
    Generic = Generic,
    Arc = Arc,
    Lerp = Lerp,
    Circle = Arc
}

table.freeze(Curve)
return Curve
