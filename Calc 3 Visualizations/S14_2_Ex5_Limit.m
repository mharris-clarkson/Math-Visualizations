function S14_2_Ex5_Limit()
%% Illustrates path-dependent limits for f(x,y) = x^2*y/(x^4+y^2).
%  Supports both linear paths y=mx and parabolic paths y=mx^2, toggled
%  by a button. Shows that the limit can differ along different path types.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
f        = @(x,y) (x.^2 .* y) ./ (x.^4 + y.^2);
xmin     = -1; xmax = 1;
ymin     = -1; ymax = 1;
m0       = 0;  % Initial slope
pathType = "line"; % "line" or "parabola"

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
% run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Path-Dependent Limit: $x^2y/(x^4+y^2)$', 1);
hold(app.ax, 'on')
xlim(app.ax, [xmin xmax])
ylim(app.ax, [ymin ymax])

%% Optional math functions for plot computations
    function [x, y] = computePath(t, m)
        x = t;
        if pathType == "line"
            y = m * t;
        else
            y = m * t.^2;
        end
    end

    function limitVal = approx_limit(zp, t)
        r     = abs(t);
        valid = r > 0;
        [~, idx] = sort(r(valid));
        k     = 10;
        z_near   = zp(valid);
        limitVal = mean(z_near(idx(1:k)));
        if abs(limitVal) < 1e-3
            limitVal = 0;
        end
    end

%% Make the initial plots
% Surface
[xg, yg] = meshgrid(linspace(xmin, xmax, 500));
zg = f(xg, yg);
surf(app.ax, xg, yg, zg);
cmocean('balance')
colorbar(app.ax)
shading(app.ax, 'flat')
plot3(app.ax, 0, 0, 0.001, 'ko', 'MarkerSize', 10, 'LineWidth', 2)

% Initial path
t  = linspace(-1, 1, 400);
[xp, yp] = computePath(t, m0);
zp = f(xp, yp);
hPath = plot3(app.ax, xp, yp, zp, 'k', 'LineWidth', 2);

Pretty_Plot(app.ax)

%% Precompute math for updates
% Light weight — skip

%% Build UI
NumControls = 2;

mSlider = app.addControl('slider', '$m = $', 1, NumControls, @updatePlot, ...
    'Default', m0, 'Min', -10, 'Max', 10);

btnPath = app.addControl('button', 'Path: $y = mx$', 2, NumControls, @togglePath);

% Launch update to set initial title
updatePlot();

%% Functions for UI elements
    function togglePath(~, ~)
        if pathType == "line"
            pathType = "parabola";
            btnPath.String = 'Path: $y = mx^2$';
        else
            pathType = "line";
            btnPath.String = 'Path: $y = mx$';
        end
        updatePlot();
    end

%% Main Draw update function.
    function updatePlot(~, ~)
        m  = mSlider.Value;
        [xp, yp] = computePath(t, m);
        zp = f(xp, yp);

        set(hPath, 'XData', xp, 'YData', yp, 'ZData', zp);

        lv = approx_limit(zp, t);
        if pathType == "line"
            pathStr = sprintf('$y = %.2f x$', m);
        else
            pathStr = sprintf('$y = %.2f x^2$', m);
        end
        title(app.ax, sprintf('Limit along %s: $ %.4f$', pathStr, lv), ...
            'Interpreter', 'latex')
        ylim(app.ax, [ymin ymax]);
    end
end
