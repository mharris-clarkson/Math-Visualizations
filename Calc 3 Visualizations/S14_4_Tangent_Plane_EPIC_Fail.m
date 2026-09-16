function S14_2_Tangent_Plane_EPIC_Fail()
%% Shows an extreme case where the tangent plane fails catastrophically.
%  The function f(x,y) = 1 when x=0 or y=0 (the axes), and 0 elsewhere.
%  Both partial derivatives at (0,0) are zero, yet the "tangent plane"
%  z=1 bears no resemblance to the surface.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
zfun = @(x,y) 1.0 * ((x == 0) | (y == 0));

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Tangent Plane EPIC Fail', 1);
hold(app.ax, 'on')
view(app.ax, 3)
title(app.ax, app.fig.Name, 'Interpreter', 'latex')

%% Make the initial plots
% Surface grid (fine near 0 to capture the axis spikes)
xv = [-1:0.01:-0.01, -1e-4, 0, 1e-4, 0.01:0.01:1];
[xg, yg] = meshgrid(xv);
zg = zfun(xg, yg);
surf(app.ax, xg, yg, zg, 'EdgeColor', 'none');
cmocean('balance')
Pretty_Plot(app.ax)

% Base point at origin
plot3(app.ax, 0, 0, 1, 'ko', 'MarkerSize', 12, 'MarkerFaceColor', 'g')

% Axis curves through origin
t   = linspace(-1, 1, 400);
C1  = @(t) [t;   0*t; zfun(t, 0)];
C2  = @(t) [0*t;   t; zfun(0, t)];
C1p = C1(t); C2p = C2(t);
plot3(app.ax, C1p(1,:), C1p(2,:), C1p(3,:), 'r', 'LineWidth', 2)
plot3(app.ax, C2p(1,:), C2p(2,:), C2p(3,:), 'b', 'LineWidth', 2)

% Placeholders for tangent lines and plane
hT1    = plot3(app.ax, nan, nan, nan, 'g', 'LineWidth', 2);
hT2    = plot3(app.ax, nan, nan, nan, 'g', 'LineWidth', 2);
[Xp0, Yp0] = meshgrid(nan(10));
Zp0  = Yp0;
hPlane = surf(app.ax, Xp0, Yp0, Zp0, ...
    'FaceAlpha', 0.5, 'EdgeColor', 'none', 'FaceColor', [0 0.6 0]);

%% Precompute math for updates
% Light weight — skip

%% Build UI
NumControls = 2;

btnTangent = app.addControl('button', 'Show Tangent Lines', 1, NumControls, ...
    @updatePlot, 'ColorChange', true);

btnPlane = app.addControl('button', 'Show Tangent Plane', 2, NumControls, ...
    @updatePlot, 'ColorChange', true);

%% Functions for UI elements
    function fp = diffF(f, t0)
        h  = 1e-8;
        fp = (f(t0+h) - f(t0-h)) / (2*h);
        fp = fp / norm(fp);
    end

%% Main Draw update function.
    function updatePlot(~, ~)
        % Tangent lines (both have zero slope at origin so point along axes)
        if btnTangent.Value
            p1 = diffF(C1, 0);
            p2 = diffF(C2, 0);
            s  = [-1 1];
            set(hT1, 'XData', s*p1(1), 'YData', s*p1(2), 'ZData', s*p1(3) + 1);
            set(hT2, 'XData', s*p2(1), 'YData', s*p2(2), 'ZData', s*p2(3) + 1);
        else
            set([hT1 hT2], 'XData', nan, 'YData', nan, 'ZData', nan)
        end

        % "Tangent plane" at z=1 (the value at the origin)
        if btnPlane.Value
            [xp, yp] = meshgrid([-1 1]);
            set(hPlane, 'XData', xp, 'YData', yp, 'ZData', ones(size(xp)))
        else
            set(hPlane, 'XData', Xp0, 'YData', Yp0, 'ZData', Zp0)
        end
    end
end
