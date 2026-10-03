# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0]

### Added

#### Method Implementation for Analytical Curves
* **Lerp/Line:** Implemented the `:d1t(t)`, `:d2t(t)`, `:lengthAt(t)` methods
* **Arc/Circle:** Implemented the `:d1t(t)`, `:d2t(t)`, `:lengthAt(t)` methods
* **Clothoid/Cornu Spiral/Euler Spiral:** Implemented the `:d1t(t)`, `:d2t(t)`, `:lengthAt(t)` methods
* **BezierQuad:** Implemented the `:lengthAt(t)` method (closed-form solution)
* **BezierCubic:** Implemented the `:lengthAt(t)` method (approximation computed numerically)

#### Numerical Computation for Generic Curves
* **Generic Curves:** Implemented numerical computation for `:d1t(t)`, `:d2t(t)` and `:lengthAt(t)` methods. 
* * These computations are only approximations and are likely to deviate by a small amount from the analytical result for any non-trivial curve.

#### CFrame64 and Vector64 libraries
* Added `CFrame64` and `Vector64` libraries, which mirror the functionality of `CFrame` and `Vector3`, except that the internal components are represented by doubles (`f64`) instead of floats (`f32`).
* This is required because some numerical approximations for generic curves (`d2t` in particular) involve extremely small intervals which may cause floating-point precision problems if we were to use single-precision floats.
* You can convert a `CFrame`/`Vector3` to a `CFrame64`/`Vector3f64` by calling `CFrame64.fromCFrame()` and `Vector64.fromVector3()`, respectively
* `CFrame64`s and `Vector3f64`s can normally interact with `CFrames` and `Vector3` without explicit conversion, **as long as they are in the left side of the expression.** The result is upgraded to the double-precision format.

```luau
local v1 = Vector64.new(1, 1, 1)
local v2 = v1 + Vector3.new(2, 2, 2) -- result: Vector3f64(3, 3, 3)
local v3 = Vector3.new(2, 2, 2) + v1 -- error!

local cf1 = CFrame64.new(1, 1, 1)
local cf2 = cf1 * CFrame.Angles(0, math.pi, 0) -- ok
local cf3 = CFrame.Angles(0, math.pi, 0) * cf1 -- error!
```

### Changed
* `:locationAt(t)` will now return `CFrame64` values instead of `CFrame`s
* `:d1t(t)` and `:d2t(t)` will now return `Vector3f64` values instead of `Vector3`s

> ⚠️ **These are breaking changes**, because there is no implicit way to downgrade these types into their built-in counterparts. You have to explicitly call `:toCFrame()` or `:toVector3()` to convert

## [0.1.1] - 2026-07-05

### Fixed
* Fixed the `Arc3.banked` constructor which produced erratic and unpredictable behavior depending on the rotation of the starting point. Now the behavior should be consistent irrespective of the starting `CFrame` rotation.

### Removed
* Removed the `globalAlignTo` parameter from `Arc3.banked` as it is now computed from the starting point's `.lookVector` and the optional `rotateOn` vector.

## [0.1.0] - 2024-10-09

Initial Release
