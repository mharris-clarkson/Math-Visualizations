function S14_6_Directional_Derivative()
%% Demonstrates the directional derivative of a bump function at a point
%  (x,y). Click or drag on the surface to move the point, and use the
%  slider to rotate the evaluation direction (as an angle theta away from
%  the gradient direction). The blue arrow is (u_1, u_2, D_u f) for the
%  unit direction u, so it is tangent to the surface and its z-component is
%  the directional derivative D_u f = |grad f| cos(theta). Where
%  grad f = 0, theta is measured from the x-axis instead.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all
%% User parameters for math objects.
% Adjust these to modify selected math objects below.
r2 = @(x,y) x.^2 + y.^2;
f  = @(x,y) (r2(x,y) < 1) .* exp(1./(r2(x,y) - 1));  % smooth bump function

x0     = 0.5;   % initial x (on the side of the bump, where grad f is not 0)
y0     = 0.3;   % initial y
theta0 = 0;     % initial rotation angle (rad) away from the gradient

max_val   = 1.4;   % domain is -max_val <= x, y <= max_val
Delta_val = 0.05;  % grid spacing for the surface mesh
nRay      = 400;   % samples along the mouse ray when finding the surface under the cursor
%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')
%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Directional Derivatives on Surface', 1);
view(app.ax, -16, 47)
xlim(app.ax, max_val*[-1, 1])
ylim(app.ax, max_val*[-1, 1])
zlim(app.ax, [0, 0.6])
%% Optional math functions for plot computations
    function redraw(x, y, theta)
        z    = f(x,y);
        grad = Grad_f(f, [x; y]);
        % Unit direction u: the gradient direction rotated by theta. (The
        % old code used the rotated gradient itself, which is not a unit
        % vector, so the title showed |grad f|^2 cos(theta) as D_u f.)
        if norm(grad) > 1e-12
            ghat = grad / norm(grad);
        else
            ghat = [1; 0];          % grad f = 0: measure theta from the x-axis
        end
        R  = [cos(theta) -sin(theta); sin(theta) cos(theta)];
        u  = R*ghat;                                % unit direction
        Du = grad(1)*u(1) + grad(2)*u(2);           % D_u f = grad f . u = |grad f| cos(theta)
        set(hPt,  'XData', x, 'YData', y, 'ZData', z);
        set(hVec, 'XData', x, 'YData', y, 'ZData', z, ...
            'UData', u(1), 'VData', u(2), 'WData', Du);
        title(app.ax, {sprintf('Directional Derivative at $(%.2f,%.2f)$, $\\theta=%s$: $D_{u}f = %.4f$', ...
            x, y, Pi_Label(theta, 'Dollars', false), Du), ...
            'Click or drag on the surface to move the point'})
    end

% Point (x,y) on the surface under the mouse: walk along the mouse ray from
% the front of the axes box and stop where it first passes below the
% surface. If the ray misses (e.g. it leaves the domain), use where it
% meets the plane z = 0 instead.
    function P = pointUnderMouse()
        cp = app.ax.CurrentPoint;                    % row 1 = front, row 2 = back
        t  = linspace(0, 1, nRay).';
        L  = cp(1,:) + t.*(cp(2,:) - cp(1,:));       % points along the ray
        inBox = all(abs(L(:,1:2)) <= max_val, 2);
        g = L(:,3) - f(L(:,1), L(:,2));              % height above the surface
        g(~inBox) = NaN;
        k = find(g(1:end-1) > 0 & g(2:end) <= 0, 1);
        if ~isempty(k)
            s = g(k)/(g(k) - g(k+1));                % linear interpolation in the step
            P = L(k,1:2) + s*(L(k+1,1:2) - L(k,1:2));
        else
            dz = cp(2,3) - cp(1,3);
            if abs(dz) < 1e-12, P = []; return, end
            P = cp(1,1:2) - cp(1,3)/dz*(cp(2,1:2) - cp(1,1:2));
        end
        P = min(max(P, -max_val), max_val);          % stay inside the domain
    end
%% Make the initial plots
[X, Y] = meshgrid(-max_val:Delta_val:max_val);
Z = f(X, Y);
surf(app.ax, X, Y, Z, 'EdgeColor', 'none')
colormap(app.ax, Pretty_Colormap('amp'))   % (redraw used to reapply this on every move)
contour3(app.ax, X, Y, Z, 20, 'k', 'LineWidth', 1)
Pretty_Plot(app.ax)
zlim(app.ax, [0, 0.6])

% Point and direction arrow: created once, updated in place by redraw()
hPt  = plot3(app.ax, NaN, NaN, NaN, 'bo', 'MarkerFaceColor', 'b', ...
    'MarkerSize', 10, 'LineWidth', 2);
hVec = quiver3(app.ax, 0, 0, 0, 0, 0, 0, 1, ...
    'Color', 'b', 'LineWidth', 2, 'MaxHeadSize', 0.5);

% Current point (moved by dragging)
px = x0;  py = y0;
redraw(px, py, theta0)
%% Precompute math for updates
% Light weight — skip
%% Dragging: clicks in the axes move the point to the surface under the mouse
% (the plotted objects ignore clicks so they all reach the axes, and the
%  built-in rotate/pan on drag is turned off so it does not compete)
set(app.ax.Children, 'HitTest', 'off', 'PickableParts', 'none')
disableDefaultInteractivity(app.ax)
app.ax.ButtonDownFcn = @startDrag;
%% Build UI
NumControls = 1;
thetaSlider = app.addControl('slider', '$\theta = $', 1, NumControls, @updatePlot, ...
'colOrRow', 'row', 'Default', theta0, 'Min', 0, 'Max', 2*pi, 'Number_format', 'pi');
%% Functions for UI elements
    function updatePlot(~, ~)
        redraw(px, py, thetaSlider.Value)
    end

    function startDrag(~, ~)
        doDrag();                                    % a click alone moves the point
        app.fig.WindowButtonMotionFcn = @doDrag;
        app.fig.WindowButtonUpFcn     = @stopDrag;
    end

    function doDrag(~, ~)
        P = pointUnderMouse();
        if isempty(P), return, end
        px = P(1);  py = P(2);
        redraw(px, py, thetaSlider.Value)
        drawnow limitrate
    end

    function stopDrag(~, ~)
        app.fig.WindowButtonMotionFcn = '';
        app.fig.WindowButtonUpFcn     = '';
    end
%% Main Draw update function.
% Handled above by redraw(), called from updatePlot() and the drag callbacks.
end
