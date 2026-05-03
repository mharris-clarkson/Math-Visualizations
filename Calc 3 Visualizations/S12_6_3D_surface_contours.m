function S12_6_3D_surface_contours()
%% Visualizes the level surfaces (isosurfaces) of f(x,y,z) = x^2+y^2+z^2
%  as the level value is changed. Illustrates how a 3D function produces
%  a family of nested spherical surfaces.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
maxRadius  = 8;       % Maximum sphere radius (sqrt of max level value)
n0         = 1;       % Initial contour

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('3D Isosurface of $f(x,y,z) = x^2+y^2+z^2$', 1);
axis(app.ax, [-maxRadius maxRadius -maxRadius maxRadius -maxRadius maxRadius])
axis(app.ax, 'equal')
view(app.ax, 3)
camlight('headlight'); lighting gouraud
title(app.ax, app.fig.Name, 'Interpreter', 'latex')

%% Precompute math for updates
% Build the 3D grid once — expensive to recompute
[X, Y, Z] = meshgrid(-maxRadius:0.25:maxRadius, ...
                     -maxRadius:0.25:maxRadius, ...
                     -maxRadius:0.25:maxRadius);
F = X.^2 + Y.^2 + Z.^2;

%% Make the initial plots
isoH = patch(app.ax,isosurface(X, Y, Z, F, n0));
set(isoH, 'FaceColor', 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.5);
Pretty_Plot(app.ax)
xlim(app.ax, [-maxRadius, maxRadius])
ylim(app.ax, [-maxRadius, maxRadius])
zlim(app.ax, [-maxRadius, maxRadius])

%% Build UI
NumControls = 1;

nSlider = app.addControl('slider', '$f = $', 1, NumControls, @updatePlot, ...
    'Default', n0, 'Min', 1, 'Max', 64);

% Launch update to sync title
update();

%% Main Draw update function.
    function updatePlot(~, ~)
        update();
    end

    function update()
        n    = nSlider.Value;

        % Remove old isosurface and redraw
        delete(findall(app.ax, 'Type', 'patch'));
        isoH = patch(app.ax,isosurface(X, Y, Z, F, n));
        set(isoH, 'FaceColor', 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.5);
        xlim(app.ax, [-maxRadius, maxRadius])
        ylim(app.ax, [-maxRadius, maxRadius])
        zlim(app.ax, [-maxRadius, maxRadius])
        title(app.ax, sprintf('Isosurface of $f(x,y,z)=x^2+y^2+z^2$,  $f = %.2f$', n), ...
            'Interpreter', 'latex')
    end
end
