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
Delta_val = 0.005;   % grid spacing used to find the critical points
Delta_plot = 0.02;   % grid spacing of the drawn surface (looks the same, 16x fewer faces)
critTol   = 0.1;     % |grad f| below this counts as a critical point in the title
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
    % Point, tangent vectors and the local plane/paraboloid at (x,y).
    % Derivatives come from the Diff*_f helpers (step sizes tuned there).
    function [z, Tx, Ty, Zp, D, fxx, gradNorm] = geometry_at(x, y)
        z   = f(x, y);
        fx  = Diffx_f(f, x, y);
        fy  = Diffy_f(f, x, y);
        fxx = Diffxx_f(f, x, y);
        fyy = Diffyy_f(f, x, y);
        fxy = Diffxy_f(f, x, y);
        D        = fxx*fyy - fxy^2;          % second derivative test discriminant
        gradNorm = norm([fx, fy]);

        Tx = [1, 0, fx];
        Ty = [0, 1, fy];

        if useParaboloid
            Zp = z + fx*u + fy*v + 0.5*(fxx*u.^2 + 2*fxy*u.*v + fyy*v.^2);
        else
            Zp = z + fx*u + fy*v;
        end
    end

    % Title: which approximation, D and f_xx, and the test's verdict
    function updateTitle(D, fxx, gradNorm)
        if useParaboloid
            approxStr = 'Tangent Paraboloid';
        else
            approxStr = 'Tangent Plane';
        end
        if gradNorm > critTol
            verdict = sprintf('not a critical point ($|\\nabla f| = %.2f$)', gradNorm);
        elseif D < 0
            verdict = 'saddle point ($D < 0$)';
        elseif D > 0 && fxx < 0
            verdict = 'local max ($D > 0$, $f_{xx} < 0$)';
        elseif D > 0
            verdict = 'local min ($D > 0$, $f_{xx} > 0$)';
        else
            verdict = 'test inconclusive ($D = 0$)';
        end
        title(app.ax, {['Second Derivative Test --- ' approxStr], ...
            sprintf('$D = f_{xx}f_{yy} - f_{xy}^2 = %.2f$, $f_{xx} = %.2f$: %s', D, fxx, verdict)}, ...
            'Interpreter', 'latex')
    end

%% Make the initial plots
% Fine grid (Delta_val) for finding critical points below; the drawn
% surface and contours use the coarser Delta_plot grid. A transparent
% 801 x 801 surface was very slow to render and rotate on weak laptops.
[X, Y] = meshgrid(-max_val:Delta_val:max_val);
Z = f(X, Y);
[Xs, Ys] = meshgrid(-max_val:Delta_plot:max_val);
Zs = f(Xs, Ys);
surf(app.ax, Xs, Ys, Zs, 'EdgeColor', 'none', 'FaceAlpha', 0.5)
colormap(app.ax, parula)
hold(app.ax, 'on')
contour3(app.ax, Xs, Ys, Zs, 20, 'k', 'LineWidth', 1)
Pretty_Plot(app.ax)

% Local (u,v) patch for the plane/paraboloid, built once
tp_size = 0.25;
[u, v]  = meshgrid(linspace(-tp_size, tp_size, 12));

% Point, tangent vectors and plane: created once, updated in place
[z0, Tx, Ty, Zp, D0, fxx0, g0] = geometry_at(x0, y0);
hPt = plot3(app.ax, x0, y0, z0, 'ko', 'MarkerSize', 8, ...
    'LineWidth', 2, 'MarkerFaceColor', 'k');
hVx = quiver3(app.ax, x0, y0, z0, Tx(1), Tx(2), Tx(3), 0, 'r', 'LineWidth', 2);
hVy = quiver3(app.ax, x0, y0, z0, Ty(1), Ty(2), Ty(3), 0, 'b', 'LineWidth', 2);
hTp = surf(app.ax, x0+u, y0+v, Zp, ...
    'FaceAlpha', 1, 'EdgeColor', 'none', 'FaceColor', [0 0 0]);
updateTitle(D0, fxx0, g0)

%% Precompute critical points for snap buttons
% Local max / min: grid points that beat all 8 neighbours.
% Local_Extrema_2D is base MATLAB (no Image Processing Toolbox needed).
[localMaxMask, localMinMask] = Local_Extrema_2D(Z);
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
% Keep only the grid point where |grad f| is smallest in each cluster, so
% each saddle appears once (the old version listed 5 points for 3 saddles)
[~, gradMin] = Local_Extrema_2D(gradMag);
saddleMask = gradMin & (gradMag < 0.05) & (detH < 0);
saddleList = [X(saddleMask), Y(saddleMask)];

maxIndex    = 1;
minIndex    = 1;
saddleIndex = 1;

%% Build UI
NumControls = 6;

xSlider = app.addControl('slider', '$x_0 = $', 1, NumControls, @updatePlot, ...
    'Default', x0, 'Min', -max_val, 'Max', max_val);

ySlider = app.addControl('slider', '$y_0 = $', 2, NumControls, @updatePlot, ...
    'Default', y0, 'Min', -max_val, 'Max', max_val);

btnToggle = app.addControl('button', '', 3, NumControls, ...
    @toggleApprox, 'ColorChange', true, ...
    'Toggle', ["Tangent Plane", "Tangent Paraboloid"]);

app.addControl('button', 'Snap: Local Max',    4, NumControls, @goToMax);
app.addControl('button', 'Snap: Local Min',    5, NumControls, @goToMin);
app.addControl('button', 'Snap: Saddle Point', 6, NumControls, @goToSaddle);

%% Functions for UI elements
    function toggleApprox(~, ~)
        useParaboloid = logical(btnToggle.Value);   % text follows via 'Toggle'
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
    % Moves the existing objects (no delete/re-create), and no longer
    % resets the camera, so a view the student rotated to is kept.
    function updatePlot(~, ~)
        x = xSlider.Value;
        y = ySlider.Value;
        [z, Tx, Ty, Zp, D, fxx, gradNorm] = geometry_at(x, y);
        set(hPt, 'XData', x, 'YData', y, 'ZData', z);
        set(hVx, 'XData', x, 'YData', y, 'ZData', z, ...
            'UData', Tx(1), 'VData', Tx(2), 'WData', Tx(3));
        set(hVy, 'XData', x, 'YData', y, 'ZData', z, ...
            'UData', Ty(1), 'VData', Ty(2), 'WData', Ty(3));
        set(hTp, 'XData', x+u, 'YData', y+v, 'ZData', Zp);
        updateTitle(D, fxx, gradNorm)
    end
end