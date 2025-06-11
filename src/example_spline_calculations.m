%% ISO 4156-1:2021 Involute Spline Calculator - Comprehensive Examples
% 
% This script demonstrates various applications of the involute spline
% calculator and profile generator according to ISO 4156-1:2021 standard.
%
% Author: Adil Wahab Bhatti
% Version: 2.0
% Date: 2025

clear; clc; close all;

fprintf('=== ISO 4156-1:2021 Involute Spline Calculator Examples ===\n\n');

%% Example 1: Basic Spline Calculation
fprintf('1. BASIC SPLINE CALCULATION\n');
fprintf('   Standard automotive transmission spline\n');
fprintf('   ----------------------------------------\n');

% Basic calculation with default parameters
basic_spline = calculateInvoluteSpline('Verbose', true);

% Pause for user to review
fprintf('\nPress any key to continue to next example...\n');
pause;

%% Example 2: High-Precision Aerospace Spline
fprintf('\n2. HIGH-PRECISION AEROSPACE SPLINE\n');
fprintf('   Fine module, high tooth count, tight tolerances\n');
fprintf('   -----------------------------------------------\n');

aerospace_spline = calculateInvoluteSpline(...
    'Module', 1.0, ...
    'TeethCount', 48, ...
    'PressureAngle', 37.5, ...
    'RootType', 'fillet', ...
    'ToleranceClass', 4, ...
    'SplineLength', 25, ...
    'Verbose', true);

pause;

%% Example 3: Heavy-Duty Industrial Spline
fprintf('\n3. HEAVY-DUTY INDUSTRIAL SPLINE\n');
fprintf('   Large module, 45° pressure angle, relaxed tolerances\n');
fprintf('   ---------------------------------------------------\n');

industrial_spline = calculateInvoluteSpline(...
    'Module', 6, ...
    'TeethCount', 16, ...
    'PressureAngle', 45, ...
    'RootType', 'flat', ...
    'ToleranceClass', 7, ...
    'SplineLength', 150, ...
    'Verbose', true);

pause;

%% Example 4: Profile Generation and Visualization
fprintf('\n4. PROFILE GENERATION AND VISUALIZATION\n');
fprintf('   Generate involute profiles with detailed plots\n');
fprintf('   ----------------------------------------------\n');

[profiles, profile_data] = generateSplineProfile(...
    'Module', 2.5, ...
    'TeethCount', 20, ...
    'PressureAngle', 30, ...
    'RootType', 'fillet', ...
    'ToleranceClass', 5, ...
    'ProfilePoints', 150, ...
    'PlotProfile', true, ...
    'Verbose', false);

fprintf('Profile generation complete. Check the generated plots.\n');
pause;

%% Example 5: Comparative Analysis
fprintf('\n5. COMPARATIVE ANALYSIS\n');
fprintf('   Compare different pressure angles for same basic geometry\n');
fprintf('   --------------------------------------------------------\n');

pressure_angles = [30, 37.5, 45];
modules = [2, 2, 2];
results = cell(length(pressure_angles), 1);

fprintf('Comparing pressure angles for Module=2, Teeth=24, Class=5:\n\n');
fprintf('%-12s %-12s %-12s %-12s %-12s\n', 'Press. Angle', 'Pitch Dia.', 'Base Dia.', 'Major Dia.', 'Form Height');
fprintf('%-12s %-12s %-12s %-12s %-12s\n', '(degrees)', '(mm)', '(mm)', '(mm)', '(mm)');
fprintf('%s\n', repmat('-', 1, 65));

for i = 1:length(pressure_angles)
    results{i} = calculateInvoluteSpline(...
        'Module', 2, ...
        'TeethCount', 24, ...
        'PressureAngle', pressure_angles(i), ...
        'ToleranceClass', 5, ...
        'Verbose', false);
    
    fprintf('%-12.1f %-12.6f %-12.6f %-12.6f %-12.6f\n', ...
            pressure_angles(i), ...
            results{i}.geometry.pitchDiameter, ...
            results{i}.geometry.baseDiameter, ...
            results{i}.diameters.external.majorMax, ...
            results{i}.geometry.formToothHeight);
end

pause;

%% Example 6: Tolerance Class Comparison
fprintf('\n6. TOLERANCE CLASS COMPARISON\n');
fprintf('   Effect of tolerance class on key parameters\n');
fprintf('   -------------------------------------------\n');

tolerance_classes = [4, 5, 6, 7];
tol_results = cell(length(tolerance_classes), 1);

fprintf('Tolerance class effects for Module=3, Teeth=20, Alpha=30°:\n\n');
fprintf('%-5s %-12s %-12s %-12s %-12s\n', 'Class', 'Total Tol.', 'Mach. Tol.', 'Dev. Allow.', 'Pitch Dev.');
fprintf('%-5s %-12s %-12s %-12s %-12s\n', '', '(mm)', '(mm)', '(mm)', '(mm)');
fprintf('%s\n', repmat('-', 1, 55));

