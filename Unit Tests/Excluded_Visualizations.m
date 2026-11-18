function [names, reasons] = Excluded_Visualizations()
%% Scripts the automatic test skips on purpose, with the reason for each
% These files are still found and listed by the test, but instead of
% being run they are reported as "skipped" with the reason below, so the
% results show that they would normally have been run.
%
% Add a file: put its name in names and a short reason in reasons.
% Force one to run anyway:
%   Exercise_Visualization(p, 'IgnoreExclusions', true)
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.

list = {
    'Run_KHI_Sim.m',                      'Long fluid simulation (several minutes; writes KH_data.mat)'
    'S16_5_Divergence.m',                 'Infinite animation loop (runs until the window is closed)'
    'S16_5_Curl.m',                       'Requires an interaction with mouseMove'
    'Fourier_Series_RealtimeWaterfall.m', 'Infinite animation loop (runs until the window is closed)'
    'Fourier_Application.m',              'Has forced pauses'
    'Callabrate_FFT.m',                   'No visual aspects (makes sound)'
    };

names   = string(list(:, 1));
reasons = string(list(:, 2));
end
