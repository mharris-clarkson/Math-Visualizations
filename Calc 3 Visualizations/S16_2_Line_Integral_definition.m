function S16_2_Line_Integral_definition()
%% Line Integral Definition Visualized -- Spline Curve
% The curve C is a cubic spline through 6 draggable control points in the
% xy-plane (parameterized by chord length). Drag any yellow diamond (a
% control point) to reshape C; the Riemann sum panels, the arc-length plot
% and the sum all update. The n slider ends at n -> infinity, where the
% panels become the continuous curtain under f along C (the line integral
% itself). Arrows along C show its direction (start = green circle, end =
% black square). A button rotates the view between the top view and 3D
% (dragging works in both).
%
%   Left  : 3D view (surface, curve, control points, curtain panels)
%   Right : 2D "unrolled" Riemann sum on the arc-length axis (can be hidden)
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

close all

%% User parameters for math objects
f = @(x,y) (x.^2);                                 % surface / integrand
% another one to try (positive everywhere):
% f  = @(x,y) 1.5 + 0.8*sin(2*x).*cos(1.5*y);

% control points in a rough box
% (another start to try: roughly on an upper semicircle
%  t6 = linspace(0, 1, 6); px = cos(pi*t6); py = sin(pi*t6);)
px = [1,    1, 1, 0.8, 0, -1];
py = [-1, -0.5, 0,  1, 1, 1];
bound = 1.5;                % control points are clamped to [-bound, bound]^2

Nfine = 600;                % points used to draw the spline
n0 = 0;  nMax = 50;          % initial / largest finite number of panels
Show1D      = false;         % 1D (arc-length) plot initially hidden
oneWidthFactor = 1.8;        % 3D axes width with the 1D plot hidden (x two-pane width)
ax2ShiftFrac = 0.12;         % move the 1D plot's left edge right by this fraction

color1 = [0.15 0.35 0.75];  % alternating panel colors (blue / orange)
color2 = [0.95 0.55 0.15];
color3 = [0.20 0.65 0.45];  % line-integral area in the limit (green)
cpColor = [1.00 0.80 0.00]; % control points (yellow diamonds, black outline)
nGrid = 60;                 % surface grid resolution

view3D = [130 50];         % [azimuth elevation] of the 3D view (top view is [0 90])

nArr   = 6;                 % number of direction arrows along the curve
arrLen = 0.3*bound;         % arrow length (in 3D data units)

panelColors = [color1; color2];
tFine = linspace(0, 1, Nfine);

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('Line Integral - Spline Curve', 2);
ax3 = app.ax(1);
ax2 = app.ax(2);

% 3D axes positions for the two-pane and one-pane layouts
drawnow
ax3.PositionConstraint = 'outerposition';
posSplit3 = ax3.OuterPosition;
posFull3  = posSplit3;
posFull3(3) = oneWidthFactor*posSplit3(3);

% Two-pane layout: keep the 3D axes off the 1D plot's y label
ax2.PositionConstraint = 'outerposition';
posSplit2 = ax2.OuterPosition;
posSplit2(1) = posSplit2(1) + ax2ShiftFrac*posSplit2(3);
posSplit2(3) = (1 - ax2ShiftFrac)*posSplit2(3);
ax2.OuterPosition = posSplit2;

