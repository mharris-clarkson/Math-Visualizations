function S16_4_Greens_theorem()
%% Visualizes Green's theorem.
%
%  For a closed curve C (counterclockwise) bounding a region D:
%
%    line integral of F . dr around C  =  double integral of the curl over D
%
%    oint_C F . dr  =  iint_D ( dQ/dx - dP/dy ) dA
%
%  Field:   F = (P, Q) = (-y, x^2)        curl = dQ/dx - dP/dy = 2x + 1
%  Region:  the unit disk D, with C the unit circle.
%  Both sides equal pi (the 2x term vanishes by symmetry, leaving area(D)).
%
%    Left   : the boundary C and the field F. A dot walks around C. The chords
%             of the current partition are colored by the sign of F . dr
%             (blue aids the motion, red opposes it) and are dim until the dot
%             has passed them.
%    Middle : the curl of F as a heat map over the whole plane, so it is clear
%             the curl belongs to the field everywhere. The boundary of D is
%             the black circle.
%    Right  : one box per chord over its arc length. The box height is F . T
%             (so its area is the term F . dr) and the running total of the
%             areas converges to the double integral.
%
%  Controls:
%    n slider - number of chords. Its last value shows n -> infinity.
%    s slider - arc length the dot has traveled around C.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
% Field F = (P, Q) and its curl dQ/dx - dP/dy.
% If you change F also update curl, exact and the titles below.
P    = @(x,y) -y;
Q    = @(x,y)  x.^2;
curl = @(x,y)  2*x + 1;
exact = pi;  % double integral of the curl over the unit disk

% Boundary curve C, counterclockwise for t in [0, tEnd]
xC   = @(t) cos(t);
yC   = @(t) sin(t);
tEnd = 2*pi;

% Slider settings
n_min = 3;      % smallest number of chords
n_max = 60;     % largest finite n on the slider. One step past it is "infinity"
n0    = n_max + 1; % initial slider value. n_max + 1 is the n -> infinity step
N_inf = 1000;   % number of chords used to represent n -> infinity
nHeads  = 14;   % arrowheads drawn along the path when n -> infinity
headLen = 0.26; % length of those arrows (data units)

% Window shown in the two xy plots
lims = [-1.35 1.35];

% Colors
cPos   = [0   0   0.7];   % blue  -- positive F.dr term
cNeg   = [0.7 0   0  ];   % red   -- negative F.dr term
cExact = [0   0.5 0  ];   % green -- exact value
cTrail = [0.2 0.2 0.2];   % dark gray -- part of C already traveled
cDot   = [1   0.6 0  ];   % orange -- the moving dot

% Curl heat map: cmocean balance, flipped so blue is positive like the F.dr terms
curlMap = '-balance';

% Field arrows in the middle plot
nCols      = 15;                   % arrows across the plot (the rows are spaced to match on screen)
arrowFrac  = 0.9;                  % longest arrow as a fraction of the grid spacing on screen (< 1 so arrows never touch)
arrowReach = 1.4;                  % arrows are drawn where x^2 + y^2 <= arrowReach
fieldColor = [0.3 0.3 0.3];

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plots and all UI elements
app = uiFigure('Green''s Theorem', 3); % Left: curl. Middle: boundary and field. Right: boxes and running total
axC = app.ax(1); % curl heat map
axM = app.ax(2); % boundary and field
axR = app.ax(3); % boxes and running total

%% Optional math functions for plot computations
% Quiver of the entries selected by mask, drawn in axis ax. Empty when nothing is selected
    function h = arrows(ax, x, y, u, v, mask, col, lw, head)
        if any(mask)
            h = quiver(ax, x(mask), y(mask), u(mask), v(mask), 0, ...
                'Color', col, 'LineWidth', lw, ...
                'MaxHeadSize', head, 'AutoScale', 'off');
        else
            h = gobjects(0);
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

% A lighter version of a color, used for the chords the dot has not reached yet
    function c = tint(c)
        c = 0.35*c + 0.65*[1 1 1];
    end

%% ============== Make the initial plots =================================
% Arc length along C. tArc maps between the parameter t and the arc length s.
tArc = linspace(0, tEnd, 5001);
sArc = [0, cumsum(hypot(diff(xC(tArc)), diff(yC(tArc))))];
L    = sArc(end); % total length of C

% Boundary curve for display
tFine = linspace(0, tEnd, 500);
xBnd  = xC(tFine);
yBnd  = yC(tFine);

% F . T along C on a fine partition. Only used to fix the y limits of the right plot.
dxF = diff(xC(tArc));
dyF = diff(yC(tArc));
mxF = 0.5*(xC(tArc(1:end-1)) + xC(tArc(2:end)));
myF = 0.5*(yC(tArc(1:end-1)) + yC(tArc(2:end)));
ftMax = max(abs((P(mxF,myF).*dxF + Q(mxF,myF).*dyF)./hypot(dxF,dyF)));

