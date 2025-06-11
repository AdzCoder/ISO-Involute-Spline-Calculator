function splineData = calculateInvoluteSpline(varargin)
%CALCULATEINVOLUTESPLINE ISO 4156-1:2021 Involute Spline Calculator
%
% DESCRIPTION:
%   Calculates involute spline parameters according to ISO 4156-1:2021
%   standard for straight-sided splines with 30°, 37.5°, or 45° pressure angles.
%
% SYNTAX:
%   splineData = calculateInvoluteSpline()
%   splineData = calculateInvoluteSpline('Parameter', Value, ...)
%
% PARAMETERS:
%   'Module'         - Module in mm (default: 2)
%   'TeethCount'     - Number of teeth (default: 20)
%   'PressureAngle'  - Pressure angle in degrees: 30, 37.5, or 45 (default: 30)
%   'RootType'       - Root type: 'flat' or 'fillet' (default: 'flat')
%   'ToleranceClass' - Tolerance class: 4, 5, 6, or 7 (default: 5)
%   'SplineLength'   - Spline length in mm (default: 50)
%   'ExternalDev'    - Fundamental deviation external in μm (default: 0)
%   'FormClearance'  - Form clearance factor (default: 0.1)
%   'Verbose'        - Display results (default: true)
%
% OUTPUT:
%   splineData - Structure containing all calculated parameters
%
% EXAMPLE:
%   % Basic calculation with default parameters
%   data = calculateInvoluteSpline();
%
%   % Custom spline calculation
%   data = calculateInvoluteSpline('Module', 3, 'TeethCount', 24, ...
%                                 'PressureAngle', 37.5, 'ToleranceClass', 6);
%
% REFERENCES:
%   ISO 4156-1:2021 - Straight cylindrical involute splines - Metric module,
%   side fit - Part 1: Generalities
%
% AUTHOR: Adil Wahab Bhatti
% VERSION: 2.0
% DATE: 2025

%% Input Parsing
p = inputParser;
addParameter(p, 'Module', 2, @(x) isnumeric(x) && x > 0);
addParameter(p, 'TeethCount', 20, @(x) isnumeric(x) && x > 0 && mod(x,1) == 0);
addParameter(p, 'PressureAngle', 30, @(x) ismember(x, [30, 37.5, 45]));
addParameter(p, 'RootType', 'flat', @(x) ismember(x, {'flat', 'fillet'}));
addParameter(p, 'ToleranceClass', 5, @(x) ismember(x, [4, 5, 6, 7]));
addParameter(p, 'SplineLength', 50, @(x) isnumeric(x) && x > 0);
addParameter(p, 'ExternalDev', 0, @isnumeric);
addParameter(p, 'FormClearance', 0.1, @(x) isnumeric(x) && x > 0);
addParameter(p, 'Verbose', true, @islogical);

parse(p, varargin{:});

% Extract parameters
m = p.Results.Module;
z = p.Results.TeethCount;
alpha = p.Results.PressureAngle;
rootType = p.Results.RootType;
toleranceClass = p.Results.ToleranceClass;
b = p.Results.SplineLength;
esv = p.Results.ExternalDev;
cf = p.Results.FormClearance * m;
verbose = p.Results.Verbose;

%% Constants
% Tolerance class factors [class 4, 5, 6, 7]
FpL_FACTORS = [2.5, 3.55, 5.0, 7.1];
FALPHA_FACTORS = [1.6, 2.5, 4.0, 6.3];
FBETA_FACTORS = [0.8, 5.0, 12.5, 20.0];
T_FACTORS = [10, 16, 25, 40];
LAMBDA_FACTORS = [40, 64, 100, 160];

alpha_rad = deg2rad(alpha);
class_idx = toleranceClass - 3;

%% Fundamental Geometry
D = m * z;                          % Pitch diameter [mm]
DB = D * cos(alpha_rad);           % Base diameter [mm]
P = m * pi;                        % Circular pitch [mm]
PB = m * pi * cos(alpha_rad);      % Base pitch [mm]
E = 0.5 * pi * m;                  % Basic circular space width [mm]
S = E;                             % Basic circular tooth thickness [mm]

%% Tolerance Units
if D <= 500
    id = 0.45 * D^(1/3) + 0.001 * D;
else
    id = 0.004 * D + 2.1;
end
iE = 0.45 * E^(1/3) + 0.001 * E;

%% Total Tolerance Calculation
T_plus_lambda_um = T_FACTORS(class_idx) * id + LAMBDA_FACTORS(class_idx) * iE;
TLAM = T_plus_lambda_um / 1000;    % Total tolerance [mm]

% Initial split of T and λ
lambda_initial = 0.4 * TLAM;
T = TLAM - lambda_initial;

%% Deviation Calculations
L = (pi * m * z) / 2;
Fp = (FpL_FACTORS(class_idx) * L + 9) / 1000;
phi_f = 0.0125 * m * z;
Falpha = (FALPHA_FACTORS(class_idx) * phi_f + 16) / 1000;
Fbeta = (FBETA_FACTORS(class_idx) * b + 4) / 1000;

