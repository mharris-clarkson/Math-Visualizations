function S16_2_Line_Integral_VectorField()
%% Visualizes the definition of the line integral of a vector field.
%
%  Curve C is parameterized by t in [0,1] (upper semicircle, counterclockwise):
%    x(t) = cos(pi*t),   y(t) = sin(pi*t)
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
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
% Curve C (t in [0,1]) in its default orientation
xC = @(t) cos(pi*t);
yC = @(t) sin(pi*t);

% Vector field F(x,y) = [Fx, Fy]
Fx = @(x,y) y;
Fy = @(x,y) x.^2;

% Slider settings
n0    = 4;      % initial number of chords
n_max = 50;     % largest finite n on the slider. One step past it is "infinity"
N_inf = 1000;   % number of chords used to represent n -> infinity
nCols     = 9;    % black field arrows across the plot (the rows are spaced to match on screen)
arrowFrac = 0.9;  % longest black arrow as a fraction of the grid spacing on screen (< 1 so arrows never touch)

% Colors
colorPos = [0 0 0.6];    % dark blue  -- positive dot product
colorNeg = [0.6 0 0];    % dark red   -- negative dot product

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plots and all UI elements
app = uiFigure('Line Integral of a Vector Field', 2); % Left: path and field. Right: signed terms
axXY  = app.ax(1);
axBar = app.ax(2);

%% Optional math functions for plot computations
reversed = false; % orientation of C. false = counterclockwise (A to B)

% Points on C at parameter values t, following the current orientation
    function [x, y] = curve(t)
        if reversed
            t = 1 - t;
        end
        x = xC(t);
        y = yC(t);
    end

% Quiver of the entries selected by mask. Empty when nothing is selected
    function h = arrows(x, y, u, v, mask, col, lw, head)
        if any(mask)
            h = quiver(axXY, x(mask), y(mask), u(mask), v(mask), 0, ...
                'Color', col, 'LineWidth', lw, ...
                'MaxHeadSize', head, 'AutoScale', 'off');
        else
            h = gobjects(0);
        end
    end

% Patch of bars for the columns selected by mask. Empty when nothing is selected
    function h = bars(X, Y, mask, col, edgeColor)
        if any(mask)
            h = patch(axBar, X(:,mask), Y(:,mask), col, ...
                'FaceAlpha', 0.55, 'EdgeColor', edgeColor, 'LineWidth', 0.6);
        else
            h = gobjects(0);
        end
    end

%% ============== Make the initial plots =================================
% Exact line integral for the default orientation. Reversing C only flips
% its sign, so no recomputation is needed.
%   integrand = F(r(t)) . r'(t)
I_default = integral(@(t) ...
    Fx(xC(t),yC(t)).*(-pi*sin(pi*t)) + ...
    Fy(xC(t),yC(t)).*(  pi*cos(pi*t)), 0, 1);

% Background vector field. Drawn by buildField once the panel size is known.
hField = gobjects(0);

% Smooth curve C (on top of field)
tFine = linspace(0, 1, 400);
plot(axXY, xC(tFine), yC(tFine), 'k', 'LineWidth', 2.5);

% Start / end markers and labels. These move when the orientation flips.
hStart = plot(axXY, nan, nan, 'ks', 'MarkerFaceColor', 'k', 'MarkerSize', 10);
hEnd   = plot(axXY, nan, nan, 'k^', 'MarkerFaceColor', 'k', 'MarkerSize', 10);
hLabA  = text(axXY, nan, nan, '$A$', 'Interpreter', 'latex', 'FontSize', 20);
hLabB  = text(axXY, nan, nan, '$B$', 'Interpreter', 'latex', 'FontSize', 20);

% Dynamic graphics objects (chords, field arrows, dots, bars). Rebuilt on every update.
hDyn = gobjects(0);

% Zero line for the bar plot
yline(axBar, 0, 'k-', 'LineWidth', 1.2);

%% Plot elements are done - Make pretty
Pretty_Plot(axXY);
Pretty_Plot(axBar);

% Limits fit the curve, the field arrows and the A/B labels. The aspect ratio
% is not preserved so the panels can fill the space.
xlim(axXY, [-1.5 1.7])
ylim(axXY, [-0.3 1.55])

xlabel(axXY, '$x$', 'Interpreter', 'latex')
ylabel(axXY, '$y$', 'Interpreter', 'latex')
xlabel(axBar, 'Arc length $s$ along $C$', 'Interpreter', 'latex')
% Titles and the bar plot y label depend on n (discrete or n -> infinity),
% so they are set in updatePlot

%% Precompute math for updates
% Arc length s(t) along C from t = 0, used as the horizontal axis of the
% bar plot. Interpolated to find the arc length of each sub-interval.
tArc = linspace(0, 1, 5000);
[xArc, yArc] = deal(xC(tArc), yC(tArc));
sArc = [0, cumsum(hypot(diff(xArc), diff(yArc)))];
L    = sArc(end); % total arc length of C

%% Build UI
NumControls = 2; % maximum number of controls

% Number of chords. The last slider value stands in for n -> infinity
nSlider = app.addControl('slider', '$n = $', 1, NumControls, @updatePlot, ...
    'Default', n0, 'Min', 1, 'Max', n_max + 1, 'Number_format', '%d', 'colOrRow', 'row');
nSlider.SliderStep = [1/n_max, 5/n_max]; % one click = one chord

% Button to reverse the orientation of C
btnOrient = app.addControl('button', 'Direction: Counterclockwise', 2, NumControls, ...
    @toggleOrientation, 'ColorChange', true, 'colOrRow', 'row');

