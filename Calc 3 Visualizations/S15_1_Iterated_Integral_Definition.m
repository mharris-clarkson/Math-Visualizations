function S15_1_Iterated_Integral_Definition()
%% Iterated Integral Definition
% Visualizes the iterated-integral idea: a moving plane sweeps across the
% surface in x; the black curves on that plane are the "inner integral"
% g(x) = integral of f(x,y) dy-direction accumulated so far (shown here
% accumulated in x, matching the original demo), and the red curve/green
% area on the far wall show the resulting profile g and the area under it.
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

close all

%% User parameters for math objects
r2 = @(x,y) x.^2 + y.^2;
f  = @(x,y) 2*exp(1)*exp(1 ./ (r2(x,y)-1 + (r2(x,y)>=1)));
f  = @(x,y) (r2(x,y)<1) .* f(x,y);
% f = @(x,y) sin(pi*x.^2.*(y+1).^2);   % alternative "bumpy" function

xlims = [-1, 1]; Nx = 80;
ylims = [-1, 1]; Ny = 25;

NyHighRes = 500;   % resolution of the red curve / green area on the far wall

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('Interactive Double Integral Definition', 1);
axis(app.ax, 'equal')
view(app.ax, 3)
title(app.ax, 'Iterated Integral Idea')

%% Precompute math
xvec = linspace(xlims(1), xlims(2), Nx);
yvec = linspace(ylims(1), ylims(2), Ny);
dx   = xvec(2) - xvec(1);

[X, Y] = meshgrid(xvec, yvec);
Z = f(X, Y);

% Zint(j,i) = running integral along x, up to xvec(i), at height yvec(j)
% (left-endpoint rule, matching the column-1 = 0 starting condition).
Zint = [zeros(Ny, 1), cumsum(Z(:, 2:end), 2)*dx];

% High-resolution version along y, used for the red curve / green area at
% the final x. Each column of Z already holds f at all of yvec for a
% fixed x, so interp1 can resample every column (every x) in one call
% instead of looping over Nx columns.
yvecHigh    = linspace(ylims(1), ylims(2), NyHighRes);
fInterpAll  = interp1(yvec, Z, yvecHigh, 'spline');   % NyHighRes x Nx
ZintHigh    = cumsum(fInterpAll, 2)*dx;
gHigh       = ZintHigh(:, end);
zPlaneMax   = max(gHigh);

%% Static graphics
surf(app.ax, X, Y, Z, 'EdgeColor', 'none', 'FaceAlpha', 0.75)
cmocean('amp')
Pretty_Plot(app.ax)

ypoints = [ylims(1), ylims(1), ylims(2), ylims(2)];
zpoints = [0, zPlaneMax, zPlaneMax, 0];
hPlane  = patch(app.ax, NaN, NaN, NaN, 'k', 'FaceAlpha', 0.25, 'EdgeColor', 'k');

% All Ny integral curves as ONE line object, with NaN separators between
% curves -- one object and one set() call per update instead of Ny.
hCurves = plot3(app.ax, NaN, NaN, NaN, 'k', 'LineWidth', 1.5);

hRedCurve = plot3(app.ax, xvec(end)*ones(size(yvecHigh)), yvecHigh, gHigh, ...
    'r', 'LineWidth', 3, 'Visible', 'off');

Yfill = [yvecHigh, fliplr(yvecHigh)];
Zfill = [zeros(size(gHigh')), fliplr(gHigh')];
Xfill = xvec(end)*ones(size(Yfill));
hGreenArea = patch(app.ax, Xfill, Yfill, Zfill, 'g', ...
    'FaceAlpha', 0.35, 'EdgeColor', 'none', 'Visible', 'off');

redraw(1)

%% Build UI
NumControls = 4;
xSlider  = app.addControl('slider', '$x = $', 1, NumControls, @updatePlot, ...
'colOrRow', 'row', 'Default', xvec(1), 'Min', xlims(1), 'Max', xlims(2), 'Number_format', '%.3f');
app.addControl('button', 'View Collapsed Plane', 2, NumControls, @rotateToSideView, 'colOrRow', 'row');
btnRed   = app.addControl('button', 'Show Red Curve', 3, NumControls, @toggleRedCurve, ...
'ColorChange', true, 'colOrRow', 'row');
btnGreen = app.addControl('button', 'Show Green Area', 4, NumControls, @toggleGreenArea, ...
'ColorChange', true, 'colOrRow', 'row');

%% Callbacks
function updatePlot(~, ~)
    i = round((xSlider.Value - xvec(1))/dx) + 1;
    redraw(min(max(i, 1), Nx))
end

function redraw(i)
    xi = xvec(i);
    set(hPlane, 'XData', xi*[1 1 1 1], 'YData', ypoints, 'ZData', zpoints)

    Xmat = [repmat(xvec(1:i), Ny, 1), nan(Ny, 1)];
    Ymat = [yvec(:).*ones(1, i), nan(Ny, 1)];
    Zmat = [Zint(:, 1:i), nan(Ny, 1)];
    set(hCurves, 'XData', reshape(Xmat.', 1, []), ...
                 'YData', reshape(Ymat.', 1, []), ...
                 'ZData', reshape(Zmat.', 1, []))
end

function toggleRedCurve(~, ~)
    tf = logical(btnRed.Value);
    set(hRedCurve, 'Visible', onoff(tf))
    btnRed.String = toggleLabel(tf, 'Red Curve');
end

function toggleGreenArea(~, ~)
    tf = logical(btnGreen.Value);
    set(hGreenArea, 'Visible', onoff(tf))
    btnGreen.String = toggleLabel(tf, 'Green Area');
    if tf
        title(app.ax, 'Iterated integral is the green area')
    else
        title(app.ax, 'Iterated Integral Idea')
    end
end

function rotateToSideView(~, ~)
    [az0, el0] = view(app.ax);
    azs = linspace(az0, 90, 50);
    els = linspace(el0, 0, 50);
    for k = 1:numel(azs)
        view(app.ax, azs(k), els(k))
        drawnow
        pause(0.02)
    end
end

end

%% Small stateless helpers (kept as ordinary local functions, not nested,
% since they don't need access to the app's shared workspace).
function s = onoff(tf)
if tf
    s = 'on';
else
    s = 'off';
end
end

function s = toggleLabel(tf, name)
if tf
    s = ['Hide ', name];
else
    s = ['Show ', name];
end
end