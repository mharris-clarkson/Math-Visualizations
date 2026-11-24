function S13_3_Arc_Length()
%% Shows how the arc length in 3D is defined by approximating a smooth
%  curve with a polygonal chain of n points. Black arrows, equally spaced
%  along the curve and all the same size, show the direction the curve is
%  traced. At the end of the slider (n -> infinity) the chain becomes the
%  curve and the title shows the exact arc length.
%  A toggle adds two panels on the right that share the t axis:
%   - top, what we integrate: the chain speed |Delta r_k|/Delta t on each
%     step (red), whose shaded area is the chain length L_n, over the faint
%     speed |r'(t)|,
%   - bottom, the running total: the chain length up to each point s_n(t)
%     (red) over the faint s(t) = int_a^t |r'(u)| du, and the total arc
%     length L (green dashed).
%  In the limit the red chain versions become the continuous functions and
%  the shaded area becomes L.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
x = @(t) cos(2*t);
y = @(t) sin(2*t);
z = @(t) t.^2/(4*pi);
tlims    = [0 4*pi];
nPoints0 = 2;       % starting number of chain points
nMax     = 100;     % slider end, shown as n -> infinity
nFine    = 1000;    % samples for the smooth curve, |r'(t)| and s(t)
showS0   = false;   % start with the right-hand panels hidden

% Direction arrows on the curve
nArrows    = 4;     % number of arrows (avoid 3: Diff_f_unit then cannot tell
                    % the 3 components from the 3 samples)
arrowScale = 0.12;  % arrow length on screen, as a fraction of the plot box

% Look (right-hand panels)
fadedBlue = [0.60 0.75 1.00];   % exact |r'(t)| and s(t): the faint target
chainFill = [1.00 0.85 0.85];   % shaded area under the chain speed (= L_n)
Lcolor    = [0 0.6 0];          % green dashed line at s = L
panelGap  = 0.02;               % extra space between the bottom title and the top panel

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
% Two panels: the curve (left) and s(t) (right). The right one is split in
% two after the controls are placed, and the curve panel is widened when
% the right-hand panels are hidden.
app = uiFigure('3D Arc Length Approximation', 2);
curveAx = app.ax(1);
sAx     = app.ax(2);
view(curveAx, 3)

%% Optional math functions for plot computations
% Move the polygonal chain, its points, the chain speed (line and shaded
% area) and s_n(t) to nPts samples (objects are created once below and
% updated in place)
    function L = drawChain(nPts)
        t      = linspace(tlims(1), tlims(2), nPts);
        X      = x(t); Y = y(t); Z = z(t);
        segLen = sqrt(diff(X).^2 + diff(Y).^2 + diff(Z).^2);
        sk     = [0 cumsum(segLen)];

        % Chain speed |Delta r_k|/Delta t, constant on each step
        vk = segLen ./ diff(t);
        tS = reshape([t(1:end-1); t(2:end)], 1, []);
        vS = reshape([vk; vk], 1, []);

        set(polyH,   'XData', X,  'YData', Y, 'ZData', Z, 'Marker', 'o');
        set(ptsH,    'XData', X,  'YData', Y, 'ZData', Z);
        set(vPolyH,  'XData', tS, 'YData', vS);
        set(vAreaH,  'XData', [tS fliplr(tS)], 'YData', [vS zeros(size(vS))]);
        set(sPolyH,  'XData', t,  'YData', sk);
        set(snLabel, 'Position', [t(end), sk(end), 0], 'String', '$s_n(t)$');
        areaLabel.String = 'shaded area $= L_n$';
        L = sk(end);
    end

% n -> infinity: the chain becomes the curve, its speed becomes |r'(t)|
% and s_n(t) becomes s(t)
    function drawLimit()
        set(polyH,  'XData', xFine, 'YData', yFine, 'ZData', zFine, 'Marker', 'none');
        set(vPolyH, 'XData', tFine, 'YData', speed);
        set(vAreaH, 'XData', [tFine fliplr(tFine)], 'YData', [speed zeros(1, nFine)]);
        set(sPolyH, 'XData', tFine, 'YData', sExact);
        snLabel.String   = '';          % red and faint curves now coincide
        areaLabel.String = 'shaded area $= L$';
    end

