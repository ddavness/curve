# Curve Library

A Roblox library that provides utilities to create and manage 3D curves (may also consider having 2D curves in the future).

Curves are created from certain key variables (start point, control point(s), etc.) and stored as `[0, 1]` -> `CFrame` functions. May be used for any purpose, including for example camera animations or procedural race track creation.

The library should be mostly unopinionated but it tends to be somewhat biased towards curves "based" on the XZ (horizontal) plane.

Since this library does not interact with the DataModel, it may be ported to another Luau platform (outside Roblox) if alternative `Vector3` and `CFrame` implementations are provided.

## Curve Type Support/Roadmap

| | `:locationAt()` | `:dt1()` (Velocity) | `:dt2()` (Acceleration) | `:lengthAt()` |
|-:|:--------:|:--------------:|:------------------:|:-----------------:|
|**Lerp (line)**|✅|🚧|🚧|🚧|
|**[Bézier](https://en.wikipedia.org/wiki/B%C3%A9zier_curve)** (Quad)|✅|✅|✅|❌|
|**Bézier** (Cubic)|✅|✅|✅|❌|
|**Bézier** (nth degree)|Evaluating|
|**Bézier** chain/spline|Evaluating|
|**[Hermite Spline](https://en.wikipedia.org/wiki/Cubic_Hermite_spline)**|Evaluating|
|**[Circular Arc](https://en.wikipedia.org/wiki/Circular_arc)**|✅|🚧|🚧|🚧|
|**[Euler Spiral](https://en.wikipedia.org/wiki/Euler_spiral)**|✅<sup>**(1)**</sup>|🚧|🚧|🚧|
|**[Archimedian Spiral](https://en.wikipedia.org/wiki/Archimedean_spiral)**|Evaluating|

> #### Legend
> * ✅ Implemented
> * 🚧 Not yet implemented, will be implemented in the future
> * ❌ Will not implement (not solvable analytically or not feasible to compute)
> #### Notes
> * **(1)** Analytical solution involves Fresnel Integrals which do not have a closed-form solution, but can be expressed via a Taylor Series expansion ([more info](https://en.wikipedia.org/wiki/Fresnel_integral)); implemented via approximations of that expansion over a finite amount of terms

## Quick Start

### Wally

Add this line to your `wally.toml` file:

```
curve = "ddavness/curve@0.1.0"
```

### Via rbxm

See the [Releases](https://github.com/ddavness/curve/releases) page

## Documentation

Soon™️

## Implentation Details

The library by default creates curves that go "forward" (they use `CFrame.lookVector` as reference), but assumes that the Roblox coordinate system is in place:
- `CFrame.rightVector` is (1, 0, 0)
- `CFrame.upVector` is (0, 1, 0)
- `CFrame.lookVector` is **(0, 0, -1)**

Additional work may have to be done if you're using a different coordinate system.

# ⚠️ This is pre-1.0.0 software

Right now, while we think the actual curve implementations are solid (and perhaps good enough for production), the API interface is a bit "raw" and may need some polishing. Therefore, it is expected that breaking changes are introduced in the future.

The results of the curve are dependent on the implementation, too. If there is any significant change to the implementation of a curve, it's possible it can create a breaking change, too (this is not expected to, but might happen).