%% Static graphics in the 3D axes
[xg, yg] = meshgrid(linspace(-bound, bound, nGrid));
surf(ax3, xg, yg, f(xg,yg), 'EdgeColor', 'none', 'FaceAlpha', 0.8, 'FaceColor', 'interp');
colormap(ax3,Pretty_Colormap('amp'));
clim(ax3,max(max(f(xg,yg)))*[0,1])
surf(ax3, xg, yg, zeros(size(xg)), 'FaceColor', [0.88 0.88 0.88], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
xlabel(ax3, 'x'); ylabel(ax3, 'y'); zlabel(ax3, 'z = f(x,y)')
view(ax3, 2)
xlim(ax3, bound*1.07*[-1 1]); ylim(ax3, bound*1.07*[-1 1])

xlabel(ax2, 'Arc length  s'); ylabel(ax2, 'f(x(s), y(s))')

%% Dynamic graphics
box3 = [1 2 3 4];  boxV = zeros(4,3);
nanv = NaN(1, Nfine);
% Line-integral curtain: strip of quads between the curve and z = 0
qi = 1:Nfine-1;
curtainFaces = [qi; qi+1; Nfine+qi+1; Nfine+qi].';
hLine3 = patch(ax3, 'Faces', curtainFaces, 'Vertices', NaN(2*Nfine,3), ...
    'FaceColor', color3, 'FaceAlpha', 0.45, 'EdgeColor', 'none');
hLine2 = patch(ax2, nanv, nanv, color3, 'FaceAlpha', 0.40, 'EdgeColor', 'none');
hCurve3 = plot3(ax3, nanv, nanv, nanv, 'k--', 'LineWidth', 1);               % curve on surface (dashed)
hProj3  = plot3(ax3, nanv, nanv, nanv, 'k', 'LineWidth', 2);                 % projection on z = 0 (solid)
hCP3    = plot3(ax3, px, py, zeros(1,6), 'd', 'MarkerFaceColor', cpColor, ...
    'MarkerEdgeColor', 'k', 'MarkerSize', 12, 'LineWidth', 1);
hCurve2 = plot(ax2, nanv, nanv, 'k', 'LineWidth', 2);
hPan3  = patch(ax3, 'Faces', box3, 'Vertices', boxV, 'FaceColor', 'flat', ...
    'FaceVertexCData', color1, 'FaceAlpha', 0.55, 'EdgeColor', 'k', 'Visible', 'off');
hPan2  = patch(ax2, 'Faces', box3, 'Vertices', boxV(:,1:2), 'FaceColor', 'flat', ...
    'FaceVertexCData', color1, 'FaceAlpha', 0.45, 'EdgeColor', 'k', 'Visible', 'off');
hDots3 = plot3(ax3, NaN, NaN, NaN, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 6, 'Visible', 'off');
hDots2 = plot(ax2, NaN, NaN, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 6, 'Visible', 'off');

% Direction arrows along the curve + start/end markers
nanA = NaN(1, nArr);
hArrow3 = quiver3(ax3, nanA, nanA, nanA, nanA, nanA, nanA, 0, ...
    'Color', 'k', 'LineWidth', 2, 'MaxHeadSize', 2.5);
hStart3 = plot3(ax3, NaN, NaN, NaN, 'o', 'MarkerFaceColor', [0.1 0.7 0.2], ...
    'MarkerEdgeColor', 'k', 'MarkerSize', 9, 'LineWidth', 1.2);   % start
hEnd3   = plot3(ax3, NaN, NaN, NaN, 's', 'MarkerFaceColor', 'k', ...
    'MarkerEdgeColor', 'k', 'MarkerSize', 8);                     % end

%% Dragging: clicks in the 3D axes grab the nearest control point
set(ax3.Children, 'HitTest', 'off', 'PickableParts', 'none')
ax3.ButtonDownFcn = @startDrag;
dragIdx = [];

%% Build UI
NumControls = 3;
% The last slider step (nMax + 1) stands for n -> infinity
sN      = app.addControl('slider', '$n = $', 1, NumControls, @updatePlot, ...
    'Default', n0, 'Min', 0, 'Max', nMax + 1, 'Number_format', '%d', ...
    'Step', 1, 'LimitLabel', '$n \to \infty$');
btn1D   = app.addControl('button', 'Show 1D Plot', 2, NumControls, @toggle1D, ...
    'ColorChange', true, 'Toggle', ["Show 1D Plot", "Hide 1D Plot"]);
btnView = app.addControl('button', '', 3, NumControls, @toggleView, ...
    'Toggle', ["Rotate to 3D view", "Rotate to top view"]);
btn1D.Value   = Show1D;

redraw(n0)
applyLayout()

%% Callbacks
function updatePlot(~, ~)
    redraw(round(sN.Value))
end

% Smoothly turn the camera between the top view and the 3D view
function toggleView(~, ~)
    if btnView.Value
        Animate_View(ax3, view3D(1), view3D(2))
    else
        Animate_View(ax3, 0, 90)
    end
end

function toggle1D(~, ~)
    Show1D = logical(btn1D.Value);
    applyVisibility()
    applyLayout()
end

function startDrag(~, ~)
    P = clickOnGround(ax3);
    if isempty(P), return, end
    [d, idx] = min(hypot(px - P(1), py - P(2)));
    if d < 0.08*diff(xlim(ax3))
        dragIdx = idx;
        app.fig.WindowButtonMotionFcn = @doDrag;
        app.fig.WindowButtonUpFcn     = @stopDrag;
    end
end

function doDrag(~, ~)
    P = clickOnGround(ax3);
    if isempty(P) || isempty(dragIdx), return, end
    px(dragIdx) = max(-bound, min(bound, P(1)));
    py(dragIdx) = max(-bound, min(bound, P(2)));
    redraw(round(sN.Value))
end

function stopDrag(~, ~)
    dragIdx = [];
    app.fig.WindowButtonMotionFcn = '';
    app.fig.WindowButtonUpFcn     = '';
end

%% Layout: 3D axes fills the whole plot region when the 1D plot is hidden
function applyLayout()
    if Show1D
        ax3.OuterPosition = posSplit3;
        pick = 'all';
        try, uistack(ax2, 'top'), catch, end      % 1D y label on top
    else
        ax3.OuterPosition = posFull3;
        pick = 'none';
    end
    % The hidden 1D axes must not swallow clicks meant for the 3D axes
    ax2.HitTest = onoff(Show1D);
    ax2.PickableParts = pick;
    set(ax2.Children, 'HitTest', onoff(Show1D), 'PickableParts', pick)
    if ~Show1D
        try, uistack(ax3, 'top'), catch, end
    end
end

%% Visibility for the current toggle states
function applyVisibility()
    % n -> infinity shows the continuous curtain, finite n the panels
    isLimit = app.isAtLimit(sN);
    set(hLine3, 'Visible', onoff(isLimit))
    set([hPan3 hDots3], 'Visible', onoff(~isLimit))
    % 2D objects also require the 1D plot to be shown
    set(hLine2, 'Visible', onoff(isLimit && Show1D))
    set([hPan2 hDots2], 'Visible', onoff(~isLimit && Show1D))
    set(hCurve2, 'Visible', onoff(Show1D))
    set([ax2, ax2.Title, ax2.XLabel, ax2.YLabel], 'Visible', onoff(Show1D))
end

%% Main Draw update function.
function redraw(n)
    % Spline through the control points, chord-length parameterization
    cum = [0, cumsum(hypot(diff(px), diff(py)))];
    tp  = cum/cum(end);
    xFine = ppval(spline(tp, px), tFine);
    yFine = ppval(spline(tp, py), tFine);
    zFine = f(xFine, yFine);

    ds = hypot(diff(xFine), diff(yFine));
    sFine = [0, cumsum(ds)];
    S_total = sFine(end);
    I_exact = sum((zFine(1:end-1) + zFine(2:end))/2 .* ds);   % trapezoid rule

    set(hCurve3, 'XData', xFine, 'YData', yFine, 'ZData', zFine)
    set(hProj3,  'XData', xFine, 'YData', yFine, 'ZData', zeros(1,Nfine))
    set(hCP3,    'XData', px, 'YData', py)

    % Direction arrows on the z = 0 projection, equally spaced in arc length
    sA = ((1:nArr) - 0.5)/nArr * S_total;
    xA = interp1(sFine, xFine, sA);
    yA = interp1(sFine, yFine, sA);
    tx = interp1(sFine, gradient(xFine, sFine), sA);
    ty = interp1(sFine, gradient(yFine, sFine), sA);
    nr = hypot(tx, ty);
    U = arrLen*tx./nr;  V = arrLen*ty./nr;  W = zeros(1, nArr);
    set(hArrow3, 'XData', xA - U/2, 'YData', yA - V/2, 'ZData', zeros(1, nArr), ...
        'UData', U, 'VData', V, 'WData', W)

    set(hStart3, 'XData', xFine(1),   'YData', yFine(1),   'ZData', 0)
    set(hEnd3,   'XData', xFine(end), 'YData', yFine(end), 'ZData', 0)

    set(hLine3, 'Vertices', [xFine(:) yFine(:) zFine(:); xFine(:) yFine(:) zeros(Nfine,1)])
    set(hLine2, 'XData', [sFine fliplr(sFine)], 'YData', [zFine zeros(1,Nfine)])
    set(hCurve2, 'XData', sFine, 'YData', zFine)
    xlim(ax2, [0 S_total]); ylim(ax2, [0 max(1.25*max(zFine), 0.1)])

    isLimit = app.isAtLimit(sN);
    if isLimit
        title(ax2, splitlines(sprintf('$n \\to \\infty$: area under $f$ along $C$\nLine integral $= %.5f$', I_exact)))
    else
        % Equal arc-length partition into n pieces, midpoint heights
        sEdges = linspace(0, S_total, n+1);
        xe = interp1(sFine, xFine, sEdges);  ye = interp1(sFine, yFine, sEdges);
        sm = 0.5*(sEdges(1:n) + sEdges(2:n+1));
        xm = interp1(sFine, xFine, sm);      ym = interp1(sFine, yFine, sm);
        fm = f(xm, ym);
        approx = sum(fm.*diff(sEdges));

        faces = reshape(1:4*n, 4, n).';
        cdata = panelColors(mod(0:n-1, 2) + 1, :);
        z0 = zeros(1, n);

        V3 = [reshape([xe(1:n); xe(2:n+1); xe(2:n+1); xe(1:n)], [], 1), ...
              reshape([ye(1:n); ye(2:n+1); ye(2:n+1); ye(1:n)], [], 1), ...
              reshape([z0; z0; fm; fm], [], 1)];
        set(hPan3, 'Faces', faces, 'Vertices', V3, 'FaceVertexCData', cdata)
        % Midpoint dots on the z = 0 projection
        set(hDots3, 'XData', xm, 'YData', ym, 'ZData', z0)

        V2 = [reshape([sEdges(1:n); sEdges(2:n+1); sEdges(2:n+1); sEdges(1:n)], [], 1), ...
              reshape([z0; z0; fm; fm], [], 1)];
        set(hPan2, 'Faces', faces, 'Vertices', V2, 'FaceVertexCData', cdata)
        set(hDots2, 'XData', sm, 'YData', fm)

        title(ax2, splitlines(sprintf('Riemann Sum on Arc-Length Axis\nApprox = %.5f    Line integral = %.5f', approx, I_exact)))
    end
    title(ax3, '$\int_C f(x,y)ds= \lim_{n\to\infty}\sum_{i=1}^n f(x_i^*,y_i^*)\Delta s_i$ $\\$ Drag the yellow diamonds to change $C$')

    applyVisibility()
    drawnow limitrate
end

end

%% Stateless helpers
function P = clickOnGround(ax)
% Where the mouse ray through the 3D axes hits the z = 0 plane ([] if parallel)
cp = ax.CurrentPoint;
dz = cp(2,3) - cp(1,3);
if abs(dz) < 1e-10
    P = [];
else
    P = cp(1,1:2) - cp(1,3)/dz*(cp(2,1:2) - cp(1,1:2));
end
end