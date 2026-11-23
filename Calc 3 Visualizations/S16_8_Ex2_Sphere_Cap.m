function S16_8_Ex2_Sphere_Cap()
%% Stokes' theorem example: S is the part of the sphere x^2 + y^2 + z^2 = 4
%  inside the cylinder x^2 + y^2 = 1 and above the xy-plane (green cap),
%  with upward normal. Its boundary C is the circle x^2 + y^2 = 1 at
%  z = sqrt(3), counterclockwise seen from above (black arrows).
%  For F = <xz, yz, xy> the title shows both sides of Stokes' theorem,
%      iint_S curl F . dS = oint_C F . dr   (= 0),
%  computed numerically. The line integral is much easier than the surface
%  integral, which is the point of the example.
%    Sphere / Cylinder buttons - hide or show the reference surfaces
%    F on C button             - the field F along the curve (blue)
%    curl F on S button        - curl F (magenta) and the normals n (black) on S
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
F1 = @(x,y,z) x.*z;            % vector field F = <F1, F2, F3>
F2 = @(x,y,z) y.*z;
F3 = @(x,y,z) x.*y;

Rs = 2;                        % sphere radius
zS = @(x,y) sqrt(Rs^2 - x.^2 - y.^2);                       % cap: z = zS(x,y), r <= 1
rC = @(t) [cos(t(:)), sin(t(:)), sqrt(Rs^2 - 1) + 0*t(:)];   % boundary C, 0 <= t <= 2 pi

zCyl     = [0 2.2];            % height range of the cylinder drawn
nGrid    = 60;                 % grid points per side for the surfaces
nArrowC  = 12;                 % arrows along C
arrowLen = 0.4;                % length of the n and curl F arrows

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Stokes example: sphere inside a cylinder', 1);
ax  = app.ax(1);

%% Optional math functions for plot computations
% Both sides of Stokes' theorem, computed numerically
tq   = linspace(0, 2*pi, 4001).';
P    = rC(tq);
dPdt = Diff_f(rC, tq);                                  % r'(t), one row per t
lineInt = trapz(tq, sum([F1(P(:,1),P(:,2),P(:,3)), F2(P(:,1),P(:,2),P(:,3)), ...
                         F3(P(:,1),P(:,2),P(:,3))] .* dPdt, 2));

% curl F . N dA with N = <-z_x, -z_y, 1> (upward), in polar coordinates
    function val = curlDotN(r, th)
        x = r.*cos(th);  y = r.*sin(th);  z = zS(x, y);
        [k1, k2, k3] = curl_f(F1, F2, F3, x, y, z);
        val = (-k1.*Diffx_f(zS,x,y) - k2.*Diffy_f(zS,x,y) + k3) .* r;
    end
surfInt = integral2(@curlDotN, 0, 1, 0, 2*pi, 'AbsTol', 1e-10);

% Both are 0 here; do not print round-off as -0.0000
lineInt(abs(lineInt) < 1e-9) = 0;
surfInt(abs(surfInt) < 1e-9) = 0;

