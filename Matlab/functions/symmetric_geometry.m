function [gi_output] = symmetric_geometry(gi_input)
%CONVENTIONAL_GEOMETRY Summary of this function goes here
%   Input:
%   - gi_input: struct containing all GI parameters necessary to compute
%   the complete set
%       required:   lambda [um],
%                   talbot_order [],
%                   phase_factor [1,2],
%                   p0, p1 or p2 [um],

% Set default output values
gi_output = gi_input;

% Calculate missing pitches
if gi_output.p0
    % p0 is set
    gi_output.p2 = gi_output.p0; % [um]
    gi_output.p1 = gi_output.phase_factor*gi_output.p2/2;  % [um]
elseif gi_output.p1
    % p1 is set
    gi_output.p2 = 2*gi_output.p/gi_output.phase_factor; % [um]
    gi_output.p0 = gi_output.p2; % [um]
else
    % p2 is set
    gi_output.p0 = gi_output.p2; % [um]
    gi_output.p1 = gi_output.phase_factor*gi_output.p2/2;  % [um]
end
% Calculate distances
% Talbot
gi_output.talbot_distance = 2*gi_output.talbot_order*gi_output.p1^2/ ...
    (gi_output.phase_factor^2 * 2*gi_output.lambda); % [um]
gi_output.talbot_distance = gi_output.talbot_distance*1e-3; % [mm]
% Intergrating
gi_output.g0_g2 = 2*gi_output.talbot_distance; % [mm]
gi_output.g0_g1 = gi_output.g0_g2/2; % [mm]
gi_output.g1_g2 = gi_output.g0_g1; % [mm]
end