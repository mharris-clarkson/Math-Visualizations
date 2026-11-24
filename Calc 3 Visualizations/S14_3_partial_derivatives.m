function S14_3_partial_derivatives()
%% Visualizes partial derivatives as tangent vectors on a bump surface.
%  Click or drag on the surface to move the base point (x0, y0); the
%  partial derivative arrows (blue: x direction, green: y direction)
%  update live.
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

x0 = 0.4;   % initial base point (off the peak, where both partials are 0)
y0 = 0.3;

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
title(app.ax, {app.fig.Name, 'Click or drag on the surface to move the point'})

%% Optional math functions for plot computations
    % Point on the surface and the unit tangent vectors in the x and y
    % directions there (helpers Diffx_f / Diffy_f give f_x and f_y)
    function [z, vx, vy] = partials_at(x, y)
        z  = f(x, y);
        fx = Diffx_f(f, x, y);
        fy = Diffy_f(f, x, y);

        vx = [1, 0, fx]; vx = vx / norm(vx);
        vy = [0, 1, fy]; vy = vy / norm(vy);
    end

%% Make the initial plots
[X, Y] = meshgrid(-max_val:Delta_val:max_val);
Z = f(X, Y);
surf(app.ax, X, Y, Z)
shading flat
colormap(app.ax, Pretty_Colormap('amp'))
Pretty_Plot(app.ax)
zlim(app.ax, [0, 0.6])   % Pretty_Plot's axis tight resets the zlim set above

% Initial partial derivative arrows (created once, updated in place)
[z0, vx, vy] = partials_at(x0, y0);
% (black / blue / green: red would vanish on the red amp colormap)
hPt = plot3(app.ax, x0, y0, z0, 'ko', 'MarkerSize', 8, 'LineWidth', 2, 'MarkerFaceColor', 'k');
hVx = quiver3(app.ax, x0, y0, z0, vx(1), vx(2), vx(3), ...
    1, 'b', 'LineWidth', 2, 'MaxHeadSize', 0.5);
hVy = quiver3(app.ax, x0, y0, z0, vy(1), vy(2), vy(3), ...
    1, 'Color', [0 0.6 0], 'LineWidth', 2, 'MaxHeadSize', 0.5);

%% Precompute math for updates
% Light weight — skip

%% Dragging: clicks in the axes move the point to the surface under the mouse
Drag_Point_On_Surface(app.ax, f, max_val*[-1 1], max_val*[-1 1], @updatePlot);

%% Build UI
% (no controls: the point is moved by dragging)

%% Main Draw update function.
    % Called by Drag_Point_On_Surface with the new base point (x, y)
    function updatePlot(x, y)
        [z, vx, vy] = partials_at(x, y);
        set(hPt, 'XData', x, 'YData', y, 'ZData', z);
        set(hVx, 'XData', x, 'YData', y, 'ZData', z, ...
            'UData', vx(1), 'VData', vx(2), 'WData', vx(3));
        set(hVy, 'XData', x, 'YData', y, 'ZData', z, ...
            'UData', vy(1), 'VData', vy(2), 'WData', vy(3));
    end
end
