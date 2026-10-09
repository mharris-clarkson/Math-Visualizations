function S15_3_Polar_Coordinates()
%% Polar Coordinates Region
% Visualizes the polar region r in [rmin,rmax], theta in [thetamin,thetamax]
% as a filled wedge/annulus, with four sliders controlling its bounds. The
% region turns red when exactly one of the two bounds is given backwards
% (rmin > rmax, or thetamin > thetamax).
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

res = 120;   % grid resolution for the filled region

blue = [0, 0.45, 0.74];
red  = [1, 0, 0];

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('Polar Coordinates Region', 1);
axis(app.ax, 'equal')
view(app.ax, 2)
Pretty_Plot(app.ax)

%% Static graphics (created once; updated in place, never recreated/cla'd)
TMP = [0,0;0,0];
hRegion   = surf(app.ax, TMP, TMP, TMP, 'EdgeColor', 'none', 'FaceAlpha', 0.75);
hInner    = plot(app.ax, NaN, NaN, 'k', 'LineWidth', 2);
hOuter    = plot(app.ax, NaN, NaN, 'k', 'LineWidth', 2);
hThetaMin = plot(app.ax, NaN, NaN, 'k', 'LineWidth', 2);
hThetaMax = plot(app.ax, NaN, NaN, 'k', 'LineWidth', 2);
plot(app.ax, 0, 0, 'ok', 'MarkerSize', 20, 'MarkerFaceColor', 'k')

% Set axis.
axis(app.ax, 'tight')
xlim(app.ax, max(rLims)*[-1,1])
ylim(app.ax, max(rLims)*[-1,1])
redraw(rmin0, rmax0, thetamin0, thetamax0)

%% Build UI
NumControls = 4;
sRmin = app.addControl('slider', '$r_{\min} = $', 1, NumControls, @updatePlot, ...
'Default', rmin0, 'Min', rLims(1), 'Max', rLims(2), 'Number_format', '%.2f');
sRmax = app.addControl('slider', '$r_{\max} = $', 2, NumControls, @updatePlot, ...
'Default', rmax0, 'Min', rLims(1), 'Max', rLims(2), 'Number_format', '%.2f');
sThMin = app.addControl('slider', '$\theta_{\min} = $', 3, NumControls, @updatePlot, ...
'Default', thetamin0, 'Min', thetaLims(1), 'Max', thetaLims(2), 'Number_format', '%.2f');
sThMax = app.addControl('slider', '$\theta_{\max} = $', 4, NumControls, @updatePlot, ...
'Default', thetamax0, 'Min', thetaLims(1), 'Max', thetaLims(2), 'Number_format', '%.2f');

%% Callback
function updatePlot(~, ~)
    redraw(sRmin.Value, sRmax.Value, sThMin.Value, sThMax.Value)
end

%% Redraw function: updates the existing graphics objects in place
function redraw(rmin, rmax, thetamin, thetamax)
    % Region fill color: red only when exactly one of the two bounds is
    % backwards; blue otherwise (including when both are backwards).
    if xor(rmin > rmax, thetamin > thetamax)
        regionColor = red;
    else
        regionColor = blue;
    end

    theta = linspace(thetamin, thetamax, res);
    r     = linspace(rmin, rmax, res);
    [TH, R] = meshgrid(theta, r);
    X = R.*cos(TH);
    Y = R.*sin(TH);

    set(hRegion, 'XData', X, 'YData', Y, 'ZData', zeros(size(X)), ...
        'FaceColor', regionColor)

    thline = linspace(thetamin, thetamax, 200);
    rline  = linspace(rmin, rmax, 200);
    set(hInner,    'XData', rmin*cos(thline), 'YData', rmin*sin(thline))
    set(hOuter,    'XData', rmax*cos(thline), 'YData', rmax*sin(thline))
    set(hThetaMin, 'XData', rline*cos(thetamin), 'YData', rline*sin(thetamin))
    set(hThetaMax, 'XData', rline*cos(thetamax), 'YData', rline*sin(thetamax))
end

end