for i = 1:length(tolerance_classes)
    tol_results{i} = calculateInvoluteSpline(...
        'Module', 3, ...
        'TeethCount', 20, ...
        'PressureAngle', 30, ...
        'ToleranceClass', tolerance_classes(i), ...
        'Verbose', false);
    
    fprintf('%-5d %-12.6f %-12.6f %-12.6f %-12.6f\n', ...
            tolerance_classes(i), ...
            tol_results{i}.tolerances.totalTolerance, ...
            tol_results{i}.tolerances.machiningTolerance, ...
            tol_results{i}.tolerances.deviationAllowance, ...
            tol_results{i}.tolerances.pitchDeviation);
end

pause;

%% Example 7: Batch Processing
fprintf('\n7. BATCH PROCESSING\n');
fprintf('   Calculate multiple splines with different parameters\n');
fprintf('   ---------------------------------------------------\n');

% Define batch parameters
batch_params = {
    struct('Module', 1.5, 'TeethCount', 32, 'PressureAngle', 30, 'ToleranceClass', 4, 'Application', 'Precision Servo');
    struct('Module', 2.0, 'TeethCount', 28, 'PressureAngle', 37.5, 'ToleranceClass', 5, 'Application', 'Automotive Diff');
    struct('Module', 4.0, 'TeethCount', 18, 'PressureAngle', 45, 'ToleranceClass', 6, 'Application', 'Marine Gearbox');
    struct('Module', 8.0, 'TeethCount', 12, 'PressureAngle', 30, 'ToleranceClass', 7, 'Application', 'Mining Equipment');
};

batch_results = cell(length(batch_params), 1);

fprintf('Batch processing %d different spline configurations:\n\n', length(batch_params));
fprintf('%-15s %-6s %-6s %-6s %-5s %-12s %-12s\n', 'Application', 'Mod.', 'Teeth', 'Angle', 'Class', 'Pitch Dia.', 'Major Dia.');
fprintf('%s\n', repmat('-', 1, 80));

for i = 1:length(batch_params)
    p = batch_params{i};
    batch_results{i} = calculateInvoluteSpline(...
        'Module', p.Module, ...
        'TeethCount', p.TeethCount, ...
        'PressureAngle', p.PressureAngle, ...
        'ToleranceClass', p.ToleranceClass, ...
        'Verbose', false);
    
    fprintf('%-15s %-6.1f %-6d %-6.1f %-5d %-12.6f %-12.6f\n', ...
            p.Application, p.Module, p.TeethCount, p.PressureAngle, ...
            p.ToleranceClass, batch_results{i}.geometry.pitchDiameter, ...
            batch_results{i}.diameters.external.majorMax);
end

pause;

%% Example 8: Custom Profile Generation with Multiple Views
fprintf('\n8. CUSTOM PROFILE GENERATION\n');
fprintf('   High-resolution profiles with custom parameters\n');
fprintf('   -----------------------------------------------\n');

% Generate profiles for different configurations
configs = {
    struct('desc', 'Fine Pitch - 30°', 'mod', 1, 'teeth', 40, 'angle', 30, 'root', 'fillet');
    struct('desc', 'Medium Pitch - 37.5°', 'mod', 2.5, 'teeth', 24, 'angle', 37.5, 'root', 'flat');
    struct('desc', 'Coarse Pitch - 45°', 'mod', 4, 'teeth', 16, 'angle', 45, 'root', 'fillet');
};

for i = 1:length(configs)
    c = configs{i};
    fprintf('Generating profile: %s\n', c.desc);
    
    [prof, data] = generateSplineProfile(...
        'Module', c.mod, ...
        'TeethCount', c.teeth, ...
        'PressureAngle', c.angle, ...
        'RootType', c.root, ...
        'ToleranceClass', 5, ...
        'ProfilePoints', 200, ...
        'PlotProfile', true, ...
        'Verbose', false);
    
    % Add custom title to figure
    figure(gcf);
    sgtitle(sprintf('%s (m=%.1f, z=%d, α=%.1f°, %s root)', ...
                   c.desc, c.mod, c.teeth, c.angle, c.root));
end

pause;

%% Example 9: Measurement and Inspection Data
fprintf('\n9. MEASUREMENT AND INSPECTION DATA\n');
fprintf('   Key dimensions for quality control\n');
fprintf('   ----------------------------------\n');

inspection_spline = calculateInvoluteSpline(...
    'Module', 2.5, ...
    'TeethCount', 20, ...
    'PressureAngle', 30, ...
    'ToleranceClass', 5, ...
    'SplineLength', 50, ...
    'Verbose', false);

fprintf('Quality Control Inspection Sheet:\n');
fprintf('=================================\n');
fprintf('Spline Specification: m=2.5, z=20, α=30°, Class 5\n\n');

