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
n0    = 1;      % initial number of chords
n_max = 50;     % largest finite n on the slider. One step past it is "infinity"
N_inf = 1000;   % number of chords used to represent n -> infinity
nCols     = 9;    % field arrows across the plot
arrowFrac = 0.9;  % longest arrow / grid spacing on screen

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
app = uiFigure('Line Integral of a Vector Field along a Spline', 2);
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

% Spline through the control points, its arc length and the exact integral
% (for the default orientation)
    function updateCurve()
        d   = max(hypot(diff(px), diff(py)), 1e-6);  % avoid repeated knots
        tp  = [0, cumsum(d)]/sum(d);                 % chord-length parameter
        ppx = spline(tp, px);
        ppy = spline(tp, py);

        xArc = ppval(ppx, tArc);
        yArc = ppval(ppy, tArc);
        sArc = [0, cumsum(hypot(diff(xArc), diff(yArc)))];
        L    = sArc(end);

        % "Exact" value: the same sum with 5000 chords
        xm = 0.5*(xArc(1:end-1) + xArc(2:end));
        ym = 0.5*(yArc(1:end-1) + yArc(2:end));
        I_default = sum(Fx(xm,ym).*diff(xArc) + Fy(xm,ym).*diff(yArc));

        set(hPath, 'XData', ppval(ppx, tFine), 'YData', ppval(ppy, tFine));
        set(hCP,   'XData', px, 'YData', py);
    end

% Move quiver h to the entries selected by mask (NaN when none)
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
hField = gobjects(0);   % background field, drawn by buildField

tFine = linspace(0, 1, 400);
hPath = plot(axXY, NaN, NaN, 'k', 'LineWidth', 2.5);

% Chord arrows Delta_r_k and field arrows F(r_k^*), one quiver per sign
quivOpts = {0, 'AutoScale', 'off'};
hChordPos = quiver(axXY, NaN, NaN, NaN, NaN, quivOpts{:}, 'Color', colorPos, 'LineWidth', 2.8, 'MaxHeadSize', 0.6);
hChordNeg = quiver(axXY, NaN, NaN, NaN, NaN, quivOpts{:}, 'Color', colorNeg, 'LineWidth', 2.8, 'MaxHeadSize', 0.6);
hFPos     = quiver(axXY, NaN, NaN, NaN, NaN, quivOpts{:}, 'Color', colorPos, 'LineWidth', 2.0, 'MaxHeadSize', 0.8);
hFNeg     = quiver(axXY, NaN, NaN, NaN, NaN, quivOpts{:}, 'Color', colorNeg, 'LineWidth', 2.0, 'MaxHeadSize', 0.8);
hMid      = plot(axXY, NaN, NaN, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 3);

% Start / end markers and labels
hStart = plot(axXY, nan, nan, 'ks', 'MarkerFaceColor', 'k', 'MarkerSize', 10);
hEnd   = plot(axXY, nan, nan, 'k^', 'MarkerFaceColor', 'k', 'MarkerSize', 10);
hLabA  = text(axXY, nan, nan, '$A$', 'FontSize', 20);
hLabB  = text(axXY, nan, nan, '$B$', 'FontSize', 20);

% Draggable control points, on top of everything
hCP = plot(axXY, px, py, 'd', 'Color', cpColor, 'MarkerFaceColor', cpColor, ...
    'MarkerEdgeColor', 'k', 'MarkerSize', 12, 'LineWidth', 1);

% Bars, one patch per sign
yline(axBar, 0, 'k-', 'LineWidth', 1.2);
hBarPos = patch(axBar, NaN(4,1), NaN(4,1), colorPos, 'FaceAlpha', 0.55, 'LineWidth', 0.6);
hBarNeg = patch(axBar, NaN(4,1), NaN(4,1), colorNeg, 'FaceAlpha', 0.55, 'LineWidth', 0.6);

%% Plot elements are done - Make pretty
Pretty_Plot(axXY);
Pretty_Plot(axBar);

xlim(axXY, xLims)
ylim(axXY, yLims)

xlabel(axBar, 'Arc length $s$ along $C$')

%% Precompute math for updates
% Fine parameter grid for the arc length and the exact integral
tArc = linspace(0, 1, 5001);
ppx = []; ppy = []; sArc = []; L = []; I_default = [];
updateCurve();

%% Dragging: clicks in the left axes grab the nearest control point
set(axXY.Children, 'HitTest', 'off', 'PickableParts', 'none')
axXY.ButtonDownFcn = @startDrag;
dragIdx = [];

%% Build UI
NumControls = 2;

% Number of chords; the last value stands for n -> infinity
nSlider = app.addControl('slider', '$n = $', 1, NumControls, @updatePlot, ...
    'Default', n0, 'Min', 1, 'Max', n_max + 1, 'Number_format', '%d', 'colOrRow', 'row', ...
    'Step', 1, 'LimitLabel', '$n \to \infty$');

btnOrient = app.addControl('button', '', 2, NumControls, @toggleOrientation, ...
    'ColorChange', true, 'colOrRow', 'row', ...
    'Toggle', ["Direction: $A$ to $B$", "Direction: $B$ to $A$"]);

% Two equal panels across the figure
axXY.Position([1 3])  = [0.07 0.40];
axBar.Position([1 3]) = [0.58 0.40];

% The field depends on the panel's pixel size, so redraw it on resize
app.fig.SizeChangedFcn = @(~,~) buildField();
drawnow
buildField();

updatePlot()

%% Functions for UI elements
% Field arrows on a grid that is even on screen, scaled in pixels so they
% point the way F does on screen and never touch
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
        uistack(hField, 'bottom')
    end

    function toggleOrientation(~, ~)
        reversed = logical(btnOrient.Value);
        updatePlot()
    end

% Grab the control point nearest the click (distance in plot fractions)
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
        isInf = app.isAtLimit(nSlider);
        if isInf
            n = N_inf;
        else
            n = sVal;
        end

        %% Update data
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

        Fscale = min(0.32, 1/n); % field arrow scale

        %% Update plots
        % Chord arrows colored by the sign of F . dr
        setArrows(hChordPos, xEdge(1:n), yEdge(1:n), DeltaX, DeltaY, isPos);
        setArrows(hChordNeg, xEdge(1:n), yEdge(1:n), DeltaX, DeltaY, ~isPos);

        % Field arrows and dots only for finite n
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

        % One box per term over its arc length: box area = F . Delta_r_k
        edgeColor = 'k';
        if isInf
            edgeColor = 'none';
        end
        if reversed
            tArcEdges = 1 - tEdges; % arc length from the start of the path
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

        xlim(axBar, [0 L])
        hMax = max(max(abs(height)), eps);
        ylim(axBar, [-1.3*hMax, 1.3*hMax])

        %% Titles and labels: discrete sums for finite n, continuous for n -> infinity
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
