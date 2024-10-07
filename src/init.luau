--!strict

local lookupTables = require(script.lookupTables)
local types = require(script.types)

-- Curve implementation
local Generic = require(script.impl.Generic)
local Lerp = require(script.impl.Lerp)
local Arc = require(script.impl.Arc)
local Clothoid = require(script.impl.Clothoid)

local bQuad = require(script.impl.Bezier.Quad)
local bCubic = require(script.impl.Bezier.Cubic)

-- Export types
export type Curve3 = types.Curve3
export type GenericCurve3 = Generic.GenericCurve3
export type Arc3 = Arc.Arc3
export type Lerp3 = Lerp.Lerp3
export type Clothoid3 = Clothoid.Clothoid3

export type BezierQuad3 = bQuad.Quad3
export type BezierCubic3 = bCubic.Cubic3

type Curve = {
    toPoints: typeof(lookupTables.toPoints),
    Generic: Generic.GenericCurve3Static,

    Lerp: Lerp.Lerp3Static,

    Arc: Arc.Arc3Static,
    Circle: Arc.Arc3Static,

    Clothoid: Clothoid.Clothoid3Static,
    CornuSpiral: Clothoid.Clothoid3Static,
    EulerSpiral: Clothoid.Clothoid3Static,

    BezierQuad: bQuad.Quad3Static,
    BezierCubic: bCubic.Cubic3Static
}

local Curve: Curve = {
    toPoints = lookupTables.toPoints,
    Generic = Generic,
    Lerp = Lerp,
    Arc = Arc,
    Circle = Arc,
    Clothoid = Clothoid,
    CornuSpiral = Clothoid,
    EulerSpiral = Clothoid,
    BezierQuad = bQuad,
    BezierCubic = bCubic
}

table.freeze(Curve)
return Curve
