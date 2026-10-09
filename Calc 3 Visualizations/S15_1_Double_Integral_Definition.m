function S15_1_Double_Integral_Definition()
%% Double Integral over a Rectangle -- Exact Integral + Gray Prisms
% Visualizes a Riemann-sum (midpoint rule) approximation to the double
% integral of a bump function over a rectangle, as a grid of gray prisms,
% compared against the numerically exact integral. A slider controls the
% number of subdivisions per side, N (so N^2 total prisms).
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

a = -1.3; b = 1.3;   % x-range of the rectangle
c = -1.3; d = 1.3;   % y-range of the rectangle

N0   = 1;    % initial number of subdivisions per side
Nmax = 100;   % slider upper bound

prismColor = [0.85, 0.85, 0.85];

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('Double Integral over a Rectangle', 1);
view(app.ax, 45, 30)

exactIntegral = integral2(f, a, b, c, d, 'AbsTol', 1e-12, 'RelTol', 1e-12);

%% Plot the true surface once -- it never changes as N changes
res = 140;
[xs, ys] = meshgrid(linspace(a, b, res), linspace(c, d, res));
zs = f(xs, ys);
surf(app.ax, xs, ys, zs, zs, 'EdgeColor', 'none', 'FaceAlpha', 0.95)
cmocean('amp')
colorbar(app.ax)
Pretty_Plot(app.ax)
zlabel(app.ax, 'f(x,y)')

%% Riemann-prism graphics: rebuilt (as 3 patch objects) each time N changes
PrismTop    = gobjects(0);
PrismBottom = gobjects(0);
PrismSide   = gobjects(0);
SamplePts   = gobjects(0);

redraw(N0)

%% Build UI
NumControls = 1;
nSlider = app.addControl('slider', '$N = $', 1, NumControls, @updatePlot, ...
'Default', N0, 'Min', 1, 'Max', Nmax, 'Number_format', '%d','colOrRow','row');

%% Callback
function updatePlot(~, ~)
    redraw(round(nSlider.Value))
end

%% Riemann-prism builder.
% Vectorized: builds the whole grid of prisms as three patch objects (top
% faces, bottom faces, side faces) in one shot instead of looping over
% every cube and calling fill3 six times each -- this is what keeps the
% slider responsive even at N = 50 (2500 prisms, 15000 faces).
function redraw(Nside)
    delete([PrismTop, PrismBottom, PrismSide, SamplePts])

    dx = (b - a)/Nside;
    dy = (d - c)/Nside;
    [x, y] = meshgrid(linspace(a + dx/2, b - dx/2, Nside), ...
                       linspace(c + dy/2, d - dy/2, Nside));
    z = f(x, y);

    integral_approx = sum(z(:))*dx*dy;

    [V, bottomFaces, topFaces, sideFaces] = buildPrismMesh(x(:), y(:), z(:), dx, dy);

    PrismBottom = patch(app.ax, 'Faces', bottomFaces, 'Vertices', V, ...
        'FaceColor', prismColor, 'EdgeColor', 'k', 'FaceAlpha', 0.25);
    PrismSide   = patch(app.ax, 'Faces', sideFaces, 'Vertices', V, ...
        'FaceColor', prismColor, 'EdgeColor', 'k', 'FaceAlpha', 0.6);
    PrismTop    = patch(app.ax, 'Faces', topFaces, 'Vertices', V, ...
        'FaceColor', prismColor, 'EdgeColor', 'k', 'FaceAlpha', 0.9);
    SamplePts   = plot3(app.ax, x(:), y(:), z(:), 'ko', ...
        'MarkerFaceColor', 'k', 'MarkerSize', 4);

    title(app.ax, sprintf(['Double Integral Approximation with %d cubes\n' ...
        'Riemann Approximation = %.6f   |   Exact Integral = %.6f'], ...
        Nside^2, integral_approx, exactIntegral))
end

end

%% Stateless helper (ordinary local function, not nested -- it only needs
% its inputs, not the app's shared workspace).
%
% Builds the vertex/face arrays for a grid of n axis-aligned prisms, each
% with base [xi-dx/2,xi+dx/2] x [yj-dy/2,yj+dy/2] and height zij. Each
% prism contributes 8 vertices (4 bottom, 4 top) stored as one contiguous
% 8-row block, so prism k's vertices are rows 8*(k-1)+1 : 8*(k-1)+8 --
% that's what lets the face index arrays below be built with plain
% vectorized arithmetic instead of a loop.
function [V, bottomFaces, topFaces, sideFaces] = buildPrismMesh(xi, yj, zij, dx, dy)
n = numel(xi);
cornerDX = dx/2*[-1, 1, 1, -1];
cornerDY = dy/2*[-1, -1, 1, 1];

Xb = xi + cornerDX;     % n x 4: corner x-coords (same at bottom and top)
Yb = yj + cornerDY;     % n x 4: corner y-coords (same at bottom and top)
Zb = zeros(n, 4);
Zt = repmat(zij, 1, 4);

Vx = reshape([Xb, Xb].', [], 1);
Vy = reshape([Yb, Yb].', [], 1);
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