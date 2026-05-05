function S14_4_tangent_plane_or_paraboloid()
%% Visualizes the tangent plane and tangent paraboloid approximations to a
%  smooth bump surface at a moveable base point (x0, y0). A toggle button
%  switches between the first-order (plane) and second-order (paraboloid)
%  local approximations.
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
    function [hPt, hVx, hVy, hTp] = plot_geometry(x, y)
        z    = f(x, y);
        fx   = Diffx_f(f,x,y);
        fy   = Diffy_f(f,x,y);
        fxx  = Diffxx_f(f,x,y);
        fyy  = Diffyy_f(f,x,y);
        fxy  = Diffxy_f(f,x,y);

        Tx = [1, 0, fx]; Tx = Tx / norm(Tx);
        Ty = [0, 1, fy]; Ty = Ty / norm(Ty);

        hPt = plot3(app.ax, x, y, z, 'ko', 'MarkerSize', 8, ...
            'LineWidth', 2, 'MarkerFaceColor', 'k');
        hVx = quiver3(app.ax, x, y, z, Tx(1), Tx(2), Tx(3), ...
            0, 'r', 'LineWidth', 2, 'MaxHeadSize', 0.5);
        hVy = quiver3(app.ax, x, y, z, Ty(1), Ty(2), Ty(3), ...
            0, 'b', 'LineWidth', 2, 'MaxHeadSize', 0.5);

        tp_size = 0.25;
        [u, v]  = meshgrid(linspace(-tp_size, tp_size, 12));
        Xp = x + u;
        Yp = y + v;
        if useParaboloid
            Zp = z + fx*u + fy*v + 0.5*(fxx*u.^2 + 2*fxy*u.*v + fyy*v.^2);
        else
            Zp = z + fx*u + fy*v;
        end
        hTp = surf(app.ax, Xp, Yp, Zp, ...
             'EdgeColor', 'none', 'FaceColor', 'b');
        uistack(hTp, 'top')
    end

    function updateTitle()
        if useParaboloid
            title(app.ax, 'Partial Derivatives with Tangent Paraboloid', ...
                'Interpreter', 'latex')
        else
            title(app.ax, 'Partial Derivatives with Tangent Plane', ...
                'Interpreter', 'latex')
        end
    end

%% Make the initial plots
[X, Y] = meshgrid(-max_val:Delta_val:max_val);
Z = f(X, Y);
surf(app.ax, X, Y, Z,'FaceAlpha', 0.9)
Pretty_Plot(app.ax)
        Pretty_Color_Positive(app.ax, Z,'colorbar','off')


[hPt, hVx, hVy, hTp] = plot_geometry(x0, y0);
updateTitle()

%% Precompute math for updates
% Light weight — skip

%% Build UI
NumControls = 3;

xSlider = app.addControl('slider', '$x_0 = $', 1, NumControls, @updatePlot, ...
    'Default', x0, 'Min', -max_val, 'Max', max_val);

ySlider = app.addControl('slider', '$y_0 = $', 2, NumControls, @updatePlot, ...
    'Default', y0, 'Min', -max_val, 'Max', max_val);

btnToggle = app.addControl('button', 'Showing: Tangent Plane', 3, NumControls, ...
    @toggleApprox, 'ColorChange', true);

%% Functions for UI elements
    function toggleApprox(~, ~)
        useParaboloid = logical(btnToggle.Value);
        if useParaboloid
            btnToggle.String = 'Showing: Tangent Paraboloid';
        else
            btnToggle.String = 'Showing: Tangent Plane';
        end
        updatePlot()
    end

%% Main Draw update function.
    function updatePlot(~, ~)
        delete(hPt); delete(hVx); delete(hVy); delete(hTp);
        [hPt, hVx, hVy, hTp] = plot_geometry(xSlider.Value, ySlider.Value);
        zlim(app.ax, [0, 0.6])
        updateTitle()
    end
end