% Use the width of the figure. Both panels get the same size.
axXY.Position([1 3])  = [0.07 0.40];
axBar.Position([1 3]) = [0.58 0.40];

% Draw the black field now that the panel size is known, and redraw it when
% the window is resized so the arrows keep pointing the right way on screen.
app.fig.SizeChangedFcn = @(~,~) buildField();
drawnow
buildField();

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
            'LineWidth', 1.3, 'MaxHeadSize', 0.6, 'AutoScale', 'off');
        uistack(hField, 'bottom') % keep the path and chords on top
    end

    function toggleOrientation(~, ~)
        reversed = logical(btnOrient.Value);
        if reversed
            btnOrient.String = 'Direction: Clockwise';
        else
            btnOrient.String = 'Direction: Counterclockwise';
        end
        updatePlot()
    end

updatePlot()

%% Main Draw update function. All initial plot functions are updated below.
    function updatePlot(~, ~)
        %% Number of chords from the slider
        sVal = round(nSlider.Value);
        nSlider.Value = sVal;
        isInf = sVal > n_max;
        if isInf
            n = N_inf;
            nSlider.UserData.label.String = '$n \to \infty$'; % after the Value listener
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
        delete(hDyn(isgraphics(hDyn)))
        hDyn = gobjects(0);

        % Chord arrows Delta_r_k, colored by sign. In the limit they blend into a
        % path colored by the sign of F . dr.
        hNew = {arrows(xEdge(1:n), yEdge(1:n), DeltaX, DeltaY, isPos,  colorPos, 2.8, 0.6), ...
                arrows(xEdge(1:n), yEdge(1:n), DeltaX, DeltaY, ~isPos, colorNeg, 2.8, 0.6)};

        % Field arrows and dots are only drawn for a finite number of chords.
        % In the limit they would just crowd the path.
        if ~isInf
            % Field arrows F(r_k^*) at the midpoints (scaled), colored by sign
            hNew = [hNew, ...
                   {arrows(xMid, yMid, Fscale*Fmx, Fscale*Fmy, isPos,  colorPos, 2.0, 0.8), ...
                    arrows(xMid, yMid, Fscale*Fmx, Fscale*Fmy, ~isPos, colorNeg, 2.0, 0.8)}];

            % Midpoint dots on top
            hNew{end+1} = plot(axXY, xMid, yMid, 'ko', ...
                'MarkerFaceColor', 'k', 'MarkerSize', 3);
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
        height = dotProds ./ diff(sEdge);
        Xb = [sEdge(1:n); sEdge(2:n+1); sEdge(2:n+1); sEdge(1:n)];
        Yb = [zeros(1,n); zeros(1,n); height; height];
        hNew = [hNew, {bars(Xb, Yb, isPos, colorPos, edgeColor), ...
                       bars(Xb, Yb, ~isPos, colorNeg, edgeColor)}];

        for i = 1:numel(hNew)
            hDyn(end+1:end+numel(hNew{i})) = hNew{i};
        end

        % Start (square) and end (triangle) of the path and their labels
        set(hStart, 'XData', xEdge(1),   'YData', yEdge(1))
        set(hEnd,   'XData', xEdge(end), 'YData', yEdge(end))
        set(hLabA, 'Position', [xEdge(1)   - 0.08*sign(xEdge(1)),   yEdge(1)   - 0.13, 0])
        set(hLabB, 'Position', [xEdge(end) - 0.08*sign(xEdge(end)), yEdge(end) - 0.13, 0])

        % Bar plot limits and title
        xlim(axBar, [0 L])
        hMax = max(max(abs(height)), eps);
        ylim(axBar, [-1.3*hMax, 1.3*hMax])

        %% Titles and labels: discrete sums for finite n, continuous versions for n -> infinity
        % (Built with [ ] instead of sprintf so the LaTeX backslashes stay literal.)
        valStr = [sprintf('%.5f', approx), '$,  Exact $= ', sprintf('%.5f', I_exact), '$'];
        if isInf
            leftTitle = {'Path $C$ and Field $\mathbf{F}(\mathbf{r})$', ...
                'Blue: $\mathbf{F}\cdot d\mathbf{r}>0$ (aids motion), Red: $<0$ (opposes)'};
            rightTitle = {'Area under $\mathbf{F}\cdot\mathbf{T}$ along $C$', ...
                ['$\int_C \mathbf{F}\cdot d\mathbf{r} = ', sprintf('%.5f', approx), '$']};
            rightYLabel = '$\mathbf{F}\cdot\mathbf{T}$';
        else
            leftTitle = {'Path $C$, Chords $\Delta\mathbf{r}_k$ and Field $\mathbf{F}(\mathbf{r}_k^*)$', ...
                'Blue: $\mathbf{F}\cdot\Delta\mathbf{r}_k>0$ (aids motion), Red: $<0$ (opposes)'};
            rightTitle = {'Box Area $=\mathbf{F}(\mathbf{r}_k^*)\cdot\Delta\mathbf{r}_k$ over Each Arc Segment', ...
                ['Sum $= ', valStr]};
            rightYLabel = '$\mathbf{F}(\mathbf{r}_k^*)\cdot\Delta\mathbf{r}_k\,/\,\Delta s_k$';
        end
        title(axXY, leftTitle, 'Interpreter', 'latex', 'FontSize', 16)
        title(axBar, rightTitle, 'Interpreter', 'latex', 'FontSize', 16)
        ylabel(axBar, rightYLabel, 'Interpreter', 'latex')
    end
end