function S16_2_Line_Integral_VectorField()
%% Visualizes the definition of the line integral of a vector field.
%
%  Curve C is a cubic spline through 4 control points (yellow diamonds),
%  parameterized by t in [0,1] (chord length between the control points).
%  Drag any yellow diamond to reshape C: the chords, the terms, the bar plot
%  and the values all update.
%
%  Vector field:
%    F(x,y) = [ y,  x^2 ]
%
%  The line integral  int_C F . dr  is approximated by the sum
%
%    sum_{k=1}^{n}  F(x(t*_k), y(t*_k)) . Delta_r_k
%
%  where Delta_r_k = ( x(t_k)-x(t_{k-1}), y(t_k)-y(t_{k-1}) ) is the chord
%  displacement vector and t*_k is the midpoint of the k-th sub-interval.
%
%  Each term is SIGNED: positive when F aligns with the direction of travel
%  and negative when it opposes it. A slider sets the number of chords n and
%  its last value shows n -> infinity. A toggle button reverses the
%  orientation of C, which flips the sign of every term and of the integral.
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
% Control points of the spline C (start on the upper semicircle, A to B)
px = cos(pi*[0 1/3 2/3 1]);
py = sin(pi*[0 1/3 2/3 1]);
cpColor = [1.00 0.80 0.00];   % yellow diamonds (black outline)

% Vector field F(x,y) = [Fx, Fy]
Fx = @(x,y) y;
Fy = @(x,y) x.^2;

% Slider settings
n0    = 4;      % initial number of chords
n_max = 50;     % largest finite n on the slider. One step past it is "infinity"
N_inf = 1000;   % number of chords used to represent n -> infinity
nCols     = 9;    % black field arrows across the plot (the rows are spaced to match on screen)
arrowFrac = 0.9;  % longest black arrow as a fraction of the grid spacing on screen (< 1 so arrows never touch)

% Plot window (the control points are kept inside it)
xLims = [-1.5 1.7];
yLims = [-0.3 1.55];

% Colors
colorPos = [0 0 0.6];    % dark blue  -- positive dot product
colorNeg = [0.6 0 0];    % dark red   -- negative dot product

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plots and all UI elements
app = uiFigure('Line Integral of a Vector Field along a Spline', 2); % Left: path and field. Right: signed terms
axXY  = app.ax(1);
axBar = app.ax(2);

%% Optional math functions for plot computations
reversed = false; % orientation of C. false = A to B (first to last control point)

% Points on C at parameter values t, following the current orientation
    function [x, y] = curve(t)
        if reversed
            t = 1 - t;
        end
        x = ppval(ppx, t);
        y = ppval(ppy, t);
    end

% Rebuild the spline through the control points, its arc length table and
% the exact line integral (default orientation; reversing only flips the sign)
    function updateCurve()
        d   = max(hypot(diff(px), diff(py)), 1e-6);  % avoid repeated knots
        tp  = [0, cumsum(d)]/sum(d);                 % chord-length parameter
        ppx = spline(tp, px);
        ppy = spline(tp, py);

        xArc = ppval(ppx, tArc);
        yArc = ppval(ppy, tArc);
        sArc = [0, cumsum(hypot(diff(xArc), diff(yArc)))];
        L    = sArc(end);

        % Exact value: the same sum on a very fine partition (5000 chords)
        xm = 0.5*(xArc(1:end-1) + xArc(2:end));
        ym = 0.5*(yArc(1:end-1) + yArc(2:end));
        I_default = sum(Fx(xm,ym).*diff(xArc) + Fy(xm,ym).*diff(yArc));

        set(hPath, 'XData', ppval(ppx, tFine), 'YData', ppval(ppy, tFine));
        set(hCP,   'XData', px, 'YData', py);
    end

% Move the existing quiver h to the entries selected by mask (NaN when
% nothing is selected), so the arrows are updated in place, not re-created
    function setArrows(h, x, y, u, v, mask)
        if any(mask)
            set(h, 'XData', x(mask), 'YData', y(mask), 'UData', u(mask), 'VData', v(mask));
        else
            set(h, 'XData', NaN, 'YData', NaN, 'UData', NaN, 'VData', NaN);
        end
    end

% Columns of M selected by mask, or one column of NaN when nothing is selected
    function Mo = pick(M, mask)
        if any(mask)
            Mo = M(:, mask);
        else
            Mo = NaN(size(M,1), 1);
        end
    end

%% ============== Make the initial plots =================================
% Background vector field. Drawn by buildField once the panel size is known.
hField = gobjects(0);

