function S16_2_Line_Integral_definition()
%% Line Integral Definition Visualized
% Bridges the Calc 1 Riemann sum idea and the 3D line integral.
%
% A curve C is parameterized by t in [0, 1] (default: upper semicircle)
%   x(t) = cos(pi*t),  y(t) = sin(pi*t)
% and a surface z = f(x,y) sits above the xy-plane.
%
% The line integral  int_C f ds  is approximated by
%   sum_{k=1}^{n}  f(x(t*_k), y(t*_k)) * Delta_s_k
% where Delta_s_k is the chord length of the k-th piece and t*_k is the
% midpoint of the k-th sub-interval. As n -> inf the sum converges to the
% exact line integral.
%
%   Left  : 3D view (surface + curtain panels)
%   Right : 2D "unrolled" Riemann sum on the arc-length axis
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

close all

%% User parameters for math objects
xC = @(t) cos(pi*t);                              % curve C
yC = @(t) sin(pi*t);
f  = @(x,y) 1.5 + 0.8*sin(2*x).*cos(1.5*y);       % surface / integrand (positive on C)

Nfine = 2000;               % points used to draw the curve and get the "exact" integral
n0 = 4;  nMax = 80;         % initial / maximum number of panels
ShowLineInt = true;         % initial toggle states
ShowPanels  = false;

color1 = [0.15 0.35 0.75];  % alternating panel colors (blue / orange)
color2 = [0.95 0.55 0.15];
color3 = [0.20 0.65 0.45];  % line-integral area (green)
gridLim = [-1.1 1.1];  nGrid = 60;   % extent of the displayed surface

%% Math: fine curve, arc length, exact line integral
tFine = linspace(0, 1, Nfine);
xFine = xC(tFine);  yFine = yC(tFine);
zFine = f(xFine, yFine);
sFine = [0, cumsum(hypot(diff(xFine), diff(yFine)))];   % arc length along C
S_total = sFine(end);
I_exact = trapz(sFine, zFine);

panelColors = [color1; color2];

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('Line Integral Definition', 2);
ax3 = app.ax(1);
ax2 = app.ax(2);
Pretty_Plot(app.ax)