%% Make the initial plots
% Upper hemisphere (faint reference)
[Th, Ph] = meshgrid(linspace(0, 2*pi, nGrid), linspace(0, pi/2, nGrid/2));
hSphere = surf(ax, Rs*sin(Ph).*cos(Th), Rs*sin(Ph).*sin(Th), Rs*cos(Ph), ...
    'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.08, 'EdgeColor', 'none');

% Cylinder x^2 + y^2 = 1
[Th, Zc] = meshgrid(linspace(0, 2*pi, nGrid), zCyl);
hCyl = surf(ax, cos(Th), sin(Th), Zc, 'FaceColor', [0 0.4 1], 'FaceAlpha', 0.12, 'EdgeColor', 'none');

% Surface S: the cap (polar grid for a clean edge)
[R, Th] = meshgrid(linspace(0, 1, nGrid/2), linspace(0, 2*pi, nGrid));
Xs = R.*cos(Th);  Ys = R.*sin(Th);  Zs = zS(Xs, Ys);
surf(ax, Xs, Ys, Zs, 'FaceColor', [0.2 0.8 0.2], 'FaceAlpha', 0.85, 'EdgeColor', 'none');

% Boundary curve C with orientation arrows
plot3(ax, P(:,1), P(:,2), P(:,3), 'k', 'LineWidth', 3);
tA  = linspace(0, 2*pi, nArrowC+1).';  tA(end) = [];
PA  = rC(tA);
TA  = Diff_f(rC, tA);  TA = 0.3 * TA ./ vecnorm(TA, 2, 2);
quiver3(ax, PA(:,1), PA(:,2), PA(:,3), TA(:,1), TA(:,2), TA(:,3), 0, ...
    'k', 'LineWidth', 2, 'MaxHeadSize', 1);

% F along C (hidden at start)
FA = [F1(PA(:,1),PA(:,2),PA(:,3)), F2(PA(:,1),PA(:,2),PA(:,3)), F3(PA(:,1),PA(:,2),PA(:,3))];
FA = 0.5 * FA / max(vecnorm(FA, 2, 2));
hFC = quiver3(ax, PA(:,1), PA(:,2), PA(:,3), FA(:,1), FA(:,2), FA(:,3), 0, ...
    'b', 'LineWidth', 1.5, 'Visible', 'off');

% curl F and unit normals on S (hidden at start)
[Rq, Tq] = meshgrid([0 0.45 0.85], linspace(0, 2*pi, 9));
Rq = Rq(:);  Tq = Tq(:);  keep = [true; Rq(2:end) > 0];   % one point at the center
xq = Rq(keep).*cos(Tq(keep));  yq = Rq(keep).*sin(Tq(keep));  zq = zS(xq, yq);
[c1, c2, c3] = curl_f(F1, F2, F3, xq, yq, zq);
Nq = [-Diffx_f(zS,xq,yq), -Diffy_f(zS,xq,yq), ones(size(xq))];
Nq = arrowLen * Nq ./ vecnorm(Nq, 2, 2);
Cq = [c1 c2 c3];  Cq = arrowLen * Cq / max(max(vecnorm(Cq, 2, 2)), eps);
hCurl = [quiver3(ax, xq, yq, zq, Cq(:,1), Cq(:,2), Cq(:,3), 0, 'm', 'LineWidth', 1.5), ...
         quiver3(ax, xq, yq, zq, Nq(:,1), Nq(:,2), Nq(:,3), 0, 'k', 'LineWidth', 1.5)];
set(hCurl, 'Visible', 'off')

%% Plot elements are done - Make pretty
axis(ax, 'equal')
view(ax, 135, 25)
box(ax, 'on')
camlight(ax); lighting(ax, 'gouraud')
title(ax, {'$S$: $x^2 + y^2 + z^2 = 4$ inside $x^2 + y^2 = 1$, $z \ge 0$, \quad $\mathbf{F} = \langle xz, yz, xy \rangle$', ...
    sprintf('$\\int\\!\\!\\int_S (\\nabla\\times\\mathbf{F})\\cdot d\\mathbf{S} = %.4f$, \\quad $\\oint_C \\mathbf{F}\\cdot d\\mathbf{r} = %.4f$', ...
        surfInt, lineInt)}, 'Interpreter', 'latex')

%% Precompute math for updates
% Everything above is fixed; the buttons only change visibility.

%% Build UI
NumControls = 4;
btnSphere = app.addControl('button', '', 1, NumControls, @updatePlot, ...
    'Toggle', ["Hide sphere", "Show sphere"]);
btnCyl    = app.addControl('button', '', 2, NumControls, @updatePlot, ...
    'Toggle', ["Hide cylinder", "Show cylinder"]);
btnF      = app.addControl('button', '', 3, NumControls, @updatePlot, ...
    'Toggle', ["Show $\mathbf{F}$ on $C$", "Hide $\mathbf{F}$ on $C$"], 'ColorChange', true);
btnCurl   = app.addControl('button', '', 4, NumControls, @updatePlot, ...
    'Toggle', ["Show $\nabla\times\mathbf{F}$ on $S$", "Hide $\nabla\times\mathbf{F}$ on $S$"], ...
    'ColorChange', true);

%% Functions for UI elements
% (All buttons call updatePlot directly.)

%% Main Draw update function.
    function updatePlot(~, ~)
        set(hSphere, 'Visible', onoff(~btnSphere.Value))
        set(hCyl,    'Visible', onoff(~btnCyl.Value))
        set(hFC,     'Visible', onoff(btnF.Value))
        set(hCurl,   'Visible', onoff(btnCurl.Value))
    end

end
