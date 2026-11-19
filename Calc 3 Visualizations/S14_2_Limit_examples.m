function S14_2_Limit_examples()
%% Path-dependent limits at (0,0): Ex 3, Ex 4 and Ex 5 in one figure.
%  A button steps through the three examples
%     Ex 3:  f(x,y) = (x^2 - y^2)/(x^2 + y^2)
%     Ex 4:  f(x,y) = xy/(x^2 + y^2)
%     Ex 5:  f(x,y) = x^2 y/(x^4 + y^2)
%  and a slider sets the slope m of the path toward the origin. The two
%  ends of the slider stand for m -> -infinity and m -> +infinity: the path
%  is drawn with a very steep slope (+/- mInf), so it hugs the y-axis.
%  Ex 5 also has a button that switches the path between lines y = mx and
%  parabolas y = mx^2, which shows that every line can give the same limit
%  while a parabola gives another.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
mMax = 30;
% Adjust these to modify selected math objects below.
ex(1) = struct('name', 'Ex 3', 'f', @(x,y) (x.^2 - y.^2) ./ (x.^2 + y.^2), ...
    'tex', '\frac{x^2-y^2}{x^2+y^2}', 'mMax', mMax, 'parabola', false, ...
    'zeroTol', 0);
ex(2) = struct('name', 'Ex 4', 'f', @(x,y) (x.*y) ./ (x.^2 + y.^2), ...
    'tex', '\frac{xy}{x^2+y^2}', 'mMax', mMax, 'parabola', false, ...
    'zeroTol', 0);
ex(3) = struct('name', 'Ex 5', 'f', @(x,y) (x.^2 .* y) ./ (x.^4 + y.^2), ...
    'tex', '\frac{x^2y}{x^4+y^2}', 'mMax', mMax, 'parabola', true, ...
    'zeroTol', 1e-3);
xmin = -1; xmax = 1;
ymin = -1; ymax = 1;
m0        = 0;      % starting slope for every example
mInf      = 10^10;  % slope used for m -> +/- infinity at the slider ends
pathColor = 'g';    % colour of the path toward (0,0)
zLiftFrac = 0.01;   % draw the path this fraction of the surface's height above it

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Path-Dependent Limits at $(0,0)$', 1);
hold(app.ax, 'on')
xlim(app.ax, [xmin xmax])
ylim(app.ax, [ymin ymax])

%% State
k = 1;          % current example
zLift = 0;      % set from the surface's height range

%% Make the initial plots (created once, updated in place)
[xg, yg] = meshgrid(linspace(xmin, xmax, 500));
zg = ex(k).f(xg, yg);
hSurf = surf(app.ax, xg, yg, zg);
shading(app.ax, 'flat')
Pretty_Color_Centered(app.ax, zg, 'colorbar', 'on');
zLift = zLiftFrac * (max(zg(:)) - min(zg(:)));
plot3(app.ax, 0, 0, 0.001, 'ko', 'MarkerSize', 10, 'LineWidth', 2)

t = linspace(-1, 1, 400);   % path parameter; the path reaches (0,0) at t = 0
hPath = plot3(app.ax, NaN, NaN, NaN, 'Color', pathColor, 'LineWidth', 2);

Pretty_Plot(app.ax)
xlim(app.ax, [xmin xmax])
ylim(app.ax, [ymin ymax])

%% Build UI (one row along the bottom)
NumControls = 3;

mSlider = app.addControl('slider', '$m = $', 1, NumControls, @updatePlot, ...
    'Default', m0, 'Min', -ex(k).mMax, 'Max', ex(k).mMax, 'colOrRow', 'row');

btnEx = app.addControl('button', ['Example: ' ex(k).name], 2, NumControls, ...
    @nextExample, 'colOrRow', 'row');

btnPath = app.addControl('button', '', 3, NumControls, @(~,~) updatePlot(), ...
    'colOrRow', 'row', 'Toggle', ["Path: $y = mx$", "Path: $y = mx^2$"], ...
    'ColorChange', true, 'Visible', 'off');

% Lower the top of the plot a little so the title (with its fraction) fits
app.ax.Position(4) = app.ax.Position(4) - 0.05;

% Launch update to set initial title
updatePlot();

%% Functions for UI elements
    function nextExample(~, ~)
        % Ex 3 -> Ex 4 -> Ex 5 -> Ex 3 ...
        k = mod(k, numel(ex)) + 1;
        btnEx.String = ['Example: ' ex(k).name];

        % New surface and colour scale
        zg = ex(k).f(xg, yg);
        set(hSurf, 'ZData', zg, 'CData', zg)
        Pretty_Color_Centered(app.ax, zg, 'colorbar', 'on');
        zLift = zLiftFrac * (max(zg(:)) - min(zg(:)));

        % Line/parabola button only for Ex 5; start every example on lines
        btnPath.Value   = false;
        btnPath.Visible = onoff(ex(k).parabola);

        % New slope range, back to the starting slope
        app.UpdateUISlider(mSlider, m0, 'Min', -ex(k).mMax, 'Max', ex(k).mMax);
        updatePlot();
    end

%% Main Draw update function.
    function updatePlot(~, ~)
        E = ex(k);
        isParabola = E.parabola && btnPath.Value;

        % Slope. The slider moves freely; only its two end positions are
        % replaced by a very steep slope standing for m -> +/- infinity.
        tol = 1e-6 * (mSlider.Max - mSlider.Min);
        atEnd = 0;
        if mSlider.Value >= mSlider.Max - tol
            atEnd = 1;
        elseif mSlider.Value <= mSlider.Min + tol
            atEnd = -1;
        end
        if atEnd ~= 0
            m = atEnd * mInf;   % +mInf at the right end, -mInf at the left end
        else
            m = mSlider.Value;
        end

        if isParabola
            tt = t * min(1, 1/sqrt(abs(m)));
            xp = tt;
            yp = m * tt.^2;
        else
            tt = t * min(1, 1/abs(m));
            xp = tt;
            yp = m * tt;
        end
        zp = E.f(xp, yp);
        % Drawn a little above the surface. Where the surface changes very
        % fast (steep paths near the y-axis) a path at exactly the surface
        % height dips in and out of it, which makes the line look uneven.
        % The limit below still uses the true values zp.
        set(hPath, 'XData', xp, 'YData', yp, 'ZData', zp + zLift);

        % Path text, and the slider label at the two ends
        if isParabola
            pathStr = sprintf('$y = %.2f x^2$', m);
        else
            pathStr = sprintf('$y = %.2f x$', m);
        end
        if atEnd == 1
            mSlider.UserData.label.String = '$m \to \infty$';
            pathStr = [pathStr ' $(m \to \infty)$'];
        elseif atEnd == -1
            mSlider.UserData.label.String = '$m \to -\infty$';
            pathStr = [pathStr ' $(m \to -\infty)$'];
        end

        lv = Limit_Along_Path(zp, tt, 'ZeroTol', E.zeroTol);
        title(app.ax, sprintf('%s: $f(x,y) = %s$, limit along %s: $%.4f$', ...
            E.name, E.tex, pathStr, lv), 'Interpreter', 'latex')
    end
end