fprintf('CRITICAL DIMENSIONS:\n');
fprintf('  Pitch Diameter (D):           %.6f mm\n', inspection_spline.geometry.pitchDiameter);
fprintf('  Base Diameter (DB):           %.6f mm\n', inspection_spline.geometry.baseDiameter);
fprintf('\nEXTERNAL SPLINE (SHAFT):\n');
fprintf('  Major Diameter Range:         %.6f to %.6f mm\n', ...
        inspection_spline.diameters.external.majorMin, ...
        inspection_spline.diameters.external.majorMax);
fprintf('  Tooth Thickness Range:        %.6f to %.6f mm\n', ...
        inspection_spline.toothThickness.actualMin, ...
        inspection_spline.toothThickness.actualMax);

fprintf('\nINTERNAL SPLINE (HUB):\n');
fprintf('  Major Diameter (min):         %.6f mm\n', inspection_spline.diameters.internal.majorMin);
fprintf('  Space Width Range:            %.6f to %.6f mm\n', ...
        inspection_spline.spaceWidth.actualMin, ...
        inspection_spline.spaceWidth.actualMax);

fprintf('\nMEASUREMENT:\n');
fprintf('  Ball/Pin Diameter (internal): %.6f mm\n', inspection_spline.measurement.ballPinDiameterInternal);
fprintf('  Over-Rollers Measurement:     %.6f mm\n', inspection_spline.measurement.measurementOverRollersInternal);

fprintf('\nTOLERANCES:\n');
fprintf('  Total Tolerance (T+λ):        %.6f mm\n', inspection_spline.tolerances.totalTolerance);
fprintf('  Machining Tolerance (T):      %.6f mm\n', inspection_spline.tolerances.machiningTolerance);
fprintf('  Deviation Allowance (λ):      %.6f mm\n', inspection_spline.tolerances.deviationAllowance);

%% Summary
fprintf('\n=== EXAMPLES COMPLETE ===\n');
fprintf('All example calculations have been completed successfully.\n');
fprintf('Generated data structures are available in the workspace:\n');
fprintf('  - basic_spline: Basic spline calculation\n');
fprintf('  - aerospace_spline: High-precision example\n');
fprintf('  - industrial_spline: Heavy-duty example\n');
fprintf('  - profiles: Profile generation results\n');
fprintf('  - results: Pressure angle comparison\n');
fprintf('  - tol_results: Tolerance class comparison\n');
fprintf('  - batch_results: Batch processing results\n');
fprintf('  - inspection_spline: QC inspection data\n');
fprintf('\nRefer to the README.md file for more detailed documentation.\n');

%% Additional Utility Function Examples
fprintf('\n=== UTILITY FUNCTIONS ===\n');

% Example: Extract key dimensions for CAD
function cadDims = extractCADDimensions(splineData)
    % Extract key dimensions needed for CAD modeling
    cadDims.pitchDiameter = splineData.geometry.pitchDiameter;
    cadDims.majorDiameterExt = splineData.diameters.external.majorMax;
    cadDims.minorDiameterExt = splineData.diameters.external.formMax;
    cadDims.majorDiameterInt = splineData.diameters.internal.majorMin;
    cadDims.formToothHeight = splineData.geometry.formToothHeight;
    cadDims.pressureAngle = splineData.input.pressureAngle;
    cadDims.module = splineData.input.module;
    cadDims.teethCount = splineData.input.teethCount;
end

% Example: Generate manufacturing specification
function spec = generateMfgSpec(splineData)
    spec.drawing_title = sprintf('Involute Spline m%.1f z%d α%.1f° Class%d', ...
                                splineData.input.module, ...
                                splineData.input.teethCount, ...
                                splineData.input.pressureAngle, ...
                                splineData.input.toleranceClass);
    
    spec.material_removal = struct();
    spec.material_removal.external = splineData.diameters.external.majorMax - ...
                                   splineData.geometry.pitchDiameter;
    spec.material_removal.internal = splineData.geometry.pitchDiameter - ...
                                   splineData.diameters.internal.majorMin;
    
    spec.tolerances = splineData.tolerances;
    spec.measurement = splineData.measurement;
end

% Demonstrate utility functions
cad_dims = extractCADDimensions(basic_spline);
mfg_spec = generateMfgSpec(basic_spline);

fprintf('CAD Dimensions extracted for basic spline:\n');
fprintf('  Pitch Diameter: %.6f mm\n', cad_dims.pitchDiameter);
fprintf('  External Major: %.6f mm\n', cad_dims.majorDiameterExt);

fprintf('\nManufacturing Spec generated:\n');
fprintf('  Drawing Title: %s\n', mfg_spec.drawing_title);
fprintf('  External Material Removal: %.6f mm\n', mfg_spec.material_removal.external);

fprintf('\n=== ALL EXAMPLES COMPLETED SUCCESSFULLY ===\n');
