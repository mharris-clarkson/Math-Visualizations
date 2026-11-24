function S13_1_Plots_Curves_in_Space()
%% Gallery of curves in 3D (complements Lecture 6 for MA 231). The
%  Previous/Next buttons step through six examples: a helix with its unit
%  tangent vector, two paraboloid-plane intersection curves (shown with
%  both surfaces), a toroidal spiral, a trefoil knot and a 3D heart curve
%  (viewed at an angle that hides what it is to start).
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
exampleIdx = 1; % Starting example (1-6)

exampleNames = { ...
    'Helix: Example 5', ...
    'Paraboloid-Plane Intersection: Example 7', ...
    'Paraboloid-Plane Intersection: Example 8', ...
    'Toroidal Spiral: Example 9', ...
    'Trefoil Knot: Example 10', ...
    '3D Heart Curve'};

% Colors for the surfaces in Examples 7 and 8
surfColor  = [0.2 0.6 0.9];   % paraboloid
planeColor = [0.9 0.6 0.2];   % plane

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure(exampleNames{exampleIdx}, 1);

%% Optional math functions for plot computations
    function drawExample(idx)
        cla(app.ax)
        legend(app.ax, 'off')

        switch idx
            case 1  % Helix with the unit tangent vector at the end
                t = linspace(0, 5*pi, 200);
                r = @(t) [cos(t); sin(t); t];
                R = r(t);
                plot3(app.ax, R(1,:), R(2,:), R(3,:), 'b', 'LineWidth', 2)

                tp = t(end);
                P  = r(tp);
                T  = Diff_f_unit(r, tp);
                quiver3(app.ax, P(1), P(2), P(3), T(1), T(2), T(3), 0.2, 'b', ...
                    'MaxHeadSize', 3, 'LineWidth', 2)
                view(app.ax, 3)

            case 2  % z = x^2 + y^2 meets z = 2 - y
                [x, y] = meshgrid(linspace(-2,2,100), linspace(-3,2,100));
                t = linspace(0, 2*pi, 500);

                surf(app.ax, x, y, x.^2 + y.^2, ...
                    'FaceAlpha', 0.3, 'FaceColor', surfColor, 'EdgeColor', 'none')
                surf(app.ax, x, y, 2 - y, ...
                    'FaceAlpha', 0.5, 'FaceColor', planeColor, 'EdgeColor', 'none')
                plot3(app.ax, 3/2*cos(t), -1/2 + 3/2*sin(t), 5/2 - 3/2*sin(t), ...
                    'k', 'LineWidth', 2)

                legend(app.ax, 'Paraboloid: $z = x^2 + y^2$', ...
                    'Plane: $z = 2 - y$', 'Intersection')
                view(app.ax, 3)

            case 3  % z^2 = 4y - x^2 meets y = x
                % Paraboloid y = (x^2 + z^2)/4 and plane y = x
                [x, z] = meshgrid(linspace(-3,5,150));
                surf(app.ax, x, (x.^2 + z.^2)/4, z, ...
                    'FaceAlpha', 0.3, 'FaceColor', surfColor, 'EdgeColor', 'none')

                [y, z] = meshgrid(linspace(-1,5,2), linspace(-3,3,2));
                surf(app.ax, y, y, z, ...
                    'FaceAlpha', 0.5, 'FaceColor', planeColor, 'EdgeColor', 'none')

                t = linspace(0, 2*pi, 100);
                plot3(app.ax, 2 + 2*cos(t), 2 + 2*cos(t), 2*sin(t), 'k', 'LineWidth', 2)

                legend(app.ax, 'Paraboloid: $z^2 = 4y - x^2$', ...
                    'Plane: $y = x$', 'Intersection')
                view(app.ax, 3)

            case 4  % Toroidal spiral
                t = linspace(0, 2*pi, 2000);
                plot3(app.ax, (4 + sin(10*t)).*cos(t), ...
                              (4 + sin(10*t)).*sin(t), ...
                              cos(10*t), 'r', 'LineWidth', 2)
                view(app.ax, 45, 25)

            case 5  % Trefoil knot (closes after t = 4*pi)
                t = linspace(0, 4*pi, 2000);
                plot3(app.ax, (2 + cos(1.5*t)).*cos(t), ...
                              (2 + cos(1.5*t)).*sin(t), ...
                              sin(1.5*t), 'r', 'LineWidth', 2)
                view(app.ax, 45, 25)

            case 6  % 3D heart curve
                t = linspace(0, 2*pi, 200);
                plot3(app.ax, 16*sin(t).^3, ...
                              13*cos(t) - 5*cos(2*t) - 2*cos(3*t) - cos(4*t), ...
                              2.5*sin(t), 'r', 'LineWidth', 2)
                view(app.ax, 45, 25)   % hides what it is to start
        end

        Pretty_Plot(app.ax)
        title(app.ax, exampleNames{idx})
        app.fig.Name = exampleNames{idx};
    end

%% Make the initial plots
drawExample(exampleIdx)

%% Build UI
NumControls = 2;
app.addPrevNext(1, NumControls, numel(exampleNames), @drawExample);
app.galleryIdx = exampleIdx;
end
