function S14_4_Tangent_Plane_Fails()
%% Shows that partial derivatives can exist at a point (0,0) yet the
%  tangent plane still fails to describe the surface, because the function
%  f(x,y) = x^2*y/(x^2+y^2) is not differentiable at the origin.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
zfun = @(x,y) x.^2 .* y ./ (x.^2 + y.^2);

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Tangent Plane Fails: $z = x^2y/(x^2+y^2)$', 1);
view(app.ax, 3)
title(app.ax, app.fig.Name)

%% Make the initial plots
[xg, yg] = meshgrid(-1:0.01:1);
zg = zfun(xg, yg);
zg(isnan(zg)) = 0;
surf(app.ax, xg, yg, zg, 'EdgeColor', 'none');
Pretty_Plot(app.ax)
Pretty_Color_Centered(app.ax, zg, 'colorbar', 'off')

plot3(app.ax, 0, 0, 0, 'ko', 'MarkerSize', 12, 'MarkerFaceColor', 'g')

% Traces along the x and y axes
t   = linspace(-1, 1, 400);
C1  = @(t) [t;   0*t; zfun(t, 0)];
C2  = @(t) [0*t;   t; zfun(0, t)];
C1p = C1(t); C2p = C2(t);
plot3(app.ax, C1p(1,:), C1p(2,:), C1p(3,:), 'r', 'LineWidth', 2)
plot3(app.ax, C2p(1,:), C2p(2,:), C2p(3,:), 'b', 'LineWidth', 2)

hT1 = plot3(app.ax, nan, nan, nan, 'g', 'LineWidth', 2);
hT2 = plot3(app.ax, nan, nan, nan, 'g', 'LineWidth', 2);
[Xp0, Yp0] = meshgrid(nan(10));
Zp0 = Yp0;
hPlane = surf(app.ax, Xp0, Yp0, Zp0, ...
    'FaceAlpha', 0.5, 'EdgeColor', 'none', 'FaceColor', [0 0.6 0]);

%% Precompute math for updates
s  = [-1 1];
p1 = s.*Diff_f_unit(C1, 0);
p2 = s.*Diff_f_unit(C2, 0);
% fx = fy = 0 at the origin, so the tangent plane is z = 0
[xp, yp] = meshgrid([-1 1]);

%% Build UI
NumControls = 2;

btnTangent = app.addControl('button', 'Show Tangent Lines', 1, NumControls, ...
    @updatePlot, 'ColorChange', true);

btnPlane = app.addControl('button', 'Show Tangent Plane', 2, NumControls, ...
    @updatePlot, 'ColorChange', true);

%% Main Draw update function.
    function updatePlot(~, ~)
        if btnTangent.Value
            set(hT1, 'XData', p1(1,:), 'YData', p1(2,:), 'ZData', p1(3,:));
            set(hT2, 'XData', p2(1,:), 'YData', p2(2,:), 'ZData', p2(3,:));
        else
            set([hT1 hT2], 'XData', nan, 'YData', nan, 'ZData', nan)
        end

        if btnPlane.Value
            set(hPlane, 'XData', xp, 'YData', yp, 'ZData', zeros(size(xp)))
        else
            set(hPlane, 'XData', Xp0, 'YData', Yp0, 'ZData', Zp0)
        end
    end
end
