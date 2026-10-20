function S15_3_Polar_Jacobian()
%% Cartesian vs Polar Area Elements (Draggable)
% Shows a small Cartesian rectangle and a small polar "wedge" element,
% both draggable with the mouse, each displaying its own area as it
% moves -- a hands-on comparison of dA = dx*dy vs dA = r*dr*dtheta.
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

close all

%% User parameters for math objects
x0 = 2; dx = 1;
y0 = 2; dy = 1;
dtheta = 1; dr = 1;

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('Cartesian vs Polar (Draggable)', 1);
ax = app.ax(1);
axis(ax, 'equal')
Pretty_Plot(app.ax)
xlabel(ax, 'x'); ylabel(ax, 'y');
xlim(ax, [-4 4]); ylim(ax, [-4 4]);
title(ax, 'Cartesian vs Polar (Draggable)')

%% Cartesian patch
xC = [x0 x0+dx x0+dx x0];
yC = [y0 y0 y0+dy y0+dy];
hCart = patch(ax, xC, yC, 'b', 'FaceAlpha', 0.4, 'ButtonDownFcn', @startDragCartesian);
hCartText = text(ax, 0, 0, '', 'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle', 'FontSize', 14, 'FontWeight', 'bold');

%% Polar patch
theta0 = atan(x0/y0);
r0     = sqrt(x0^2 + y0^2);

theta = linspace(theta0, theta0+dtheta, 200);
[xt1, yt1] = pol2cart(theta, r0);
[xt2, yt2] = pol2cart(fliplr(theta), r0+dr);

hPolar = patch(ax, [xt1 xt2], [yt1 yt2], 'r', 'FaceAlpha', 0.4, 'ButtonDownFcn', @startDragPolar);
hPolarText = text(ax, 0, 0, '', 'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle', 'FontSize', 14, 'FontWeight', 'bold');

updateAreaText()

%% Shared drag state
dragging    = '';
startPoint  = [0 0];
startParams = struct;

%% Callbacks
function startDragCartesian(~, ~)
    dragging   = 'cart';
    startPoint = ax.CurrentPoint(1,1:2);
    startParams.x0 = x0;
    startParams.y0 = y0;
    app.fig.WindowButtonMotionFcn = @draggingMotion;
    app.fig.WindowButtonUpFcn     = @stopDrag;
end

function startDragPolar(~, ~)
    dragging   = 'polar';
    startPoint = ax.CurrentPoint(1,1:2);
    startParams.r0     = r0;
    startParams.theta0 = theta0;
    app.fig.WindowButtonMotionFcn = @draggingMotion;
    app.fig.WindowButtonUpFcn     = @stopDrag;
end

function draggingMotion(~, ~)
    cp = ax.CurrentPoint(1,1:2);
    dp = cp - startPoint;

    switch dragging
        case 'cart'
            x0 = startParams.x0 + dp(1);
            y0 = startParams.y0 + dp(2);
            set(hCart, 'XData', [x0 x0+dx x0+dx x0], 'YData', [y0 y0 y0+dy y0+dy])

        case 'polar'
            cx = startParams.r0*cos(startParams.theta0) + dp(1);
            cy = startParams.r0*sin(startParams.theta0) + dp(2);
            [theta0, r0] = cart2pol(cx, cy);

            theta = linspace(theta0, theta0+dtheta, 200);
            [xt1, yt1] = pol2cart(theta, r0);
            [xt2, yt2] = pol2cart(fliplr(theta), r0+dr);
            set(hPolar, 'XData', [xt1 xt2], 'YData', [yt1 yt2])
    end

    updateAreaText()
end

function stopDrag(~, ~)
    app.fig.WindowButtonMotionFcn = '';
    app.fig.WindowButtonUpFcn     = '';
    dragging = '';
end

%% Area/centroid update -- recomputes both areas and repositions their labels
function updateAreaText()
    A_cart  = dx*dy;
    A_polar = 0.5*((r0+dr)^2 - r0^2)*dtheta;

    xc = x0 + dx/2;
    yc = y0 + dy/2;

    r1 = r0; r2 = r0 + dr;
    rc = (2/3)*(r2^3 - r1^3)/(r2^2 - r1^2);
    tc = theta0 + dtheta/2;
    [xp, yp] = pol2cart(tc, rc);

    set(hCartText, 'Position', [xc yc], 'String', sprintf('%.3f', A_cart))
    set(hPolarText, 'Position', [xp yp], 'String', sprintf('%.3f', A_polar))
end

end