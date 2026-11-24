function S14_6_Directional_Derivative()
%% Demonstrates the directional derivative of a bump function at a point
%  (x,y). Click or drag on the surface to move the point, and use the
%  slider to rotate the evaluation direction (as an angle theta away from
%  the gradient direction). The blue arrow is (u_1, u_2, D_u f) for the
%  unit direction u, so it is tangent to the surface and its z-component is
%  the directional derivative D_u f = |grad f| cos(theta). Where
%  grad f = 0, theta is measured from the x-axis instead.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all
%% User parameters for math objects.
% Adjust these to modify selected math objects below.
r2 = @(x,y) x.^2 + y.^2;
f  = @(x,y) (r2(x,y) < 1) .* exp(1./(r2(x,y) - 1));  % smooth bump function

x0     = -.1;   % initial x (on the side of the bump, where grad f is not 0)
y0     = -0.5;   % initial y
theta0 = 0;     % initial rotation angle (rad) away from the gradient

max_val   = 1.4;   % domain is -max_val <= x, y <= max_val
Delta_val = 0.05;  % grid spacing for the surface mesh
%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')
%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Directional Derivatives on Surface', 1);
view(app.ax, -16, 47)
xlim(app.ax, max_val*[-1, 1])
ylim(app.ax, max_val*[-1, 1])
zlim(app.ax, [0, 0.6])
%% Optional math functions for plot computations
    function redraw(x, y, theta)
        z    = f(x,y);
        grad = Grad_f(f, [x; y]);
        % Unit direction u: the gradient direction rotated by theta. (The
        % old code used the rotated gradient itself, which is not a unit
        % vector, so the title showed |grad f|^2 cos(theta) as D_u f.)
        if norm(grad) > 1e-12
            ghat = grad / norm(grad);
        else
            ghat = [1; 0];          % grad f = 0: measure theta from the x-axis
        end
        R  = [cos(theta) -sin(theta); sin(theta) cos(theta)];
        u  = R*ghat;                                % unit direction
        Du = grad(1)*u(1) + grad(2)*u(2);           % D_u f = grad f . u = |grad f| cos(theta)
        set(hPt,  'XData', x, 'YData', y, 'ZData', z);
        set(hVec, 'XData', x, 'YData', y, 'ZData', z, ...
            'UData', u(1), 'VData', u(2), 'WData', Du);
        title(app.ax, {sprintf('Directional Derivative at $(%.2f,%.2f)$, $\\theta=%s$: $D_{u}f = %.4f$', ...
            x, y, Pi_Label(theta, 'Dollars', false), Du), ...
            'Click or drag on the surface to move the point'})
    end

%% Make the initial plots
[X, Y] = meshgrid(-max_val:Delta_val:max_val);
Z = f(X, Y);
surf(app.ax, X, Y, Z, 'EdgeColor', 'none')
colormap(app.ax, Pretty_Colormap('amp'))   % (redraw used to reapply this on every move)
contour3(app.ax, X, Y, Z, 20, 'k', 'LineWidth', 1)
Pretty_Plot(app.ax)
zlim(app.ax, [0, 0.6])

% Point and direction arrow: created once, updated in place by redraw()
hPt  = plot3(app.ax, NaN, NaN, NaN, 'bo', 'MarkerFaceColor', 'b', ...
    'MarkerSize', 10, 'LineWidth', 2);
hVec = quiver3(app.ax, 0, 0, 0, 0, 0, 0, 1, ...
    'Color', 'b', 'LineWidth', 2, 'MaxHeadSize', 0.5);

% Current point (moved by dragging)
px = x0;  py = y0;
redraw(px, py, theta0)
%% Precompute math for updates
% Light weight — skip
%% Dragging: clicks in the axes move the point to the surface under the mouse
Drag_Point_On_Surface(app.ax, f, max_val*[-1 1], max_val*[-1 1], @movePoint);
%% Build UI
NumControls = 1;
thetaSlider = app.addControl('slider', '$\theta = $', 1, NumControls, @updatePlot, ...
'colOrRow', 'row', 'Default', theta0, 'Min', 0, 'Max', 2*pi, 'Number_format', 'pi');
%% Functions for UI elements
    function updatePlot(~, ~)
        redraw(px, py, thetaSlider.Value)
    end

    % Called by Drag_Point_On_Surface with the new point
    function movePoint(x, y)
        px = x;  py = y;
        redraw(px, py, thetaSlider.Value)
    end
%% Main Draw update function.
% Handled above by redraw(), called from updatePlot() and movePoint().
end