% Smooth curve C (on top of field) and its control points
tFine = linspace(0, 1, 400);
hPath = plot(axXY, NaN, NaN, 'k', 'LineWidth', 2.5);

% Chord arrows Delta_r_k and field arrows F(r_k^*), one quiver per sign,
% created once and updated in place
quivOpts = {0, 'AutoScale', 'off'};
hChordPos = quiver(axXY, NaN, NaN, NaN, NaN, quivOpts{:}, 'Color', colorPos, 'LineWidth', 2.8, 'MaxHeadSize', 0.6);
hChordNeg = quiver(axXY, NaN, NaN, NaN, NaN, quivOpts{:}, 'Color', colorNeg, 'LineWidth', 2.8, 'MaxHeadSize', 0.6);
hFPos     = quiver(axXY, NaN, NaN, NaN, NaN, quivOpts{:}, 'Color', colorPos, 'LineWidth', 2.0, 'MaxHeadSize', 0.8);
hFNeg     = quiver(axXY, NaN, NaN, NaN, NaN, quivOpts{:}, 'Color', colorNeg, 'LineWidth', 2.0, 'MaxHeadSize', 0.8);
hMid      = plot(axXY, NaN, NaN, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 3);

% Start / end markers and labels. These move when the orientation flips.
hStart = plot(axXY, nan, nan, 'ks', 'MarkerFaceColor', 'k', 'MarkerSize', 10);
hEnd   = plot(axXY, nan, nan, 'k^', 'MarkerFaceColor', 'k', 'MarkerSize', 10);
hLabA  = text(axXY, nan, nan, '$A$', 'FontSize', 20);
hLabB  = text(axXY, nan, nan, '$B$', 'FontSize', 20);

% Draggable control points, on top of everything
hCP = plot(axXY, px, py, 'd', 'Color', cpColor, 'MarkerFaceColor', cpColor, ...
    'MarkerEdgeColor', 'k', 'MarkerSize', 12, 'LineWidth', 1);

% Bars, one patch per sign, updated in place
yline(axBar, 0, 'k-', 'LineWidth', 1.2);
hBarPos = patch(axBar, NaN(4,1), NaN(4,1), colorPos, 'FaceAlpha', 0.55, 'LineWidth', 0.6);
hBarNeg = patch(axBar, NaN(4,1), NaN(4,1), colorNeg, 'FaceAlpha', 0.55, 'LineWidth', 0.6);

%% Plot elements are done - Make pretty
Pretty_Plot(axXY);
Pretty_Plot(axBar);

% Fixed limits so the picture does not jump while dragging. The aspect
% ratio is not preserved so the panels can fill the space.
xlim(axXY, xLims)
ylim(axXY, yLims)

xlabel(axBar, 'Arc length $s$ along $C$')
% Titles and the bar plot y label depend on n (discrete or n -> infinity),
% so they are set in updatePlot

%% Precompute math for updates
% Fine parameter grid for the arc length s(t) (horizontal axis of the bar
% plot) and the exact integral. updateCurve fills in the spline data.
tArc = linspace(0, 1, 5001);
ppx = []; ppy = []; sArc = []; L = []; I_default = [];
updateCurve();

