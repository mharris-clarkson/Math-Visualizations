function DoubleIntegralCurvyEngine(figName, f, Xb, Yb, xlims, ylims, viewAngle, N0, Nmax, sliderLabel, buildCells, options)
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
% Optional buttons (name/value, both off by default):
%   'DotsButton', true  - button that hides/shows the sample (center) dots
%   'MaskButton', true  - button that shows the surface f only over the
%                         region (NaN outside it) or over the whole window
% 'Exact', value - the exact integral, when it is known in closed form or
%                  from a better parametrization of the region (default:
%                  computed over the boundary polygon with Polygon_Integral)
%
%% Author Info
%
% Ported/cleaned up by Claude from original visualizations written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

arguments
    figName
    f
    Xb
    Yb
    xlims
    ylims
    viewAngle
    N0
    Nmax
    sliderLabel
    buildCells
    options.DotsButton (1,1) logical = false
    options.MaskButton (1,1) logical = false
    options.Exact      double = []
end

close all
run('setup.m')
app = uiFigure(figName, 1);
view(app.ax, viewAngle(1), viewAngle(2))

%% Exact integral over the region
if isempty(options.Exact)
    exactIntegral = Polygon_Integral(f, Xb, Yb);
else
    exactIntegral = options.Exact;
end

%% Surface
resSurf  = 150;
[xs, ys] = meshgrid(linspace(xlims(1), xlims(2), resSurf), ...
                     linspace(ylims(1), ylims(2), resSurf));
zs = f(xs, ys);
hSurf = surf(app.ax, xs, ys, zs, zs, 'EdgeColor', 'none');
colormap(app.ax, Pretty_Colormap('amp'))
colorbar(app.ax)
Pretty_Plot(app.ax)
zlabel(app.ax, '$f(x,y)$')

% Same surface with NaN outside the region
zsRegion = zs;
if options.MaskButton
    zsRegion(~insideRegion(xs, ys)) = NaN;
end

%% Vertical boundary curtain along the region's edge
zmax = max(zs(:));
nSeg = numel(Xb) - 1;
Vc = [Xb(1:end-1).', Yb(1:end-1).', zeros(nSeg,1); ...
      Xb(2:end).',   Yb(2:end).',   zeros(nSeg,1); ...
      Xb(2:end).',   Yb(2:end).',   zmax*ones(nSeg,1); ...
      Xb(1:end-1).', Yb(1:end-1).', zmax*ones(nSeg,1)];
curtainFaces = (1:nSeg).' + [0, nSeg, 2*nSeg, 3*nSeg];
patch(app.ax, 'Faces', curtainFaces, 'Vertices', Vc, ...
    'FaceColor', 'k', 'FaceAlpha', 0.25, 'EdgeColor', 'k');

%% Riemann cells: created on the first draw, then updated in place
Layers    = gobjects(0);
SamplePts = plot3(app.ax, NaN, NaN, NaN, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 4);
lastN     = NaN;
isBusy    = false;
redraw(N0)

%% Build UI
NumControls = 1 + options.DotsButton + options.MaskButton;
nSlider = app.addControl('slider', sliderLabel, 1, NumControls, @updatePlot, ...
    'Default', N0, 'Min', 1, 'Max', Nmax, 'Number_format', '%d', ...
    'Step', 1, 'colOrRow', 'row');

idx = 1;
if options.DotsButton
    idx = idx + 1;
    btnDots = app.addControl('button', '', idx, NumControls, @toggleDots, ...
        'colOrRow', 'row', 'Toggle', ["Hide center dots", "Show center dots"]);
end
if options.MaskButton
    idx = idx + 1;
    btnMask = app.addControl('button', '', idx, NumControls, @toggleMask, ...
        'colOrRow', 'row', 'Toggle', ["Show $f$ only over the region", "Show $f$ everywhere"]);
end

%% Callbacks
% Point-in-region test for a meshgrid of points
function in = insideRegion(x, y)
    in = Inside_Polygon_Grid(x, y, Xb, Yb);
end

% Moves made while a redraw runs are skipped; the redraw then jumps to the
% newest slider value
function updatePlot(~, ~)
    if isBusy, return, end
    isBusy = true;
    try
        N = round(nSlider.Value);
        while N ~= lastN && isvalid(app.fig)
            redraw(N)
            drawnow
            N = round(nSlider.Value);
        end
    catch err
        isBusy = false;
        rethrow(err)
    end
    isBusy = false;
end

% Hide/show the sample (center) dots
function toggleDots(~, ~)
    SamplePts.Visible = onoff(~btnDots.Value);
end

% Surface over the region only, or over the whole window
function toggleMask(~, ~)
    if btnMask.Value
        hSurf.ZData = zsRegion;
    else
        hSurf.ZData = zs;
    end
end

function redraw(N)
    if N == lastN, return, end
    lastN = N;
    [layers, X, Y, Z, titleStr] = buildCells(N, exactIntegral);

    % Recreate the patches only if the number of layers changed
    if numel(Layers) ~= numel(layers)
        delete(Layers)
        Layers = gobjects(1, numel(layers));
        for i = 1:numel(layers)
            Layers(i) = patch(app.ax, 'Faces', layers(i).Faces, 'Vertices', layers(i).Vertices, ...
                'FaceColor', [0.85, 0.85, 0.85], 'EdgeColor', 'k');
        end
        uistack(SamplePts, 'top')
    end
    for i = 1:numel(layers)
        % Clear the faces first so they never index past the new vertices
        set(Layers(i), 'Faces', [])
        set(Layers(i), 'Vertices', layers(i).Vertices, 'Faces', layers(i).Faces, ...
            'FaceAlpha', layers(i).FaceAlpha)
    end
    set(SamplePts, 'XData', X, 'YData', Y, 'ZData', Z)
    title(app.ax, titleStr)
end

end
