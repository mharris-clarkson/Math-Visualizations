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
%
% Speed (weak hardware): the surface is opaque and 150 x 150, point-in-
% region tests skip points outside the region's bounding box (and, for the
% exact integral, points where f = 0).
% The slider is rate limited: while a redraw is running, new slider moves
% are not queued; when it finishes it jumps straight to the newest N.
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
end

close all
run('setup.m')
app = uiFigure(figName, 1);
view(app.ax, viewAngle(1), viewAngle(2))

%% "Exact" integral via a fine midpoint grid restricted to the region
% (cell centers, so each sample stands for one full cell of area cellArea;
%  a linspace grid that includes the edges is biased low)
resExact = 500;
dxE = (xlims(2)-xlims(1))/resExact;
dyE = (ylims(2)-ylims(1))/resExact;
[xg, yg] = meshgrid(xlims(1) + dxE*((1:resExact) - 0.5), ...
                    ylims(1) + dyE*((1:resExact) - 0.5));
fg = f(xg, yg);
inRegion = insideRegion(xg, yg) & (fg ~= 0);   % f = 0 adds nothing
exactIntegral = sum(fg(inRegion))*dxE*dyE;

%% Surface
% 150 x 150 is visually the same as 250 x 250 for a smooth f, with a third
% of the faces; opaque because transparency is very slow to render
resSurf  = 150;
[xs, ys] = meshgrid(linspace(xlims(1), xlims(2), resSurf), ...
                     linspace(ylims(1), ylims(2), resSurf));
zs = f(xs, ys);
hSurf = surf(app.ax, xs, ys, zs, zs, 'EdgeColor', 'none');
colormap(app.ax, Pretty_Colormap('amp'))
colorbar(app.ax)
Pretty_Plot(app.ax)
zlabel(app.ax, '$f(x,y)$')

% The same surface with NaN outside the region (NaN faces are not drawn)
zsRegion = zs;
if options.MaskButton
    zsRegion(~insideRegion(xs, ys)) = NaN;
end

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

%% Riemann-cell graphics: created on the first draw, then updated in place
Layers    = gobjects(0);
SamplePts = plot3(app.ax, NaN, NaN, NaN, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 4);
lastN     = NaN;   % N currently drawn (skip redraws when N has not changed)
isBusy    = false; % true while a redraw is running (slider rate limit)
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
% Point-in-region test that skips everything outside the bounding box of
% the boundary (inpolygon costs points x boundary vertices)
function in = insideRegion(x, y)
    in = x >= min(Xb) & x <= max(Xb) & y >= min(Yb) & y <= max(Yb);
    in(in) = inpolygon(x(in), y(in), Xb, Yb);
end

% Rate-limited slider: a move that arrives while a redraw is running is
% ignored (no backlog of redraws for every intermediate N); the running
% redraw then checks the slider again and draws only its newest value.
function updatePlot(~, ~)
    if isBusy, return, end
    isBusy = true;
    try
        N = round(nSlider.Value);
        while N ~= lastN && isvalid(app.fig)
            redraw(N)
            drawnow   % show it; moves made meanwhile only update nSlider.Value
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

    % Recreate the patches only if the number of layers changed;
    % otherwise move the existing ones (much faster than delete + patch)
    if numel(Layers) ~= numel(layers)
        delete(Layers)
        Layers = gobjects(1, numel(layers));
        for i = 1:numel(layers)
            Layers(i) = patch(app.ax, 'Faces', layers(i).Faces, 'Vertices', layers(i).Vertices, ...
                'FaceColor', [0.85, 0.85, 0.85], 'EdgeColor', 'k');
        end
        uistack(SamplePts, 'top')   % dots stay on top of the cells
    end
    for i = 1:numel(layers)
        % Clear the faces first so they never point past the new vertex list
        set(Layers(i), 'Faces', [])
        set(Layers(i), 'Vertices', layers(i).Vertices, 'Faces', layers(i).Faces, ...
            'FaceAlpha', layers(i).FaceAlpha)
    end
    set(SamplePts, 'XData', X, 'YData', Y, 'ZData', Z)
    title(app.ax, titleStr)
end

end
