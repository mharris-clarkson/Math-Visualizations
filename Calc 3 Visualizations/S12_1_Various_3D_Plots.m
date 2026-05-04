function S12_1_Various_3D_Plots()
%% Plots various surfaces and regions in 3D for exploring the connection
%  between equations and the regions they describe. Cycles through five
%  examples with Previous/Next buttons.
%  Complements Lecture 1 for MA 232.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
exampleIdx = 1; % Starting example (1-5)

exampleNames = { ...
    'Example 1A: Plane $z = 5$', ...
    'Example 1B: Plane $x = y$ in 3D', ...
    'Example 2: Intersection of $x^2+z^2=4$ and $y=3$', ...
    'Example 3: Solid Bounded by Two Cylinders', ...
    'Example 6: Solid Bounded by Spheres and a Plane'};

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure(exampleNames{exampleIdx}, 1);
view(app.ax, 100, 40)

%% Optional math functions for plot computations
    function drawExample(idx)
        cla(app.ax)
        hold(app.ax, 'on')
        view(app.ax, 100, 40)

        switch idx
            case 1  % z = 5
                [x, y] = meshgrid(linspace(-5, 5, 10));
                z = 0*x + 5;
                surf(app.ax, x, y, z, ...
                    'EdgeColor', 'k', 'FaceColor', 'b', 'FaceAlpha', 0.5);
                plot_xyz_axis(app.ax, 5, 5, 8)
                legend(app.ax, '$z = 5$', 'Interpreter', 'latex')

            case 2  % y = x
                [x, z] = meshgrid(linspace(-2, 5, 10));
                y = x;
                surf(app.ax, x, y, z, ...
                    'EdgeColor', 'k', 'FaceColor', 'b', 'FaceAlpha', 0.5);
                plot_xyz_axis(app.ax, 5, 5, 8)
                legend(app.ax, '$x = y$ in 3D', 'Interpreter', 'latex')

            case 3  % Cylinder x^2+z^2=4 and plane y=3
                [theta, Y] = meshgrid(linspace(0, 2*pi, 50), linspace(-1, 4, 2));
                surf(app.ax, 2*sin(theta), Y, 2*cos(theta), ...
                    'FaceAlpha', 0.3, 'EdgeAlpha', 0.3, ...
                    'FaceColor', 'b', 'EdgeColor', 'b');
                [x, z] = meshgrid(linspace(-3, 3, 10));
                y = 3*ones(size(x));
                surf(app.ax, x, y, z, ...
                    'EdgeColor', 'k', 'FaceColor', 'g', ...
                    'EdgeAlpha', 0, 'FaceAlpha', 0.5);
                th = linspace(0, 2*pi, 100);
                plot3(app.ax, 2*cos(th), 3*ones(size(th)), 2*sin(th), ...
                    '.-k', 'LineWidth', 4)
                plot_xyz_axis(app.ax, 3, 4, 3)
                axis(app.ax, 'equal')
                legend(app.ax, '$x^2+z^2 = 4$', '$y = 3$', 'Intersection', ...
                    'Interpreter', 'latex')

            case 4  % Solid between two cylinders
                [theta, Z_cyl] = meshgrid(linspace(0, 2*pi, 100), linspace(-2, 2, 2));
                surf(app.ax, 2*cos(theta), 2*sin(theta), Z_cyl, ...
                    'FaceColor', 'b', 'FaceAlpha', 0.5, 'EdgeAlpha', 0.5);
                surf(app.ax, cos(theta), sin(theta), Z_cyl, ...
                    'FaceColor', 'r', 'FaceAlpha', 0.5, 'EdgeAlpha', 0.5);
                [r, th_cap] = meshgrid(linspace(1, 2, 50), linspace(0, 2*pi, 100));
                Xc = r .* cos(th_cap);
                Yc = r .* sin(th_cap);
                surf(app.ax, Xc, Yc,  2*ones(size(Xc)), ...
                    'FaceColor', 'k', 'FaceAlpha', 0.5, 'EdgeAlpha', 0.5);
                surf(app.ax, Xc, Yc, -2*ones(size(Xc)), ...
                    'FaceColor', 'k', 'FaceAlpha', 0.5, 'EdgeAlpha', 0.5);
                plot_xyz_axis(app.ax, 3, 3, 3)
                axis(app.ax, 'equal')
                legend(app.ax, '$x^2+y^2 = 4$', '$x^2+y^2 = 1$', 'Caps', ...
                    'Interpreter', 'latex')

            case 5  % Solid bounded by spheres and z=0 plane
                [xs, ys, zs] = sphere(50);
                Toplot = (zs <= 0);
                xi = xs; yi = ys; zi = zs;
                xi(~Toplot) = NaN; yi(~Toplot) = NaN; zi(~Toplot) = NaN;
                surf(app.ax, xi, yi, zi, ...
                    'EdgeColor', 'k', 'FaceColor', 'b', ...
                    'FaceAlpha', 0.5, 'EdgeAlpha', 0.5);
                xo = 2*xs; yo = 2*ys; zo = 2*zs;
                xo(~Toplot) = NaN; yo(~Toplot) = NaN; zo(~Toplot) = NaN;
                surf(app.ax, xo, yo, zo, ...
                    'EdgeColor', 'k', 'FaceColor', 'r', ...
                    'FaceAlpha', 0.5, 'EdgeAlpha', 0.5);
                [r, th] = meshgrid(linspace(1, 2, 10), linspace(0, 2*pi, 50));
                surf(app.ax, r.*cos(th), r.*sin(th), zeros(size(r)), ...
                    'EdgeColor', 'k', 'FaceColor', 'k', ...
                    'FaceAlpha', 0.5, 'EdgeAlpha', 0.5);
                plot_xyz_axis(app.ax, 3, 3, 1)
                axis(app.ax, 'equal')
                xlim(app.ax, [-3, 3]); ylim(app.ax, [-3, 3])
                legend(app.ax, '$x^2+y^2+z^2 = 1$', '$x^2+y^2+z^2 = 4$', '$z = 0$', ...
                    'Interpreter', 'latex')
        end

        Pretty_Plot(app.ax)
        title(app.ax, exampleNames{idx}, 'Interpreter', 'latex')
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
        exampleIdx = mod(exampleIdx - 2, 5) + 1;
        drawExample(exampleIdx)
    end

    function nextExample(~, ~)
        exampleIdx = mod(exampleIdx, 5) + 1;
        drawExample(exampleIdx)
    end

%% Main Draw update function.
% (Handled directly in prevExample / nextExample above)
end