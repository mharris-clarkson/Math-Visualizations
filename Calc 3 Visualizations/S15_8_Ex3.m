function S15_8_Ex3()
%% Spherical Coordinates Example: Region Between a Cone and a Sphere
% Plots the cone z = r and the upper sphere z = 1/2 + sqrt(1/4 - r^2), plus
% a point given by spherical coordinates (r, theta, phi) controlled by sliders.
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

close all

%% User parameters for math objects
r_val = 1;  theta_val = 0;  phi_val = 0;   % initial point (spherical coordinates)

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('Cone and Sphere', 1);
ax = app.ax(1);

Pretty_Plot(ax)
axis(ax, 'equal')
xlabel(ax, 'x'); ylabel(ax, 'y'); zlabel(ax, 'z')
view(ax, 3)

%% Static surfaces (cone and upper sphere, masked to where cone <= sphere)
[r_grid, theta_grid] = meshgrid(linspace(0, 0.5, 100), linspace(0, 2*pi, 100));
x = r_grid.*cos(theta_grid);
y = r_grid.*sin(theta_grid);

z_cone   = r_grid;
z_sphere = 0.5 + sqrt(1/4 - r_grid.^2);
mask = (r_grid.^2 <= 1/4) & (z_cone <= z_sphere);
z_cone(~mask)   = NaN;
z_sphere(~mask) = NaN;

surf(ax, x, y, z_cone,   'FaceAlpha', 0.6, 'EdgeColor', 'none');
surf(ax, x, y, z_sphere, 'FaceAlpha', 0.6, 'EdgeColor', 'none');
camlight(ax)
lighting(ax, 'phong')

%% Moving line + point (created once, updated in place)
hLine  = plot3(ax, [0 0], [0 0], [0 0], 'r', 'LineWidth', 3);
hPoint = plot3(ax, 0, 0, 0, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 8);

%% Build UI
nC = 3;
s_r     = app.addControl('slider', '$r = $',      1, nC, @updatePlot, 'Default', r_val,     'Min', 0, 'Max', 2,   'Number_format', '%.2f');
s_theta = app.addControl('slider', '$\theta = $', 2, nC, @updatePlot, 'Default', theta_val, 'Min', 0, 'Max', 2*pi, 'Number_format', '%.2f');
s_phi   = app.addControl('slider', '$\phi = $',   3, nC, @updatePlot, 'Default', phi_val,   'Min', 0, 'Max', pi,  'Number_format', '%.2f');

redraw(r_val, theta_val, phi_val)

%% Callback
function updatePlot(~, ~)
    redraw(s_r.Value, s_theta.Value, s_phi.Value)
end

%% Redraw: moves the line and point to the new spherical coordinates
function redraw(r, theta, phi)
    p = r*[cos(theta)*sin(phi), sin(theta)*sin(phi), cos(phi)];
    set(hLine,  'XData', [0 p(1)], 'YData', [0 p(2)], 'ZData', [0 p(3)])
    set(hPoint, 'XData', p(1),     'YData', p(2),     'ZData', p(3))
end

end
