function S15_2_Double_Integral_General_Region()
%% Double Integral over a General (Curvy) Region
% Visualizes a Riemann-sum approximation to the double integral of a bump
% function over a leaf-shaped region bounded by a closed curve through the
% origin, compared against a fine-grid estimate of the exact integral. A
% slider controls grid resolution; a button toggles masking the surface
% to show only the values inside the region.
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
Nmax = 100;   % slider upper bound

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

% Force the positive-x branch to a straight vertical line
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

%% "Exact" integral, via a fine grid restricted to the region
[xg, yg]      = meshgrid(linspace(xlims(1), xlims(2), resExact), ...
                          linspace(ylims(1), ylims(2), resExact));
inRegionFine  = inpolygon(xg, yg, Xb, Yb);
cellArea      = (xlims(2)-xlims(1))*(ylims(2)-ylims(1))/numel(xg);
exactIntegral = sum(f(xg(inRegionFine), yg(inRegionFine)))*cellArea;

%% Surface
[xs, ys] = meshgrid(linspace(xlims(1), xlims(2), resSurf), ...
                     linspace(ylims(1), ylims(2), resSurf));
zs       = f(xs, ys);
maskSurf = inpolygon(xs, ys, Xb, Yb);

hSurf = surf(app.ax, xs, ys, zs, zs, 'EdgeColor', 'none', 'FaceAlpha', 0.95);
cmocean('amp')
colorbar(app.ax)
Pretty_Plot(app.ax)
zlabel(app.ax, 'f(x,y)')

%% Vertical boundary "curtain" along the region's edge -- one patch object
% for all segments instead of one fill3 call per curve segment.
zmax = max(zs(:));
nSeg = numel(Xb) - 1;
V = [Xb(1:end-1).', Yb(1:end-1).', zeros(nSeg,1); ...
     Xb(2:end).',   Yb(2:end).',   zeros(nSeg,1); ...
     Xb(2:end).',   Yb(2:end).',   zmax*ones(nSeg,1); ...
     Xb(1:end-1).', Yb(1:end-1).', zmax*ones(nSeg,1)];
curtainFaces = (1:nSeg).' + [0, nSeg, 2*nSeg, 3*nSeg];
patch(app.ax, 'Faces', curtainFaces, 'Vertices', V, ...
    'FaceColor', 'k', 'FaceAlpha', 0.3, 'EdgeColor', 'k');

%% Riemann-prism graphics: rebuilt (as 3 patch objects) each time N changes
PrismTop    = gobjects(0);
PrismBottom = gobjects(0);
PrismSide   = gobjects(0);
SamplePts   = gobjects(0);

redraw(N0)

%% Build UI
NumControls = 2;
nSlider = app.addControl('slider', '$N = $', 1, NumControls, @updatePlot, ...
'colOrRow', 'row', 'Default', N0, 'Min', 1, 'Max', Nmax, 'Number_format', '%d');
btnMask = app.addControl('button', 'Mask OFF', 2, NumControls, @toggleMask, ...
'ColorChange', true, 'colOrRow', 'row');

%% Callbacks
function updatePlot(~, ~)
    redraw(round(nSlider.Value))
end

function toggleMask(~, ~)
    if logical(btnMask.Value)
        set(hSurf, 'ZData', zs.*maskSurf, 'CData', zs.*maskSurf)
        btnMask.String = 'Mask ON';
    else
        set(hSurf, 'ZData', zs, 'CData', zs)
        btnMask.String = 'Mask OFF';
    end
end

%% Riemann-prism builder.
% Vectorized: finds which candidate cell centers lie inside the region
% with one inpolygon call, then builds all of those prisms as three patch
% objects in one shot -- instead of looping over every candidate cell,
% testing inpolygon one point at a time, and calling fill3 six times for
% each cell that passes.
function redraw(Nside)
    delete([PrismTop, PrismBottom, PrismSide, SamplePts])

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

    PrismBottom = patch(app.ax, 'Faces', bottomFaces, 'Vertices', V, ...
        'FaceColor', prismColor, 'EdgeColor', 'k', 'FaceAlpha', 0.25);
    PrismSide   = patch(app.ax, 'Faces', sideFaces, 'Vertices', V, ...
        'FaceColor', prismColor, 'EdgeColor', 'k', 'FaceAlpha', 0.6);
    PrismTop    = patch(app.ax, 'Faces', topFaces, 'Vertices', V, ...
        'FaceColor', prismColor, 'EdgeColor', 'k', 'FaceAlpha', 0.9);
    SamplePts   = plot3(app.ax, x, y, z, 'ko', ...
        'MarkerFaceColor', 'k', 'MarkerSize', 4);

    title(app.ax, sprintf(['Double Integral Approximation over Curvy Region\n' ...
        'Number cubes = %d   Cubes inside region = %d\n' ...
        'Riemann Approx = %.6f   |   Exact = %.6f'], ...
        Nside^2, totalCubes, integral_approx, exactIntegral))
end

end

%% Stateless helper (ordinary local function, not nested -- it only needs
% its inputs, not the app's shared workspace; identical to the one used
% in the rectangular double-integral port). Builds the vertex/face
% arrays for a grid of n axis-aligned prisms, each with base
% [xi-dx/2,xi+dx/2] x [yj-dy/2,yj+dy/2] and height zij.
function [V, bottomFaces, topFaces, sideFaces] = buildPrismMesh(xi, yj, zij, dx, dy)
xi = xi(:); yj = yj(:); zij = zij(:);
n = numel(xi);
cornerDX = dx/2*[-1, 1, 1, -1];
cornerDY = dy/2*[-1, -1, 1, 1];

CX = xi + cornerDX;     % n x 4: corner x-coords (same at bottom and top)
CY = yj + cornerDY;     % n x 4: corner y-coords (same at bottom and top)
Zb = zeros(n, 4);
Zt = repmat(zij, 1, 4);

Vx = reshape([CX, CX].', [], 1);
Vy = reshape([CY, CY].', [], 1);
Vz = reshape([Zb, Zt].', [], 1);
V  = [Vx, Vy, Vz];       % 8n x 3

base        = 8*(0:n-1).';
bottomFaces = base + (1:4);
topFaces    = base + (5:8);
sideFaces   = [base + [1 2 6 5]; ...
               base + [2 3 7 6]; ...
               base + [3 4 8 7]; ...
               base + [4 1 5 8]];
end