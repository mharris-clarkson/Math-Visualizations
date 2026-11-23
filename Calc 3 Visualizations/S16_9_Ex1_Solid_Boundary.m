function S16_9_Ex1_Solid_Boundary()
%% Divergence theorem example: the solid E bounded by the parabolic
%  cylinder z = 1 - x^2 and the planes z = 0, y = 0 and y + z = 2.
%  Its boundary S is made of four faces. For
%      F = <xy, y^2 + e^(x z^2), sin(xy)>
%  the flux through each face (outward) is listed in the legend, and the
%  title compares their sum with iiint_E div F dV = iiint_E 3y dV = 184/35.
%  The flux through each face is awkward (two of them involve e^(x z^2)),
%  but the volume integral is easy, which is the point of the example.
%    Explode button - pull the faces apart to see the four pieces of S
%    Normals button - show the outward unit normals on every face
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
F1 = @(x,y,z) x.*y;                    % vector field F = <F1, F2, F3>
F2 = @(x,y,z) y.^2 + exp(x.*z.^2);
F3 = @(x,y,z) sin(x.*y);

nGrid    = 40;      % grid points per side for each face (original 200)
explodeD = 0.35;    % how far the faces move apart when exploded
arrowLen = 0.3;     % length of the normal arrows
faceCols = [0.8 0.2 0.2; 0.2 0.6 0.8; 0.2 0.8 0.4; 0.8 0.6 0.2];

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Divergence theorem example: boundary of a solid', 1);
ax  = app.ax(1);

%% Optional math functions for plot computations
divF = @(x,y,z) Diffx_f(F1,x,y,z) + Diffy_f(F2,x,y,z) + Diffz_f(F3,x,y,z);

% Volume integral over E: -1 <= x <= 1, 0 <= z <= 1 - x^2, 0 <= y <= 2 - z
% (integral3 order x, z, y, so the handle takes (x, z, y))
volInt = integral3(@(x,z,y) divF(x,y,z), -1, 1, 0, @(x) 1 - x.^2, 0, @(x,z) 2 - z, ...
    'AbsTol', 1e-10);

% Outward flux through each face, F . (r_u x r_v) over its parameter domain
Fdot = @(x,y,z,n1,n2,n3) F1(x,y,z).*n1 + F2(x,y,z).*n2 + F3(x,y,z).*n3;
flux = zeros(1, 4);
% 1. Top z = 1 - x^2, params (x, y), 0 <= y <= 1 + x^2, N = <2x, 0, 1>
flux(1) = integral2(@(x,y) Fdot(x, y, 1 - x.^2, 2*x, 0, 1), -1, 1, 0, @(x) 1 + x.^2);
% 2. Bottom z = 0, params (x, y), 0 <= y <= 2, N = <0, 0, -1>
flux(2) = integral2(@(x,y) Fdot(x, y, 0*x, 0, 0, -1), -1, 1, 0, 2);
% 3. Side y = 0, params (x, z), 0 <= z <= 1 - x^2, N = <0, -1, 0>
flux(3) = integral2(@(x,z) Fdot(x, 0*x, z, 0, -1, 0), -1, 1, 0, @(x) 1 - x.^2);
% 4. Slant y + z = 2, params (x, z), 0 <= z <= 1 - x^2, N = <0, 1, 1>
flux(4) = integral2(@(x,z) Fdot(x, 2 - z, z, 0, 1, 1), -1, 1, 0, @(x) 1 - x.^2);
flux(abs(flux) < 1e-9) = 0;       % bottom face is exactly 0 (odd in x)

%% Make the initial plots
[Xg, Sg] = meshgrid(linspace(-1, 1, nGrid), linspace(0, 1, nGrid));   % s scales the second variable

face = struct('X', {}, 'Y', {}, 'Z', {}, 'shift', {}, 'name', {});
% 1. Top: z = 1 - x^2, y from 0 to 1 + x^2
face(1).X = Xg;  face(1).Y = Sg.*(1 + Xg.^2);  face(1).Z = 1 - Xg.^2;
face(1).shift = [0 0 1];          face(1).name = 'Top $z = 1 - x^2$';
% 2. Bottom: z = 0, y from 0 to 2
face(2).X = Xg;  face(2).Y = 2*Sg;  face(2).Z = 0*Xg;
face(2).shift = [0 0 -1];         face(2).name = 'Bottom $z = 0$';
% 3. Side: y = 0, z from 0 to 1 - x^2
face(3).X = Xg;  face(3).Y = 0*Xg;  face(3).Z = Sg.*(1 - Xg.^2);
face(3).shift = [0 -1 0];         face(3).name = 'Side $y = 0$';
% 4. Slant: y + z = 2, z from 0 to 1 - x^2
face(4).X = Xg;  face(4).Z = Sg.*(1 - Xg.^2);  face(4).Y = 2 - face(4).Z;
face(4).shift = [0 1 1]/sqrt(2);  face(4).name = 'Slant $y + z = 2$';

