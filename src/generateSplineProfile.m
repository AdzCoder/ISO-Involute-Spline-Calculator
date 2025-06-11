function [profiles, splineData] = generateSplineProfile(varargin)
%GENERATESPLINEPROFILE Generate involute spline tooth profiles
%
% DESCRIPTION:
%   Generates parametric involute spline tooth profiles for both internal 
%   and external splines according to ISO 4156-1:2021 standard.
%
% SYNTAX:
%   [profiles, splineData] = generateSplineProfile()
%   [profiles, splineData] = generateSplineProfile('Parameter', Value, ...)
%
% PARAMETERS:
%   All parameters from calculateInvoluteSpline() plus:
%   'ProfilePoints'  - Number of points per involute curve (default: 100)
%   'PlotProfile'    - Generate plots (default: true)
%   'ExportDXF'      - Export DXF file (default: false)
%   'Filename'       - Base filename for exports (default: 'spline_profile')
%
% OUTPUT:
%   profiles   - Structure containing profile coordinates
%   splineData - Complete spline calculation data
%
% EXAMPLE:
%   % Generate and plot default spline profile
%   [profiles, data] = generateSplineProfile();
%
%   % Custom spline with high resolution
%   [profiles, data] = generateSplineProfile('Module', 3, 'TeethCount', 16, ...
%                                           'ProfilePoints', 200, 'PlotProfile', true);
%
% AUTHOR: Adil Wahab Bhatti
% VERSION: 2.0
% DATE: 2025

%% Input Parsing
p = inputParser;

% Inherit all parameters from calculateInvoluteSpline
addParameter(p, 'Module', 2, @(x) isnumeric(x) && x > 0);
addParameter(p, 'TeethCount', 20, @(x) isnumeric(x) && x > 0 && mod(x,1) == 0);
addParameter(p, 'PressureAngle', 30, @(x) ismember(x, [30, 37.5, 45]));
addParameter(p, 'RootType', 'flat', @(x) ismember(x, {'flat', 'fillet'}));
addParameter(p, 'ToleranceClass', 5, @(x) ismember(x, [4, 5, 6, 7]));
addParameter(p, 'SplineLength', 50, @(x) isnumeric(x) && x > 0);
addParameter(p, 'ExternalDev', 0, @isnumeric);
addParameter(p, 'FormClearance', 0.1, @(x) isnumeric(x) && x > 0);
addParameter(p, 'Verbose', false, @islogical);

% Profile generation specific parameters
addParameter(p, 'ProfilePoints', 100, @(x) isnumeric(x) && x > 10);
addParameter(p, 'PlotProfile', true, @islogical);
addParameter(p, 'ExportDXF', false, @islogical);
addParameter(p, 'Filename', 'spline_profile', @ischar);

parse(p, varargin{:});

%% Calculate Spline Data
splineData = calculateInvoluteSpline('Module', p.Results.Module, ...
                                   'TeethCount', p.Results.TeethCount, ...
                                   'PressureAngle', p.Results.PressureAngle, ...
                                   'RootType', p.Results.RootType, ...
                                   'ToleranceClass', p.Results.ToleranceClass, ...
                                   'SplineLength', p.Results.SplineLength, ...
                                   'ExternalDev', p.Results.ExternalDev, ...
                                   'FormClearance', p.Results.FormClearance, ...
                                   'Verbose', p.Results.Verbose);

%% Extract Key Parameters
m = splineData.input.module;
z = splineData.input.teethCount;
alpha_rad = deg2rad(splineData.input.pressureAngle);
rootType = splineData.input.rootType;

D = splineData.geometry.pitchDiameter;
DB = splineData.geometry.baseDiameter;
rb = DB / 2;  % Base radius

nPoints = p.Results.ProfilePoints;

%% Generate Involute Profiles
profiles = struct();

% Angular parameters
tooth_angle = 2 * pi / z;           % Angular width of one tooth
half_tooth_angle = tooth_angle / 2;

% Pressure angle at pitch circle
inv_alpha = tan(alpha_rad) - alpha_rad;  % Involute function

%% External Spline Profile
% Major and minor radii for external spline
Ra_ext = splineData.diameters.external.majorMax / 2;
Rf_ext = splineData.diameters.external.formMax / 2;

% Generate external involute profile
[x_ext, y_ext] = generateInvoluteProfile(rb, Ra_ext, Rf_ext, inv_alpha, ...
                                        half_tooth_angle, nPoints, 'external', rootType);

