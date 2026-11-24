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

nArrows    = 4;     % direction arrows on the curve (not 3)
arrowScale = 0.12;  % arrow length as a fraction of the plot box

fadedBlue = [0.60 0.75 1.00];   % exact |r'(t)| and s(t)
chainFill = [1.00 0.85 0.85];   % area under the chain speed (= L_n)
Lcolor    = [0 0.6 0];          % line at s = L
panelGap  = 0.02;               % gap between the two right-hand panels

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('3D Arc Length Approximation', 2);
curveAx = app.ax(1);
sAx     = app.ax(2);
view(curveAx, 3)

%% Optional math functions for plot computations
% Polygonal chain with nPts points, its speed and s_n(t)
    function L = drawChain(nPts)
        t      = linspace(tlims(1), tlims(2), nPts);
        X      = x(t); Y = y(t); Z = z(t);
        segLen = sqrt(diff(X).^2 + diff(Y).^2 + diff(Z).^2);
        sk     = [0 cumsum(segLen)];

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

% n -> infinity: the chain becomes the curve
    function drawLimit()
        set(polyH,  'XData', xFine, 'YData', yFine, 'ZData', zFine, 'Marker', 'none');
        set(vPolyH, 'XData', tFine, 'YData', speed);
        set(vAreaH, 'XData', [tFine fliplr(tFine)], 'YData', [speed zeros(1, nFine)]);
        set(sPolyH, 'XData', tFine, 'YData', sExact);
        snLabel.String   = '';
        areaLabel.String = 'shaded area $= L$';
    end

%% Precompute math for updates
r      = @(t) [x(t); y(t); z(t)];
tFine  = linspace(tlims(1), tlims(2), nFine);
xFine  = x(tFine); yFine = y(tFine); zFine = z(tFine);
speed  = sqrt(Diff_f(x, tFine).^2 + Diff_f(y, tFine).^2 + Diff_f(z, tFine).^2);
sExact = cumtrapz(tFine, speed);

L_exact = arc_length(x, y, z, tlims);

% Arrows at equal arc length steps
sArrow = linspace(0, sExact(end), nArrows + 2);
tArrow = interp1(sExact, tFine, sArrow(2:end-1));
PArrow = r(tArrow);
TArrow = Diff_f_unit(r, tArrow);

% Same arrow length on screen: normalise in plot box units
curveExt = [max(xFine)-min(xFine); max(yFine)-min(yFine); max(zFine)-min(zFine)];
curveExt(curveExt == 0) = max(curveExt);
TBox     = TArrow ./ curveExt;
UArrow   = arrowScale * (TBox ./ vecnorm(TBox)) .* curveExt;

%% Make the initial plots
plot3(curveAx, xFine, yFine, zFine, 'b', 'LineWidth', 2);
polyH = plot3(curveAx, NaN, NaN, NaN, 'r-o', 'LineWidth', 2, 'MarkerFaceColor', 'r');
ptsH  = plot3(curveAx, NaN, NaN, NaN, 'ko', 'MarkerFaceColor', 'y', 'MarkerSize', 6);

quiver3(curveAx, PArrow(1,:), PArrow(2,:), PArrow(3,:), ...
    UArrow(1,:), UArrow(2,:), UArrow(3,:), 0, ...
    'k', 'LineWidth', 2, 'MaxHeadSize', 0.8);

% Bottom right panel: running total s_n(t) over s(t), and L
labelSize = sAx.FontSize;
plot(sAx, tlims, [L_exact L_exact], '--', 'Color', Lcolor, 'LineWidth', 2);
plot(sAx, tFine, sExact, 'Color', fadedBlue, 'LineWidth', 1.5);
sPolyH = plot(sAx, NaN, NaN, 'r', 'LineWidth', 2.5);

text(sAx, tlims(1), L_exact, ' $L$', 'Color', Lcolor, 'FontSize', labelSize, ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
iMid = round(0.6*nFine);
text(sAx, tFine(iMid), sExact(iMid), '$s(t)$ ', 'Color', fadedBlue, 'FontSize', labelSize, ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
snLabel = text(sAx, NaN, NaN, '', 'Color', 'r', 'FontSize', labelSize, ...
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');

xlabel(sAx, '$t$')
ylabel(sAx, '$s$')
xlim(sAx, tlims)
ylim(sAx, [0 1.1*L_exact])
title(sAx, 'Running total: $s(t) = \int_{a}^{t} |\mathbf{r}''(u)|\,du$')

nLast = NaN;

%% Build UI
NumControls = 2;

nSlider = app.addControl('slider', '$n = $', 1, NumControls, @updatePlot, ...
    'colOrRow', 'row', ...
    'Default', nPoints0, 'Min', 2, 'Max', nMax, 'Number_format', '%d', ...
    'Step', 1, 'LimitLabel', '$n \to \infty$');

sButton = app.addControl('button', 'Show $s(t)$', 2, NumControls, @updateLayout, ...
    'colOrRow', 'row', ...
    'Toggle', ["Show $s(t)$", "Hide $s(t)$"]);

% Panel positions once the controls have moved the plots
posCurve = curveAx.Position;
posS     = sAx.Position;
posFull  = [posCurve(1), posCurve(2), posS(1) + posS(3) - posCurve(1), posCurve(4)];

% Split the right-hand space, leaving room for the bottom panel's title
drawnow limitrate
titleGap = sAx.TightInset(4) + panelGap;
hHalf    = (posS(4) - titleGap)/2;
sAx.Position = [posS(1), posS(2), posS(3), hHalf];
speedAx = axes(app.fig, 'Position', [posS(1), posS(2) + hHalf + titleGap, posS(3), hHalf]);
hold(speedAx, 'on')
Pretty_Plot(speedAx)

% Top right panel: chain speed (shaded area = L_n) over |r'(t)|
vAreaH = patch(speedAx, NaN, NaN, chainFill, 'EdgeColor', 'none');
plot(speedAx, tFine, speed, 'Color', fadedBlue, 'LineWidth', 1.5);
vPolyH = plot(speedAx, NaN, NaN, 'r', 'LineWidth', 2.5);

text(speedAx, tFine(end), speed(end), '$|\mathbf{r}''(t)|$ ', 'Color', fadedBlue, 'FontSize', labelSize, ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
speedTop  = 1.2*max(speed);
areaLabel = text(speedAx, mean(tlims), 0.12*speedTop, '', 'Color', 'r', 'FontSize', labelSize, ...
    'HorizontalAlignment', 'center');

set(speedAx, 'XTickLabel', [])
xlabel(speedAx, '')
ylabel(speedAx, '$|\mathbf{r}''|$')
xlim(speedAx, tlims)
ylim(speedAx, [0 speedTop])
title(speedAx, 'What we integrate: $|\mathbf{r}''(t)|$')

sButton.Value = double(showS0);
updateLayout();
updatePlot();

%% Functions for UI elements
% Show/hide the right-hand panels; widen the curve panel when hidden
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
            drawLimit();
            ptsH.Visible = 'off';
            title(curveAx, ['Arc Length $L = ' sprintf('%.5f', L_exact) '$'])
        else
            L_poly = drawChain(nPts);
            ptsH.Visible = 'on';
            title(curveAx, sprintf('Arc Length $= %.5f$,  Approx $= %.5f$', ...
                L_exact, L_poly))
        end
    end
end
