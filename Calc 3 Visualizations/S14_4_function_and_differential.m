function S14_4_function_and_differential()
%% Visualizes a function f(x,y), its tangent plane at a base point
%  (x0, y0) and the total differential
%
%    dz = f_x(x0,y0) dx + f_y(x0,y0) dy
%
%  against the actual change Delta z = f(x0+dx, y0+dy) - f(x0,y0).
%  Click or drag on the surface to move the base point (red); two sliders
%  set the step dx, dy (dashed black legs in the plane z = f(x0,y0)).
%  Above the end of the step, the green segment is dz (the rise along the
%  tangent plane) and the red segment is the error Delta z - dz (the rest
%  of the rise, along the surface). Shrink dx and dy and the error
%  disappears much faster than dz does: that is why dz approximates
%  Delta z.
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

x0   = 1;   % initial base point
y0   = 0.5;
dx0  = 0.8;   % initial step
dy0  = 0.6;
dMax = 1;     % dx, dy sliders run from -dMax to dMax

surfLim = 2;          % surface drawn on [-surfLim, surfLim]^2
dragLim = 1.2;        % base point stays in [-dragLim, dragLim]^2
zLims   = [-2 10];    % fixed vertical range
L       = 2.6;        % side length of the tangent plane patch
nloc    = 2;          % plane grid
nSurf   = 80;         % surface grid resolution
viewAngle = [40, 28]; % [azimuth elevation]

colDz  = [0.10 0.60 0.20];   % dz
colErr = [0.85 0.10 0.10];   % Delta z - dz

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Function $f(x,y)$ and its Differential', 1);

%% Precompute math for updates
[xg, yg] = meshgrid(linspace(-surfLim, surfLim, nSurf));
zg = f(xg, yg);
fx = @(x,y) Diffx_f(f,x,y);
fy = @(x,y) Diffy_f(f,x,y);

%% Optional math functions for plot computations
% Tangent plane at (xc,yc) on a square of side L
    function [xl, yl, zl] = differentialData(xc, yc)
        [xl, yl] = meshgrid(linspace(xc-L/2, xc+L/2, nloc), ...
            linspace(yc-L/2, yc+L/2, nloc));
        zl = f(xc,yc) + fx(xc,yc).*(xl-xc) + fy(xc,yc).*(yl-yc);
    end

%% Make the initial plots
pSurf = surf(app.ax, xg, yg, zg, 'EdgeColor', 'none', 'FaceAlpha', 0.6);
Pretty_Color_Positive(app.ax, zg);
plane = surf(app.ax, NaN(2), NaN(2), NaN(2), ...
    'FaceColor', 'b', 'FaceAlpha', 0.35, 'EdgeColor', 'b');

% Step dx then dy in the plane z = f(x0,y0), and the two rises above its end
hStep = plot3(app.ax, NaN, NaN, NaN, 'k--', 'LineWidth', 2);
hDz   = plot3(app.ax, NaN, NaN, NaN, '-', 'Color', colDz,  'LineWidth', 5);
hErr  = plot3(app.ax, NaN, NaN, NaN, '-', 'Color', colErr, 'LineWidth', 5);
tDx   = text(app.ax, NaN, NaN, NaN, '$dx$', 'FontSize', 18, 'HorizontalAlignment', 'center');
tDy   = text(app.ax, NaN, NaN, NaN, '$dy$', 'FontSize', 18, 'HorizontalAlignment', 'center');

% Base point (on the surface), end point on the surface and on the plane
p0    = plot3(app.ax, NaN, NaN, NaN, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
p1    = plot3(app.ax, NaN, NaN, NaN, 'ko', 'MarkerSize', 7,  'MarkerFaceColor', 'k');
p1pl  = plot3(app.ax, NaN, NaN, NaN, 'o', 'MarkerSize', 7, ...
    'MarkerFaceColor', colDz, 'MarkerEdgeColor', 'k');

legend(app.ax, [pSurf, plane, p0, hDz, hErr], ...
    {'$f(x,y)$', 'tangent plane', 'base point $(x_0,y_0)$', ...
     '$dz = f_x\,dx + f_y\,dy$', 'error $\Delta z - dz$'}, ...
    'Location', 'northwest', 'AutoUpdate', 'off')
Pretty_Plot(app.ax)
view(app.ax, viewAngle(1), viewAngle(2))
xlim(app.ax, surfLim*[-1 1]);  ylim(app.ax, surfLim*[-1 1]);  zlim(app.ax, zLims)

px = x0;  py = y0;   % current base point

%% Build UI: drag the base point, sliders for dx and dy
Drag_Point_On_Surface(app.ax, f, dragLim*[-1 1], dragLim*[-1 1], @movePoint);

NumControls = 2;

dxSlider = app.addControl('slider', '$dx = $', 1, NumControls, @updatePlot, ...
    'Default', dx0, 'Min', -dMax, 'Max', dMax, 'colOrRow', 'row');

dySlider = app.addControl('slider', '$dy = $', 2, NumControls, @updatePlot, ...
    'Default', dy0, 'Min', -dMax, 'Max', dMax, 'colOrRow', 'row');

updatePlot()

%% Functions for UI elements
    function movePoint(x, y)
        px = x;  py = y;
        updatePlot()
    end

%% Main Draw update function.
    function updatePlot(~, ~)
        dx = dxSlider.Value;
        dy = dySlider.Value;
        z0 = f(px, py);
        x1 = px + dx;  y1 = py + dy;

        dz     = fx(px,py)*dx + fy(px,py)*dy;   % rise along the tangent plane
        Deltaz = f(x1, y1) - z0;                % rise along the surface

        set(p0,   'XData', px, 'YData', py, 'ZData', z0)
        set(p1,   'XData', x1, 'YData', y1, 'ZData', z0 + Deltaz)
        set(p1pl, 'XData', x1, 'YData', y1, 'ZData', z0 + dz)

        % Step legs in the plane z = z0: first dx, then dy
        set(hStep, 'XData', [px x1 x1], 'YData', [py py y1], 'ZData', z0*[1 1 1])
        set(tDx, 'Position', [px + dx/2, py, z0])
        set(tDy, 'Position', [x1, py + dy/2, z0])

        % Above the end of the step: dz (green), then the error (red)
        set(hDz,  'XData', [x1 x1], 'YData', [y1 y1], 'ZData', z0 + [0 dz])
        set(hErr, 'XData', [x1 x1], 'YData', [y1 y1], 'ZData', z0 + [dz Deltaz])

        [xl, yl, zl] = differentialData(px, py);
        set(plane, 'XData', xl, 'YData', yl, 'ZData', zl)

        title(app.ax, {sprintf(['$dz = %.3f$ (tangent plane),   $\\Delta z = %.3f$ (surface),' ...
            '   error $= %.3f$'], dz, Deltaz, Deltaz - dz), ...
            'Drag the red point; the sliders set $dx$ and $dy$'})
    end
end
