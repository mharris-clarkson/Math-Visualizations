function S15_2_Double_Integral_General_Region()
%% Double Integral over a General (Curvy) Region
% Visualizes a Riemann-sum approximation to the double integral of a bump
% function over a leaf-shaped region bounded by a closed curve through the
% origin, compared against a fine-grid estimate of the exact integral. A
% slider controls grid resolution; a button shows the surface f only over
% the region (as in the S15_3 double-integral demos).
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

N0   = 1;    % initial number of subdivisions per side
Nmax = 25;   % slider upper bound

prismColor = [0.85, 0.85, 0.85];
resExact   = 500;   % grid resolution for the "exact" integral
resSurf    = 250;   % surface plotting resolution

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('Double Integral over Curvy Region', 1);
view(app.ax, 57, 60)

%% Region boundary: leaf-like closed curve passing through the origin
theta = linspace(0, pi, 300);
Xc = (theta - pi/2)/pi/2;
Yc = sin(theta) + 0.3*sin(2*theta);

% Re-space the positive-x half so it starts exactly at x = 0
posX    = Xc >= 0;
Xc(posX) = linspace(0, max(Xc), nnz(posX));

% Shift so the curve passes through the origin, and close it
Xb = Xc - Xc(1);
Yb = Yc - Yc(1);
if Xb(1) ~= Xb(end)
    Xb(end+1) = Xb(1);
    Yb(end+1) = Yb(1);
end

xlims = [min(Xb), max(Xb)];
ylims = [min(Yb), max(Yb)];

%% "Exact" integral: fine midpoint grid restricted to the region
dxg           = (xlims(2)-xlims(1))/resExact;
dyg           = (ylims(2)-ylims(1))/resExact;
[xg, yg]      = meshgrid(linspace(xlims(1)+dxg/2, xlims(2)-dxg/2, resExact), ...
                          linspace(ylims(1)+dyg/2, ylims(2)-dyg/2, resExact));
inRegionFine  = Inside_Polygon_Grid(xg, yg, Xb, Yb);
cellArea      = dxg*dyg;
exactIntegral = sum(f(xg(inRegionFine), yg(inRegionFine)))*cellArea;

%% Surface
[xs, ys] = meshgrid(linspace(xlims(1), xlims(2), resSurf), ...
                     linspace(ylims(1), ylims(2), resSurf));
zs       = f(xs, ys);
% Same surface with NaN outside the region
zsRegion = zs;
zsRegion(~Inside_Polygon_Grid(xs, ys, Xb, Yb)) = NaN;

hSurf = surf(app.ax, xs, ys, zs, zs, 'EdgeColor', 'none', 'FaceAlpha', 0.95);
Pretty_Color_Positive(app.ax, zs);
Pretty_Plot(app.ax)
zlabel(app.ax, 'f(x,y)')

%% Vertical boundary curtain along the region's edge
zmax = max(zs(:));
nSeg = numel(Xb) - 1;
V = [Xb(1:end-1).', Yb(1:end-1).', zeros(nSeg,1); ...
     Xb(2:end).',   Yb(2:end).',   zeros(nSeg,1); ...
     Xb(2:end).',   Yb(2:end).',   zmax*ones(nSeg,1); ...
     Xb(1:end-1).', Yb(1:end-1).', zmax*ones(nSeg,1)];
curtainFaces = (1:nSeg).' + [0, nSeg, 2*nSeg, 3*nSeg];
patch(app.ax, 'Faces', curtainFaces, 'Vertices', V, ...
    'FaceColor', 'k', 'FaceAlpha', 0.3, 'EdgeColor', 'k');

%% Riemann prisms: created once, updated in place
PrismBottom = patch(app.ax, 'Faces', zeros(0,4), 'Vertices', zeros(0,3), ...
    'FaceColor', prismColor, 'EdgeColor', 'k', 'FaceAlpha', 0.25);
PrismSide   = patch(app.ax, 'Faces', zeros(0,4), 'Vertices', zeros(0,3), ...
    'FaceColor', prismColor, 'EdgeColor', 'k', 'FaceAlpha', 0.6);
PrismTop    = patch(app.ax, 'Faces', zeros(0,4), 'Vertices', zeros(0,3), ...
    'FaceColor', prismColor, 'EdgeColor', 'k', 'FaceAlpha', 0.9);
SamplePts   = plot3(app.ax, NaN, NaN, NaN, 'ko', ...
    'MarkerFaceColor', 'k', 'MarkerSize', 4);
Ncurrent    = NaN;

redraw(N0)

%% Build UI
NumControls = 2;
nSlider = app.addControl('slider', '$N = $', 1, NumControls, @updatePlot, ...
'colOrRow', 'row', 'Default', N0, 'Min', 1, 'Max', Nmax, 'Number_format', '%d');
btnMask = app.addControl('button', '', 2, NumControls, @toggleMask, ...
'colOrRow', 'row', 'Toggle', ["Show $f$ only over the region", "Show $f$ everywhere"]);

%% Callbacks
function updatePlot(~, ~)
    redraw(round(nSlider.Value))
end

% Surface over the region only, or over the whole window
function toggleMask(~, ~)
    if btnMask.Value
        hSurf.ZData = zsRegion;
    else
        hSurf.ZData = zs;
    end
end

%% Riemann-prism builder (cells whose centres are inside the region)
function redraw(Nside)
    if Nside == Ncurrent, return, end
    Ncurrent = Nside;

    dx = (xlims(2) - xlims(1))/Nside;
    dy = (ylims(2) - ylims(1))/Nside;
    [x, y] = meshgrid(linspace(xlims(1)+dx/2, xlims(2)-dx/2, Nside), ...
                       linspace(ylims(1)+dy/2, ylims(2)-dy/2, Nside));

    inside = inpolygon(x, y, Xb, Yb);
    x = x(inside);
    y = y(inside);
    z = f(x, y);

    totalCubes      = numel(x);
    integral_approx = sum(z)*dx*dy;

    [V, bottomFaces, topFaces, sideFaces] = buildPrismMesh(x, y, z, dx, dy);

    set(PrismBottom, 'Vertices', V, 'Faces', bottomFaces)
    set(PrismSide,   'Vertices', V, 'Faces', sideFaces)
    set(PrismTop,    'Vertices', V, 'Faces', topFaces)
    set(SamplePts,   'XData', x, 'YData', y, 'ZData', z)

    title(app.ax, splitlines(sprintf(['Double Integral Approximation over Curvy Region\n' ...
        'Number cubes = %d   Cubes inside region = %d\n' ...
        'Riemann Approx = %.6f   $|$   Exact = %.6f'], ...
        Nside^2, totalCubes, integral_approx, exactIntegral)))
end

end