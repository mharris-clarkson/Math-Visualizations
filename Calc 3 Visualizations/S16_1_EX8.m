function S16_1_EX8()
%% Example of a Conservative Vector Field
% Plots the conservative field F = -grad(phi) for any potential phi(x,y),
% together with contour lines of phi. The gradient is computed
% numerically (central differences), so to try another potential just edit
% the phi handle in the user parameters (it must work elementwise on matrices).
%
% The field is perpendicular to every contour line of phi.
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

close all

%% User parameters for math objects
phi     = @(x,y) 0.5*(x.^2 + y.^2);   % potential
%phi     = @(x,y) sin(x).*cos(y);
lims    = [-2 2];                      % plot limits for both x and y
sgn     = -1;    % -1: F = -grad(phi) ("downhill"); +1: F = +grad(phi)
nGrid   = 21;    % arrows per side
nContours = 10;  % number of contour levels
h       = 1e-6;  % finite-difference step

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('Conservative Vector Field', 1);
ax = app.ax(1);

Pretty_Plot(ax)
axis(ax, 'equal')
xlabel(ax, 'x'); ylabel(ax, 'y')
title(ax, 'Conservative vector field with potential contours')

%% Vector field F = sgn*grad(phi), by central differences
[X, Y] = meshgrid(linspace(lims(1), lims(2), nGrid));
Fx = sgn*(phi(X+h, Y) - phi(X-h, Y))/(2*h);
Fy = sgn*(phi(X, Y+h) - phi(X, Y-h))/(2*h);
quiver(ax, X, Y, Fx, Fy)

%% Contours of the potential
[Xc, Yc] = meshgrid(linspace(lims(1), lims(2), 200));
contour(ax, Xc, Yc, phi(Xc, Yc), nContours, 'r', 'LineWidth', 2)

end