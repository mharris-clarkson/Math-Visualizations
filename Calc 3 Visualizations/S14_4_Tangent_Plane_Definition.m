function S14_4_Tangent_Plane_Definition
%% Demonstrates the definition of the tangent plane to a surface z=f(x,y).
%  The surface f(x,y) = -x^2 - y^2 is shown together with two families of
%  curves through the point (0,0,f(0,0)): a "random" pair of curves and
%  the standard x- and y-axis traces. The tangent lines to the active
%  curves and the resulting tangent plane can be toggled on and off.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
% This code was ported from an older format using Claude AI.
%
close all
%% User parameters for math objects.
% Adjust these to modify selected math objects below.
zfun    = @(x,y) -x.^2 - y.^2;
C1_rand = @(t) [t; t.^2; zfun(t, t.^2)];
C2_rand = @(t) [t; t;    zfun(t, t)];
C1_xy   = @(t) [t;   0*t; zfun(t, 0)];
C2_xy   = @(t) [0*t; t;   zfun(0, t)];
%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')
%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Tangent Plane Definition', 1);
view(app.ax, 3)
title(app.ax, app.fig.Name)
%% Make the initial plots
[xg, yg] = meshgrid(-1:0.05:1);
surf(app.ax, xg, yg, zfun(xg, yg), 'EdgeColor', 'none');
colormap(app.ax, Pretty_Colormap('amp'))
Pretty_Plot(app.ax)
plot3(app.ax, 0, 0, zfun(0,0), 'ko', 'MarkerSize', 12, 'MarkerFaceColor', 'g')
t   = linspace(-1, 1, 400);
hC1 = plot3(app.ax, nan, nan, nan, 'r', 'LineWidth', 2);
hC2 = plot3(app.ax, nan, nan, nan, 'b', 'LineWidth', 2);
hT1 = plot3(app.ax, nan, nan, nan, 'g', 'LineWidth', 2);
hT2 = plot3(app.ax, nan, nan, nan, 'g', 'LineWidth', 2);
[Xp0, Yp0] = meshgrid(nan(10));
Zp0    = Yp0;
hPlane = surf(app.ax, Xp0, Yp0, Zp0, ...
    'FaceAlpha', 0.5, 'EdgeColor', 'none', 'FaceColor', [0 0.6 0]);
%% Precompute math for updates
% Tangent lines and plane through (0,0,f(0,0))
z0       = zfun(0,0);
[fx, fy] = Grad_f(zfun, 0, 0);
s        = [-1 1];
T_rand   = {s.*Diff_f_unit(C1_rand, 0), s.*Diff_f_unit(C2_rand, 0)};
T_xy     = {s.*Diff_f_unit(C1_xy, 0),   s.*Diff_f_unit(C2_xy, 0)};
[xp, yp] = meshgrid([-1 1]);
zp       = z0 + fx*xp + fy*yp;
%% Build UI
NumControls  = 4;
btnCurveType = app.addControl('button', '', 1, NumControls, ...
    @updatePlot, 'ColorChange', true, 'Toggle', ["Random curves", "X-Y curves"]);
btnCurve     = app.addControl('button', 'Show Curves', 2, NumControls, ...
    @updatePlot, 'ColorChange', true);
btnTangent   = app.addControl('button', 'Show Tangent Lines', 3, NumControls, ...
    @updatePlot, 'ColorChange', true);
btnPlane     = app.addControl('button', 'Show Tangent Plane', 4, NumControls, ...
    @updatePlot, 'ColorChange', true);
%% Main Draw update function.
    function updatePlot(~, ~)
        if btnCurveType.Value
            C1 = C1_xy;
            C2 = C2_xy;
            Tl = T_xy;
        else
            C1 = C1_rand;
            C2 = C2_rand;
            Tl = T_rand;
        end
        if btnCurve.Value
            C1p = C1(t);
            C2p = C2(t);
            set(hC1, 'XData', C1p(1,:), 'YData', C1p(2,:), 'ZData', C1p(3,:));
            set(hC2, 'XData', C2p(1,:), 'YData', C2p(2,:), 'ZData', C2p(3,:));
        else
            set([hC1 hC2], 'XData', nan, 'YData', nan, 'ZData', nan)
        end
        if btnTangent.Value
            set(hT1, 'XData', Tl{1}(1,:), 'YData', Tl{1}(2,:), 'ZData', z0 + Tl{1}(3,:));
            set(hT2, 'XData', Tl{2}(1,:), 'YData', Tl{2}(2,:), 'ZData', z0 + Tl{2}(3,:));
        else
            set([hT1 hT2], 'XData', nan, 'YData', nan, 'ZData', nan)
        end
        % Tangent plane z = z0 + f_x x + f_y y
        if btnPlane.Value
            set(hPlane, 'XData', xp, 'YData', yp, 'ZData', zp)
        else
            set(hPlane, 'XData', Xp0, 'YData', Yp0, 'ZData', Zp0)
        end
    end
end