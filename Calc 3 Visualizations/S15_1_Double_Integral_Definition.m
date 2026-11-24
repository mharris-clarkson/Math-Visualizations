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
Pretty_Color_Positive(app.ax, zs);   % amp colormap on [0, max f] + colorbar
Pretty_Plot(app.ax)
zlabel(app.ax, 'f(x,y)')

%% Riemann-prism graphics: 3 patch objects + 1 line, created once and
% updated in place (set Faces/Vertices) each time N changes
PrismBottom = patch(app.ax, 'Faces', zeros(0,4), 'Vertices', zeros(0,3), ...
    'FaceColor', prismColor, 'EdgeColor', 'k', 'FaceAlpha', 0.25);
PrismSide   = patch(app.ax, 'Faces', zeros(0,4), 'Vertices', zeros(0,3), ...
    'FaceColor', prismColor, 'EdgeColor', 'k', 'FaceAlpha', 0.6);
PrismTop    = patch(app.ax, 'Faces', zeros(0,4), 'Vertices', zeros(0,3), ...
    'FaceColor', prismColor, 'EdgeColor', 'k', 'FaceAlpha', 0.9);
SamplePts   = plot3(app.ax, NaN, NaN, NaN, 'ko', ...
    'MarkerFaceColor', 'k', 'MarkerSize', 4);
Ncurrent    = NaN;   % N currently drawn (skip redraws when N has not changed)

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
    % The slider moves continuously but N is a whole number: only rebuild
    % the prisms when N actually changes
    if Nside == Ncurrent, return, end
    Ncurrent = Nside;

    dx = (b - a)/Nside;
    dy = (d - c)/Nside;
    [x, y] = meshgrid(linspace(a + dx/2, b - dx/2, Nside), ...
                       linspace(c + dy/2, d - dy/2, Nside));
    z = f(x, y);

    integral_approx = sum(z(:))*dx*dy;

    [V, bottomFaces, topFaces, sideFaces] = buildPrismMesh(x(:), y(:), z(:), dx, dy);

    % Vertices first, then Faces, in one set() call per object
    set(PrismBottom, 'Vertices', V, 'Faces', bottomFaces)
    set(PrismSide,   'Vertices', V, 'Faces', sideFaces)
    set(PrismTop,    'Vertices', V, 'Faces', topFaces)
    set(SamplePts,   'XData', x(:), 'YData', y(:), 'ZData', z(:))

    % splitlines: a newline inside one LaTeX string does not start a new
    % line; '$|$' because a bare | in LaTeX text mode prints as a dash
    title(app.ax, splitlines(sprintf(['Double Integral Approximation with %d cubes\n' ...
        'Riemann Approximation = %.6f   $|$   Exact Integral = %.6f'], ...
        Nside^2, integral_approx, exactIntegral)))
end

end