% Normal arrows: a few points per face, outward unit normals
[xa, sa] = meshgrid(linspace(-0.7, 0.7, 4), [0.3 0.7]);
xa = xa(:);  sa = sa(:);  one = ones(size(xa));  zer = zeros(size(xa));
face(1).P = [xa, sa.*(1 + xa.^2), 1 - xa.^2];        face(1).N = [2*xa, zer, one];
face(2).P = [xa, 2*sa, zer];                          face(2).N = [zer, zer, -one];
face(3).P = [xa, zer, sa.*(1 - xa.^2)];               face(3).N = [zer, -one, zer];
face(4).P = [xa, 2 - sa.*(1 - xa.^2), sa.*(1 - xa.^2)]; face(4).N = [zer, one, one];

hFace = gobjects(1, 4);  hNorm = gobjects(1, 4);  legStr = cell(1, 4);
for i = 1:4
    hFace(i) = surf(ax, face(i).X, face(i).Y, face(i).Z, ...
        'FaceColor', faceCols(i,:), 'EdgeColor', 'none', 'FaceAlpha', 0.9);
    Nu = arrowLen * face(i).N ./ vecnorm(face(i).N, 2, 2);
    hNorm(i) = quiver3(ax, face(i).P(:,1), face(i).P(:,2), face(i).P(:,3), ...
        Nu(:,1), Nu(:,2), Nu(:,3), 0, 'k', 'LineWidth', 1.5, 'Visible', 'off');
    legStr{i} = sprintf('%s: flux $= %.4f$', face(i).name, flux(i));
end

% Edges of the solid (one line object, NaN-separated pieces)
t  = linspace(-1, 1, 200).';  nanRow = [NaN NaN NaN];
edges = [t, 0*t, 1 - t.^2;          nanRow;   % top meets y = 0
         t, 1 + t.^2, 1 - t.^2;     nanRow;   % top meets y + z = 2
         t, 0*t, 0*t;               nanRow;   % bottom meets y = 0
         t, 2 + 0*t, 0*t];                    % bottom meets y + z = 2
hEdges = plot3(ax, edges(:,1), edges(:,2), edges(:,3), 'k', 'LineWidth', 2);

legend(ax, hFace, legStr, 'Location', 'northeast', 'Interpreter', 'latex')

%% Plot elements are done - Make pretty
axis(ax, 'equal')
view(ax, 3)
camlight(ax); lighting(ax, 'gouraud')
title(ax, {'$E$: $z = 1 - x^2$, $z = 0$, $y = 0$, $y + z = 2$, \quad $\mathbf{F} = \langle xy,\ y^2 + e^{xz^2},\ \sin(xy) \rangle$', ...
    sprintf('$\\int\\!\\!\\int_S \\mathbf{F}\\cdot d\\mathbf{S} = %.4f$, \\quad $\\int\\!\\!\\int\\!\\!\\int_E \\nabla\\cdot\\mathbf{F}\\,dV = %.4f$ \\quad $(184/35 = %.4f)$', ...
        sum(flux), volInt, 184/35)}, 'Interpreter', 'latex')

%% Precompute math for updates
% Face data and normals are stored in face(i); the buttons only move or hide them.

%% Build UI
NumControls = 2;
btnExplode = app.addControl('button', '', 1, NumControls, @updatePlot, ...
    'Toggle', ["Explode faces", "Join faces"], 'ColorChange', true);
btnNormals = app.addControl('button', '', 2, NumControls, @updatePlot, ...
    'Toggle', ["Show normals", "Hide normals"], 'ColorChange', true);

%% Functions for UI elements
% (Both buttons call updatePlot directly.)

%% Main Draw update function.
    function updatePlot(~, ~)
        d = explodeD * btnExplode.Value;      % 0 when joined
        for j = 1:4
            sh = d * face(j).shift;
            set(hFace(j), 'XData', face(j).X + sh(1), 'YData', face(j).Y + sh(2), ...
                'ZData', face(j).Z + sh(3))
            set(hNorm(j), 'XData', face(j).P(:,1) + sh(1), 'YData', face(j).P(:,2) + sh(2), ...
                'ZData', face(j).P(:,3) + sh(3), 'Visible', onoff(btnNormals.Value))
        end
        set(hEdges, 'Visible', onoff(~btnExplode.Value))   % edges belong to two faces
    end

end
