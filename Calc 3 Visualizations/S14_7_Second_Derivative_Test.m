function S14_7_Second_Derivative_Test()
%% Interactive visualization of the second derivative test on the peaks
%  function. Shows the tangent plane or paraboloid at a moveable point,
%  with buttons to snap to local maxima, minima, and saddle points.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
f         = @peaks;
max_val   = 2;
Delta_val = 0.005;
x0        = 0;
y0        = 0;
useParaboloid = false;

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Second Derivative Test Visualizer', 1);
view(app.ax, -16, 47)
xlim(app.ax, max_val*[-1, 1])
ylim(app.ax, max_val*[-1, 1])

%% Optional math functions for plot computations
    function [hPt, hVx, hVy, hTp] = plot_geometry(x, y)
        z   = f(x, y);
        h   = 1e-5;
        fx  = (f(x+h,y) - f(x-h,y)) / (2*h);
        fy  = (f(x,y+h) - f(x,y-h)) / (2*h);
        fxx = (f(x+h,y) - 2*f(x,y) + f(x-h,y)) / h^2;
        fyy = (f(x,y+h) - 2*f(x,y) + f(x,y-h)) / h^2;
        fxy = (f(x+h,y+h) - f(x+h,y-h) - f(x-h,y+h) + f(x-h,y-h)) / (4*h^2);

        Tx = [1, 0, fx];
        Ty = [0, 1, fy];

        hPt = plot3(app.ax, x, y, z, 'ko', 'MarkerSize', 8, ...
            'LineWidth', 2, 'MarkerFaceColor', 'k');
        hVx = quiver3(app.ax, x, y, z, Tx(1), Tx(2), Tx(3), 0, 'r', 'LineWidth', 2);
        hVy = quiver3(app.ax, x, y, z, Ty(1), Ty(2), Ty(3), 0, 'b', 'LineWidth', 2);

        tp_size = 0.25;
        [u, v]  = meshgrid(linspace(-tp_size, tp_size, 12));
        if useParaboloid
            Zp = z + fx*u + fy*v + 0.5*(fxx*u.^2 + 2*fxy*u.*v + fyy*v.^2);
        else
            Zp = z + fx*u + fy*v;
        end
        hTp = surf(app.ax, x+u, y+v, Zp, ...
            'FaceAlpha', 1, 'EdgeColor', 'none', 'FaceColor', [0 0 0]);
    end

    function updateTitle()
        if useParaboloid
            title(app.ax, 'Second Derivative Test --- Tangent Paraboloid', 'Interpreter', 'latex')
        else
            title(app.ax, 'Second Derivative Test --- Tangent Plane', 'Interpreter', 'latex')
        end
    end

%% Make the initial plots
[X, Y] = meshgrid(-max_val:Delta_val:max_val);
Z = f(X, Y);
surf(app.ax, X, Y, Z, 'EdgeColor', 'none', 'FaceAlpha', 0.5)
colormap(app.ax, parula)
hold(app.ax, 'on')
contour3(app.ax, X, Y, Z, 20, 'k', 'LineWidth', 1)
Pretty_Plot(app.ax)

[hPt, hVx, hVy, hTp] = plot_geometry(x0, y0);
updateTitle()

%% Precompute critical points for snap buttons
% Local max / min via image processing
localMaxMask = imregionalmax(Z);
localMinMask = imregionalmin(Z);
maxList = [X(localMaxMask), Y(localMaxMask)];
minList = [X(localMinMask), Y(localMinMask)];
maxList(any(abs(maxList) > 1.9, 2), :) = [];
minList(any(abs(minList) > 1.9, 2), :) = [];

% Saddle points via gradient + Hessian determinant
h_fd  = Delta_val;
fx_g  = (circshift(Z,[0 -1]) - circshift(Z,[0  1])) / (2*h_fd);
fy_g  = (circshift(Z,[-1 0]) - circshift(Z,[1  0])) / (2*h_fd);
fxx_g = (circshift(Z,[0 -1]) - 2*Z + circshift(Z,[0  1])) / h_fd^2;
fyy_g = (circshift(Z,[-1 0]) - 2*Z + circshift(Z,[1  0])) / h_fd^2;
fxy_g = (circshift(circshift(Z,[-1 0]),[0 -1]) ...
       - circshift(circshift(Z,[-1 0]),[0  1]) ...
       - circshift(circshift(Z,[ 1 0]),[0 -1]) ...
       + circshift(circshift(Z,[ 1 0]),[0  1])) / (4*h_fd^2);
gradMag   = sqrt(fx_g.^2 + fy_g.^2);
detH      = fxx_g.*fyy_g - fxy_g.^2;
saddleMask = (gradMag < 0.05) & (detH < 0);
saddleList = unique(round([X(saddleMask), Y(saddleMask)], 3), 'rows');

maxIndex    = 1;
minIndex    = 1;
saddleIndex = 1;

%% Build UI
NumControls = 6;

xSlider = app.addControl('slider', '$x_0 = $', 1, NumControls, @updatePlot, ...
    'Default', x0, 'Min', -max_val, 'Max', max_val);

ySlider = app.addControl('slider', '$y_0 = $', 2, NumControls, @updatePlot, ...
    'Default', y0, 'Min', -max_val, 'Max', max_val);

btnToggle = app.addControl('button', 'Tangent Plane', 3, NumControls, ...
    @toggleApprox, 'ColorChange', true);

app.addControl('button', 'Snap: Local Max',    4, NumControls, @goToMax);
app.addControl('button', 'Snap: Local Min',    5, NumControls, @goToMin);
app.addControl('button', 'Snap: Saddle Point', 6, NumControls, @goToSaddle);

%% Functions for UI elements
    function toggleApprox(~, ~)
        useParaboloid = logical(btnToggle.Value);
        if useParaboloid
            btnToggle.String = 'Tangent Paraboloid';
        else
            btnToggle.String = 'Tangent Plane';
        end
        updatePlot()
    end

    function goToMax(~, ~)
        if isempty(maxList); return; end
        xSlider.Value = maxList(maxIndex, 1);
        ySlider.Value = maxList(maxIndex, 2);
        maxIndex = mod(maxIndex, size(maxList,1)) + 1;
        updatePlot()
    end

    function goToMin(~, ~)
        if isempty(minList); return; end
        xSlider.Value = minList(minIndex, 1);
        ySlider.Value = minList(minIndex, 2);
        minIndex = mod(minIndex, size(minList,1)) + 1;
        updatePlot()
    end

    function goToSaddle(~, ~)
        if isempty(saddleList); return; end
        xSlider.Value = saddleList(saddleIndex, 1);
        ySlider.Value = saddleList(saddleIndex, 2);
        saddleIndex = mod(saddleIndex, size(saddleList,1)) + 1;
        updatePlot()
    end

%% Main Draw update function.
    function updatePlot(~, ~)
        delete(hPt); delete(hVx); delete(hVy); delete(hTp);
        [hPt, hVx, hVy, hTp] = plot_geometry(xSlider.Value, ySlider.Value);
        view(app.ax, -16, 47)
        updateTitle()
    end
end