%% Dragging: clicks in the left axes grab the nearest control point
% (the plotted objects ignore clicks so they reach the axes' ButtonDownFcn)
set(axXY.Children, 'HitTest', 'off', 'PickableParts', 'none')
axXY.ButtonDownFcn = @startDrag;
dragIdx = [];

%% Build UI
NumControls = 2; % maximum number of controls

% Number of chords. The last slider value stands in for n -> infinity
% ('Step' snaps to whole chords, 'LimitLabel' writes n -> infinity at the end)
nSlider = app.addControl('slider', '$n = $', 1, NumControls, @updatePlot, ...
    'Default', n0, 'Min', 1, 'Max', n_max + 1, 'Number_format', '%d', 'colOrRow', 'row', ...
    'Step', 1, 'LimitLabel', '$n \to \infty$');

% Button to reverse the orientation of C
btnOrient = app.addControl('button', '', 2, NumControls, @toggleOrientation, ...
    'ColorChange', true, 'colOrRow', 'row', ...
    'Toggle', ["Direction: $A$ to $B$", "Direction: $B$ to $A$"]);

% Use the width of the figure. Both panels get the same size.
axXY.Position([1 3])  = [0.07 0.40];
axBar.Position([1 3]) = [0.58 0.40];

% Draw the black field now that the panel size is known, and redraw it when
% the window is resized so the arrows keep pointing the right way on screen.
app.fig.SizeChangedFcn = @(~,~) buildField();
drawnow
buildField();

updatePlot()

%% Functions for UI elements
% Black field arrows on a grid that is even ON SCREEN. The axes do not keep
% the aspect ratio, so the vectors are converted to pixels first. That way
% each arrow points the way F really points on screen, and the longest arrow
% is arrowFrac of the grid spacing so no arrow reaches its neighbors.
    function buildField()
        delete(hField(isgraphics(hField)))
        pos  = getpixelposition(axXY);
        ppuX = pos(3)/diff(xlim(axXY));   % pixels per data unit in x
        ppuY = pos(4)/diff(ylim(axXY));   % pixels per data unit in y
        if ~(ppuX > 0 && ppuY > 0)
            return
        end
        xs = linspace(-1.35, 1.35, nCols);
        hp = (xs(2) - xs(1))*ppuX;        % grid spacing in pixels
        dy = hp/ppuY;                     % the same spacing on screen in y
        ys = (ceil(-0.2/dy):floor(1.3/dy))*dy;
        [xg, yg] = meshgrid(xs, ys);
        u = Fx(xg, yg);
        v = Fy(xg, yg);
        k = arrowFrac*hp/max(hypot(u(:), v(:))); % pixels per unit of F
        hField = quiver(axXY, xg, yg, k*u/ppuX, k*v/ppuY, 0, 'k', ...
            'LineWidth', 1.3, 'MaxHeadSize', 0.6, 'AutoScale', 'off', ...
            'HitTest', 'off', 'PickableParts', 'none');
        uistack(hField, 'bottom') % keep the path and chords on top
    end

    function toggleOrientation(~, ~)
        reversed = logical(btnOrient.Value);   % label follows Value ('Toggle')
        updatePlot()
    end

% Grab the control point nearest the click (distance measured in plot
% fractions, since the two axes have different scales)
    function startDrag(~, ~)
        P = axXY.CurrentPoint(1, 1:2);
        d = hypot((px - P(1))/diff(xLims), (py - P(2))/diff(yLims));
        [dMin, idx] = min(d);
        if dMin < 0.05
            dragIdx = idx;
            app.fig.WindowButtonMotionFcn = @doDrag;
            app.fig.WindowButtonUpFcn     = @stopDrag;
        end
    end

    function doDrag(~, ~)
        if isempty(dragIdx), return, end
        P = axXY.CurrentPoint(1, 1:2);
        px(dragIdx) = min(max(P(1), xLims(1) + 0.05), xLims(2) - 0.05);
        py(dragIdx) = min(max(P(2), yLims(1) + 0.05), yLims(2) - 0.05);
        updateCurve();
        updatePlot();
    end

    function stopDrag(~, ~)
        dragIdx = [];
        app.fig.WindowButtonMotionFcn = '';
        app.fig.WindowButtonUpFcn     = '';
    end

%% Main Draw update function. All initial plot functions are updated below.
    function updatePlot(~, ~)
        %% Number of chords from the slider
        sVal = round(nSlider.Value);
        isInf = app.isAtLimit(nSlider); % last slider step = n -> infinity (label set by uiFigure)
        if isInf
            n = N_inf;
        else
            n = sVal;
        end

        %% Update data
        % Partition and midpoints
        tEdges = linspace(0, 1, n+1);
        tMid   = 0.5*(tEdges(1:n) + tEdges(2:n+1));

        [xEdge, yEdge] = curve(tEdges);
        [xMid,  yMid ] = curve(tMid);

        % Chord vectors Delta_r_k and field at the midpoints
        DeltaX = diff(xEdge);
        DeltaY = diff(yEdge);
        Fmx = Fx(xMid, yMid);
        Fmy = Fy(xMid, yMid);

        % Signed terms F(r_k^*) . Delta_r_k and their sum
        dotProds = Fmx.*DeltaX + Fmy.*DeltaY;
        approx   = sum(dotProds);
        if reversed
            I_exact = -I_default;
        else
            I_exact = I_default;
        end
        isPos = dotProds >= 0;

        Fscale = min(0.32, 1/n); % keep the field arrows visible at any n

        %% Update plots
        % Chord arrows Delta_r_k, colored by sign. In the limit they blend into a
        % path colored by the sign of F . dr.
        setArrows(hChordPos, xEdge(1:n), yEdge(1:n), DeltaX, DeltaY, isPos);
        setArrows(hChordNeg, xEdge(1:n), yEdge(1:n), DeltaX, DeltaY, ~isPos);

        % Field arrows and dots are only drawn for a finite number of chords.
        % In the limit they would just crowd the path.
        if isInf
            noArrow = false(1, n);
            setArrows(hFPos, xMid, yMid, Fmx, Fmy, noArrow);
            setArrows(hFNeg, xMid, yMid, Fmx, Fmy, noArrow);
            set(hMid, 'XData', NaN, 'YData', NaN)
        else
            setArrows(hFPos, xMid, yMid, Fscale*Fmx, Fscale*Fmy, isPos);
            setArrows(hFNeg, xMid, yMid, Fscale*Fmx, Fscale*Fmy, ~isPos);
            set(hMid, 'XData', xMid, 'YData', yMid)
        end

        % One box per term over the arc length of its sub-interval. The box
        % height is (F . Delta_r_k) / Delta_s_k, so its AREA is the term
        % F . Delta_r_k and the total area is the sum. Outlines are dropped
        % when there are too many boxes.
        edgeColor = 'k';
        if isInf
            edgeColor = 'none';
        end
        if reversed
            tArcEdges = 1 - tEdges; % arc length is measured from the start of the path
        else
            tArcEdges = tEdges;
        end
        sEdge  = abs(interp1(tArc, sArc, tArcEdges) - interp1(tArc, sArc, tArcEdges(1)));
        height = dotProds ./ max(diff(sEdge), eps);
        Xb = [sEdge(1:n); sEdge(2:n+1); sEdge(2:n+1); sEdge(1:n)];
        Yb = [zeros(1,n); zeros(1,n); height; height];
        set(hBarPos, 'XData', pick(Xb, isPos),  'YData', pick(Yb, isPos),  'EdgeColor', edgeColor)
        set(hBarNeg, 'XData', pick(Xb, ~isPos), 'YData', pick(Yb, ~isPos), 'EdgeColor', edgeColor)

        % Start (square) and end (triangle) of the path and their labels
        set(hStart, 'XData', xEdge(1),   'YData', yEdge(1))
        set(hEnd,   'XData', xEdge(end), 'YData', yEdge(end))
        set(hLabA, 'Position', [xEdge(1)   - 0.08*sign(xEdge(1)),   yEdge(1)   - 0.13, 0])
        set(hLabB, 'Position', [xEdge(end) - 0.08*sign(xEdge(end)), yEdge(end) - 0.13, 0])

        % Bar plot limits
        xlim(axBar, [0 L])
        hMax = max(max(abs(height)), eps);
        ylim(axBar, [-1.3*hMax, 1.3*hMax])

        %% Titles and labels: discrete sums for finite n, continuous versions for n -> infinity
        % (Built with [ ] instead of sprintf so the LaTeX backslashes stay literal.)
        valStr = [sprintf('%.5f', approx), '$,  Exact $= ', sprintf('%.5f', I_exact), '$'];
        if isInf
            leftTitle = {'Spline Path $C$ and Field $\mathbf{F}(\mathbf{r})$: drag the yellow diamonds', ...
                'Blue: $\mathbf{F}\cdot d\mathbf{r}>0$ (aids motion), Red: $<0$ (opposes)'};
            rightTitle = {'Area under $\mathbf{F}\cdot\mathbf{T}$ along $C$', ...
                ['$\int_C \mathbf{F}\cdot d\mathbf{r} = ', sprintf('%.5f', approx), '$']};
            rightYLabel = '$\mathbf{F}\cdot\mathbf{T}$';
        else
            leftTitle = {'Spline Path $C$ (drag the yellow diamonds), Chords $\Delta\mathbf{r}_k$, Field $\mathbf{F}(\mathbf{r}_k^*)$', ...
                'Blue: $\mathbf{F}\cdot\Delta\mathbf{r}_k>0$ (aids motion), Red: $<0$ (opposes)'};
            rightTitle = {'Box Area $=\mathbf{F}(\mathbf{r}_k^*)\cdot\Delta\mathbf{r}_k$ over Each Arc Segment', ...
                ['Sum $= ', valStr]};
            rightYLabel = '$\mathbf{F}(\mathbf{r}_k^*)\cdot\Delta\mathbf{r}_k\,/\,\Delta s_k$';
        end
        title(axXY, leftTitle, 'FontSize', 16)
        title(axBar, rightTitle, 'FontSize', 16)
        ylabel(axBar, rightYLabel)

        drawnow limitrate
    end
end
