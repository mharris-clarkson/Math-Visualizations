function S14_4_tangent_plane_or_paraboloid()
%% Visualizes the tangent plane and tangent paraboloid approximations to a
%  smooth bump surface at a base point (x0, y0). Click or drag on the
%  surface to move the point. A toggle button switches between the
%  first-order (plane) and second-order (paraboloid) local approximations.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
r2  = @(x,y) x.^2 + y.^2;
f   = @(x,y) (r2(x,y) < 1) .* exp(1./(r2(x,y) - 1));

max_val      = 1.4;
Delta_val    = 0.05;
x0           = 0;
y0           = 0;
useParaboloid = false;

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Tangent Plane vs Tangent Paraboloid', 1);
view(app.ax, 135, 45)
xlim(app.ax, max_val*[-1, 1])
ylim(app.ax, max_val*[-1, 1])
zlim(app.ax, [0, 0.6])

%% Optional math functions for plot computations
% Point, unit tangents and the local plane/paraboloid at (x,y)
    function [z, Tx, Ty, Xp, Yp, Zp] = geometry_at(x, y)
        z    = f(x, y);
        fx   = Diffx_f(f,x,y);
        fy   = Diffy_f(f,x,y);
        fxx  = Diffxx_f(f,x,y);
        fyy  = Diffyy_f(f,x,y);
        fxy  = Diffxy_f(f,x,y);

        Tx = [1, 0, fx]; Tx = Tx / norm(Tx);
        Ty = [0, 1, fy]; Ty = Ty / norm(Ty);

        Xp = x + u;
        Yp = y + v;
        if useParaboloid
            Zp = z + fx*u + fy*v + 0.5*(fxx*u.^2 + 2*fxy*u.*v + fyy*v.^2);
        else
            Zp = z + fx*u + fy*v;
        end
    end

    function updateTitle()
        if useParaboloid
            title(app.ax, {'Partial Derivatives with Tangent Paraboloid', ...
                'Click or drag on the surface to move the point'})
        else
            title(app.ax, {'Partial Derivatives with Tangent Plane', ...
                'Click or drag on the surface to move the point'})
        end
    end

%% Make the initial plots
[X, Y] = meshgrid(-max_val:Delta_val:max_val);
Z = f(X, Y);
surf(app.ax, X, Y, Z,'FaceAlpha', 0.9)
Pretty_Plot(app.ax);
Pretty_Color_Positive(app.ax, Z,'colorbar','off');
zlim(app.ax, [0, 0.6])

%% Precompute math for updates
tp_size = 0.25;
[u, v]  = meshgrid(linspace(-tp_size, tp_size, 12));

[z0, Tx, Ty, Xp, Yp, Zp] = geometry_at(x0, y0);
hPt = plot3(app.ax, x0, y0, z0, 'ko', 'MarkerSize', 8, ...
    'LineWidth', 2, 'MarkerFaceColor', 'k');
hVx = quiver3(app.ax, x0, y0, z0, Tx(1), Tx(2), Tx(3), ...
    0, 'r', 'LineWidth', 2, 'MaxHeadSize', 0.5);
hVy = quiver3(app.ax, x0, y0, z0, Ty(1), Ty(2), Ty(3), ...
    0, 'b', 'LineWidth', 2, 'MaxHeadSize', 0.5);
hTp = surf(app.ax, Xp, Yp, Zp, ...
     'EdgeColor', 'none', 'FaceColor', 'b');
uistack(hTp, 'top')
updateTitle()

px = x0;  py = y0;   % current base point

%% Build UI: drag the point on the surface, toggle the approximation
Drag_Point_On_Surface(app.ax, f, max_val*[-1 1], max_val*[-1 1], @movePoint);

NumControls = 1;
btnToggle = app.addControl('button', 'Showing: Tangent Plane', 1, NumControls, ...
    @toggleApprox, 'ColorChange', true, ...
    'Toggle', ["Showing: Tangent Plane", "Showing: Tangent Paraboloid"]);

%% Functions for UI elements
    function movePoint(x, y)
        px = x;  py = y;
        updatePlot()
    end

    function toggleApprox(~, ~)
        useParaboloid = logical(btnToggle.Value);
        updatePlot()
    end

%% Main Draw update function.
    function updatePlot(~, ~)
        x = px;
        y = py;
        [z, Tx, Ty, Xp, Yp, Zp] = geometry_at(x, y);
        set(hPt, 'XData', x, 'YData', y, 'ZData', z);
        set(hVx, 'XData', x, 'YData', y, 'ZData', z, ...
            'UData', Tx(1), 'VData', Tx(2), 'WData', Tx(3));
        set(hVy, 'XData', x, 'YData', y, 'ZData', z, ...
            'UData', Ty(1), 'VData', Ty(2), 'WData', Ty(3));
        set(hTp, 'XData', Xp, 'YData', Yp, 'ZData', Zp);
        updateTitle()
    end
end