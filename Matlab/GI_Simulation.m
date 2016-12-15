%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialize %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all

%% Add necessary path
addpath(genpath(pwd));

%% Input parameters

% GI:
parameters.gi.design_energy     = 30;       % [keV]
parameters.gi.talbot_order      = 3;        % []
parameters.gi.g0                = true;     % [true]
parameters.gi.g1_type           = 'pi';     % ['pi','pi-half']
parameters.gi.geometry          = 'inverse';% ['inverse','symmetric',
                                            %  'conventional']
% phase stepping
parameters.gi.number_steps      = 9;        % []
parameters.gi.number_period     = 1;        % []
% gratings
% choose smallest pitch:
%   p0 for inverse
%   p0, p1 or p2 for symmetric (other set to 0)
%   p2 ??? for conventional
% and fixed distance:
%   g0_g1 for inverse
%   none
%   ??? for conventional
switch parameters.gi.geometry
    case 'inverse'
        parameters.gi.p0        = 3;        % [um]
        parameters.gi.g0_g1     = 250;      % [mm]
    case 'symmetric'
        parameters.gi.p0        = 4;        % [um]
        parameters.gi.p1        = 0;        % [um]
        parameters.gi.p2        = 0;        % [um]
    case 'conventional'
        parameters.gi.p2        = 3;        % [um]
end
% choose one distance, set others to 0
parameters.gi.g0_g1             = 0;        % [mm]
parameters.gi.g0_g2             = 800;      % [mm], total GI length

% Source:
% Size equal to p0/2 if G0 is used
parameters.source.geometry      = 'cone';   % ['cone']
% parameters.source.flux          = 15000;    % [photons/(pixel * s)], sum
%                                             % over spectrum range
%                                             % If [0], keep normaliazed
% parameters.source.flux_range    = [18:35];  % [keV], Energy range of flux 
%                                             % count
spectrum_name                   = 'Mammo70kV.csv';

% Detector:
parameters.detector.pixel_size  = 50;       % [um]

% Physics:
parameters.physics.attenuation  = true;     % [true, false]
parameters.physics.x_resolution = 5e-4;     % [um]
parameters.physics.add_noise    = true;     % [true, false]

%% Complete and convert ;parameters

% GI:
if strcmp(parameters.gi.g1_type,'pi-half')
    parameters.gi.phase_factor = 1;
else
    parameters.gi.phase_factor = 2;
end

% calculate remaining GI parameters
parameters.gi = calculate_gi(parameters.gi);

% Source:
parameters.source.spectrum = read_spectrum(fullfile(pwd,'spectra', ...
                                            spectrum_name));
                                            % Energy [kev] and normalized
                                            % spectrum (photon density 
                                            % distribution)
% % Fit spectrum to flux (if flux not zero)
% if parameters.source.flux
%     parameters.source.spectrum = blabla(parameters.source.spectrum)
% end

% Detector:
parameters.detector.pixel_area  = parameters.detector.pixel_size^2;
                                            % [um^2]
                                            

%%






% "Input" can be either p2 in um or G1-G2 distance in um
% input = 1:0.1:4;
input = 2;
inputP2 = 1;
params.totalSetupLength = 55.6;
% params.fluxNormalizationFactor = photonsPerSpectrum(5)/params.n_phs;
params.fluxNormalizationFactor = parameters.source.spectrum/ ...
                                                    parameters.gi.steps;

