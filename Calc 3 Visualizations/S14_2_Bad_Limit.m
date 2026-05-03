function S14_2_Bad_Limit()
%% Visualizes a path that spirals toward the origin along which the limit
%  of a nasty multivariable function is explored. The slider controls how
%  tightly the spiral winds before reaching (0,0).
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
phiMax0 = 5;   % Initial maximum phi value for spiral
N       = 5000; % Number of points on the spiral

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
% run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Example of a Nasty Limit', 1);
hold(app.ax, 'on')
view(app.ax, 0, 90)
axis(app.ax, 'equal')
xlim(app.ax, [-0.2, 0.2])
ylim(app.ax, [-0.2, 0.2])
title(app.ax, app.fig.Name, 'Interpreter', 'latex')

%% Optional math functions for plot computations
    function [x, y] = spiral_path(phiMax)
        phi   = linspace(1/(2*pi), phiMax, N);
        theta = 1 ./ phi;
        r     = (theta - min(theta)) / (max(theta) - min(theta));
        x     = r .* cos(phi);
        y     = r .* sin(phi);
    end

%% Make the initial plots
% Background color grid
[xg, yg] = meshgrid(-0.2:0.1:0.2);
pcolor(app.ax, xg, yg, 0*xg)
shading(app.ax, 'flat')
colormap(app.ax, winter)

% Origin marker
plot(app.ax, 0, 0, '.r', 'MarkerSize', 20)

% Spiral path handle
[x0, y0] = spiral_path(phiMax0);
hSpiral   = plot(app.ax, x0, y0, 'r', 'LineWidth', 2);

%% Precompute math for updates
% Light weight — skip

%% Build UI
NumControls = 1;

phiSlider = app.addControl('slider', '$\phi = $', 1, NumControls, @updatePlot, ...
    'Default', phiMax0, 'Min', 5, 'Max', 100);

%% Main Draw update function.
    function updatePlot(~, ~)
        [x, y] = spiral_path(phiSlider.Value);
        set(hSpiral, 'XData', x, 'YData', y);
        % Redraw origin marker on top
        plot(app.ax, 0, 0, '.r', 'MarkerSize', 20)
        xlim(app.ax, [-0.2, 0.2])
        ylim(app.ax, [-0.2, 0.2])
    end
end