%% ---- Left panel: curl of F over the whole plane ----
xvec = linspace(lims(1), lims(2), 300);
yvec = linspace(lims(1), lims(2), 300);
[Xg, Yg] = meshgrid(xvec, yvec);
Curl_grid = curl(Xg, Yg); % no mask, the curl exists everywhere
imagesc(axC, xvec, yvec, Curl_grid);
set(axC, 'YDir', 'normal');

% Diverging cmocean map centered on zero (white = zero curl)
colormap(axC, cmocean(curlMap));
clim(axC, max(abs(Curl_grid(:)))*[-1 1]);
cb = colorbar(axC, 'Location', 'eastoutside');
cb.Label.String = '$\mathrm{curl}\,\vec{F}$';
cb.Label.Interpreter = 'latex';
cb.Label.FontSize = 18;

% The boundary of D and the label for D
plot(axC, xBnd([1:end 1]), yBnd([1:end 1]), 'k-', 'LineWidth', 2.5);
text(axC, 0.1, 0, '$D$', 'Interpreter', 'latex', 'FontSize', 26, 'HorizontalAlignment', 'center');

%% ---- Middle panel: boundary, field and the moving dot ----
hField = gobjects(0); % drawn by buildField once the panel size is known
plot(axM, xBnd([1:end 1]), yBnd([1:end 1]), 'k-', 'LineWidth', 1.2);
hTrail = plot(axM, NaN, NaN, '-', 'Color', cTrail, 'LineWidth', 3);
% Colored chords for n -> infinity (one line object per color, pieces split by NaN).
% They are created after the black curve so they are drawn on top of it.
chordCol = {cPos, tint(cPos), cNeg, tint(cNeg)}; % passed+, ahead+, passed-, ahead-
hChord = gobjects(1,4);
for g = 1:4
    hChord(g) = plot(axM, NaN, NaN, '-', 'Color', chordCol{g}, 'LineWidth', 3);
end
hDot   = plot(axM, NaN, NaN, 'o', 'MarkerSize', 8, ...
    'MarkerFaceColor', cDot, 'MarkerEdgeColor', 'k', 'LineWidth', 1.2);

% Arrows for finite n are rebuilt on every update (there are few of them)
hDynM = gobjects(0);
lastInf = []; % remembers the last n mode so the slow label updates run only on a change

%% ---- Right panel: boxes over arc length and the running total ----
yline(axR, 0, 'k-', 'LineWidth', 1.2);
hExact  = yline(axR, exact, '--', 'Color', cExact, 'LineWidth', 2);
boxAlpha = [0.60 0.20 0.60 0.20]; % passed+, ahead+, passed-, ahead-
hBox = gobjects(1,4);
for g = 1:4
    hBox(g) = patch(axR, NaN(4,1), NaN(4,1), chordCol{1 + 2*(g > 2)}, ...
        'FaceAlpha', boxAlpha(g), 'EdgeColor', 'k', 'LineWidth', 0.6);
end
hBoxLeg = patch(axR, NaN, NaN, [0.55 0.55 0.55], 'FaceAlpha', 0.5, 'EdgeColor', 'k'); % legend entry for the boxes
hCum    = plot(axR, NaN, NaN, 'k-o', 'LineWidth', 1.8, 'MarkerSize', 4, 'MarkerFaceColor', 'k');
hCumDot = plot(axR, NaN, NaN, 'o', 'MarkerSize', 8, ...
    'MarkerFaceColor', cDot, 'MarkerEdgeColor', 'k', 'LineWidth', 1.2);

%% Plot elements are done - Make pretty
Pretty_Plot(axC);
Pretty_Plot(axM);
Pretty_Plot(axR);
grid(axC, 'off')

% Limits. The two xy plots fill their panels, so the aspect ratio is not preserved.
xlim(axC, lims); ylim(axC, lims)
xlim(axM, lims); ylim(axM, lims)

% The right plot has a fixed arc length axis. The y range has room below for the legend.
yHi = 1.3*max(exact, ftMax);
yLo = -1.1*ftMax;
xlim(axR, [0 L])
ylim(axR, [yLo - 0.35*(yHi - yLo), yHi])

% Labels
xlabel(axC, '$x$', 'Interpreter', 'latex')
ylabel(axC, '$y$', 'Interpreter', 'latex')
xlabel(axM, '$x$', 'Interpreter', 'latex')
ylabel(axM, '$y$', 'Interpreter', 'latex')
xlabel(axR, 'Arc length $s$ along $C$', 'Interpreter', 'latex')