% Refined deviation allowance λ
lambda = 0.6 * sqrt(Fp^2 + Falpha^2 + Fbeta^2);

%% Space Width Calculations
EVMIN = E;
EVMAX = EVMIN + T;
EMAX = EVMIN + lambda + T;
EMIN = EVMIN + lambda;

%% Tooth Thickness Calculations
SVMAX = S + esv / 1000;
SVMIN = SVMAX - T;
SMAX = SVMAX - lambda;
SMIN = SVMAX - (lambda + T);

%% Effective Clearance
CVMAX = EVMAX - SVMIN;
CVMIN = EVMIN - SVMAX;

%% Diameter Calculations - Internal Spline
[DEIMIN, DIEMAX] = calculateInternalDiameters(m, z, alpha, alpha_rad, rootType);

%% Major Diameter - External Spline
DEEMAX = calculateExternalMajorDiameter(m, z, alpha, alpha_rad, esv);

% Minor diameter external based on module
if m <= 0.75
    DEEMIN = DEEMAX - 10 * id / 1000;
elseif m <= 2
    DEEMIN = DEEMAX - 11 * id / 1000;
else
    DEEMIN = DEEMAX - 12 * id / 1000;
end

%% Form Diameter External
DFEMAX = D + 2 * cf;

%% Minor Diameter Internal
DFIMIN = calculateInternalFormDiameter(m, z, alpha, cf);
DIIMIN = DFIMIN + 2 * cf;

if m <= 0.75
    DIIMAX = DIIMIN + 10 * id / 1000;
elseif m <= 2
    DIIMAX = DIIMIN + 11 * id / 1000;
else
    DIIMAX = DIIMIN + 12 * id / 1000;
end

%% Ball/Pin Diameter for Internal Measurement
DRE = 2 * sqrt((D / 2)^2 - (S / 2)^2);
DRi = 2 * sqrt((D / 2)^2 - (E / 2)^2);
MRI = E + DRE;
MRE = S + DRE;

%% Form Tooth Height (Table 2 values)
hs = getFormToothHeight(alpha, rootType) * m;

%% Create Output Structure
splineData = struct();

% Input parameters
splineData.input.module = m;
splineData.input.teethCount = z;
splineData.input.pressureAngle = alpha;
splineData.input.rootType = rootType;
splineData.input.toleranceClass = toleranceClass;
splineData.input.splineLength = b;
splineData.input.externalDeviation = esv;
splineData.input.formClearance = cf;

% Basic geometry
splineData.geometry.pitchDiameter = D;
splineData.geometry.baseDiameter = DB;
splineData.geometry.circularPitch = P;
splineData.geometry.basePitch = PB;
splineData.geometry.basicSpaceWidth = E;
splineData.geometry.basicToothThickness = S;

% Tolerances
splineData.tolerances.toleranceUnit = id / 1000;
splineData.tolerances.totalTolerance = TLAM;
splineData.tolerances.machiningTolerance = T;
splineData.tolerances.deviationAllowance = lambda;
splineData.tolerances.pitchDeviation = Fp;
splineData.tolerances.profileDeviation = Falpha;
splineData.tolerances.helixDeviation = Fbeta;

% Space widths
splineData.spaceWidth.effectiveMin = EVMIN;
splineData.spaceWidth.effectiveMax = EVMAX;
splineData.spaceWidth.actualMax = EMAX;
splineData.spaceWidth.actualMin = EMIN;

% Tooth thickness
splineData.toothThickness.effectiveMax = SVMAX;
splineData.toothThickness.effectiveMin = SVMIN;
splineData.toothThickness.actualMax = SMAX;
splineData.toothThickness.actualMin = SMIN;

% Clearances
splineData.clearance.effectiveMax = CVMAX;
splineData.clearance.effectiveMin = CVMIN;
splineData.clearance.form = cf;

% Diameters
splineData.diameters.internal.majorMin = DEIMIN;
splineData.diameters.internal.minorMax = DIEMAX;
splineData.diameters.internal.formMin = DFIMIN;
splineData.diameters.internal.minorMin = DIIMIN;
splineData.diameters.internal.minorMax = DIIMAX;
splineData.diameters.external.majorMax = DEEMAX;
splineData.diameters.external.majorMin = DEEMIN;
splineData.diameters.external.formMax = DFEMAX;

% Measurement
splineData.measurement.ballPinDiameterInternal = DRi;
splineData.measurement.ballPinDiameterExternal = DRE;
splineData.measurement.measurementOverRollersInternal = MRI;
splineData.measurement.measurementOverRollersExternal = MRE;

% Form tooth height
splineData.geometry.formToothHeight = hs;

%% Display Results
if verbose
    displayResults(splineData);
end

end

