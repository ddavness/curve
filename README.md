# Curve Library

A Roblox library that provides utilities to create and manage 3D curves (may also consider having 2D curves in the future).

Curves are created from certain key variables (start point, control point(s), etc.) and stored as `[0, 1]` -> `CFrame` functions. May be used for any purpose, including for example camera animations or procedural race track creation.

Since this library does not interact with the DataModel, it may be portable as a generic Luau library if a generic `Vector3` and `CFrame` implementations are provided.

## Curve Type Support/Roadmap

| | `:locationAt()` | `:dt1()` (Velocity) | `:dt2()` (Acceleration) | `:lengthAt()` |
|-:|:--------:|:--------------:|:------------------:|:-----------------:|
|**Lerp (line)**|✅|🚧|🚧|🚧|
|**Bézier** (Quad)|✅|✅|✅|❌|
|**Bézier** (Cubic)|✅|✅|✅|❌|
|**Bézier** (nth degree)|Evaluating|
|**Bézier** chain/spline|Evaluating|
|**Hermite Spline**|Evaluating|
|**Circle Arc**|✅|🚧|🚧|🚧|
|**Euler Spiral**|✅<sup>**(1)**</sup>|🚧|🚧|🚧|
|**Archimedian Spiral**|Evaluating|

> #### Legend
> * ✅ Implemented
> * 🚧 Not yet implemented, will be implemented in the future
> * ❌ Will not implement (not solvable analytically or not feasible to compute)
> #### Notes
> * **(1)** Analytical solution involves Fresnel Integrals which do not have a closed-form solution, but can be expressed via a Taylor Series expansion ([more info](https://en.wikipedia.org/wiki/Fresnel_integral)); implemented via approximations of that expansion over a finite amount of terms
