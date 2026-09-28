# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
* **Lerp/Line:** Implemented the `:d1t(t)`, `:d2t(t)`, `:lengthAt(t)` methods
* **Arc/Circle:** Implemented the `:d1t(t)`, `:d2t(t)`, `:lengthAt(t)` methods
* **Clothoid/Cornu Spiral/Euler Spiral:** Implemented the `:d1t(t)`, `:d2t(t)`, `:lengthAt(t)` methods
* **BezierQuad:** Implemented the `:lengthAt(t)` method (closed-form solution)
* **BezierCubic:** Implemented the `:lengthAt(t)` method (approximation computed numerically)

## [0.1.1] - 2026-07-05

### Fixed
* Fixed the `Arc3.banked` constructor which produced erratic and unpredictable behavior depending on the rotation of the starting point. Now the behavior should be consistent irrespective of the starting `CFrame` rotation.

### Removed
* Removed the `globalAlignTo` parameter from `Arc3.banked` as it is now computed from the starting point's `.lookVector` and the optional `rotateOn` vector.

## [0.1.0] - 2024-10-09

Initial Release
