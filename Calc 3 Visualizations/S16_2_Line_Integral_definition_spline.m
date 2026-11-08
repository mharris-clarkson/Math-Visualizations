function S16_2_Line_Integral_definition_spline()
%% Line Integral Definition Visualized -- Spline Curve
% The curve C is a cubic spline through 6 draggable control points in the
% xy-plane (parameterized by chord length). Drag any red control point in
% the 3D view to reshape C; the curtain, the arc-length plot and the Riemann
% sum all update.
%
%   Left  : 3D view (surface, curve, control points, curtain panels)
%   Right : 2D "unrolled" Riemann sum on the arc-length axis
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

close all

%% User parameters for math objects
f  = @(x,y) 1.5 + 0.8*sin(2*x).*cos(1.5*y);       % surface / integrand (positive everywhere)

t6 = linspace(0, 1, 6);
px = cos(pi*t6);            % control points: start roughly on an upper semicircle
py = sin(pi*t6);
bound = 1.5;                % control points are clamped to [-bound, bound]^2

Nfine = 600;                % points used to draw the spline
n0 = 8;  nMax = 80;         % initial / maximum number of panels
ShowLineInt = true;         % initial toggle states
ShowPanels  = false;

color1 = [0.15 0.35 0.75];  % alternating panel colors (blue / orange)
color2 = [0.95 0.55 0.15];
color3 = [0.20 0.65 0.45];  % line-integral area (green)
cpColor = [0.85 0.10 0.10]; % control points
nGrid = 60;                 % surface grid resolution

panelColors = [color1; color2];
tFine = linspace(0, 1, Nfine);

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('Line Integral - Spline Curve', 2);
ax3 = app.ax(1);
ax2 = app.ax(2);
Pretty_Plot(app.ax)