%% Precompute math for updates
% Smooth curve, speed |r'(t)| and arc length function s(t) = int_a^t |r'(u)| du
r      = @(t) [x(t); y(t); z(t)];
tFine  = linspace(tlims(1), tlims(2), nFine);
xFine  = x(tFine); yFine = y(tFine); zFine = z(tFine);
speed  = sqrt(Diff_f(x, tFine).^2 + Diff_f(y, tFine).^2 + Diff_f(z, tFine).^2);
sExact = cumtrapz(tFine, speed);

% Exact arc length
L_exact = arc_length(x, y, z, tlims);

% Direction arrows, independent of how fast the curve is traced:
% 1) Placed at equal arc length steps (not equal t steps, which bunch the
%    arrows where the curve is slow): invert s(t) to get the times.
sArrow = linspace(0, sExact(end), nArrows + 2);
tArrow = interp1(sExact, tFine, sArrow(2:end-1));
PArrow = r(tArrow);
TArrow = Diff_f_unit(r, tArrow);

% 2) Same length on screen. The axes stretch each coordinate by its own
%    range (e.g. z much taller than x, y), so a unit vector in data units
%    looks long or short depending on its direction. Normalise in plot box
%    units instead, then scale back to data units.
curveExt = [max(xFine)-min(xFine); max(yFine)-min(yFine); max(zFine)-min(zFine)];
curveExt(curveExt == 0) = max(curveExt);   % flat curve: no stretch in that direction
TBox     = TArrow ./ curveExt;
UArrow   = arrowScale * (TBox ./ vecnorm(TBox)) .* curveExt;

%% Make the initial plots
% Curve panel: smooth reference curve, polygonal chain and sample points
plot3(curveAx, xFine, yFine, zFine, 'b', 'LineWidth', 2);
polyH = plot3(curveAx, NaN, NaN, NaN, 'r-o', 'LineWidth', 2, 'MarkerFaceColor', 'r');
ptsH  = plot3(curveAx, NaN, NaN, NaN, 'ko', 'MarkerFaceColor', 'y', 'MarkerSize', 6);

% Direction arrows (drawn last so they sit on top of the chain)
quiver3(curveAx, PArrow(1,:), PArrow(2,:), PArrow(3,:), ...
    UArrow(1,:), UArrow(2,:), UArrow(3,:), 0, ...
    'k', 'LineWidth', 2, 'MaxHeadSize', 0.8);

% Bottom right panel: running total s_n(t) (red) over the faint s(t), and L.
% Lines are labelled directly instead of with a colour key in the title,
% in the same font size as the rest of the plot (text() defaults to 10).
labelSize = sAx.FontSize;
plot(sAx, tlims, [L_exact L_exact], '--', 'Color', Lcolor, 'LineWidth', 2);
plot(sAx, tFine, sExact, 'Color', fadedBlue, 'LineWidth', 1.5);
sPolyH = plot(sAx, NaN, NaN, 'r', 'LineWidth', 2.5);

