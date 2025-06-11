# ISO 4156-1:2021 Involute Spline Calculator

A comprehensive MATLAB implementation for calculating and generating involute spline parameters according to **ISO 4156-1:2021** standard for straight cylindrical involute splines with metric module and side fit.

![Spline Profile Example](https://img.shields.io/badge/MATLAB-R2018b+-blue?style=flat-square) ![ISO Standard](https://img.shields.io/badge/ISO-4156--1%3A2021-green?style=flat-square) ![License](https://img.shields.io/badge/License-MIT-orange?style=flat-square)

## 🔧 Features

- **Complete ISO 4156-1:2021 Implementation**: Accurate calculations for all spline parameters
- **Multiple Pressure Angles**: Support for 30°, 37.5°, and 45° pressure angles
- **Tolerance Classes**: Full implementation of tolerance classes 4, 5, 6, and 7
- **Root Types**: Both flat and fillet root configurations
- **Profile Generation**: Parametric generation of involute tooth profiles
- **Visualization**: Comprehensive plotting of spline profiles and geometry
- **Batch Processing**: Calculate multiple spline configurations efficiently

## 📐 Supported Parameters

| Parameter | Range/Options | Default |
|-----------|---------------|---------|
| Module (m) | > 0 mm | 2 mm |
| Number of Teeth (z) | Integer > 0 | 20 |
| Pressure Angle (α) | 30°, 37.5°, 45° | 30° |
| Root Type | flat, fillet | flat |
| Tolerance Class | 4, 5, 6, 7 | 5 |
| Spline Length (b) | > 0 mm | 50 mm |

## 🚀 Quick Start

### Basic Usage

```matlab
% Calculate spline with default parameters
splineData = calculateInvoluteSpline();

% Custom spline calculation
splineData = calculateInvoluteSpline('Module', 3, 'TeethCount', 24, ...
                                   'PressureAngle', 37.5, 'ToleranceClass', 6);

% Generate spline profiles with visualization
[profiles, splineData] = generateSplineProfile('Module', 2.5, 'TeethCount', 16, ...
                                              'PlotProfile', true);
```

### Advanced Example

```matlab
% High-precision spline for aerospace application
[profiles, data] = generateSplineProfile(...
    'Module', 1.5, ...
    'TeethCount', 32, ...
    'PressureAngle', 30, ...
    'RootType', 'fillet', ...
    'ToleranceClass', 4, ...
    'SplineLength', 75, ...
    'ProfilePoints', 200, ...
    'PlotProfile', true, ...
    'Verbose', true);

% Access calculated parameters
fprintf('Pitch Diameter: %.6f mm\n', data.geometry.pitchDiameter);
fprintf('Major Diameter (ext): %.6f to %.6f mm\n', ...
        data.diameters.external.majorMin, data.diameters.external.majorMax);
```

## 📊 Output Structure

The calculator returns a comprehensive structure containing:

### Input Parameters
- Module, teeth count, pressure angle, root type
- Tolerance class, spline length, deviations

### Basic Geometry
- Pitch diameter, base diameter
- Circular pitch, base pitch
- Form tooth height

### Tolerances
- Tolerance units, total tolerance
- Machining tolerance, deviation allowance
- Pitch, profile, and helix deviations

### Dimensions
- Space widths (effective and actual)
- Tooth thickness (effective and actual)
- All critical diameters for internal and external splines

### Measurement Data
- Ball/pin diameters for measurement
- Over-rollers measurements

## 🎯 Applications

- **Mechanical Design**: Automotive transmissions, aerospace gearboxes
- **Manufacturing**: CNC programming, inspection planning
- **Quality Control**: Tolerance verification, measurement setup
- **Education**: Teaching involute spline geometry and standards
- **Research**: Spline optimization and analysis

## 📝 Functions

### `calculateInvoluteSpline()`
Core calculation function implementing ISO 4156-1:2021 formulas.

**Parameters:**
- `'Module'` - Module in mm
- `'TeethCount'` - Number of teeth
- `'PressureAngle'` - 30, 37.5, or 45 degrees
- `'RootType'` - 'flat' or 'fillet'
- `'ToleranceClass'` - 4, 5, 6, or 7
- `'SplineLength'` - Length in mm
- `'ExternalDev'` - External deviation in μm
- `'FormClearance'` - Form clearance factor
- `'Verbose'` - Display results

### `generateSplineProfile()`
Generates parametric involute tooth profiles for visualization and CAD export.

**Additional Parameters:**
- `'ProfilePoints'` - Number of points per curve
- `'PlotProfile'` - Generate plots
- `'ExportDXF'` - Export capability
- `'Filename'` - Base filename

## 🔬 Technical Implementation

### Tolerance Calculations
- Implements complete tolerance stack-up per ISO 4156-1:2021
- Considers all geometric deviations (pitch, profile, helix)
- Accurate tolerance unit calculations for different diameter ranges

### Involute Mathematics
- Precise involute curve generation
- Proper tooth thickness and space width calculations
- Accurate pressure angle transformations

### Profile Generation
- Parametric involute curves
- Root fillet modeling
- Complete spline assembly generation

## 📋 Requirements

- **MATLAB**: R2018b or later
- **Toolboxes**: None required (uses base MATLAB only)
- **Memory**: Minimal (< 10 MB for typical calculations)

## 🎨 Visualization Features

The profile generator creates comprehensive plots including:
- Single tooth profile comparisons
- External and internal spline details
- Complete spline assemblies
- Reference circles (pitch, base, major)
- Dimensional annotations

## 📖 Examples

### Example 1: Automotive Transmission Spline
```matlab
% Typical automotive application
data = calculateInvoluteSpline('Module', 2.5, 'TeethCount', 23, ...
                              'PressureAngle', 30, 'ToleranceClass', 6, ...
                              'SplineLength', 60);
```

### Example 2: Aerospace High-Precision Spline
```matlab
% High-precision aerospace application
[profiles, data] = generateSplineProfile('Module', 1.0, 'TeethCount', 48, ...
                                        'PressureAngle', 37.5, 'RootType', 'fillet', ...
                                        'ToleranceClass', 4, 'ProfilePoints', 300);
```

### Example 3: Heavy Machinery Spline
```matlab
% Heavy-duty industrial application
data = calculateInvoluteSpline('Module', 6, 'TeethCount', 16, ...
                              'PressureAngle', 45, 'ToleranceClass', 7, ...
                              'SplineLength', 120);
```

## 🔍 Validation

The implementation has been validated against:
- ISO 4156-1:2021 worked examples
- Commercial spline calculation software
- Physical measurement data
- Finite element analysis results

## 📚 References

1. **ISO 4156-1:2021** - Straight cylindrical involute splines — Metric module, side fit — Part 1: Generalities
2. **ISO 4156-2:2021** - Part 2: Dimensions
3. **ISO 4156-3:2021** - Part 3: Inspection
4. Dudley, D.W. "Handbook of Practical Gear Design"
5. Radzevich, S.P. "Dudley's Handbook of Practical Gear Design and Manufacture"

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

### Development Guidelines
- Follow MATLAB coding standards
- Include comprehensive documentation
- Add test cases for new features
- Validate against ISO standards

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Adil Wahab Bhatti**

## 🙏 Acknowledgments

- ISO Technical Committee TC 96 for the comprehensive standard
- MATLAB community for optimization suggestions
- Industry colleagues for validation and testing

## 📈 Version History

### Version 2.0 (2025)
- Complete rewrite with modular architecture
- Added parametric profile generation
- Comprehensive visualization features
- Full ISO 4156-1:2021 compliance
- Enhanced error handling and validation

### Version 1.0 (2024)
- Initial implementation
- Basic calculation functionality
- Command-line interface

---

**Note**: This calculator implements the ISO 4156-1:2021 standard for educational and engineering purposes. Always verify critical calculations with official standards and consult qualified engineers for production applications.
