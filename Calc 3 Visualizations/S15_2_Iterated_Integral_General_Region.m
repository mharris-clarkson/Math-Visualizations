function S15_2_Iterated_Integral_General_Region()
%% Iterated Integral over a Region
% Volume under f(x,y) = x*y bounded by y = sqrt(x) and y = x^3.
%
% f is set to 0 outside the region x^3 <= y <= sqrt(x), 0 <= x <= 1, so the
% iterated integral can be computed over a plain rectangle that contains
% the region.
%
% A moving plane sweeps across the surface in the INNER variable. The black
% curves are the running inner integrals (one per value of the outer
% variable). The purple curve / green area on the far wall show the result
% of the inner integral and the area under it (= the volume).
%
% The red curtain is y = sqrt(x); the blue curtain is y = x^3.
% The "Swap Order" button switches between  dx dy  and  dy dx.
%
%
%% Author Info
%
% Adapted by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

close all

%% User parameters for math objects
inRegion = @(x,y) (x >= 0) & (x <= 1) & (y >= x.^3) & (y <= sqrt(max(x,0)));
f  = @(x,y) (x.*y) .* inRegion(x,y);     % 0 outside the region

xlims = [-0.01, 1.01]; Nx = 300;
ylims = [-0.01, 1.01]; Ny = 300;

Ncurves  = 40;         % number of black running-integral curves
tailLen  = 0.001;      % how far the black curves extend past the region

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('Interactive Double Integral Over a Region', 1);
axis(app.ax, 'equal')
view(app.ax, 3)

%% Precompute math
xvec = linspace(xlims(1), xlims(2), Nx);
yvec = linspace(ylims(1), ylims(2), Ny);
dx   = xvec(2) - xvec(1);
dy   = yvec(2) - yvec(1);

[X, Y] = meshgrid(xvec, yvec);
Z = f(X, Y);