text(sAx, tlims(1), L_exact, ' $L$', 'Color', Lcolor, 'FontSize', labelSize, ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
iMid = round(0.6*nFine);   % label s(t) part way along, above-left of the curve
text(sAx, tFine(iMid), sExact(iMid), '$s(t)$ ', 'Color', fadedBlue, 'FontSize', labelSize, ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
snLabel = text(sAx, NaN, NaN, '', 'Color', 'r', 'FontSize', labelSize, ...   % moves with the end of s_n(t)
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');

xlabel(sAx, '$t$')
ylabel(sAx, '$s$')
xlim(sAx, tlims)
ylim(sAx, [0 1.1*L_exact])   % fixed so the panel does not jump with n
title(sAx, 'Running total: $s(t) = \int_{a}^{t} |\mathbf{r}''(u)|\,du$')

nLast = NaN;   % n currently drawn (skip redraws when n has not changed)

%% Build UI
NumControls = 2;

nSlider = app.addControl('slider', '$n = $', 1, NumControls, @updatePlot, ...
    'colOrRow', 'row', ...
    'Default', nPoints0, 'Min', 2, 'Max', nMax, 'Number_format', '%d', ...
    'Step', 1, ...                       % arrows move n by exactly one
    'LimitLabel', '$n \to \infty$');     % shown at n = nMax

sButton = app.addControl('button', 'Show $s(t)$', 2, NumControls, @updateLayout, ...
    'colOrRow', 'row', ...
    'Toggle', ["Show $s(t)$", "Hide $s(t)$"]);

% Panel positions, read after the row of controls has lifted the plots:
% curve and right-hand panels side by side, or curve over the full width.
posCurve = curveAx.Position;
posS     = sAx.Position;
posFull  = [posCurve(1), posCurve(2), posS(1) + posS(3) - posCurve(1), posCurve(4)];

% Split the right-hand space: speed |r'(t)| on top, s(t) below. The gap
% between them is the height of the bottom panel's title (TightInset(4),
% the space it needs above the axes box) plus panelGap, so the title can
% never run into the panel above, whatever the font or screen size.
drawnow limitrate                 % make sure the title size is up to date
titleGap = sAx.TightInset(4) + panelGap;
hHalf    = (posS(4) - titleGap)/2;
sAx.Position = [posS(1), posS(2), posS(3), hHalf];
speedAx = axes(app.fig, 'Position', [posS(1), posS(2) + hHalf + titleGap, posS(3), hHalf]);
hold(speedAx, 'on')
Pretty_Plot(speedAx)

% Top right panel: what we integrate. The shaded area under the red chain
% speed is the chain length L_n (and L in the limit); faint |r'(t)| behind.
vAreaH = patch(speedAx, NaN, NaN, chainFill, 'EdgeColor', 'none');
plot(speedAx, tFine, speed, 'Color', fadedBlue, 'LineWidth', 1.5);
vPolyH = plot(speedAx, NaN, NaN, 'r', 'LineWidth', 2.5);

text(speedAx, tFine(end), speed(end), '$|\mathbf{r}''(t)|$ ', 'Color', fadedBlue, 'FontSize', labelSize, ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
speedTop  = 1.2*max(speed);   % chain speeds never exceed max |r'|
areaLabel = text(speedAx, mean(tlims), 0.12*speedTop, '', 'Color', 'r', 'FontSize', labelSize, ...
    'HorizontalAlignment', 'center');

% Shared t axis: only the bottom panel shows the t tick labels
set(speedAx, 'XTickLabel', [])
xlabel(speedAx, '')
ylabel(speedAx, '$|\mathbf{r}''|$')
xlim(speedAx, tlims)
ylim(speedAx, [0 speedTop])
title(speedAx, 'What we integrate: $|\mathbf{r}''(t)|$')

% Draw the initial state
sButton.Value = double(showS0);   % listener sets the button text
updateLayout();
updatePlot();

%% Functions for UI elements
% Show/hide the right-hand panels and widen the curve panel when hidden
    function updateLayout(~, ~)
        showS = logical(sButton.Value);
        set([sAx; speedAx; sAx.Children; speedAx.Children; sAx.Title; speedAx.Title], ...
            'Visible', onoff(showS));
        if showS
            curveAx.Position = posCurve;
        else
            curveAx.Position = posFull;
        end
    end

%% Main Draw update function.
    function updatePlot(~, ~)
        nPts = round(nSlider.Value);
        if nPts == nLast, return, end
        nLast = nPts;

        if app.isAtLimit(nSlider)
            % Continuous case: exact arc length, |r'(t)| and s(t)
            drawLimit();
            ptsH.Visible = 'off';
            title(curveAx, ['Arc Length $L = ' sprintf('%.5f', L_exact) '$'])
        else
            % Polygonal chain with nPts points
            L_poly = drawChain(nPts);
            ptsH.Visible = 'on';
            title(curveAx, sprintf('Arc Length $= %.5f$,  Approx $= %.5f$', ...
                L_exact, L_poly))
        end
    end
end