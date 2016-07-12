%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialize %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all

%% Add necessary path
addpath(genpath(pwd));

%% Input parameters

% GI:
parameters.gi.design_energy     = 30;       % [keV]
parameters.gi.talbot_order      = 3;        % []
parameters.gi.g0                = true;     % [true, false]
parameters.gi.g1_type           = 'pi';     % ['pi','pi-half']
% phase stepping
parameters.gi.number_steps      = 9;        % []
parameters.gi.number_period     = 1;        % []
% gratings
% choose one pitch, set 0 others
parameters.gi.p0                = 3;        % [um]
parameters.gi.p1                = 0;        % [um]
parameters.gi.p2                = 0;        % [um]
% choose one distance, set 0 others
parameters.gi.g0_g1             = 0;        % [cm]
parameters.gi.g1_g2             = 0;        % [cm]
parameters.gi.g0_g2             = 80;       % [cm], total GI length

% Source:
parameters.source.geometry      = 'cone';   % ['cone', 'parallel']
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
parameters.gi.g0_g1 = parameters.gi.g0_g1*1e4;  % [um]
parameters.gi.g1_g2 = parameters.gi.g1_g2*1e4;  % [um]
parameters.gi.g0_g2 = parameters.gi.g0_g2*1e4;  % [um]
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

