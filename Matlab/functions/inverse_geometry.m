function [gi_output] = inverse_geometry(gi_input)
%CONVENTIONAL_GEOMETRY Summary of this function goes here
%   Input:
%   - gi_input: struct containing all GI parameters necessary to compute
%   the complete set
%       required:   lambda [um],
%                   talbot_order [],
%                   phase_factor [1,2],
%                   p0 [um],
%                   g0_g1 [mm]

% Set default output values
gi_output = gi_input;

% Calculate geometry based on set distance
% G0 to G1 distance is set:
% Calc talbot distance based according to:
% d_n = l^2/(n/2lambda * p0^2 - l)
gi_output.talbot_distance = (gi_output.g0_g1^2)/ ...
    ((gi_output.talbot_order*(gi_output.p0*1e-3)^2)/ ...
    (2*(gi_output.lambda*1e-3)) - gi_output.g0_g1); % [mm]
% Inter-grating distances
gi_output.g1_g2 = gi_output.talbot_distance; % [mm]
gi_output.g0_g2 = gi_output.g0_g1 + gi_output.g1_g2; % [mm]
% Calculate remaining pitches
% p2 = p0 * d_n/l
gi_output.p2 = gi_output.p0*gi_output.g1_g2/gi_output.g0_g2; % [um]
% p1 = ny*p2*l/(l+d_n)
gi_output.p1 = gi_output.phase_factor*gi_output.p2*gi_output.g0_g1/ ...
    (gi_output.g0_g2); % [um]
end