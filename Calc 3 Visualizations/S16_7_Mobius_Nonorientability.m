function S16_7_Mobius_Nonorientability()
%% The Möbius strip is not orientable.
%  A point travels around the centerline (v = 0) of the Möbius strip
%      r(u,v) = < (1 + v cos(u/2)) cos u, (1 + v cos(u/2)) sin u, v sin(u/2) >
%  carrying the normal n = r_u x r_v (red) and -n (black), which change
%  continuously along the way. The dashed arrow is the starting normal n(0).
%  After one lap (u = 2 pi) the point is back where it started but the
%  normal points the other way, so no continuous choice of normal exists.
%  After two laps (u = 4 pi) it is back to n(0).
%    u slider - position along the centerline, 0 to 4 pi
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
halfWidth = 0.3;     % strip is -halfWidth <= v <= halfWidth
nU        = 150;     % surface grid along the strip
nV        = 20;      % surface grid across the strip
nPath     = 400;     % points on the centerline
arrowLen  = 0.35;    % length of the normal arrows
uMax      = 2*pi;    % one lap

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Mobius strip: not orientable', 1);
ax  = app.ax(1);

%% Optional math functions for plot computations
% Möbius map, vectorized: u and v columns (or scalars) -> rows [x y z]
mobius = @(u,v) [(1 + v.*cos(u/2)).*cos(u), ...
                 (1 + v.*cos(u/2)).*sin(u), ...
                  v.*sin(u/2)];

% Unit normal n = r_u x r_v at (u, v = 0)
    function nv = mobiusNormal(u)
        ru = Diff_f(@(t) mobius(t, 0), u);
        rv = Diff_f(@(t) mobius(u, t), 0);
        nv = cross(ru, rv);
        nv = nv / norm(nv);
    end

%% Make the initial plots
% Surface
[U, V] = meshgrid(linspace(0, 2*pi, nU), linspace(-halfWidth, halfWidth, nV));
XYZ = mobius(U(:), V(:));
X = reshape(XYZ(:,1), size(U));
Y = reshape(XYZ(:,2), size(U));
Z = reshape(XYZ(:,3), size(U));
surf(ax, X, Y, Z, 'EdgeColor', 'none', 'FaceAlpha', 0.85);
Pretty_Color_Centered(ax, Z, 'colorbar', 'off');

% Centerline (v = 0) and the part already travelled
uPath = linspace(0, 2*pi, nPath).';
cPath = mobius(uPath, 0);
plot3(ax, cPath(:,1), cPath(:,2), cPath(:,3), '--', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.5);
trail = plot3(ax, cPath(1,1), cPath(1,2), cPath(1,3), 'k', 'LineWidth', 3);

% Starting normal (dashed reference)
p0 = mobius(0, 0);
n0 = mobiusNormal(0);
quiver3(ax, p0(1), p0(2), p0(3), arrowLen*n0(1), arrowLen*n0(2), arrowLen*n0(3), 0, ...
    'r', 'LineWidth', 1.5, 'LineStyle', '--');

% Moving point with n (red) and -n (black)
pt = plot3(ax, p0(1), p0(2), p0(3), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 7);
hN    = quiver3(ax, p0(1), p0(2), p0(3),  arrowLen*n0(1),  arrowLen*n0(2),  arrowLen*n0(3), 0, ...
    'r', 'LineWidth', 2);
hNneg = quiver3(ax, p0(1), p0(2), p0(3), -arrowLen*n0(1), -arrowLen*n0(2), -arrowLen*n0(3), 0, ...
    'k', 'LineWidth', 2);

legend(ax, [hN hNneg], {'$\mathbf{n} = \mathbf{r}_u \times \mathbf{r}_v$', '$-\mathbf{n}$'}, ...
    'Location', 'northeast')

%% Plot elements are done - Make pretty
axis(ax, 'equal')
view(ax, 3)


%% Build UI
NumControls = 1;
sU = app.addControl('slider', '$u = $', 1, NumControls, @updatePlot, ...
    'Default', 0, 'Min', 0, 'Max', uMax, 'Number_format', 'pi', ...
    'colOrRow', 'row');

updatePlot()

%% Main Draw update function.
    function updatePlot(~, ~)
        u = app.getValue(sU);
        p = mobius(u, 0);
        n = mobiusNormal(u);

        % Trail: everything travelled so far (a full loop after one lap)
        k = max(1, round(min(u, 2*pi)/(2*pi) * (nPath-1)) + 1);
        set(trail, 'XData', cPath(1:k,1), 'YData', cPath(1:k,2), 'ZData', cPath(1:k,3))

        set(pt, 'XData', p(1), 'YData', p(2), 'ZData', p(3))
        set(hN, 'XData', p(1), 'YData', p(2), 'ZData', p(3), ...
            'UData',  arrowLen*n(1), 'VData',  arrowLen*n(2), 'WData',  arrowLen*n(3))
        set(hNneg, 'XData', p(1), 'YData', p(2), 'ZData', p(3), ...
            'UData', -arrowLen*n(1), 'VData', -arrowLen*n(2), 'WData', -arrowLen*n(3))

        msg = '';
        if abs(u - 2*pi) < 1e-9
            msg = ': same point, opposite normal!';
        elseif abs(u - 4*pi) < 1e-9
            msg = ': two laps, normal is back to $\mathbf{n}(0)$';
        end
        title(ax, ['Möbius strip' msg])
    end

end
