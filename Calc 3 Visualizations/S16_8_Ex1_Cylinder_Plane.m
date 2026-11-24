function S16_8_Ex1_Cylinder_Plane()
%% Stokes' theorem example: the curve C where the plane y + z = 2 cuts the
%  cylinder x^2 + y^2 = 1, oriented counterclockwise seen from above, and
%  the piece S of the plane inside the cylinder (green), with upward normal.
%  For F = <-y^2, x, z^2> the title shows both sides of Stokes' theorem,
%      oint_C F . dr = iint_S curl F . dS   (= pi),
%  computed numerically. Black arrows on C show its orientation.
%    Cylinder / Plane buttons - hide or show the reference surfaces
%    F on C button            - the field F along the curve (blue)
%    curl F on S button       - curl F (magenta) and the normals n (black) on S
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
F1 = @(x,y,z) -y.^2;           % vector field F = <F1, F2, F3>
F2 = @(x,y,z)  x;
F3 = @(x,y,z)  z.^2;

zS = @(x,y) 2 - y;             % surface S: z = zS(x,y) over the unit disk
rC = @(t) [cos(t(:)), sin(t(:)), 2 - sin(t(:))];   % boundary C, 0 <= t <= 2 pi

zCyl     = [-1 3];             % height range of the cylinder drawn
planeBox = 1.5;                % plane drawn over [-planeBox, planeBox]^2
nGrid    = 60;                 % grid points per side for the surfaces
nTheta   = 121;                % points around the circle
nArrowC  = 12;                 % arrows along C
arrowLen = 0.4;                % length of the n and curl F arrows

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Stokes example: cylinder and plane', 1);
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

%% Make the initial plots
% Cylinder x^2 + y^2 = 1
[Th, Zc] = meshgrid(linspace(0, 2*pi, nTheta), linspace(zCyl(1), zCyl(2), 2));
hCyl = surf(ax, cos(Th), sin(Th), Zc, 'FaceColor', 'b', 'FaceAlpha', 0.15, 'EdgeColor', 'none');

% Plane y + z = 2 outside the cylinder, on a grid from the circle out to the square
thGrid = linspace(0, 2*pi, nTheta);
[Rho, Th] = meshgrid(linspace(0, 1, 6), thGrid);
edgeR = planeBox ./ max(abs(cos(Th)), abs(sin(Th)));   % distance to the square at angle Th
Rp = (1 - Rho) + Rho .* edgeR;
Xp = Rp.*cos(Th);  Yp = Rp.*sin(Th);
hPlane = surf(ax, Xp, Yp, zS(Xp, Yp), 'FaceColor', 'r', 'FaceAlpha', 0.4, 'EdgeColor', 'none');

% Surface S: the plane inside the cylinder
[R, Th] = meshgrid(linspace(0, 1, nGrid/2), thGrid);
Xs = R.*cos(Th);  Ys = R.*sin(Th);  Zs = zS(Xs, Ys);
surf(ax, Xs, Ys, Zs, 'FaceColor', [0.2 0.8 0.2], 'FaceAlpha', 0.7, 'EdgeColor', 'none');

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
Rq = Rq(:);  Tq = Tq(:);  keep = [true; Rq(2:end) > 0];
xq = Rq(keep).*cos(Tq(keep));  yq = Rq(keep).*sin(Tq(keep));  zq = zS(xq, yq);
[c1, c2, c3] = curl_f(F1, F2, F3, xq, yq, zq);
Nq = [-Diffx_f(zS,xq,yq), -Diffy_f(zS,xq,yq), ones(size(xq))];
Nq = arrowLen * Nq ./ vecnorm(Nq, 2, 2);
Cq = [c1 c2 c3];  Cq = arrowLen * Cq / max(vecnorm(Cq, 2, 2));
hCurl = [quiver3(ax, xq, yq, zq, Cq(:,1), Cq(:,2), Cq(:,3), 0, 'm', 'LineWidth', 1.5), ...
         quiver3(ax, xq, yq, zq, Nq(:,1), Nq(:,2), Nq(:,3), 0, 'k', 'LineWidth', 1.5)];
set(hCurl, 'Visible', 'off')

%% Plot elements are done - Make pretty
axis(ax, 'equal')
view(ax, 135, 25)
box(ax, 'on')
camlight(ax); lighting(ax, 'gouraud')
title(ax, {'$C$: $x^2 + y^2 = 1$ meets $y + z = 2$, \quad $\mathbf{F} = \langle -y^2, x, z^2 \rangle$', ...
    sprintf('$\\oint_C \\mathbf{F}\\cdot d\\mathbf{r} = %.4f$, \\quad $\\int\\!\\!\\int_S (\\nabla\\times\\mathbf{F})\\cdot d\\mathbf{S} = %.4f$', ...
        lineInt, surfInt)})


%% Build UI
NumControls = 4;
btnCyl   = app.addControl('button', '', 1, NumControls, @updatePlot, ...
    'Toggle', ["Hide cylinder", "Show cylinder"]);
btnPlane = app.addControl('button', '', 2, NumControls, @updatePlot, ...
    'Toggle', ["Hide plane", "Show plane"]);
btnF     = app.addControl('button', '', 3, NumControls, @updatePlot, ...
    'Toggle', ["Show $\mathbf{F}$ on $C$", "Hide $\mathbf{F}$ on $C$"], 'ColorChange', true);
btnCurl  = app.addControl('button', '', 4, NumControls, @updatePlot, ...
    'Toggle', ["Show $\nabla\times\mathbf{F}$ on $S$", "Hide $\nabla\times\mathbf{F}$ on $S$"], ...
    'ColorChange', true);

%% Main Draw update function.
    function updatePlot(~, ~)
        set(hCyl,   'Visible', onoff(~btnCyl.Value))
        set(hPlane, 'Visible', onoff(~btnPlane.Value))
        set(hFC,    'Visible', onoff(btnF.Value))
        set(hCurl,  'Visible', onoff(btnCurl.Value))
    end

end
