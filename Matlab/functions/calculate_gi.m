function [ gi_output ] = calculate_gi(gi_input, source_input)
%CALCULATE_GI Calculate all grating interferometer parameters based on
%minimal input parameters
%   Input:
%   - gi_input: struct containing all GI parameters necessary to compute
%   the complete set
%       required:   design_energy [keV],
%                   talbot_order [],
%                   g0 [true/false],
%                   g1_type ['pi','pi-half'],
%                   geometry ['inverse','symmetric','conventional']
%                   one of p0, p1 or p2 [um],
%                   one of g0_g1 or g0_g2 [mm]
%
%   - source_input: struct containing source information
%       required:   geometry ['cone', 'parallel']
%
%   Output:
%   - gi_output: struct containing all GI parameters
%       struct:
%           gi_output.design_energy
%                    .talbot_order
%                    .g0
%                    .g1_type
%                    .p1
%                    .p2
%                    .p3
%                    .g0_g1
%                    .g1_g2
%                    .g0_g2
%                    .
%                    .
%

% Set default output values
gi_output = gi_input;

% Design wavelength
gi_output.lambda = energy_to_wavelength(input_gi.design_energy);

% Calculate parameters based on geometry
switch gi_input.geometry
    case 'inverse'
        gi_output = inverse_geometry(gi_output);
    case 'symmetric'
        gi_output = symmetric_geometry(gi_output);
    case 'conventional'
        gi_output = conventional_geometry(gi_output);
end

end