%% Internal Spline Profile  
% Major and minor radii for internal spline
Ra_int = splineData.diameters.internal.majorMin / 2;
Rf_int = splineData.diameters.internal.formMin / 2;

% Generate internal involute profile
[x_int, y_int] = generateInvoluteProfile(rb, Ra_int, Rf_int, inv_alpha, ...
                                        half_tooth_angle, nPoints, 'internal', rootType);

%% Create Complete Tooth Profiles
% External spline - create full tooth by mirroring
x_ext_tooth = [x_ext, flip(x_ext)];
y_ext_tooth = [y_ext, -flip(y_ext)];

% Internal spline - create full space by mirroring  
x_int_tooth = [x_int, flip(x_int)];
y_int_tooth = [y_int, -flip(y_int)];

%% Store Profile Data
profiles.external.single_side.x = x_ext;
profiles.external.single_side.y = y_ext;
profiles.external.full_tooth.x = x_ext_tooth;
profiles.external.full_tooth.y = y_ext_tooth;

profiles.internal.single_side.x = x_int;
profiles.internal.single_side.y = y_int;
profiles.internal.full_space.x = x_int_tooth;
profiles.internal.full_space.y = y_int_tooth;

% Key radii
profiles.radii.base = rb;
profiles.radii.pitch = D / 2;
profiles.radii.external_major = Ra_ext;
profiles.radii.external_form = Rf_ext;
profiles.radii.internal_major = Ra_int;
profiles.radii.internal_form = Rf_int;

%% Generate Complete Spline Profiles
if z <= 50  % Only generate full profiles for reasonable tooth counts
    profiles.external.complete = generateCompleteProfile(x_ext_tooth, y_ext_tooth, z);
    profiles.internal.complete = generateCompleteProfile(x_int_tooth, y_int_tooth, z);
end

%% Plot Profiles
if p.Results.PlotProfile
    plotSplineProfiles(profiles, splineData);
end

%% Export DXF (placeholder - would need DXF export library)
if p.Results.ExportDXF
    fprintf('DXF export functionality requires additional DXF library.\n');
    fprintf('Profile coordinates saved to workspace variables.\n');
end

end

%% Helper Functions
function [x, y] = generateInvoluteProfile(rb, Ra, Rf, inv_alpha, half_tooth_angle, nPoints, type, rootType)
    % Generate involute curve from base circle to addendum
    
    % Pressure angle at addendum
    if strcmp(type, 'external')
        alpha_a = acos(rb / Ra);
    else
        alpha_a = acos(rb / Ra);  % For internal, Ra is actually minimum
    end
    
    % Involute parameter range
    u_max = sqrt((Ra/rb)^2 - 1);
    u = linspace(0, u_max, nPoints);
    
    % Involute coordinates in tooth coordinate system
    x_inv = rb * (cos(u) + u .* sin(u));
    y_inv = rb * (sin(u) - u .* cos(u));
    
    % Rotate to center the tooth on y-axis
    if strcmp(type, 'external')
        theta_offset = half_tooth_angle - inv_alpha;
    else
        theta_offset = -(half_tooth_angle - inv_alpha);  % Internal is inverted
    end
    
    % Apply rotation
    cos_offset = cos(theta_offset);
    sin_offset = sin(theta_offset);
    
    x = x_inv * cos_offset - y_inv * sin_offset;
    y = x_inv * sin_offset + y_inv * cos_offset;
    
    % Add root section
    if strcmp(rootType, 'fillet')
        % Add fillet at root (simplified)
        root_radius = Rf;
        if strcmp(type, 'external')
            x = [root_radius * cos(theta_offset), x];
            y = [root_radius * sin(theta_offset), y];
        else
            x = [x, root_radius * cos(theta_offset)];
            y = [y, root_radius * sin(theta_offset)];
        end
    else
        % Flat root
        if strcmp(type, 'external')
            x = [Rf * cos(theta_offset), x];
            y = [Rf * sin(theta_offset), y];
        else
            x = [x, Rf * cos(theta_offset)];
            y = [y, Rf * sin(theta_offset)];
        end
    end
end

