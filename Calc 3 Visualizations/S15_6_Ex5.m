function S15_6_Ex5()
%% Region of Integration for a Triple Integral
% Plots the surfaces bounding the solid E: the paraboloid y = x^2 + z^2
% and the plane y = 4, to help set up:
%
% \begin{example}{}{}
%   Evaluate $\iiint_E \sqrt{x^2+z^2}dV$ where $E$ is the region bounded by
%   the paraboloid $y=x^2+z^2$ and the plane $y=4$.
%
%   See L23\_Ex5 for a plot.
% \end{example}
%
%% Author Info
%
% Cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

close all

%% User parameters for math objects
y   = @(x,z) x.^2 + z.^2;
top = 4;   % plane y = top

%% Paraboloid (r = sqrt(top) at the plane) and the disk cap at y = top
[r, th] = meshgrid(linspace(0, sqrt(top), 60), linspace(0, 2*pi, 100));
Xp = r.*cos(th);  Zp = r.*sin(th);  Yp = y(Xp, Zp);
Xc = Xp;  Zc = Zp;  Yc = top*ones(size(Xc));

%% Plot
figure
hold on
hPar = surf(Xp, Yp, Zp, 'FaceColor', 'c', 'FaceAlpha', 0.8, 'EdgeColor', 'none', 'DisplayName', 'y = x^2 + z^2');
hCap = surf(Xc, Yc, Zc, 'FaceColor', 'm', 'FaceAlpha', 0.6, 'EdgeColor', 'none', 'DisplayName', 'y = 4');
xlabel('x'); ylabel('y'); zlabel('z')
set(gca, 'FontSize', 18)
legend([hPar hCap], 'Location', 'northeast')
view(125, 25)
grid on

end