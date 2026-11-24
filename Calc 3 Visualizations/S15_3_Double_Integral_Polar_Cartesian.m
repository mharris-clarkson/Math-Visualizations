function S15_3_Double_Integral_Polar_Cartesian()
%% Double Integral over a Curvy Region -- Cartesian Riemann Prisms
% Approximates the double integral of a bump function over a circular
% leaf-shaped region with axis-aligned (x,y) prisms, keeping only the
% ones whose center lies inside the region. Companion to
% S15_3_Double_Integral_Polar_Polar, which approximates the same
% integral with polar wedges instead -- both share DoubleIntegralCurvyEngine.
% A button shows the surface f only over the region.
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

%% User parameters for math objects
r2 = @(x,y) x.^2 + y.^2;
f  = @(x,y) 2*exp(1)*exp(1 ./ (r2(x,y)-1 + (r2(x,y)>=1)));
f  = @(x,y) (r2(x,y)<1) .* f(x,y);

N0 = 1; Nmax = 25;   % subdivisions per side

%% Region boundary: circle centered at (-1,0), passing through the origin
theta = linspace(0, 2*pi, 300);
Xc = cos(theta) - 1;
Yc = sin(theta);
posX     = Xc >= 0;
Xc(posX) = linspace(0, max(Xc), nnz(posX));
Xb = Xc - Xc(1);
Yb = Yc - Yc(1);
if Xb(1) ~= Xb(end)
    Xb(end+1) = Xb(1);
    Yb(end+1) = Yb(1);
end

xlims = [min(Xb), max(Xb)];
ylims = [min(Yb), max(Yb)];

% Exact integral over the disk, in polar coordinates about its centre
exactDisk = integral2(@(r,th) f(-1 + r.*cos(th), r.*sin(th)).*r, 0, 1, 0, 2*pi, ...
    'AbsTol', 1e-12, 'RelTol', 1e-10);

%% Run the shared engine
run('setup.m')
DoubleIntegralCurvyEngine('Double Integral Approximation over Curvy Region', ...
    f, Xb, Yb, xlims, ylims, [153, 78], N0, Nmax, '$N = $', @buildCells, ...
    'MaskButton', true, 'Exact', exactDisk)

%% Cell builder: axis-aligned prisms whose centres are inside the region
function [layers, X, Y, Z, titleStr] = buildCells(Nside, exactIntegral)
    dx = (xlims(2)-xlims(1))/Nside;
    dy = (ylims(2)-ylims(1))/Nside;
    [x, y] = meshgrid(linspace(xlims(1)+dx/2, xlims(2)-dx/2, Nside), ...
                       linspace(ylims(1)+dy/2, ylims(2)-dy/2, Nside));
    inside = inpolygon(x, y, Xb, Yb);
    X = x(inside); Y = y(inside); Z = f(X, Y);

    [V, bottomFaces, topFaces, sideFaces] = buildPrismMesh(X, Y, Z, dx, dy);
    layers = struct('Faces', {bottomFaces, sideFaces, topFaces}, ...
                     'Vertices', {V, V, V}, ...
                     'FaceAlpha', {0.25, 0.6, 0.9});

    titleStr = splitlines(sprintf(['Double Integral Approximation over Curvy Region\n' ...
        'Number cubes = %d   Cubes inside region = %d\n' ...
        'Riemann Approx = %.6f   $|$   Exact = %.6f'], ...
        Nside^2, numel(X), sum(Z)*dx*dy, exactIntegral));
end

end