function S14_3_partial_derivatives()
%% Visualizes partial derivatives as tangent vectors on a bump surface.
%  Two sliders move the base point (x0, y0) across the surface and the
%  partial derivative arrows update live.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
r2  = @(x,y) x.^2 + y.^2;
f   = @(x,y) (r2(x,y) < 1) .* exp(1./(r2(x,y) - 1));

max_val   = 1.4;
Delta_val = 0.05;

x0 = 0;
y0 = 0;

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Partial Derivatives', 1);
hold(app.ax, 'on')
view(app.ax, -16, 47)
xlim(app.ax, max_val*[-1, 1])
ylim(app.ax, max_val*[-1, 1])
zlim(app.ax, [0, 0.6])
title(app.ax, app.fig.Name, 'Interpreter', 'latex')

%% Optional math functions for plot computations
    function [hPt, hVx, hVy] = plot_partials(x, y)
        z  = f(x, y);
        h  = 1e-5;
        fx = (f(x+h,y) - f(x-h,y)) / (2*h);
        fy = (f(x,y+h) - f(x,y-h)) / (2*h);

        vx = [1, 0, fx]; vx = vx / norm(vx);
        vy = [0, 1, fy]; vy = vy / norm(vy);

        hPt = plot3(app.ax, x, y, z, 'ro', 'MarkerSize', 8, 'LineWidth', 2);
        hVx = quiver3(app.ax, x, y, z, vx(1), vx(2), vx(3), ...
            1, 'r', 'LineWidth', 2, 'MaxHeadSize', 0.5);
        hVy = quiver3(app.ax, x, y, z, vy(1), vy(2), vy(3), ...
            1, 'm', 'LineWidth', 2, 'MaxHeadSize', 0.5);
    end

%% Make the initial plots
[X, Y] = meshgrid(-max_val:Delta_val:max_val);
Z = f(X, Y);
surf(app.ax, X, Y, Z)
colormap(app.ax, winter)
Pretty_Plot(app.ax)

% Initial partial derivative arrows
[hPt, hVx, hVy] = plot_partials(x0, y0);

%% Precompute math for updates
% Light weight — skip

%% Build UI
NumControls = 2;

xSlider = app.addControl('slider', '$x_0 = $', 1, NumControls, @updatePlot, ...
    'Default', x0, 'Min', -max_val, 'Max', max_val);

ySlider = app.addControl('slider', '$y_0 = $', 2, NumControls, @updatePlot, ...
    'Default', y0, 'Min', -max_val, 'Max', max_val);

%% Main Draw update function.
    function updatePlot(~, ~)
        delete(hPt); delete(hVx); delete(hVy);
        [hPt, hVx, hVy] = plot_partials(xSlider.Value, ySlider.Value);
        zlim(app.ax, [0, 0.6])
    end
end