%% Static graphics in the 3D axes
[xg, yg] = meshgrid(linspace(gridLim(1), gridLim(2), nGrid));
surf(ax3, xg, yg, f(xg,yg), 'EdgeColor', 'none', 'FaceAlpha', 0.8, 'FaceColor', 'interp');
colormap(ax3,cmocean('amp'));
clim(ax3,max(max(f(xg,yg)))*[0,1])
plot3(ax3, xFine, yFine, zFine, 'k', 'LineWidth', 2);                    % curve on surface
plot3(ax3, xFine, yFine, zeros(size(xFine)), 'k--', 'LineWidth', 1);     % its projection
surf(ax3, xg, yg, zeros(size(xg)), 'FaceColor', [0.88 0.88 0.88], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
xlabel(ax3, 'x'); ylabel(ax3, 'y'); zlabel(ax3, 'z = f(x,y)')
view(ax3, -40, 25)
xlim(ax3, [-1.2 1.2]); ylim(ax3, [-0.2 1.2])

%% Static graphics in the 2D axes
plot(ax2, sFine, zFine, 'k', 'LineWidth', 2);
xlabel(ax2, 'Arc length  s'); ylabel(ax2, 'f(x(s), y(s))')
xlim(ax2, [0 S_total]); ylim(ax2, [0 1.25*max(zFine)])

%% Preallocated dynamic graphics: ONE object per kind, updated in place
% (All panels are a single patch with n faces -- no per-panel objects are
% ever created or deleted.)
box3 = [1 2 3 4];  boxV = zeros(4,3);
% Line-integral curtain: a strip of quads (top row on the curve, bottom row on z = 0),
% so it follows the curve exactly instead of being one big twisted polygon
qi = 1:Nfine-1;
curtainFaces = [qi; qi+1; Nfine+qi+1; Nfine+qi].';
hLine3 = patch(ax3, 'Faces', curtainFaces, ...
    'Vertices', [xFine(:) yFine(:) zFine(:); xFine(:) yFine(:) zeros(Nfine,1)], ...
    'FaceColor', color3, 'FaceAlpha', 0.45, 'EdgeColor', 'none');
hLine2 = patch(ax2, [sFine fliplr(sFine)], [zFine zeros(1,Nfine)], color3, ...
    'FaceAlpha', 0.40, 'EdgeColor', 'none');
hPan3  = patch(ax3, 'Faces', box3, 'Vertices', boxV, 'FaceColor', 'flat', ...
    'FaceVertexCData', color1, 'FaceAlpha', 0.55, 'EdgeColor', 'k', 'Visible', 'off');
hPan2  = patch(ax2, 'Faces', box3, 'Vertices', boxV(:,1:2), 'FaceColor', 'flat', ...
    'FaceVertexCData', color1, 'FaceAlpha', 0.45, 'EdgeColor', 'k', 'Visible', 'off');
hDots3 = plot3(ax3, NaN, NaN, NaN, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6, 'Visible', 'off');
hDots2 = plot(ax2, NaN, NaN, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6, 'Visible', 'off');

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

%% Redraw: panel geometry for n pieces, all vectorized, written into the preallocated patches
function redraw(n)
    set([hLine3 hLine2], 'Visible', onoff(ShowLineInt))
    set([hPan3 hPan2 hDots3 hDots2], 'Visible', onoff(ShowPanels))

    if ShowPanels
        tEdges = linspace(0, 1, n+1);
        tMid   = 0.5*(tEdges(1:n) + tEdges(2:n+1));
        xe = xC(tEdges);  ye = yC(tEdges);
        xm = xC(tMid);    ym = yC(tMid);
        fm = f(xm, ym);

        DeltaS = hypot(diff(xe), diff(ye));      % chord lengths
        se = [0, cumsum(DeltaS)];                % arc-length edges
        sm = 0.5*(se(1:n) + se(2:n+1));
        approx = sum(fm.*DeltaS);

        faces = reshape(1:4*n, 4, n).';
        cdata = panelColors(mod(0:n-1, 2) + 1, :);
        z0 = zeros(1, n);

        % 3D curtain panels: corners (edge k, edge k+1) at heights 0 and f(mid)
        V3 = [reshape([xe(1:n); xe(2:n+1); xe(2:n+1); xe(1:n)], [], 1), ...
              reshape([ye(1:n); ye(2:n+1); ye(2:n+1); ye(1:n)], [], 1), ...
              reshape([z0; z0; fm; fm], [], 1)];
        set(hPan3, 'Faces', faces, 'Vertices', V3, 'FaceVertexCData', cdata)
        set(hDots3, 'XData', xm, 'YData', ym, 'ZData', fm)

        % 2D Riemann rectangles on the arc-length axis
        V2 = [reshape([se(1:n); se(2:n+1); se(2:n+1); se(1:n)], [], 1), ...
              reshape([z0; z0; fm; fm], [], 1)];
        set(hPan2, 'Faces', faces, 'Vertices', V2, 'FaceVertexCData', cdata)
        set(hDots2, 'XData', sm, 'YData', fm)

        title(ax3, sprintf('3D curtain  (n = %d panels)', n))
        title(ax2, sprintf('Riemann Sum on Arc-Length Axis\nApprox = %.5f    Exact = %.5f', approx, I_exact))
    else
        title(ax3, '3D view')
        title(ax2, sprintf('f along the arc-length axis\nLine integral = %.5f', I_exact))
    end
    drawnow limitrate
end

end

%% Stateless helper
function s = onoff(tf)
if tf
    s = 'on';
else
    s = 'off';
end
end