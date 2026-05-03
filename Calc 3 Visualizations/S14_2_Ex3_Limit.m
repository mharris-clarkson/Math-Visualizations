function S14_2_Ex3_Limit()
%% Illustrates path-dependent limits for f(x,y) = (x^2-y^2)/(x^2+y^2).
%  The slider sweeps the slope m of the linear path y = mx toward (0,0),
%  showing that the limit value changes with the path chosen.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
f      = @(x,y) (x.^2 - y.^2) ./ (x.^2 + y.^2);
xmin   = -1; xmax = 1;
ymin   = -1; ymax = 1;
m0     = 0;   % Initial slope

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
% run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Path-Dependent Limit: $(x^2-y^2)/(x^2+y^2)$', 1);
hold(app.ax, 'on')
xlim(app.ax, [xmin xmax])
ylim(app.ax, [ymin ymax])

%% Optional math functions for plot computations
    function [x, y] = computePath(t, m)
        x = t;
        y = m * t;
    end

    function limitVal = approx_limit(zp, t)
        r     = abs(t);
        valid = r > 0;
        [~, idx] = sort(r(valid));
        k     = 10;
        z_near   = zp(valid);
        limitVal = mean(z_near(idx(1:k)));
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
hPath = plot3(app.ax, xp, yp, zp, 'g', 'LineWidth', 2);

Pretty_Plot(app.ax)

%% Precompute math for updates
% Light weight — skip

%% Build UI
NumControls = 1;

mSlider = app.addControl('slider', '$m = $', 1, NumControls, @updatePlot, ...
    'Default', m0, 'Min', -20, 'Max', 20);

% Launch update to set initial title
updatePlot();

%% Main Draw update function.
    function updatePlot(~, ~)
        m  = mSlider.Value;
        [xp, yp] = computePath(t, m);
        zp = f(xp, yp);

        set(hPath, 'XData', xp, 'YData', yp, 'ZData', zp);

        lv = approx_limit(zp, t);
        title(app.ax, sprintf( ...
            'Limit along $y = %.2f x$: $ %.4f$', m, lv), ...
            'Interpreter', 'latex')
        ylim(app.ax, [ymin ymax])
    end
end
