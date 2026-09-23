function S14_6_Directional_Derivative()
%% Demonstrates the directional derivative of a bump function at a point
%  (x,y). Two sliders move the point around the surface and a third slider
%  rotates the evaluation direction (as an angle theta away from the
%  gradient direction). The blue arrow shows the rotated direction scaled
%  by the gradient magnitude, and its z-component is the directional
%  derivative in that direction.
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

x0     = 0;     % initial x
y0     = 0;     % initial y
theta0 = 0;     % initial rotation angle (rad) away from the gradient

max_val   = 1.4;   % slider range for x and y
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
function grad = numerical_gradient(xPoint)
        h = 1e-5;
        x = xPoint(1); y = xPoint(2);
        grad = [(f(x+h,y) - f(x-h,y))/(2*h); ...
                (f(x,y+h) - f(x,y-h))/(2*h)];
end
function redraw(x, y, theta)
        delete(findall(app.ax, 'Tag', 'dirPt'));
        delete(findall(app.ax, 'Tag', 'dirVec'));
        z    = f(x,y);
        grad = numerical_gradient([x; y]);
        R      = [cos(theta) -sin(theta); sin(theta) cos(theta)];
        dirRot = R*grad;                                   % gradient, rotated by theta
        dz     = grad(1)*dirRot(1) + grad(2)*dirRot(2);     % directional derivative
        plot3(app.ax, x, y, z, 'bo', 'MarkerFaceColor', 'b', ...
'MarkerSize', 8, 'LineWidth', 2, 'Tag', 'dirPt');
        cmocean('amp')
        quiver3(app.ax, x, y, z, dirRot(1), dirRot(2), dz, 1, ...
'Color', 'b', 'LineWidth', 2, 'MaxHeadSize', 0.5, 'Tag', 'dirVec');
        zlim(app.ax, [0, 0.6])
        title(app.ax, sprintf('Directional Derivative at $(%.2f,%.2f)$, $\\theta=%.2f$: $D_{u}f = %.4f$', ...
            x, y, theta, dz), 'Interpreter', 'latex')
end
%% Make the initial plots
[X, Y] = meshgrid(-max_val:Delta_val:max_val);
Z = f(X, Y);
surf(app.ax, X, Y, Z, 'EdgeColor', 'none')
colormap(app.ax, parula)
hold(app.ax, 'on')
contour3(app.ax, X, Y, Z, 20, 'k', 'LineWidth', 1)
Pretty_Plot(app.ax)
redraw(x0, y0, theta0)
%% Precompute math for updates
% Light weight — skip
%% Build UI
NumControls = 3;
xSlider = app.addControl('slider', '$x = $', 1, NumControls, @updatePlot, ...
'colOrRow', 'row', 'Default', x0, 'Min', -max_val, 'Max', max_val, 'Number_format', '%.2f');
ySlider = app.addControl('slider', '$y = $', 2, NumControls, @updatePlot, ...
'colOrRow', 'row', 'Default', y0, 'Min', -max_val, 'Max', max_val, 'Number_format', '%.2f');
thetaSlider = app.addControl('slider', '$\theta = $', 3, NumControls, @updatePlot, ...
'colOrRow', 'row', 'Default', theta0, 'Min', 0, 'Max', 2*pi, 'Number_format', '%.2f');
%% Functions for UI elements
function updatePlot(~, ~)
        redraw(xSlider.Value, ySlider.Value, thetaSlider.Value)
end
%% Main Draw update function.
% Handled above by redraw(), called directly from updatePlot().
end