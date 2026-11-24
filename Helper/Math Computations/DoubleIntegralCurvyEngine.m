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
% Midpoint rule: one sample at the centre of each of the resExact^2 cells,
% each worth dx*dy. (Sampling the cell corners with linspace while
% weighting by area/numel made the value about 0.4% too small.)
resExact      = 500;
dxE           = (xlims(2)-xlims(1))/resExact;
dyE           = (ylims(2)-ylims(1))/resExact;
[xg, yg]      = meshgrid(linspace(xlims(1)+dxE/2, xlims(2)-dxE/2, resExact), ...
                         linspace(ylims(1)+dyE/2, ylims(2)-dyE/2, resExact));
inRegion      = inpolygon(xg, yg, Xb, Yb);
exactIntegral = sum(f(xg(inRegion), yg(inRegion)))*dxE*dyE;

%% Surface
resSurf  = 250;
[xs, ys] = meshgrid(linspace(xlims(1), xlims(2), resSurf), ...
                     linspace(ylims(1), ylims(2), resSurf));
zs = f(xs, ys);
surf(app.ax, xs, ys, zs, zs, 'EdgeColor', 'none', 'FaceAlpha', 0.95)
colormap(app.ax, Pretty_Colormap('amp'))   % cached cmocean('amp')
colorbar(app.ax)
Pretty_Plot(app.ax)
zlabel(app.ax, '$f(x,y)$')

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

%% Riemann-cell graphics: updated in place each time N changes
Layers    = gobjects(0);
SamplePts = gobjects(0);
lastN     = NaN;
redraw(N0)

%% Build UI
% 'Step',1 makes the slider arrows move N by exactly one (with the default
% 1%/10% steps an arrow click often left round(N) unchanged).
nSlider = app.addControl('slider', sliderLabel, 1, 1, @updatePlot, ...
'Default', N0, 'Min', 1, 'Max', Nmax, 'Number_format', '%d', 'colOrRow', 'Row', ...
'Step', 1);

%% Callback
function updatePlot(~, ~)
    redraw(round(nSlider.Value))
end

function redraw(N)
    if N == lastN, return, end   % same N: nothing to redraw
    lastN = N;
    [layers, X, Y, Z, titleStr] = buildCells(N, exactIntegral);

    if numel(Layers) == numel(layers) && all(isgraphics(Layers))
        % Same number of layers: swap the mesh data in place (much cheaper
        % than deleting and re-creating the patch objects)
        for i = 1:numel(layers)
            set(Layers(i), 'Faces', [], 'Vertices', layers(i).Vertices, ...
                'Faces', layers(i).Faces, 'FaceAlpha', layers(i).FaceAlpha);
        end
        set(SamplePts, 'XData', X, 'YData', Y, 'ZData', Z);
    else
        delete([Layers, SamplePts])
        Layers = gobjects(1, numel(layers));
        for i = 1:numel(layers)
            Layers(i) = patch(app.ax, 'Faces', layers(i).Faces, 'Vertices', layers(i).Vertices, ...
                'FaceColor', [0.85, 0.85, 0.85], 'EdgeColor', 'k', 'FaceAlpha', layers(i).FaceAlpha);
        end
        SamplePts = plot3(app.ax, X, Y, Z, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 4);
    end
    title(app.ax, titleStr)
end

end