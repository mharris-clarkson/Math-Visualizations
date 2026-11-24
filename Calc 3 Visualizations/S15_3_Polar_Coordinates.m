function S15_3_Polar_Coordinates()
%% Polar Coordinates Region
% Visualizes the polar region r in [rmin,rmax], theta in [thetamin,thetamax]
% as a filled wedge/annulus, with four sliders controlling its bounds. The
% min sliders can never pass their max sliders (app.linkMinMax). When the
% angle range covers the full circle, the two radial edge lines are hidden
% so no seam is drawn across the disk/annulus. Light x and y axis lines and
% the grid sit underneath the region for reference.
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.
close all
%% User parameters for math objects
rmin0     = 0;
rmax0     = 2;
thetamin0 = 0;
thetamax0 = pi/2;
rLims     = [0, 5];
thetaLims = [0, 2*pi];
res = 120;   % angular resolution of the filled region
axisColor = [0.6, 0.6, 0.6];   % light grey for the x and y axes
%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('Polar Coordinates Region', 1);
axis(app.ax, 'equal')
view(app.ax, 2)
Pretty_Plot(app.ax)
grid(app.ax, 'on')
%% Static graphics (created once; updated in place, never recreated/cla'd)
% x and y axes first, slightly below z = 0, so they sit underneath the region
L = max(rLims);
plot3(app.ax, [-L, L], [0, 0], -0.01*[1, 1], 'Color', axisColor, 'LineWidth', 1)
plot3(app.ax, [0, 0], [-L, L], -0.01*[1, 1], 'Color', axisColor, 'LineWidth', 1)
TMP = [0,0;0,0];
hRegion   = surf(app.ax, TMP, TMP, TMP, 'EdgeColor', 'none', 'FaceAlpha', 0.75, ...
    'FaceColor', 'b');
hInner    = plot(app.ax, NaN, NaN, 'k', 'LineWidth', 2);
hOuter    = plot(app.ax, NaN, NaN, 'k', 'LineWidth', 2);
hThetaMin = plot(app.ax, NaN, NaN, 'k', 'LineWidth', 2);
hThetaMax = plot(app.ax, NaN, NaN, 'k', 'LineWidth', 2);
% Set axis: same whole-number ticks (and grid lines) on x and y
axis(app.ax, 'tight')
xlim(app.ax, L*[-1,1])
ylim(app.ax, L*[-1,1])
xticks(app.ax, -L:L)
yticks(app.ax, -L:L)
redraw(rmin0, rmax0, thetamin0, thetamax0)
%% Build UI
NumControls = 4;
sRmin = app.addControl('slider', '$r_{\min} = $', 1, NumControls, @updatePlot, ...
    'Default', rmin0, 'Min', rLims(1), 'Max', rLims(2), 'Number_format', '%.2f');
sRmax = app.addControl('slider', '$r_{\max} = $', 2, NumControls, @updatePlot, ...
    'Default', rmax0, 'Min', rLims(1), 'Max', rLims(2), 'Number_format', '%.2f');
sThMin = app.addControl('slider', '$\theta_{\min} = $', 3, NumControls, @updatePlot, ...
    'Default', thetamin0, 'Min', thetaLims(1), 'Max', thetaLims(2), 'Number_format', 'pi');
sThMax = app.addControl('slider', '$\theta_{\max} = $', 4, NumControls, @updatePlot, ...
    'Default', thetamax0, 'Min', thetaLims(1), 'Max', thetaLims(2), 'Number_format', 'pi');
% Keep each min slider at or below its max slider (region never turns inside out)
app.linkMinMax(sRmin, sRmax);
app.linkMinMax(sThMin, sThMax);
% Lift the plot a little so the x label is not cut off at the bottom
app.ax.Position(2) = app.ax.Position(2) + 0.03;
%% Callback
    function updatePlot(~, ~)
        redraw(sRmin.Value, sRmax.Value, sThMin.Value, sThMax.Value)
    end
%% Redraw function: updates the existing graphics objects in place
    function redraw(rmin, rmax, thetamin, thetamax)
        theta = linspace(thetamin, thetamax, res);
        r     = [rmin, rmax];   
        [TH, R] = meshgrid(theta, r);
        X = R.*cos(TH);
        Y = R.*sin(TH);
        set(hRegion, 'XData', X, 'YData', Y, 'ZData', zeros(size(X)))
        thline = linspace(thetamin, thetamax, 200);
        rline  = linspace(rmin, rmax, 200);
        set(hInner,    'XData', rmin*cos(thline), 'YData', rmin*sin(thline))
        set(hOuter,    'XData', rmax*cos(thline), 'YData', rmax*sin(thline))
        set(hThetaMin, 'XData', rline*cos(thetamin), 'YData', rline*sin(thetamin))
        set(hThetaMax, 'XData', rline*cos(thetamax), 'YData', rline*sin(thetamax))
        % Full circle: the two radial edges sit on top of each other and draw a
        % seam across the disk, so hide them (small tolerance for round-off)
        fullCircle = (thetamax - thetamin) >= 2*pi - 1e-9;
        set([hThetaMin, hThetaMax], 'Visible', onoff(~fullCircle))
    end
end