%% Helper Functions
function [DEIMIN, DIEMAX] = calculateInternalDiameters(m, z, alpha, alpha_rad, rootType)
    switch alpha
        case 30
            if strcmp(rootType, 'flat')
                DEIMIN = m * z + 1.5 * m;
                DIEMAX = m * z - 1.5 * m * tan(alpha_rad);
            else % fillet
                DEIMIN = m * z + 1.8 * m;
                DIEMAX = m * z - 1.8 * m * tan(alpha_rad);
            end
        case 37.5
            DEIMIN = m * z + 1.4 * m;
            DIEMAX = m * z - 1.4 * m * tan(alpha_rad);
        case 45
            DEIMIN = m * z + 1.2 * m;
            DIEMAX = m * z - 1.2 * m * tan(alpha_rad);
    end
end

function DEEMAX = calculateExternalMajorDiameter(m, z, alpha, alpha_rad, esv)
    switch alpha
        case 30
            DEEMAX = m * z + esv / 1000 + (1.5 * m) * tan(alpha_rad);
        case 37.5
            DEEMAX = m * z + esv / 1000 + (0.9 * m) * tan(alpha_rad);
        case 45
            DEEMAX = m * z + esv / 1000 + (0.8 * m) * tan(alpha_rad);
    end
end

function DFIMIN = calculateInternalFormDiameter(m, z, alpha, cf)
    switch alpha
        case 30
            DFIMIN = m * z + 1.2 * cf;
        case 37.5
            DFIMIN = m * z + 0.9 * cf + 2;
        case 45
            DFIMIN = m * z + 0.8 * cf + 2;
    end
end

function hs = getFormToothHeight(alpha, rootType)
    % Form tooth height factors from ISO 4156-1:2021 Table 2
    if alpha == 30
        if strcmp(rootType, 'flat')
            hs = 0.6;
        else % fillet
            hs = 0.9;
        end
    elseif alpha == 37.5
        hs = 0.7;
    else % 45°
        hs = 0.6;
    end
end

function displayResults(data)
    fprintf('\n=== ISO 4156-1:2021 Involute Spline Calculator ===\n');
    fprintf('Author: Adil Wahab Bhatti | Version: 2.0\n\n');
    
    % Input parameters
    fprintf('INPUT PARAMETERS:\n');
    fprintf('  Module (m): %.3f mm\n', data.input.module);
    fprintf('  Number of teeth (z): %d\n', data.input.teethCount);
    fprintf('  Pressure angle (α): %.1f°\n', data.input.pressureAngle);
    fprintf('  Root type: %s\n', data.input.rootType);
    fprintf('  Tolerance class: %d\n', data.input.toleranceClass);
    fprintf('  Spline length (b): %.1f mm\n', data.input.splineLength);
    
    % Basic geometry
    fprintf('\nBASIC GEOMETRY:\n');
    fprintf('  Pitch diameter (D): %.6f mm\n', data.geometry.pitchDiameter);
    fprintf('  Base diameter (DB): %.6f mm\n', data.geometry.baseDiameter);
    fprintf('  Circular pitch (P): %.6f mm\n', data.geometry.circularPitch);
    fprintf('  Base pitch (PB): %.6f mm\n', data.geometry.basePitch);
    fprintf('  Form tooth height (hs): %.6f mm\n', data.geometry.formToothHeight);
    
    % Tolerances
    fprintf('\nTOLERANCES:\n');
    fprintf('  Tolerance unit (i): %.6f mm\n', data.tolerances.toleranceUnit);
    fprintf('  Total tolerance (T+λ): %.6f mm\n', data.tolerances.totalTolerance);
    fprintf('  Machining tolerance (T): %.6f mm\n', data.tolerances.machiningTolerance);
    fprintf('  Deviation allowance (λ): %.6f mm\n', data.tolerances.deviationAllowance);
    
    % Space widths and tooth thickness
    fprintf('\nSPACE WIDTHS:\n');
    fprintf('  Basic space width (E): %.6f mm\n', data.geometry.basicSpaceWidth);
    fprintf('  Effective space width: %.6f to %.6f mm\n', ...
            data.spaceWidth.effectiveMin, data.spaceWidth.effectiveMax);
    fprintf('  Actual space width: %.6f to %.6f mm\n', ...
            data.spaceWidth.actualMin, data.spaceWidth.actualMax);
    
    fprintf('\nTOOTH THICKNESS:\n');
    fprintf('  Basic tooth thickness (S): %.6f mm\n', data.geometry.basicToothThickness);
    fprintf('  Effective tooth thickness: %.6f to %.6f mm\n', ...
            data.toothThickness.effectiveMin, data.toothThickness.effectiveMax);
    fprintf('  Actual tooth thickness: %.6f to %.6f mm\n', ...
            data.toothThickness.actualMin, data.toothThickness.actualMax);
    
    % Key diameters
    fprintf('\nKEY DIAMETERS:\n');
    fprintf('  Internal major diameter (min): %.6f mm\n', data.diameters.internal.majorMin);
    fprintf('  External major diameter: %.6f to %.6f mm\n', ...
            data.diameters.external.majorMin, data.diameters.external.majorMax);
    fprintf('  Ball/pin diameter (internal): %.6f mm\n', data.measurement.ballPinDiameterInternal);
    
    fprintf('\n=== Calculation Complete ===\n\n');
end