% Height for the axis limits (covers both orders)
zTop = max([Z(:); sum(Z, 2)*dx; sum(Z, 1)'*dy]);

%% State shared by the nested functions
% xInner = true  : inner integral in x (plane at fixed x), outer in y
% xInner = false : inner integral in y (plane at fixed y), outer in x
xInner  = true;
u = []; v = []; du = 1; Zint = []; g = []; total = 0;
cIdx = []; vp = []; zp = [];
M = []; Mtail = []; uStart = 0; uEnd = 1;     % mask of f > 0 and sweep extent of the region
xSlider = [];
btnRed = []; btnGreen = [];
purple = [0.55 0 0.85];

%% Static graphics
Zs = Z;
Zs(~inRegion(X, Y)) = NaN;   % surface only over the region
surf(app.ax, X, Y, Zs, 'FaceColor', [0.95 0.75 0.10], 'EdgeColor', 'none', ...
    'FaceAlpha', 0.8)
Pretty_Plot(app.ax)
xlim(app.ax, xlims); ylim(app.ax, ylims); zlim(app.ax, [0, 1.03*zTop])

% Bounding curtains: red y = sqrt(x), blue y = x^3
xc = linspace(0, 1, 200);
% Curtain heights follow the surface along each boundary curve
zcRed  = [zeros(1, numel(xc)); xc.*sqrt(xc)];
zcBlue = [zeros(1, numel(xc)); xc.*xc.^3];
yRed  = sqrt(xc);
yBlue = xc.^3;
surf(app.ax, [xc; xc], [yRed; yRed],   zcRed, 'FaceColor', 'r', ...
    'FaceAlpha', 0.1, 'EdgeColor', 'none');
surf(app.ax, [xc; xc], [yBlue; yBlue], zcBlue, 'FaceColor', 'b', ...
    'FaceAlpha', 0.1, 'EdgeColor', 'none');
plot3(app.ax, xc, yRed,  zeros(size(xc)), 'r', 'LineWidth', 2)
plot3(app.ax, xc, yBlue, zeros(size(xc)), 'b', 'LineWidth', 2)
plot3(app.ax, xc, yRed,  zcRed(2, :), 'r', 'LineWidth', 1)
plot3(app.ax, xc, yBlue, zcBlue(2, :), 'b', 'LineWidth', 1)

hPlane  = patch(app.ax, NaN, NaN, NaN, 'k', 'FaceAlpha', 0.25, 'EdgeColor', 'k');
hCurves = plot3(app.ax, NaN, NaN, NaN, 'k', 'LineWidth', 1.5);   % NaN-separated curves
hWall   = plot3(app.ax, NaN, NaN, NaN, 'Color', purple, 'LineWidth', 3, 'Visible', 'off');
hGreen  = patch(app.ax, NaN, NaN, NaN, 'g', 'FaceAlpha', 0.35, ...
    'EdgeColor', 'none', 'Visible', 'off');

setOrder(true)

%% Build UI
NumControls = 5;
xSlider = app.addControl('slider', '$t = $', 1, NumControls, @updatePlot, ...
'colOrRow', 'row', 'Default', 0, 'Min', 0, 'Max', 100, 'Number_format', '%.1f');
app.addControl('button', 'View Collapsed Plane', 2, NumControls, @rotateToSideView, 'colOrRow', 'row');
app.addControl('button', 'Swap Order', 3, NumControls, @swapOrder, 'colOrRow', 'row');
btnRed   = app.addControl('button', 'Show Purple Curve', 4, NumControls, @toggleWallCurve, ...
'ColorChange', true, 'colOrRow', 'row');
btnGreen = app.addControl('button', 'Show Green Area', 5, NumControls, @toggleGreenArea, ...
'ColorChange', true, 'colOrRow', 'row');

%% Callbacks
function updatePlot(~, ~)
    i = currentIndex();
    redraw(i)
end

function swapOrder(~, ~)
    setOrder(~xInner)
end

% Rebuild everything that depends on the order of integration
function setOrder(tf)
    xInner = tf;
    if xInner
        u = xvec; v = yvec; F = Z;        % F(v,u): rows = outer, cols = inner
    else
        u = yvec; v = xvec; F = Z.';
    end
    du = u(2) - u(1);

    % Running inner integral for every outer value
    Zint  = [zeros(numel(v), 1), cumsum(F(:, 2:end), 2)*du];
    g     = Zint(:, end);                 % full inner integral, a function of v
    total = trapz(v, g);                  % outer integral = volume

    % Where the region lives and its extent along the sweep
    M      = F > 0;
    kTail  = max(1, round(tailLen/du));
    Mtail  = movmax(double(M), [kTail 0], 2) > 0;
    inReg  = any(M, 1);
    uStart = u(find(inReg, 1, 'first'));
    uEnd   = min(u(find(inReg, 1, 'last')) + tailLen, u(end));

    % Curves only for outer values that hit the region
    valid = find(g > 1e-12);
    pick  = unique(round(linspace(1, numel(valid), Ncurves)));
    cIdx  = valid(pick);

    % Far-wall curve (inner integral as a function of the outer variable)
    vi = valid(1):valid(end);
    vr = v(vi);   gr = g(vi).';
    [Xw, Yw] = toXY(u(end)*ones(size(vr)), vr);
    set(hWall, 'XData', Xw, 'YData', Yw, 'ZData', gr)

    % Green area under that curve
    Vf = [vr, fliplr(vr)];
    Zf = [zeros(size(gr)), fliplr(gr)];
    [Xf, Yf] = toXY(u(end)*ones(size(Vf)), Vf);
    set(hGreen, 'XData', Xf, 'YData', Yf, 'ZData', Zf)

    vp = [v(vi(1)), v(vi(1)), v(vi(end)), v(vi(end))];
    zp = [0, max(g), max(g), 0];

    updateTitle()
    redraw(currentIndex())
end

% Map (sweep value, outer value) coordinates to (x, y)
function [Xo, Yo] = toXY(U, V)
    if xInner
        Xo = U; Yo = V;
    else
        Xo = V; Yo = U;
    end
end

function i = currentIndex()
    if isempty(xSlider)
        i = 1;
    else
        % t = percent of the region swept
        pos = uStart + xSlider.Value/100*(uEnd - uStart);
        i = round((pos - u(1))/du) + 1;
        i = min(max(i, 1), numel(u));
    end
end

function redraw(i)
    [xp, yp] = toXY(u(i)*[1 1 1 1], vp);
    set(hPlane, 'XData', xp, 'YData', yp, 'ZData', zp)

    nc   = numel(cIdx);
    Umat = [repmat(u(1:i), nc, 1), nan(nc, 1)];
    vc   = v(cIdx);  vc = vc(:);
    Vmat = [repmat(vc, 1, i), nan(nc, 1)];
    Zc   = Zint(cIdx, 1:i);
    Zc(~Mtail(cIdx, 1:i)) = NaN;          % hide the parts outside the region
    Zmat = [Zc, nan(nc, 1)];
    [Xm, Ym] = toXY(Umat, Vmat);
    set(hCurves, 'XData', reshape(Xm.', 1, []), ...
                 'YData', reshape(Ym.', 1, []), ...
                 'ZData', reshape(Zmat.', 1, []))
end

function updateTitle()
    if xInner
        orderStr = 'dx dy  (inner integral in x)';
    else
        orderStr = 'dy dx  (inner integral in y)';
    end
    title(app.ax, sprintf('Iterated integral over a non-rectangular region, order %s', ...
        orderStr), 'Interpreter', 'none')
end

function toggleWallCurve(~, ~)
    tf = logical(btnRed.Value);
    set(hWall, 'Visible', onoff(tf))
    btnRed.String = toggleLabel(tf, 'Purple Curve');
end

function toggleGreenArea(~, ~)
    tf = logical(btnGreen.Value);
    set(hGreen, 'Visible', onoff(tf))
    btnGreen.String = toggleLabel(tf, 'Green Area');
end

function rotateToSideView(~, ~)
    Animate_View(app.ax, 90, 0)
end

end