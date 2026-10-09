function DoubleIntegralCurvyEngine(figName, f, Xb, Yb, xlims, ylims, viewAngle, N0, Nmax, sliderLabel, buildCells)
%% Shared engine for "Riemann approximation over a curvy region" demos.
% Handles everything common to the Cartesian-prism and polar-wedge
% versions: the exact integral, the colored surface, the vertical
% boundary curtain along the region's edge, the slider, and redrawing.
%
% buildCells(N, exactIntegral) must return:
%   layers   - struct array with fields Faces, Vertices, FaceAlpha,
%              one entry per patch "layer" to draw (e.g. top/bottom/side
%              faces, or just a single top-face layer)
%   X, Y, Z  - sample point coordinates (column vectors) for the dots
%   titleStr - the fully formatted title string for this N
%
%% Author Info
%
% Ported/cleaned up by Claude from original visualizations written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

close all
run('setup.m')
app = uiFigure(figName, 1);
view(app.ax, viewAngle(1), viewAngle(2))

%% "Exact" integral via a fine grid restricted to the region
resExact      = 500;
[xg, yg]      = meshgrid(linspace(xlims(1), xlims(2), resExact), ...
                          linspace(ylims(1), ylims(2), resExact));
inRegion      = inpolygon(xg, yg, Xb, Yb);
cellArea      = (xlims(2)-xlims(1))*(ylims(2)-ylims(1))/numel(xg);
exactIntegral = sum(f(xg(inRegion), yg(inRegion)))*cellArea;

%% Surface
resSurf  = 250;
[xs, ys] = meshgrid(linspace(xlims(1), xlims(2), resSurf), ...
                     linspace(ylims(1), ylims(2), resSurf));
zs = f(xs, ys);
surf(app.ax, xs, ys, zs, zs, 'EdgeColor', 'none', 'FaceAlpha', 0.95)
cmocean('amp')
colorbar(app.ax)
Pretty_Plot(app.ax)
zlabel(app.ax, 'f(x,y)')

%% Vertical boundary curtain along the region's edge -- one patch object
% for every segment, instead of one fill3 call per segment.
zmax = max(zs(:));
nSeg = numel(Xb) - 1;
Vc = [Xb(1:end-1).', Yb(1:end-1).', zeros(nSeg,1); ...
      Xb(2:end).',   Yb(2:end).',   zeros(nSeg,1); ...
      Xb(2:end).',   Yb(2:end).',   zmax*ones(nSeg,1); ...
      Xb(1:end-1).', Yb(1:end-1).', zmax*ones(nSeg,1)];
curtainFaces = (1:nSeg).' + [0, nSeg, 2*nSeg, 3*nSeg];
patch(app.ax, 'Faces', curtainFaces, 'Vertices', Vc, ...
    'FaceColor', 'k', 'FaceAlpha', 0.25, 'EdgeColor', 'k');

%% Riemann-cell graphics: rebuilt each time N changes
Layers    = gobjects(0);
SamplePts = gobjects(0);
redraw(N0)

%% Build UI
nSlider = app.addControl('slider', sliderLabel, 1, 1, @updatePlot, ...
'Default', N0, 'Min', 1, 'Max', Nmax, 'Number_format', '%d', 'colOrRow', 'Row');

%% Callback
function updatePlot(~, ~)
    redraw(round(nSlider.Value))
end

function redraw(N)
    delete([Layers, SamplePts])
    [layers, X, Y, Z, titleStr] = buildCells(N, exactIntegral);

    Layers = gobjects(1, numel(layers));
    for i = 1:numel(layers)
        Layers(i) = patch(app.ax, 'Faces', layers(i).Faces, 'Vertices', layers(i).Vertices, ...
            'FaceColor', [0.85, 0.85, 0.85], 'EdgeColor', 'k', 'FaceAlpha', layers(i).FaceAlpha);
    end
    SamplePts = plot3(app.ax, X, Y, Z, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 4);
    title(app.ax, titleStr)
end

end