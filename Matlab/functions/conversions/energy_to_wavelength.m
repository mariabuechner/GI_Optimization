function [ wavelength ] = energy_to_wavelength( energy )
%ENERGY_TO_WAVELENGTH Convert energy [keV] to wavelength [um]
%   Input:
%   - energy: in [keV]
%
%   Output:
%   - wavelength: in [um]

% Constants
h=6.626e-34; % Planck's constant [J/s]
c=299792458; % Speed of light [m/s]
eV=1.602e-19; % eV (J)

% Convert
energy = energy*1e3*eV; % [keV -> eV -> J]
wavelength = h*c /(energy); % [m]
wavelength = wavelength*1e6; % [um]
end

