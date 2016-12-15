function [spectrum] = read_spectrum(file_path)
%READ_SPECTRUM Read spectrum .csv file and return energy [keV] and 
%normalized photon density
%   .csv files need to be structured like this:
%   energy,photons
%   7.0,13753450.0
%   8.0,15415480.0
%   9.0,16847820.0
%   10.0,17655110.0
%   ... ,...
%   with energy in [keV]

% Read file
input_spectrum = csvread(file_path,1); % 1 -> skip header
spectrum.energy = input_spectrum(:,1); % [keV]
spectrum.photons = input_spectrum(:,2); % []

% Normalize to 1 (sum(photons) = 1)
spectrum.photons = spectrum.photons/sum(spectrum.photons);

end

