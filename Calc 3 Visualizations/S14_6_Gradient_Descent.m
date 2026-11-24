function S14_6_Gradient_Descent()
%% Demonstrates gradient descent (or ascent) on a surface. A slider controls
%  the number of steps taken from the initial point, and the path traced so
%  far is drawn over the contour plot. The path crosses the level curves at
%  right angles because the gradient is perpendicular to them.
%
%  One toggle button switches between gradient descent and gradient ascent.
%  A second toggle button switches the step rule between
%    - fixed length steps:    x_new = x -/+ Deltax * grad f / |grad f|
%    - steps proportional to the gradient (true gradient descent):
%                             x_new = x -/+ alpha * grad f
%  With the second rule the steps shrink as the gradient goes to zero, so
%  the path settles at a critical point instead of hopping around it.
%
%  The red arrow shows the next step, drawn 10 times longer. A third button
%  picks a new random starting point in the domain.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
f = @(x,y) 3*(1-x).^2.*exp(-(x.^2) - (y+1).^2) ...
   - 10*(x/5 - x.^3 - y.^5).*exp(-x.^2-y.^2) ...
   - 1/3*exp(-(x+1).^2 - y.^2);

x0     = [-0.3; 0.2];  % initial point [x; y]
Deltax = 0.05;         % step length for the fixed length rule
alpha  = 0.02;         % step factor for the proportional rule
nStepsMax  = 100;      % largest number of steps on the slider
arrowScale = 10;       % next-step arrow drawn this many times longer
nLevels    = 40;       % contour levels
xlims  = [-3, 3];
ylims  = [-3, 3];
startMargin = 0.1;     % random starts keep this fraction away from the edges

useAscent       = false;  % false = descent, true = ascent
useProportional = false;  % false = fixed length steps, true = steps proportional to grad f

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Gradient Descent', 1);
view(app.ax, 0, 90)
axis(app.ax, 'equal')
xlim(app.ax, xlims); ylim(app.ax, ylims)

%% Optional math functions for plot computations
% One step from xPoint with the current settings
    function step = next_step(xPoint)
        grad = Grad_f(f, xPoint);
        dir  = 2*double(useAscent) - 1;       % +1 ascent, -1 descent
        if useProportional
            step = dir * alpha * grad;
        else
            step = dir * Deltax * grad / max(norm(grad), eps);
        end
    end

% Whole path: column k+1 is the point after k steps
    function P = compute_path()
        P = zeros(2, nStepsMax + 1);
        P(:, 1) = x0;
        for k = 1:nStepsMax
            P(:, k+1) = P(:, k) + next_step(P(:, k));
        end
    end

%% Make the initial plots
res = 200;
[xGrid, yGrid] = meshgrid(linspace(xlims(1), xlims(2), res), ...
                           linspace(ylims(1), ylims(2), res));
zGrid = f(xGrid, yGrid);
contourf(app.ax, xGrid, yGrid, zGrid, nLevels);
colormap(app.ax, Pretty_Colormap('balance'))
clim(app.ax, max(abs(zGrid(:)))*[-1, 1])
colorbar(app.ax)
Pretty_Plot(app.ax)

% Path so far, start point, current point and next-step arrow
hTrail = plot(app.ax, NaN, NaN, 'k.-', 'LineWidth', 1.5, 'MarkerSize', 12);
hStart = plot(app.ax, x0(1), x0(2), 'ks', 'MarkerFaceColor', 'w', 'MarkerSize', 9);
hPoint = plot(app.ax, NaN, NaN, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8);
hArrow = quiver(app.ax, 0, 0, 0, 0, 0, ...
    'Color', 'r', 'LineWidth', 2, 'MaxHeadSize', 2);

xlim(app.ax, xlims); ylim(app.ax, ylims)

%% Precompute math for updates
Path = compute_path();

%% Build UI
NumControls = 4;

nSlider = app.addControl('slider', 'Steps $=$ ', 1, NumControls, @updatePlot, ...
    'Default', 0, 'Min', 0, 'Max', nStepsMax, 'Number_format', '%d', 'colOrRow', 'row');

btnMode = app.addControl('button', '', 2, NumControls, ...
    @toggleMode, 'ColorChange', true, 'colOrRow', 'row', ...
    'Toggle', ["Gradient Descent", "Gradient Ascent"]);

btnRule = app.addControl('button', '', 3, NumControls, ...
    @toggleRule, 'ColorChange', true, 'colOrRow', 'row', ...
    'Toggle', ["Step: Fixed Length", "Step: $\propto \nabla f$"]);

app.addControl('button', 'New Random Start', 4, NumControls, ...
    @randomStart, 'colOrRow', 'row');

redraw(0)

%% Functions for UI elements
    function toggleMode(~, ~)
        useAscent = logical(btnMode.Value);
        restart()
    end

    function toggleRule(~, ~)
        useProportional = logical(btnRule.Value);
        restart()
    end

    function randomStart(~, ~)
        mx = startMargin*diff(xlims);
        my = startMargin*diff(ylims);
        x0 = [xlims(1) + mx + rand*(diff(xlims) - 2*mx); ...
              ylims(1) + my + rand*(diff(ylims) - 2*my)];
        set(hStart, 'XData', x0(1), 'YData', x0(2));
        restart()
    end

    % Recompute the path and go back to the start point
    function restart()
        Path = compute_path();
        app.UpdateUISlider(nSlider, 0);
        redraw(0)
    end

%% Main Draw update function.
    function updatePlot(~, ~)
        redraw(round(nSlider.Value))
    end

    function redraw(nSteps)
        xCurr = Path(:, nSteps + 1);
        zVal  = f(xCurr(1), xCurr(2));
        grad  = Grad_f(f, xCurr);
        step  = next_step(xCurr);

        set(hTrail, 'XData', Path(1, 1:nSteps+1), 'YData', Path(2, 1:nSteps+1));
        set(hPoint, 'XData', xCurr(1), 'YData', xCurr(2));
        set(hArrow, 'XData', xCurr(1), 'YData', xCurr(2), ...
            'UData', arrowScale*step(1), 'VData', arrowScale*step(2));

        if useAscent
            modeStr = 'Ascent';
        else
            modeStr = 'Descent';
        end
        title(app.ax, sprintf(['Gradient %s: $f(x,y) = %.4f$ and ' ...
            '$|\\nabla f| = %.4f$ after %d steps'], ...
            modeStr, zVal, norm(grad), nSteps))
    end
end
