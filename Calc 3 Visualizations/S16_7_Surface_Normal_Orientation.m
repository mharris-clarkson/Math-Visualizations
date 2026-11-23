function S16_7_Surface_Normal_Orientation()
%% Unit normal and orientation of the surface S: z = x^2 - y^2.
%  A red point sits on the saddle with its unit normal
%      n = <-f_x, -f_y, 1> / sqrt(1 + f_x^2 + f_y^2)
%  drawn as an arrow. Drag the point with the mouse (or use the sliders) to
%  watch n follow the surface; the normal changes continuously, which is
%  what makes the surface orientable.
%    x0, y0 sliders     - move the point
%    Orientation button - swap between the upward normal (blue) and the
%                         downward normal -n (red)
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
f = @(x,y) x.^2 - y.^2;   % surface z = f(x,y)

x0 = 0.0;                 % starting point
y0 = 0.0;
xlims = [-2 2]; ylims = [-2 2];
res      = 100;           % grid points per side for the surface
arrowLen = 0.75;          % length of the normal arrow
nRay     = 400;           % samples along the mouse ray when dragging

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Surface normal and orientation', 1);
ax  = app.ax(1);

%% Optional math functions for plot computations
% Unit normal from the helper gradient: n = <-f_x, -f_y, 1>/|.|
    function nv = computeNormal(x, y)
        g  = Grad_f(f, [x; y]);
        nv = [-g(1), -g(2), 1];
        nv = orientation * nv / norm(nv);
    end

%% Make the initial plots
orientation = 1;          % +1 upward normal, -1 downward normal
dragging    = false;

[X, Y] = meshgrid(linspace(xlims(1), xlims(2), res), ...
                  linspace(ylims(1), ylims(2), res));
Z = f(X, Y);
surf(ax, X, Y, Z, 'EdgeColor', 'none', 'FaceAlpha', 0.85);
Pretty_Color_Centered(ax, Z, 'colorbar', 'off');

% Point (clickable: starts a drag)
ptHandle = plot3(ax, x0, y0, f(x0,y0), 'ro', ...
    'MarkerSize', 10, 'LineWidth', 2, 'MarkerFaceColor', 'r', ...
    'ButtonDownFcn', @startDrag, ...
    'PickableParts', 'all', 'HitTest', 'on');

n = computeNormal(x0, y0);
normalHandle = quiver3(ax, x0, y0, f(x0,y0), ...
    arrowLen*n(1), arrowLen*n(2), arrowLen*n(3), 0, ...
    'LineWidth', 2, 'MaxHeadSize', 2, 'Color', 'b');

%% Plot elements are done - Make pretty
xlim(ax, xlims); ylim(ax, ylims)
view(ax, -27, 63)

%% Precompute math for updates
tRay = linspace(0, 1, nRay).';   % parameter along the mouse ray

%% Build UI
NumControls = 3;
sX = app.addControl('slider', '$x_0 = $', 1, NumControls, @moveFromSliders, ...
    'Default', x0, 'Min', xlims(1), 'Max', xlims(2));
sY = app.addControl('slider', '$y_0 = $', 2, NumControls, @moveFromSliders, ...
    'Default', y0, 'Min', ylims(1), 'Max', ylims(2));
btnOrient = app.addControl('button', '', 3, NumControls, @toggleOrientation, ...
    'Toggle', ["Swap orientation", "Back to standard"], 'ColorChange', true);

% Figure callbacks for dragging the point
app.fig.WindowButtonUpFcn     = @stopDrag;
app.fig.WindowButtonMotionFcn = @draggingFcn;

updatePlot()

%% Functions for UI elements
    function moveFromSliders(~, ~)
        x0 = sX.Value;
        y0 = sY.Value;
        updatePlot()
    end

    function toggleOrientation(~, ~)
        if btnOrient.Value
            orientation = -1;
        else
            orientation = 1;
        end
        updatePlot()
    end

    function startDrag(~, ~)
        dragging = true;
    end

    function stopDrag(~, ~)
        dragging = false;
    end

    function draggingFcn(~, ~)
        if ~dragging
            return
        end
        [xNew, yNew, ok] = rayHitsSurface(ax.CurrentPoint);
        if ~ok
            return
        end
        x0 = xNew;
        y0 = yNew;
        sX.Value = x0;   % sliders (and their labels) follow the mouse
        sY.Value = y0;
        updatePlot()
    end

    % The mouse gives a line through the scene (front and back points).
    % Walk along it and return the first place it crosses z = f(x,y).
    % (The original used the front point's x and y, which is only right
    % when looking straight down.)
    function [xh, yh, ok] = rayHitsSurface(cp)
        P = cp(1,:) + tRay .* (cp(2,:) - cp(1,:));
        inside = P(:,1) >= xlims(1) & P(:,1) <= xlims(2) & ...
                 P(:,2) >= ylims(1) & P(:,2) <= ylims(2);
        gap = P(:,3) - f(P(:,1), P(:,2));
        gap(~inside) = NaN;
        k = find(sign(gap(1:end-1)) .* sign(gap(2:end)) <= 0, 1);
        ok = ~isempty(k);
        if ~ok
            xh = []; yh = [];
            return
        end
        s  = gap(k) / (gap(k) - gap(k+1));            % linear interpolation
        if ~isfinite(s), s = 0; end
        Ph = P(k,:) + s*(P(k+1,:) - P(k,:));
        xh = Ph(1); yh = Ph(2);
    end

%% Main Draw update function.
    function updatePlot(~, ~)
        z0 = f(x0, y0);
        n  = computeNormal(x0, y0);

        if orientation == 1
            col = 'b';
            name = 'Upward';
        else
            col = 'r';
            name = 'Downward';
        end

        set(ptHandle, 'XData', x0, 'YData', y0, 'ZData', z0);
        set(normalHandle, 'XData', x0, 'YData', y0, 'ZData', z0, ...
            'UData', arrowLen*n(1), 'VData', arrowLen*n(2), 'WData', arrowLen*n(3), ...
            'Color', col);
        title(ax, sprintf('%s unit normal at $(%.2f, %.2f, %.2f)$: $\\mathbf{n} = \\langle %.2f, %.2f, %.2f \\rangle$', ...
            name, x0, y0, z0, n(1), n(2), n(3)))
        drawnow limitrate
    end

end