%% Static graphics in the 3D axes
[xg, yg] = meshgrid(linspace(-bound, bound, nGrid));
surf(ax3, xg, yg, f(xg,yg), 'EdgeColor', 'none', 'FaceAlpha', 0.8, 'FaceColor', 'interp');
colormap(ax3,cmocean('amp'));
clim(ax3,max(max(f(xg,yg)))*[0,1])
surf(ax3, xg, yg, zeros(size(xg)), 'FaceColor', [0.88 0.88 0.88], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
xlabel(ax3, 'x'); ylabel(ax3, 'y'); zlabel(ax3, 'z = f(x,y)')
view(ax3, -40, 25)
xlim(ax3, bound*1.07*[-1 1]); ylim(ax3, bound*1.07*[-1 1])

xlabel(ax2, 'Arc length  s'); ylabel(ax2, 'f(x(s), y(s))')

%% Preallocated dynamic graphics: ONE object per kind, updated in place
% (No object is ever deleted or recreated while dragging or sliding.)
box3 = [1 2 3 4];  boxV = zeros(4,3);
nanv = NaN(1, Nfine);
% Line-integral curtain: a strip of quads (top row on the curve, bottom row on z = 0)
qi = 1:Nfine-1;
curtainFaces = [qi; qi+1; Nfine+qi+1; Nfine+qi].';
hLine3 = patch(ax3, 'Faces', curtainFaces, 'Vertices', NaN(2*Nfine,3), ...
    'FaceColor', color3, 'FaceAlpha', 0.45, 'EdgeColor', 'none');
hLine2 = patch(ax2, nanv, nanv, color3, 'FaceAlpha', 0.40, 'EdgeColor', 'none');
hCurve3 = plot3(ax3, nanv, nanv, nanv, 'k', 'LineWidth', 2);                 % curve on surface
hProj3  = plot3(ax3, nanv, nanv, nanv, 'k--', 'LineWidth', 1);               % projection on z = 0
hPoly3  = plot3(ax3, px, py, zeros(1,6), ':', 'Color', cpColor, 'LineWidth', 1.2);
hCP3    = plot3(ax3, px, py, zeros(1,6), 'o', 'Color', cpColor, 'MarkerFaceColor', cpColor, ...
    'MarkerSize', 10, 'LineWidth', 1.5);
hCurve2 = plot(ax2, nanv, nanv, 'k', 'LineWidth', 2);
hPan3  = patch(ax3, 'Faces', box3, 'Vertices', boxV, 'FaceColor', 'flat', ...
    'FaceVertexCData', color1, 'FaceAlpha', 0.55, 'EdgeColor', 'k', 'Visible', 'off');
hPan2  = patch(ax2, 'Faces', box3, 'Vertices', boxV(:,1:2), 'FaceColor', 'flat', ...
    'FaceVertexCData', color1, 'FaceAlpha', 0.45, 'EdgeColor', 'k', 'Visible', 'off');
hDots3 = plot3(ax3, NaN, NaN, NaN, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6, 'Visible', 'off');
hDots2 = plot(ax2, NaN, NaN, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6, 'Visible', 'off');

%% Dragging: clicks in the 3D axes grab the nearest control point
% (every 3D object ignores clicks so they all reach the axes' ButtonDownFcn)
set(ax3.Children, 'HitTest', 'off', 'PickableParts', 'none')
ax3.ButtonDownFcn = @startDrag;
dragIdx = [];

%% Build UI
sN      = app.addControl('slider', '$n = $', 1, 3, @updatePlot, ...
    'Default', n0, 'Min', 4, 'Max', nMax, 'Number_format', '%d');
btnLine = app.addControl('button', 'Hide Line Integral', 2, 3, @toggleLineInt, 'ColorChange', true);
btnPan  = app.addControl('button', 'Show Panels', 3, 3, @togglePanels, 'ColorChange', true);
btnLine.Value = ShowLineInt;
btnPan.Value  = ShowPanels;

redraw(n0)

%% Callbacks
function updatePlot(~, ~)
    redraw(round(sN.Value))
end

function toggleLineInt(~, ~)
    ShowLineInt = logical(btnLine.Value);
    if ShowLineInt, btnLine.String = 'Hide Line Integral'; else, btnLine.String = 'Show Line Integral'; end
    set([hLine3 hLine2], 'Visible', onoff(ShowLineInt))
end

function togglePanels(~, ~)
    ShowPanels = logical(btnPan.Value);
    if ShowPanels, btnPan.String = 'Hide Panels'; else, btnPan.String = 'Show Panels'; end
    redraw(round(sN.Value))
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

%% Redraw: re-evaluates the spline and updates every preallocated object in place
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
    I_exact = sum(zFine(1:end-1).*ds);

    % Curve, projection, control points, line-integral area (3D and 2D)
    set(hCurve3, 'XData', xFine, 'YData', yFine, 'ZData', zFine)
    set(hProj3,  'XData', xFine, 'YData', yFine, 'ZData', zeros(1,Nfine))
    set(hPoly3,  'XData', px, 'YData', py)
    set(hCP3,    'XData', px, 'YData', py)
    set(hLine3, 'Vertices', [xFine(:) yFine(:) zFine(:); xFine(:) yFine(:) zeros(Nfine,1)])
    set(hLine2, 'XData', [sFine fliplr(sFine)], 'YData', [zFine zeros(1,Nfine)])
    set(hCurve2, 'XData', sFine, 'YData', zFine)
    xlim(ax2, [0 S_total]); ylim(ax2, [0 max(1.25*max(zFine), 0.1)])

    set([hLine3 hLine2], 'Visible', onoff(ShowLineInt))
    set([hPan3 hPan2 hDots3 hDots2], 'Visible', onoff(ShowPanels))

    if ShowPanels
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
        set(hDots3, 'XData', xm, 'YData', ym, 'ZData', fm)

        V2 = [reshape([sEdges(1:n); sEdges(2:n+1); sEdges(2:n+1); sEdges(1:n)], [], 1), ...
              reshape([z0; z0; fm; fm], [], 1)];
        set(hPan2, 'Faces', faces, 'Vertices', V2, 'FaceVertexCData', cdata)
        set(hDots2, 'XData', sm, 'YData', fm)

        title(ax2, sprintf('Riemann Sum on Arc-Length Axis\nApprox = %.5f    Line integral = %.5f', approx, I_exact))
    else
        title(ax2, sprintf('f along the arc-length axis\nLine integral = %.5f', I_exact))
    end
    title(ax3, sprintf('3D curtain  (n = %d panels) - drag the red dots', n))
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

function s = onoff(tf)
if tf
    s = 'on';
else
    s = 'off';
end
end