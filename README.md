# Curve Library

A Roblox library that provides utilities to create and manage 3D curves (and 2D in the future:tm:)
(might be portable as a generic library if a generic Vector3/CFrame implementation is provided)

## Curve Support/Roadmap

<center>

| | Position | Velocity (dt1) | Acceleration (dt2) | Length (integral) |
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

</center>

> #### Legend
> * ✅ Implemented
> * 🚧 Not yet implemented, will be implemented in the future
> * ❌ Will not implement (not solvable analytically or not feasible to compute)
> #### Notes
> * **(1)** Analytical solution involves Fresnel Integrals which do not have a closed-form solution, but can be expressed via a Taylor Series expansion ([more info](https://en.wikipedia.org/wiki/Fresnel_integral)); implemented via approximations of that expansion over a finite amount of terms