% Titles. The middle and right ones are set in updatePlot.
title(axC, 'Curl of $\vec{F}$', 'Interpreter', 'latex', 'FontSize', 15)
title(axR, {'Green''s Theorem: Line Integral $=$ Double Integral', ...
    '$\int_C \vec{F}\cdot d\vec{r}=\int\int_D \mathrm{curl}\,\vec{F}\,dA=\pi$'}, ...
    'Interpreter', 'latex', 'FontSize', 15)

% Legend for the right plot. Its strings change with n.
leg = legend(axR, [hBoxLeg, hCum, hExact], {'', '', ''}, ...
    'Interpreter', 'latex', 'Location', 'southeast', 'FontSize', 13, 'AutoUpdate', 'off');

%% Precompute math for updates
% Light weight so skip

%% Build UI
NumControls = 2; % maximum number of controls

% Number of chords. The last slider value stands in for n -> infinity
nSlider = app.addControl('slider', '$n = $', 1, NumControls, @updatePlot, ...
    'Default', n0, 'Min', n_min, 'Max', n_max + 1, 'Number_format', '%d', 'colOrRow', 'row');
nSlider.SliderStep = [1/(n_max + 1 - n_min), 5/(n_max + 1 - n_min)]; % one click = one chord

% Arc length traveled by the dot, from the start of C to its end
sSlider = app.addControl('slider', '$s = $', 2, NumControls, @updatePlot, ...
    'Default', L, 'Min', 0, 'Max', L, 'Number_format', '%.2f', 'colOrRow', 'row');

% All three panels get exactly the same size. The gaps leave room for the
% colorbar (and its label) between the left and middle plots, and for the
% tick labels and y label of each plot, so nothing runs into its neighbor.
panelW = 0.235;
panelH = 0.62;
panelB = 0.22;
axM.Position = [0.045, panelB, panelW, panelH]; % boundary and field first
axC.Position = [0.340, panelB, panelW, panelH]; % curl second, its colorbar follows the axes
axR.Position = [0.730, panelB, panelW, panelH];

% Draw the field now that the panel size is known, and redraw it when the
% window is resized so the arrows keep pointing the right way on screen.
app.fig.SizeChangedFcn = @(~,~) buildField();
drawnow
buildField();

updatePlot()

%% Functions for UI elements
% Field arrows on a grid that is even ON SCREEN. The axes do not keep the
% aspect ratio, so the vectors are converted to pixels first. That way each
% arrow points the way F really points on screen, and the longest arrow is
% arrowFrac of the grid spacing so no arrow reaches its neighbors.
    function buildField()
        delete(hField(isgraphics(hField)))
        pos  = getpixelposition(axM);
        ppuX = pos(3)/diff(xlim(axM));    % pixels per data unit in x
        ppuY = pos(4)/diff(ylim(axM));    % pixels per data unit in y
        if ~(ppuX > 0 && ppuY > 0)
            return
        end
        xs = linspace(-1.3, 1.3, nCols);
        hp = (xs(2) - xs(1))*ppuX;        % grid spacing in pixels
        dy = hp/ppuY;                     % the same spacing on screen in y
        ys = (ceil(-1.3/dy):floor(1.3/dy))*dy;
        [xq, yq] = meshgrid(xs, ys);
        inReach = xq.^2 + yq.^2 <= arrowReach;
        xq = xq(inReach);
        yq = yq(inReach);
        u = P(xq, yq);
        v = Q(xq, yq);
        k = arrowFrac*hp/max(hypot(u, v)); % pixels per unit of F
        hField = quiver(axM, xq, yq, k*u/ppuX, k*v/ppuY, 0, ...
            'Color', fieldColor, 'LineWidth', 1.3, 'MaxHeadSize', 0.6, 'AutoScale', 'off');
        uistack(hField, 'bottom') % keep the chords and the dot on top
    end

