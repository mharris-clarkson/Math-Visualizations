function S15_6_Ex4()
%% Region of Integration for a Triple Integral
% Plots the top surface z = 12xy over the part of the unit square with
% y <= x, i.e. the solid E in the first octant bounded by z = 12xy and the
% planes y = x, x = 1, to help write the 6 possible iterated integrals of:
%
% \begin{example}{}{}
%   Evaluate $\iiint_E z dV$ where $E$ is the solid in the first octant
%   bounded by the surface $z=12xy$ and the planes $y=x, x=1$.
%
%   Before evaluating the integral, write all 6 possible iterated integrals.
%
%   See L23\_Ex4 for a plot.
% \end{example}
%
%% Author Info
%
% Cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

close all

%% User parameters for math objects
z = @(x,y) 12*x.*y;
res = 500;   % grid points per side

%% Surface over the region 0 <= y <= x <= 1 (NaN hides everything with y > x)
[X, Y] = meshgrid(linspace(0, 1, res));
Z = z(X, Y);
Z(Y > X) = NaN;

%% Other bounding surfaces of E (each is a ruled sheet: t = 0..1 scales z from 0 up to the top)
[s, t] = meshgrid(linspace(0, 1, 40));

% Plane x = 1: y = s, z from 0 to 12*1*y
Xr = ones(size(s));  Yr = s;  Zr = t .* z(1, s);

% Plane y = x: x = s, z from 0 to 12*x*x
Xd = s;  Yd = s;  Zd = t .* z(s, s);

%% Plot
figure
hold on
hTop = surf(X, Y, Z, 'FaceColor', 'c', 'FaceAlpha', 0.8, 'EdgeColor', 'none', 'DisplayName', 'z = 12xy (top)');
hRight = surf(Xr, Yr, Zr, 'FaceColor', 'g', 'FaceAlpha', 0.6, 'EdgeColor', 'none', 'DisplayName', 'x = 1');
hDiag  = surf(Xd, Yd, Zd, 'FaceColor', 'm', 'FaceAlpha', 0.6, 'EdgeColor', 'none', 'DisplayName', 'y = x');
hBot   = patch([0 1 1], [0 0 1], [0 0 0], 'y', 'FaceAlpha', 0.6, 'EdgeColor', 'k', 'DisplayName', 'z = 0 (bottom)');

xlabel('x'); ylabel('y'); zlabel('z')
set(gca, 'FontSize', 18)
legend([hTop hRight hDiag hBot], 'Location', 'northeast')
view(125, 25)
grid on

end