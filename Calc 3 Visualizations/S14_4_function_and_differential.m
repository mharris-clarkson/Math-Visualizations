function S14_4_function_and_differential()
%% Visualizes a function f(x,y) and its total differential (tangent plane)
%  at a moveable base point (x0, y0). Two sliders control the point
%  position and the tangent plane updates live.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
f  = @(x,y) x.^2 + 0.5*y.^2 + x.*y;

x0   = 0;     % initial base point
y0   = 0;
L    = 2;     % side length of local tangent plane domain
nloc = 30;    % tangent plane grid resolution

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Function $f(x,y)$ and its Differential', 1);
view(app.ax, 3)

%% Precompute math for updates
[xg, yg] = meshgrid(linspace(-3, 3, 120));
zg = f(xg, yg);
fx = @(x,y) Diffx_f(f,x,y);
fy = @(x,y) Diffy_f(f,x,y);

%% Make the initial plots
pSurf = surf(app.ax, xg, yg, zg, 'EdgeColor', 'none', 'FaceAlpha', 0.6);
Pretty_Color_Positive(app.ax,zg)
p0    = plot3(app.ax, x0, y0, f(x0,y0), 'ro', ...
    'MarkerSize', 8, 'MarkerFaceColor', 'r');
plane = drawDifferential(x0, y0);
legend(app.ax, [pSurf, p0, plane], ...
    {'$f(x,y)$', 'Point $(x_0,y_0)$', 'Differential $dz$'}, ...
    'Interpreter', 'latex', 'Location', 'northwest')
Pretty_Plot(app.ax)
title(app.ax, 'Function $f(x,y)$ and its Differential (Tangent Plane)', ...
    'Interpreter', 'latex')

%% Optional math functions for plot computations
    function h = drawDifferential(xc, yc)
        [xl, yl] = meshgrid(linspace(xc-L/2, xc+L/2, nloc), ...
            linspace(yc-L/2, yc+L/2, nloc));
        zl = fx(xc,yc).*(xl-xc) + fy(xc,yc).*(yl-yc);
        h  = surf(app.ax, xl, yl, zl, ...
            'FaceColor', 'b', 'FaceAlpha', 0.5, 'EdgeColor', 'none');
    end

%% Build UI
NumControls = 2;

xSlider = app.addControl('slider', '$x_0 = $', 1, NumControls, @updatePlot, ...
    'Default', x0, 'Min', -2, 'Max', 2, 'colOrRow', 'row');

ySlider = app.addControl('slider', '$y_0 = $', 2, NumControls, @updatePlot, ...
    'Default', y0, 'Min', -2, 'Max', 2, 'colOrRow', 'row');

%% Main Draw update function.
    function updatePlot(~, ~)
        x0 = xSlider.Value;
        y0 = ySlider.Value;

        set(p0, 'XData', x0, 'YData', y0, 'ZData', f(x0, y0))

        delete(plane)
        plane = drawDifferential(x0, y0);

        legend(app.ax, [pSurf, p0, plane], ...
            {'$f(x,y)$', 'Point $(x_0,y_0)$', 'Differential $dz$'}, ...
            'Interpreter', 'latex', 'Location', 'northwest')
    end
end