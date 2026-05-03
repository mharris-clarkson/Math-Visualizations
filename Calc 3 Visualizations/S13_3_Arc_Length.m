function S13_3_Arc_Length()
%% Shows how the arc length in 3D is defined by approximating a smooth
%  curve with a polygonal chain.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
x = @(t) cos(t);
y = @(t) sin(t);
z = @(t) t/(2*pi);
tlims   = [0 4*pi];
nPoints0 = 2;

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('3D Arc Length Approximation', 1);
view(app.ax, 3)
title(app.ax, app.fig.Name, 'Interpreter', 'latex')

%% Optional math functions for plot computations
    function [L] = update_poly(nPts)
        % Delete old approximation handles and redraw
        delete(findall(app.ax, 'Tag', 'polyH'));
        delete(findall(app.ax, 'Tag', 'ptsH'));
        t = linspace(tlims(1), tlims(2), nPts);
        X = x(t); Y = y(t); Z = z(t);
        plot3(app.ax, X, Y, Z, 'r-o', 'LineWidth', 2, ...
            'MarkerFaceColor', 'r', 'Tag', 'polyH');
        plot3(app.ax, X, Y, Z, 'ko', 'MarkerFaceColor', 'y', ...
            'MarkerSize', 6, 'Tag', 'ptsH');
        L = sum(sqrt(diff(X).^2 + diff(Y).^2 + diff(Z).^2));
    end

%% Make the initial plots
% Smooth reference curve
tFine = linspace(tlims(1), tlims(2), 500);
plot3(app.ax, x(tFine), y(tFine), z(tFine), 'b', 'LineWidth', 2);

% Precompute exact arc length
L_exact = arc_length(x, y, z, tlims);

% Initial polygonal approximation
L_poly = update_poly(nPoints0);

title(app.ax, sprintf([app.fig.Name '. Arc Length $= %.5f$,  Approx $= %.5f$'], ...
    L_exact, L_poly), 'Interpreter', 'latex')

%% Precompute math for updates
% Light weight — skip

%% Build UI
NumControls = 1;

nSlider = app.addControl('slider', '$n = $', 1, NumControls, @updatePlot, ...
    'Default', nPoints0, 'Min', 2, 'Max', 100, 'Number_format', '%d');

%% Main Draw update function.
    function updatePlot(~, ~)
        nPts   = round(nSlider.Value);
        L_poly = update_poly(nPts);
        title(app.ax, sprintf('Arc Length $= %.5f$,  Approx $= %.5f$', ...
            L_exact, L_poly), 'Interpreter', 'latex')
    end
end