function complete_profile = generateCompleteProfile(x_tooth, y_tooth, z)
    % Generate complete spline by rotating single tooth
    complete_profile.x = [];
    complete_profile.y = [];
    
    tooth_angle = 2 * pi / z;
    
    for i = 0:(z-1)
        angle = i * tooth_angle;
        cos_angle = cos(angle);
        sin_angle = sin(angle);
        
        % Rotate tooth
        x_rot = x_tooth * cos_angle - y_tooth * sin_angle;
        y_rot = x_tooth * sin_angle + y_tooth * cos_angle;
        
        complete_profile.x = [complete_profile.x, x_rot];
        complete_profile.y = [complete_profile.y, y_rot];
    end
end

function plotSplineProfiles(profiles, splineData)
    % Create comprehensive plots of spline profiles
    
    figure('Name', 'ISO 4156-1:2021 Involute Spline Profiles', 'Position', [100, 100, 1200, 800]);
    
    % Single tooth comparison
    subplot(2, 2, 1);
    plot(profiles.external.full_tooth.x, profiles.external.full_tooth.y, 'b-', 'LineWidth', 2);
    hold on;
    plot(profiles.internal.full_space.x, profiles.internal.full_space.y, 'r-', 'LineWidth', 2);
    
    % Add reference circles
    theta = linspace(0, 2*pi, 100);
    plot(profiles.radii.pitch * cos(theta), profiles.radii.pitch * sin(theta), 'k--', 'LineWidth', 1);
    plot(profiles.radii.base * cos(theta), profiles.radii.base * sin(theta), 'g--', 'LineWidth', 1);
    
    axis equal;
    grid on;
    legend('External Tooth', 'Internal Space', 'Pitch Circle', 'Base Circle', 'Location', 'best');
    title('Single Tooth Profile Comparison');
    xlabel('X (mm)');
    ylabel('Y (mm)');
    
    % External spline detail
    subplot(2, 2, 2);
    plot(profiles.external.full_tooth.x, profiles.external.full_tooth.y, 'b-', 'LineWidth', 2);
    hold on;
    plot(profiles.radii.pitch * cos(theta), profiles.radii.pitch * sin(theta), 'k--');
    plot(profiles.radii.external_major * cos(theta), profiles.radii.external_major * sin(theta), 'r--');
    axis equal;
    grid on;
    title('External Spline Tooth');
    xlabel('X (mm)');
    ylabel('Y (mm)');
    legend('Tooth Profile', 'Pitch Circle', 'Major Circle', 'Location', 'best');
    
    % Internal spline detail
    subplot(2, 2, 3);
    plot(profiles.internal.full_space.x, profiles.internal.full_space.y, 'r-', 'LineWidth', 2);
    hold on;
    plot(profiles.radii.pitch * cos(theta), profiles.radii.pitch * sin(theta), 'k--');
    plot(profiles.radii.internal_major * cos(theta), profiles.radii.internal_major * sin(theta), 'b--');
    axis equal;
    grid on;
    title('Internal Spline Space');
    xlabel('X (mm)');
    ylabel('Y (mm)');
    legend('Space Profile', 'Pitch Circle', 'Major Circle', 'Location', 'best');
    
    % Complete spline (if available)
    subplot(2, 2, 4);
    if isfield(profiles, 'external') && isfield(profiles.external, 'complete')
        plot(profiles.external.complete.x, profiles.external.complete.y, 'b-', 'LineWidth', 1);
        hold on;
        if isfield(profiles.internal, 'complete')
            plot(profiles.internal.complete.x, profiles.internal.complete.y, 'r-', 'LineWidth', 1);
        end
        plot(profiles.radii.pitch * cos(theta), profiles.radii.pitch * sin(theta), 'k--');
        legend('External Spline', 'Internal Spline', 'Pitch Circle', 'Location', 'best');
        title(sprintf('Complete Spline (z=%d)', splineData.input.teethCount));
    else
        text(0.5, 0.5, 'Complete profile not generated\n(tooth count too high)', ...
             'HorizontalAlignment', 'center', 'Units', 'normalized');
        title('Complete Spline Profile');
    end
    axis equal;
    grid on;
    xlabel('X (mm)');
    ylabel('Y (mm)');
    
    % Add overall title with parameters
    sgtitle(sprintf('Module: %.1f mm | Teeth: %d | Pressure Angle: %.1f° | Class: %d', ...
                   splineData.input.module, splineData.input.teethCount, ...
                   splineData.input.pressureAngle, splineData.input.toleranceClass));
end