%% Main Draw update function. All initial plot functions are updated below.
    function updatePlot(~, ~)
        %% Number of chords from the slider
        nVal = round(nSlider.Value);
        if nSlider.Value ~= nVal
            nSlider.Value = nVal;
        end
        isInf = nVal > n_max;
        if isInf
            n = N_inf;
            nSlider.UserData.label.String = '$n \to \infty$'; % after the Value listener
        else
            n = nVal;
        end

        % Arc length traveled by the dot
        s = sSlider.Value;

        %% Update data
        % Partition of C into n chords
        tEdges = linspace(0, tEnd, n+1);
        tMid   = 0.5*(tEdges(1:n) + tEdges(2:n+1));

        xEdge = xC(tEdges);  yEdge = yC(tEdges);
        xMid  = xC(tMid);    yMid  = yC(tMid);
        dX = diff(xEdge);
        dY = diff(yEdge);

        % Arc length of each chord and the terms F(r_k^*) . Delta_r_k
        sEdge   = interp1(tArc, sArc, tEdges);
        dots    = P(xMid,yMid).*dX + Q(xMid,yMid).*dY;
        height  = dots./diff(sEdge);  % box height: area of the box is the term
        cumDots = cumsum(dots);

        isPos  = dots >= 0;
        isDone = sEdge(2:end) <= s + 1e-9; % chords the dot has passed

        % Running total up to s (linear inside a chord, since its box has constant height)
        sCum = unique([sEdge(sEdge <= s + 1e-9), s]);
        vCum = interp1(sEdge, [0, cumDots], sCum);

        %% Update plots: middle panel
        tS = interp1(sArc, tArc, s);           % parameter value at arc length s
        tTrail = linspace(0, tS, 200);
        set(hTrail, 'XData', xC(tTrail), 'YData', yC(tTrail));
        set(hDot,   'XData', xC(tS),     'YData', yC(tS));

        mk = {isPos & isDone, isPos & ~isDone, ~isPos & isDone, ~isPos & ~isDone};
        delete(hDynM(isgraphics(hDynM)))
        hDynM = gobjects(0);
        if isInf
            % Colored path as line pieces, no arrows
            Xs = [xEdge(1:n); xEdge(2:n+1); NaN(1,n)];
            Ys = [yEdge(1:n); yEdge(2:n+1); NaN(1,n)];
            for g = 1:4
                set(hChord(g), 'XData', reshape(Xs(:,mk{g}),[],1), 'YData', reshape(Ys(:,mk{g}),[],1));
            end
            % A few arrows along the path so the direction is still clear.
            % Each is centered on a point of C and follows the tangent there.
            kk   = round(linspace(1, n, nHeads + 1));
            kk   = kk(1:end-1) + round(n/(2*nHeads));  % spread evenly around C
            tlen = hypot(dX(kk), dY(kk));
            ux   = headLen*dX(kk)./tlen;
            uy   = headLen*dY(kk)./tlen;
            for g = 1:4
                hq = arrows(axM, xMid(kk) - ux/2, yMid(kk) - uy/2, ux, uy, mk{g}(kk), chordCol{g}, 3, 1);
                hDynM(end+1:end+numel(hq)) = hq;
            end
        else
            set(hChord, 'XData', NaN, 'YData', NaN)
            for g = 1:4
                hq = arrows(axM, xEdge(1:n), yEdge(1:n), dX, dY, mk{g}, chordCol{g}, 2.2, 0.7);
                hDynM(end+1:end+numel(hq)) = hq;
            end
        end
        uistack(hDot, 'top')

        title(axM, ['Line integral so far: $\int_{C_s}\vec{F}\cdot d\vec{r}=', ...
            sprintf('%.4f', vCum(end)), '$'], 'Interpreter', 'latex', 'FontSize', 15)

        %% Update plots: right panel
        % One box per chord over its arc length. The box height is
        % (F . Delta_r_k) / Delta_s_k, so its AREA is the term F . Delta_r_k.
        % Outlines are dropped when there are too many boxes.
        edgeColor = 'k';
        if isInf
            edgeColor = 'none';
        end
        Xb = [sEdge(1:n); sEdge(2:n+1); sEdge(2:n+1); sEdge(1:n)];
        Yb = [zeros(1,n); zeros(1,n); height; height];
        for g = 1:4
            set(hBox(g), 'XData', pick(Xb, mk{g}), 'YData', pick(Yb, mk{g}), 'EdgeColor', edgeColor)
        end

        % Running total and the current value
        if isInf
            set(hCum, 'XData', sCum, 'YData', vCum, 'Marker', 'none')
        else
            set(hCum, 'XData', sCum, 'YData', vCum, 'Marker', 'o')
        end
        set(hCumDot, 'XData', s, 'YData', vCum(end))

        %% Discrete labels for finite n, continuous ones for n -> infinity (only on a mode change)
        if isequal(lastInf, isInf)
            drawnow limitrate
            return
        end
        lastInf = isInf;
        if isInf
            leg.String = {'Box: height $\vec{F}\cdot\vec{T}$, area $\vec{F}\cdot d\vec{r}$', ...
                          'Running total of the areas', ...
                          'Double integral $=\pi$'};
            ylabel(axR, '$\vec{F}\cdot\vec{T}$', 'Interpreter', 'latex')
        else
            leg.String = {'Box: area $\vec{F}(\vec{r}_k^*)\cdot\Delta\vec{r}_k$', ...
                          'Running total of the areas', ...
                          'Double integral $=\pi$'};
            ylabel(axR, '$\vec{F}(\vec{r}_k^*)\cdot\Delta\vec{r}_k\,/\,\Delta s_k$', 'Interpreter', 'latex')
        end

        drawnow limitrate
    end
end