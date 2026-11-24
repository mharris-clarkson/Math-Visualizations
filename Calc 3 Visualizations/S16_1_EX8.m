function S16_1_EX8()
%% Example of a Conservative Vector Field
% Plots the conservative field F = -grad(phi) for any potential phi(x,y),
% together with contour lines of phi. The gradient is computed
% numerically (central differences, Grad_f), so to try another potential just edit
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

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('Conservative Vector Field', 1);
ax = app.ax(1);

% (uiFigure already applied Pretty_Plot, including the $x$, $y$ labels)
axis(ax, 'equal')
title(ax, 'Conservative vector field with potential contours')

%% Vector field F = sgn*grad(phi), by central differences (Grad_f helper)
[X, Y] = meshgrid(linspace(lims(1), lims(2), nGrid));
[Fx, Fy] = Grad_f(phi, X, Y);
quiver(ax, X, Y, sgn*Fx, sgn*Fy)

%% Contours of the potential
[Xc, Yc] = meshgrid(linspace(lims(1), lims(2), 200));
contour(ax, Xc, Yc, phi(Xc, Yc), nContours, 'r', 'LineWidth', 2)

end