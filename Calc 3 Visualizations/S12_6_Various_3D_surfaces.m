function S12_6_Various_3D_surfaces()
%% Plots various 3D surfaces alongside their contour plots, introducing
%  the connection between surface geometry and level curves.
%  Cycles through four examples with Previous/Next buttons.
%  Complements Lecture 5 for MA 232.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
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

% Replace the single axes with two subplots positioned inside the figure
delete(app.ax)
ax_left  = subplot(1, 2, 1, 'Parent', app.fig);
ax_right = subplot(1, 2, 2, 'Parent', app.fig);

% Shift subplots up to leave room for controls
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
                Pretty_Color_Positive(ax_left, Z)
                plot_xyz_axis(ax_left, 5, 5, 24)
                view(ax_left, -25, 15)
                Pretty_Plot(ax_left)
                title(ax_left, 'Surface: $z = x^2$', 'Interpreter', 'latex')

                [C, hc] = contour(ax_right, X, Y, Z, levels, 'k', 'LineWidth', 1.5);
                clabel(C, hc, 'FontSize', 14, 'Color', 'k')
                Pretty_Plot(ax_right)
                title(ax_right, 'Contour Plot', 'Interpreter', 'latex')

            case 2  % Paraboloid z = x^2 + 4y^2
                [X, Y] = meshgrid(-3:0.1:3);
                Z = X.^2 + 4*Y.^2;
                levels = 0:5:45;

                surf(ax_left, X, Y, Z)
                shading(ax_left, 'flat')
                contour3(ax_left, X, Y, Z, levels, 'k', 'LineWidth', 1.5)
                Pretty_Color_Positive(ax_left, Z)
                view(ax_left, -72, 20)
                plot_xyz_axis(ax_left, 2, 2, 25)
                Pretty_Plot(ax_left)
                title(ax_left, 'Surface: $z = x^2 + 4y^2$', 'Interpreter', 'latex')

                [C, hc] = contour(ax_right, X, Y, Z, levels, 'k', 'LineWidth', 1.5);
                clabel(C, hc, 'FontSize', 14, 'Color', 'k')
                Pretty_Plot(ax_right)
                title(ax_right, 'Contour Plot', 'Interpreter', 'latex')

            case 3  % Saddle z = x^2 - y^2
                [X, Y] = meshgrid(-10:0.1:10);
                Z = X.^2 - Y.^2;
                levels = [-100:10:-10, -5, 0, 5, 10:10:100];

                surf(ax_left, X, Y, Z)
                shading(ax_left, 'flat')
                contour3(ax_left, X, Y, Z, levels, 'k', 'LineWidth', 1.5)
                Pretty_Color_Centered(ax_left, Z)
                plot_xyz_axis(ax_left, 5, 5, 24)
                view(ax_left, -25, 15)
                Pretty_Plot(ax_left)
                title(ax_left, 'Surface: $z = x^2 - y^2$', 'Interpreter', 'latex')

                [C, hc] = contour(ax_right, X, Y, Z, levels(levels > 0),  'r', 'LineWidth', 1.5);
                clabel(C, hc, 'FontSize', 14, 'Color', 'r')
                [C, hc] = contour(ax_right, X, Y, Z, [0 0], 'k', 'LineWidth', 1.5);
                clabel(C, hc, 'FontSize', 14, 'Color', 'k')
                [C, hc] = contour(ax_right, X, Y, Z, levels(levels < 0),  'b', 'LineWidth', 1.5);
                clabel(C, hc, 'FontSize', 14, 'Color', 'b')
                Pretty_Plot(ax_right)
                title(ax_right, 'Contour Plot', 'Interpreter', 'latex')

            case 4  % Hyperboloid x^2 + y^2 - z^2 = 4
                [u, v] = meshgrid(linspace(-8, 8, 50), linspace(0, 2*pi, 50));
                X = sqrt(u.^2 + 4) .* cos(v);
                Y = sqrt(u.^2 + 4) .* sin(v);
                Z = u;
                levels = -10:2:10;

                surf(ax_left, X, Y, Z)
                shading(ax_left, 'flat')
                contour3(ax_left, X, Y, Z, levels, 'k', 'LineWidth', 1.5)
                Pretty_Color_Centered(ax_left, Z)
                plot_xyz_axis(ax_left, 5, 5, 5)
                view(ax_left, -25, 15)
                Pretty_Plot(ax_left)
                title(ax_left, 'Surface: $x^2 + y^2 - z^2 = 4$', 'Interpreter', 'latex')

                [C, hc] = contour(ax_right, X, Y, Z, levels(levels >  1), 'r', 'LineWidth', 1.5);
                clabel(C, hc, 'FontSize', 14, 'Color', 'r')
                [C, hc] = contour(ax_right, X, Y, Z, [0 0], 'k', 'LineWidth', 1.5);
                clabel(C, hc, 'FontSize', 14, 'Color', 'k')
                [C, hc] = contour(ax_right, X, Y, Z, levels(levels < -1), 'b', 'LineWidth', 1.5);
                clabel(C, hc, 'FontSize', 14, 'Color', 'b')
                Pretty_Plot(ax_right)
                title(ax_right, 'Contour Plot', 'Interpreter', 'latex')
        end

        app.fig.Name = exampleNames{idx};
    end

%% Make the initial plots
drawExample(exampleIdx)

%% Precompute math for updates
% Light weight — skip

%% Build UI
NumControls = 2;

app.addControl('button', '$\leftarrow$ Previous', 1, NumControls, @prevExample);
app.addControl('button', 'Next $\rightarrow$',    2, NumControls, @nextExample);

%% Functions for UI elements
    function prevExample(~, ~)
        exampleIdx = mod(exampleIdx - 2, 4) + 1;
        drawExample(exampleIdx)
    end

    function nextExample(~, ~)
        exampleIdx = mod(exampleIdx, 4) + 1;
        drawExample(exampleIdx)
    end

%% Main Draw update function.
% (Handled directly in prevExample / nextExample above)
end