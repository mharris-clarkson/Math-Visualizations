function S14_7_extrama()
%% Visualizes all local maxima and minima of the peaks function using
%  neighborhood filtering. Red markers show local maxima, cyan markers
%  show local minima.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
resolution  = 400;   % grid resolution for peaks function
nhood       = true(3); % 3x3 neighborhood for local extrema detection

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Peaks Function: Local Maxima and Minima', 1);
view(app.ax, 3)

%% Precompute math for updates
[x, y, z] = peaks(resolution);

localMax = z == ordfilt2(z, 9, nhood);
localMin = z == ordfilt2(z, 1, nhood);

%% Make the initial plots
surf(app.ax, x, y, z)
shading(app.ax, 'interp')
Pretty_Color_Centered(app.ax,7*[-1,1])
hold(app.ax, 'on')
plot3(app.ax, x(localMax), y(localMax), z(localMax), ...
    'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 8)
plot3(app.ax, x(localMin), y(localMin), z(localMin), ...
    'ko', 'MarkerFaceColor', 'c', 'MarkerSize', 8)
hold(app.ax, 'off')

legend(app.ax, 'Surface', 'Local Maxima', 'Local Minima', ...
    'Interpreter', 'latex', 'Location', 'northeast')
Pretty_Plot(app.ax)
title(app.ax, 'Peaks Function with Local Maxima (red) and Minima (cyan)', ...
    'Interpreter', 'latex')

%% Build UI
% Static visualization — no controls needed

%% Main Draw update function.
% Static — no updates required.
end