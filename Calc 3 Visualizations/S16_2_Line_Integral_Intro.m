function L27_S16_2_Integral()
%% Line Integral of a Scalar Function: 2D "Normal Integral" vs 3D Picture
% Evaluates  int_C f ds  along a curve C in the xy-plane. Two views, with a
% button to switch between them:
%   2D (start): f along the curve plotted against arc length s -- the line
%               integral looks like an ordinary integral over its domain.
%   3D:         the surface z = f(x,y), the curve C on it, and the "curtain"
%               under the curve, whose area is what the integral computes.
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

close all

%% User parameters for math objects
f = @(x,y) x.^2+y.^2;          % surface z = f(x,y); on the line y = x this is s^2
t = linspace(0, 1, 200);          % curve parameter
x = t;  y = t;                    % curve C: (x(t), y(t))
gridLim = [-1 1];                 % extent of the displayed surface
nGrid = 80;

%% Math: values along the curve, arc length, and the line integral
z = f(x, y);
s = [0, cumsum(hypot(diff(x), diff(y)))];    % arc length along C
lineIntegral = trapz(s, z);                  % int_C f ds

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('Area Under a Curve', 1);
ax = app.ax(1);

Pretty_Plot(ax)
axis(ax, 'equal')
colormap(ax, parula)

%% 3D graphics (surface, curve on it, curtain, reference plane)
[xg, yg] = meshgrid(linspace(gridLim(1), gridLim(2), nGrid));
Xc = [x; x];  Yc = [y; y];  Zc = [zeros(size(z)); z];   % curtain: drop each point to z = 0

g3 = [ ...
    surf(ax, xg, yg, f(xg, yg), 'EdgeColor', 'none', 'FaceAlpha', 0.6), ...
    plot3(ax, x, y, z, 'k', 'LineWidth', 2), ...
    surf(ax, Xc, Yc, Zc, 'FaceColor', [1 0.6 0.6], 'FaceAlpha', 0.8, 'EdgeColor', 'none'), ...
    surf(ax, xg, yg, zeros(size(xg)), 'FaceColor', [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.4)];

%% 2D graphics: f along the curve vs arc length (the area is the same as the curtain's)
g2 = [ ...
    patch(ax, [s fliplr(s)], [zeros(size(s)) fliplr(z)], [1 0.6 0.6], 'FaceAlpha', 0.8, 'EdgeColor', 'none'), ...
    plot(ax, s, z, 'k', 'LineWidth', 2)];

%% Build UI
app.addControl('button', 'Switch 2D / 3D View', 1, 1, @toggleView);

is3D = false;
showView()

%% Callback
function toggleView(~, ~)
    is3D = ~is3D;
    showView()
end

%% Show one view: toggles which objects are visible and sets the axes to match
function showView()
    set(g3, 'Visible', onoff(is3D))
    set(g2, 'Visible', onoff(~is3D))
    zlim(ax, 'auto')
    if is3D
        xlim(ax, [0 1]); ylim(ax, [0 1])
        xlabel(ax, 'x'); ylabel(ax, 'y'); zlabel(ax, 'z')
        title(ax, 'Area Under a Curve')
        view(ax, 45,25)
    else
        xlim(ax, [0 s(end)]); ylim(ax, [0 1.05*max(z)])
        xlabel(ax, 's'); ylabel(ax, 'f(s)'); zlabel(ax, '')
        title(ax, sprintf('$\\int_C f(s)\\,ds = %.4f$', lineIntegral), 'Interpreter', 'latex')
        view(ax, 2)
    end
end

end

%% Stateless helper
function s = onoff(tf)
if tf
    s = 'on';
else
    s = 'off';
end
end