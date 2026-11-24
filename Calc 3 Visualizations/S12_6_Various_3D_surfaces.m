function S12_6_Various_3D_surfaces()
%% Plots various 3D surfaces alongside their contour plots, introducing
%  the connection between surface geometry and level curves.
%  Cycles through four examples with Previous/Next buttons.
%  Complements Lecture 5 for MA 231.
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
exampleIdx = 1; % Starting example (1-4)

exampleNames = { ...
    'Example 2: Parabolic Sheet $z = x^2$', ...
    'Example 3: Paraboloid $z = x^2 + 4y^2$', ...
    'Example 4: Saddle $z = x^2 - y^2$', ...
    'Example 5: Hyperboloid $x^2 + y^2 - z^2 = 4$'};

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure(exampleNames{exampleIdx}, 1);

% Two side-by-side panels, lifted to leave room for the controls
delete(app.ax)
ax_left  = subplot(1, 2, 1, 'Parent', app.fig);
ax_right = subplot(1, 2, 2, 'Parent', app.fig);
ax_left.Position  = ax_left.Position  .* [1 1 1 1] + [0 0.08 0 -0.08];
ax_right.Position = ax_right.Position .* [1 1 1 1] + [0 0.08 0 -0.08];

%% Optional math functions for plot computations
    function drawExample(idx)
        cla(ax_left);  cla(ax_right)
        hold(ax_left,  'on'); hold(ax_right, 'on')

        switch idx
            case 1  % Parabolic sheet z = x^2
                [X, Y] = meshgrid(linspace(-5, 5, 50));
                Z = X.^2;
                levels = round(linspace(min(Z(:)), max(Z(:)), 12));

                surf(ax_left, X, Y, Z)
                shading(ax_left, 'flat')
                contour3(ax_left, X, Y, Z, levels, 'k', 'LineWidth', 1.5)
                Pretty_Color_Positive(ax_left, Z);
                plot_xyz_axis(ax_left, 5, 5, 24)
                view(ax_left, -25, 15)
                Pretty_Plot(ax_left)
                title(ax_left, 'Surface: $z = x^2$')

                [C, hc] = contour(ax_right, X, Y, Z, levels, 'k', 'LineWidth', 1.5);
                clabel(C, hc, 'FontSize', 14, 'Color', 'k')
                Pretty_Plot(ax_right)
                title(ax_right, 'Contour Plot')

            case 2  % Paraboloid z = x^2 + 4y^2
                [X, Y] = meshgrid(-3:0.1:3);
                Z = X.^2 + 4*Y.^2;
                levels = 0:5:45;

                surf(ax_left, X, Y, Z)
                shading(ax_left, 'flat')
                contour3(ax_left, X, Y, Z, levels, 'k', 'LineWidth', 1.5)
                Pretty_Color_Positive(ax_left, Z);
                view(ax_left, -72, 20)
                plot_xyz_axis(ax_left, 2, 2, 25)
                Pretty_Plot(ax_left)
                title(ax_left, 'Surface: $z = x^2 + 4y^2$')

                [C, hc] = contour(ax_right, X, Y, Z, levels, 'k', 'LineWidth', 1.5);
                clabel(C, hc, 'FontSize', 14, 'Color', 'k')
                Pretty_Plot(ax_right)
                title(ax_right, 'Contour Plot')

            case 3  % Saddle z = x^2 - y^2
                [X, Y] = meshgrid(-10:0.1:10);
                Z = X.^2 - Y.^2;
                levels = [-100:10:-10, -5, 0, 5, 10:10:100];

                surf(ax_left, X, Y, Z)
                shading(ax_left, 'flat')
                contour3(ax_left, X, Y, Z, levels, 'k', 'LineWidth', 1.5)
                Pretty_Color_Centered(ax_left, Z);
                plot_xyz_axis(ax_left, 5, 5, 24)
                view(ax_left, -25, 15)
                Pretty_Plot(ax_left)
                title(ax_left, 'Surface: $z = x^2 - y^2$')

                [C, hc] = contour(ax_right, X, Y, Z, levels(levels > 0),  'r', 'LineWidth', 1.5);
                clabel(C, hc, 'FontSize', 14, 'Color', 'r')
                [C, hc] = contour(ax_right, X, Y, Z, [0 0], 'k', 'LineWidth', 1.5);
                clabel(C, hc, 'FontSize', 14, 'Color', 'k')
                [C, hc] = contour(ax_right, X, Y, Z, levels(levels < 0),  'b', 'LineWidth', 1.5);
                clabel(C, hc, 'FontSize', 14, 'Color', 'b')
                Pretty_Plot(ax_right)
                title(ax_right, 'Contour Plot')

            case 4  % Hyperboloid x^2 + y^2 - z^2 = 4
                [u, v] = meshgrid(linspace(-8, 8, 50), linspace(0, 2*pi, 50));
                X = sqrt(u.^2 + 4) .* cos(v);
                Y = sqrt(u.^2 + 4) .* sin(v);
                Z = u;
                levels = -10:2:10;

                surf(ax_left, X, Y, Z)
                shading(ax_left, 'flat')
                contour3(ax_left, X, Y, Z, levels, 'k', 'LineWidth', 1.5)
                Pretty_Color_Centered(ax_left, Z);
                plot_xyz_axis(ax_left, 5, 5, 5)
                view(ax_left, -25, 15)
                Pretty_Plot(ax_left)
                title(ax_left, 'Surface: $x^2 + y^2 - z^2 = 4$')

                [C, hc] = contour(ax_right, X, Y, Z, levels(levels >  1), 'r', 'LineWidth', 1.5);
                clabel(C, hc, 'FontSize', 14, 'Color', 'r')
                [C, hc] = contour(ax_right, X, Y, Z, [0 0], 'k', 'LineWidth', 1.5);
                clabel(C, hc, 'FontSize', 14, 'Color', 'k')
                [C, hc] = contour(ax_right, X, Y, Z, levels(levels < -1), 'b', 'LineWidth', 1.5);
                clabel(C, hc, 'FontSize', 14, 'Color', 'b')
                Pretty_Plot(ax_right)
                title(ax_right, 'Contour Plot')
        end

        app.fig.Name = exampleNames{idx};
    end

%% Make the initial plots
drawExample(exampleIdx)

%% Build UI
NumControls = 2;
app.addPrevNext(1, NumControls, numel(exampleNames), @drawExample);
app.galleryIdx = exampleIdx;
end