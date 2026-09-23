function S14_6_Gradient_Descent()
%% Demonstrates gradient descent (or ascent) on a surface. A slider controls
%  the number of steps taken from the initial point. A toggle button switches
%  between gradient descent and gradient ascent.
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
Deltax = 0.05;         % step size
xlims  = [-3, 3];
ylims  = [-3, 3];

useAscent = false;  % false = descent, true = ascent

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Gradient Descent', 1);
view(app.ax, 0, 90)
axis(app.ax, 'equal')
xlim(app.ax, xlims); ylim(app.ax, ylims)

%% Optional math functions for plot computations
    function grad = numerical_gradient(xPoint)
        h = 1e-6;
        x = xPoint(1); y = xPoint(2);
        grad = [(f(x+h,y) - f(x-h,y))/(2*h); ...
                (f(x,y+h) - f(x,y-h))/(2*h)];
    end

    function xCurr = run_steps(nSteps)
        xCurr = x0;
        dir   = 1 - 2*double(~useAscent);  % +1 ascent, -1 descent
        for k = 1:nSteps
            grad  = numerical_gradient(xCurr);
            xCurr = xCurr + dir * Deltax * grad / norm(grad);
        end
    end

    function redraw(nSteps)
        delete(findall(app.ax, 'Tag', 'gradPt'));
        delete(findall(app.ax, 'Tag', 'gradVec'));

        xCurr    = run_steps(nSteps);
        xVal     = xCurr(1); yVal = xCurr(2);
        zVal     = f(xVal, yVal);
        grad     = numerical_gradient(xCurr);
        gradStep = grad / norm(grad) * Deltax;
        dir      = 1 - 2*double(~useAscent);

        plot(app.ax, xVal, yVal, 'ro', ...
            'MarkerFaceColor', 'r', 'MarkerSize', 8, 'Tag', 'gradPt');
        quiver(app.ax, xVal, yVal, 10*dir*gradStep(1), 10*dir*gradStep(2), 0, ...
            'Color', 'r', 'LineWidth', 2, 'MaxHeadSize', 2, 'Tag', 'gradVec');

        if useAscent
            modeStr = 'Ascent';
        else
            modeStr = 'Descent';
        end
        title(app.ax, sprintf('Gradient %s: $f(x,y) = %.4f$ after %d steps', ...
            modeStr, zVal, nSteps), 'Interpreter', 'latex')
    end

%% Make the initial plots
res = 200;
[xGrid, yGrid] = meshgrid(linspace(xlims(1), xlims(2), res), ...
                           linspace(ylims(1), ylims(2), res));
zGrid = arrayfun(f, xGrid, yGrid);
contourf(app.ax, xGrid, yGrid, zGrid, 100);
shading(app.ax, 'interp')
colormap(app.ax, cmocean('balance'))
clim(app.ax, max(abs(zGrid(:)))*[-1, 1])
colorbar(app.ax)
Pretty_Plot(app.ax)

redraw(0)

%% Precompute math for updates
% Light weight — skip

%% Build UI
NumControls = 2;

nSlider = app.addControl('slider', 'Steps $=$ ', 1, NumControls, @updatePlot, ...
    'Default', 0, 'Min', 0, 'Max', 100, 'Number_format', '%d', 'colOrRow', 'row');

btnMode = app.addControl('button', 'Gradient Descent', 2, NumControls, ...
    @toggleMode, 'ColorChange', true, 'colOrRow', 'row');

%% Functions for UI elements
    function toggleMode(~, ~)
        useAscent = logical(btnMode.Value);
        if useAscent
            btnMode.String = 'Gradient Ascent';
            app.UpdateUISlider(nSlider, 0);
        else
            btnMode.String = 'Gradient Descent';
            app.UpdateUISlider(nSlider, 0);
        end
        redraw(round(nSlider.Value))
    end

%% Main Draw update function.
    function updatePlot(~, ~)
        redraw(round(nSlider.Value))
    end
end