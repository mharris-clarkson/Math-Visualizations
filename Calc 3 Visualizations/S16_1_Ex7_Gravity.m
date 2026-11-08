function S16_1_Ex7_Gravity()
%% Newton's Law of Gravity Vector Field
% Plots the gravitational force on a test mass m at points around a mass M
% at the origin:  F = -G*M*m * r_vec / |r|^3  (magnitude G*M*m/|r|^2).
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

close all

%% User parameters for math objects
G = 1;     % gravitational constant
M = 1;     % mass at the origin
m = 1;     % test mass
gridPts = -5:1:5;   % grid points along each axis

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('Gravitational Vector Field', 1);
ax = app.ax(1);

Pretty_Plot(ax)
axis(ax, 'equal')
xlabel(ax, 'x'); ylabel(ax, 'y'); zlabel(ax, 'z')
title(ax, 'Gravitational Vector Field')
view(ax, 3)

%% Force field on a 3D grid (the origin is skipped to avoid dividing by zero)
[x, y, z] = meshgrid(gridPts, gridPts, gridPts);
r3 = (x.^2 + y.^2 + z.^2).^(3/2);
r3(r3 == 0) = Inf;          % F = 0 at the origin instead of NaN

Fx = -G*M*m .* x ./ r3;
Fy = -G*M*m .* y ./ r3;
Fz = -G*M*m .* z ./ r3;

quiver3(ax, x, y, z, Fx, Fy, Fz, 'b');

end