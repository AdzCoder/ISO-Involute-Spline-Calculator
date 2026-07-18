# ISO 4156-1:2021 Involute Spline Calculator

[![MATLAB](https://img.shields.io/badge/MATLAB-R2018b+-blue?style=flat-square)](https://www.mathworks.com/products/matlab.html)
[![ISO Standard](https://img.shields.io/badge/ISO-4156--1%3A2021-green?style=flat-square)](https://www.iso.org/standard/79775.html)
[![Licence](https://img.shields.io/badge/Licence-MIT-orange?style=flat-square)](LICENSE)

A MATLAB tool for calculating straight cylindrical involute spline parameters to **ISO 4156-1:2021** (metric module, side fit), and for generating the tooth profiles. It computes the geometry, tolerances, and inspection dimensions for internal and external splines from a handful of inputs, so the tedious standards arithmetic behind a transmission spline is done in one call.

Built as a self-contained engineering utility while studying machine and transmission design; it uses base MATLAB only, with no toolbox dependencies.

## What it does

Given a module, tooth count, pressure angle, tolerance class, and length, the calculator returns a structured result covering the basic geometry (pitch and base diameters, circular and base pitch), the full tolerance stack-up (pitch, profile, and helix deviations), the effective and actual space widths and tooth thicknesses, all critical diameters, and the ball/pin sizes for over-pin measurement. A companion function generates the parametric involute tooth profile for plotting.

## Supported parameters

| Parameter | Options | Default |
|-----------|---------|---------|
| Module (m) | > 0 mm | 2 mm |
| Teeth (z) | integer > 0 | 20 |
| Pressure angle (α) | 30°, 37.5°, 45° | 30° |
| Root type | flat, fillet | flat |
| Tolerance class | 4, 5, 6, 7 | 5 |
| Spline length (b) | > 0 mm | 50 mm |

## Usage

```matlab
% Defaults
splineData = calculateInvoluteSpline();

% Custom spline
splineData = calculateInvoluteSpline('Module', 3, 'TeethCount', 24, ...
                                     'PressureAngle', 37.5, 'ToleranceClass', 6);

% Generate and plot the tooth profile
[profiles, data] = generateSplineProfile('Module', 2.5, 'TeethCount', 16, ...
                                         'PlotProfile', true);
```

`src/example_spline_calculations.m` runs a set of worked examples across automotive, aerospace, and heavy-duty cases.

## Functions

- **`calculateInvoluteSpline(...)`**: core ISO 4156-1:2021 calculation. Returns a struct of inputs, geometry, tolerances, dimensions, and measurement data.
- **`generateSplineProfile(...)`**: builds the parametric involute profile and, with `'PlotProfile'`, plots single teeth and the full spline against its reference circles. A `'ProfilePoints'` option sets curve resolution.

DXF export is stubbed rather than implemented: `'ExportDXF'` currently prints a notice, since writing DXF needs an external library. Profiles can still be plotted or read from the returned arrays.

## Requirements

- **MATLAB** R2018b or later
- No toolboxes required (base MATLAB only)

## Repository layout

- `src/calculateInvoluteSpline.m`: standards calculation
- `src/generateSplineProfile.m`: profile generation and plotting
- `src/example_spline_calculations.m`: worked examples

## References

1. **ISO 4156-1:2021**: Straight cylindrical involute splines, metric module, side fit (Part 1: Generalities)
2. **ISO 4156-2:2021**: Part 2, Dimensions
3. **ISO 4156-3:2021**: Part 3, Inspection
4. Radzevich, S.P. *Dudley's Handbook of Practical Gear Design and Manufacture*

The calculator implements the standard for educational and engineering use. Verify critical calculations against the official standard before relying on them in production.

## Licence

MIT Licence: see the [LICENCE](LICENSE) file for details.

---

*Developed by Adil Wahab Bhatti.*
