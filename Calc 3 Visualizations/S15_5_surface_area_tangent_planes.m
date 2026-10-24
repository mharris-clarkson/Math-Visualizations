function S15_5_surface_area_tangent_planes()
%% Surface Area via Tangent Planes
% Approximates the area of a bump surface by summing tangent-plane patches
% taken at the center of each cell of an N x N grid, and compares it with a
% high-resolution reference value. Each tangent plane shows its center
% point, normal vector (blue), and the fx / fy direction vectors (green).
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

close all

%% User parameters for math objects
r2 = @(x,y) x.^2 + y.^2;
fRaw = @(x,y) 2*exp(1)*exp(1 ./ (r2(x,y)-1 + (r2(x,y)>=1)));
f  = @(x,y) (r2(x,y)<1) .* fRaw(x,y);

h  = 1e-5;   % finite-difference step for partial derivatives
fx = @(x,y) (f(x+h,y) - f(x-h,y)) / (2*h);
fy = @(x,y) (f(x,y+h) - f(x,y-h)) / (2*h);

xlims = [-1 1]; ylims = [-1 1];
resHigh = 200;      % resolution of the reference surface / "true" area
resLow0 = 1;        % initial N
resMax  = 100;       % largest N on the slider
arrowLen = 0.2;     % length of the normal / fx / fy arrows

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('Surface Area Approximation', 1);
ax = app.ax(1);

Pretty_Plot(ax)
axis(ax, 'equal')
xlabel(ax, 'x'); ylabel(ax, 'y'); zlabel(ax, 'z')
xlim(ax, xlims); ylim(ax, ylims)
view(ax, -38, 20)

%% Reference surface and "true" surface area (fully vectorized, no loops)
[XH, YH] = meshgrid(linspace(xlims(1), xlims(2), resHigh), ...
                    linspace(ylims(1), ylims(2), resHigh));
ZH = f(XH, YH);
surf(ax, XH, YH, ZH, 'FaceAlpha', 0.5, 'EdgeColor', 'none');

dxH = XH(1,2) - XH(1,1);
dyH = YH(2,1) - YH(1,1);
xcH = movmean(movmean(XH, 2, 1, 'Endpoints', 'discard'), 2, 2, 'Endpoints', 'discard');
ycH = movmean(movmean(YH, 2, 1, 'Endpoints', 'discard'), 2, 2, 'Endpoints', 'discard');
SurfaceAreaTrue = sum(dxH*dyH*sqrt(1 + fx(xcH,ycH).^2 + fy(xcH,ycH).^2), 'all');

%% Tangent-plane graphics: 5 objects total, created once, updated via set()
% (The original created 5 objects per cell and deleted/recreated all of
% them on every slider move -- thousands of graphics objects at N = 31.)
c = computeCells(resLow0);
planePatch = patch(ax, 'Faces', c.Faces, 'Vertices', c.Vertices, ...
    'FaceColor', 'r', 'EdgeColor', 'k');
centerDots = plot3(ax, c.xc, c.yc, c.zc, 'ko', 'MarkerFaceColor', 'y', ...
    'MarkerSize', 6, 'LineStyle', 'none');
normalArrows = quiver3(ax, c.xc, c.yc, c.zc, c.n(:,1), c.n(:,2), c.n(:,3), 0, ...
    'Color', 'b', 'LineWidth', 1.5, 'MaxHeadSize', 1);
fxArrows = quiver3(ax, c.xc, c.yc, c.zc, c.tx(:,1), c.tx(:,2), c.tx(:,3), 0, ...
    'Color', 'g', 'LineWidth', 1.5, 'MaxHeadSize', 1);
fyArrows = quiver3(ax, c.xc, c.yc, c.zc, c.ty(:,1), c.ty(:,2), c.ty(:,3), 0, ...
    'Color', 'g', 'LineWidth', 1.5, 'MaxHeadSize', 1);
setTitle(resLow0, c.SA)

%% Build UI
sRes = app.addControl('slider', '$N = $', 1, 1, @updateResolution, ...
    'Default', resLow0, 'Min', 1, 'Max', resMax, 'Number_format', '%d');

%% Callback: recompute all cells in one shot and update the 5 objects in place
function updateResolution(~, ~)
    N = max(1, round(sRes.Value));
    c = computeCells(N);
    set(planePatch, 'Faces', c.Faces, 'Vertices', c.Vertices)
    set(centerDots, 'XData', c.xc, 'YData', c.yc, 'ZData', c.zc)
    set(normalArrows, 'XData', c.xc, 'YData', c.yc, 'ZData', c.zc, ...
        'UData', c.n(:,1),  'VData', c.n(:,2),  'WData', c.n(:,3))
    set(fxArrows, 'XData', c.xc, 'YData', c.yc, 'ZData', c.zc, ...
        'UData', c.tx(:,1), 'VData', c.tx(:,2), 'WData', c.tx(:,3))
    set(fyArrows, 'XData', c.xc, 'YData', c.yc, 'ZData', c.zc, ...
        'UData', c.ty(:,1), 'VData', c.ty(:,2), 'WData', c.ty(:,3))
    setTitle(N, c.SA)
    drawnow limitrate
end

function setTitle(N, SA)
    t = sprintf('Surface Area: True = %.5f, Approx = %.5f, Number Planes = %d', ...
        SurfaceAreaTrue, SA, N^2);
    title(ax, t)
    app.fig.Name = t;
end

%% Vectorized geometry for an N x N grid of tangent planes (no per-cell loop)
function c = computeCells(N)
    dx = (xlims(2)-xlims(1))/N;
    dy = (ylims(2)-ylims(1))/N;
    [I, J] = ndgrid(1:N, 1:N);
    x0 = xlims(1) + (I(:)-1)*dx;   x1 = x0 + dx;
    y0 = ylims(1) + (J(:)-1)*dy;   y1 = y0 + dy;
    xc = (x0+x1)/2;  yc = (y0+y1)/2;  zc = f(xc, yc);
    dfdx = fx(xc, yc);  dfdy = fy(xc, yc);

    % Tangent-plane corners, one row per cell: [x0 x1 x1 x0], [y0 y0 y1 y1]
    xq = [x0 x1 x1 x0];
    yq = [y0 y0 y1 y1];
    zq = zc + dfdx.*(xq - xc) + dfdy.*(yq - yc);

    nCells = N^2;
    c.Vertices = [reshape(xq.', [], 1), reshape(yq.', [], 1), reshape(zq.', [], 1)];
    c.Faces    = reshape(1:4*nCells, 4, nCells).';
    c.xc = xc;  c.yc = yc;  c.zc = zc;

    one = ones(nCells, 1);  zer = zeros(nCells, 1);
    c.n  = unitRows([-dfdx, -dfdy, one]) * arrowLen;   % normal
    c.tx = unitRows([one, zer, dfdx])    * arrowLen;   % along x
    c.ty = unitRows([zer, one, dfdy])    * arrowLen;   % along y

    c.SA = sum(dx*dy*sqrt(1 + dfdx.^2 + dfdy.^2));
end

end

%% Stateless helper
function V = unitRows(V)
V = V ./ sqrt(sum(V.^2, 2));
end