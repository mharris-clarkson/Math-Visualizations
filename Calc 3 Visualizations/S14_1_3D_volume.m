function S14_1_3D_volume()
%% Visualizes nested isosurfaces of a 3D scalar field composed of three
%  inverse-distance potentials centered at (1,0,0), (0,1,0), and (0,0,1).
%  Multiple semi-transparent shells reveal the volumetric structure.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
maxRadius = 5;
fValues   = 1:maxRadius;  % isosurface level values (f = k^2 each)

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
titleStr = 'Plot of $f = \frac{1}{(x-1)^2+y^2+z^2}+\frac{1}{x^2+(y-1)^2+z^2}+\frac{1}{x^2+y^2+(z-1)^2}$';
app = uiFigure(titleStr, 1);
axis(app.ax, [-maxRadius maxRadius -maxRadius maxRadius -maxRadius maxRadius])
axis(app.ax, 'equal')
view(app.ax, 3)
title(app.ax, titleStr, 'Interpreter', 'latex')

%% Precompute math for updates
% Build the 3D grid once — expensive to recompute
[X, Y, Z] = meshgrid(-maxRadius:0.1:maxRadius, ...
                     -maxRadius:0.1:maxRadius, ...
                     -maxRadius:0.1:maxRadius);

F = 1./((X-1).^2 + Y.^2     + Z.^2) + ...
    1./(X.^2     + (Y-1).^2  + Z.^2) + ...
    1./(X.^2     + Y.^2      + (Z-1).^2);

%% Make the initial plots
colors = jet(length(fValues));
for k = 1:length(fValues)
    fval = fValues(k)^2;
    p = patch(isosurface(X, Y, Z, F, fval));
    set(p, 'FaceColor', colors(k,:), 'EdgeColor', 'none', 'FaceAlpha', 0.2);
end

camlight('headlight'); lighting gouraud
Pretty_Plot(app.ax)
xlim(app.ax, [-maxRadius, maxRadius])
ylim(app.ax, [-maxRadius, maxRadius])
zlim(app.ax, [-maxRadius, maxRadius])

%% Build UI
% No interactive controls needed — static visualization

%% Main Draw update function.
% Static — no updates required.
end