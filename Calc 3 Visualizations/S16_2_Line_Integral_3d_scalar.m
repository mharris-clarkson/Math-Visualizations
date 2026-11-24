function S16_2_Line_Integral_3d_scalar()
%% Line Integral of a 3D Scalar Field Along a Path
% The scalar field F(x,y,z) is shown as a set of translucent level surfaces.
% A path C winds through it. Drag the slider to walk along C:
%   Left  : the path (black), the part traveled so far (red) and the current point
%   Right : F along the path vs. arc length s; the shaded area up to the
%           current point is the line integral of F over the part traveled.
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

close all

%% User parameters for math objects
% Scalar field: sum of inverse-square "charges" at (1,0,0), (0,1,0), (0,0,1)
Ffun = @(x,y,z) 1./((x-1).^2 + y.^2 + z.^2) ...
    + 1./(x.^2 + (y-1).^2 + z.^2) ...
    + 1./(x.^2 + y.^2 + (z-1).^2);

% Path C, t in [0, 2*pi]  (another one to try:  x = cos(4*pi*t), y = sin(4*pi*t), z = sin(2*pi*t) + 0.5)
x = @(t) 1/2*(sin(t) + 2*sin(2*t));
y = @(t) 1/2*(cos(t) - 2*cos(2*t));
z = @(t) -sin(3*t);
N = 10000;                       % points along the path (also the slider range)
t = linspace(0, 2*pi, N);

maxRadius = 2;                 % plot window: [-maxRadius, maxRadius]^3
gridStep  = 0.05;              % grid spacing for the level surfaces
levels    = (1:10).^2;         % values of F drawn as level surfaces
Fclamp    = 1e3;               % clamp F near the charges
areaColor = [1 0.6 0.6];

%% Arc length, F along the path and the running line integral
xp = x(t);  yp = y(t);  zp = z(t);
s = [0, cumsum(sqrt(diff(xp).^2 + diff(yp).^2 + diff(zp).^2))];   % arc length
fLine = Ffun(xp, yp, zp);
Icum  = cumtrapz(s, fLine);

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('Line Integral of a 3D Scalar Field', 2);
axL = app.ax(1);
axR = app.ax(2);

%% Left axes: level surfaces of F
axis(axL, 'equal')
xlim(axL, maxRadius*[-1 1]); ylim(axL, maxRadius*[-1 1]); zlim(axL, maxRadius*[-1 1])
xticks(axL, -maxRadius:2:maxRadius); yticks(axL, -maxRadius:2:maxRadius); zticks(axL, -maxRadius:2:maxRadius)
title(axL, ['3D Level Surfaces of $f$ and a Path $C$'])

[X, Y, Z] = meshgrid(-maxRadius:gridStep:maxRadius);
F = min(Ffun(X, Y, Z), Fclamp);
colors = jet(numel(levels));
for k = 1:numel(levels)
    fv = isosurface(X, Y, Z, F, levels(k));
    patch(axL, 'Faces', fv.faces, 'Vertices', fv.vertices, ...
        'FaceColor', colors(k,:), 'EdgeColor', 'none', 'FaceAlpha', 0.2);
end
camlight(axL, 'headlight'); lighting(axL, 'gouraud')
view(axL, 3)

%% Path, trail and current point
plot3(axL, xp, yp, zp, 'k', 'LineWidth', 2);
plot3(axL, xp(1), yp(1), zp(1), '^m', 'MarkerFaceColor', 'm', 'MarkerSize', 8);   % start
trail = plot3(axL, xp(1), yp(1), zp(1), 'r', 'LineWidth', 2);
point = plot3(axL, xp(1), yp(1), zp(1), 'or', 'MarkerFaceColor', 'r', 'MarkerSize', 8);

%% Right axes: F along the path vs. arc length, with the area traveled so far
area = patch(axR, [s(1) s(1) 0], [fLine(1) 0 0], areaColor, 'FaceAlpha', 0.8, 'EdgeColor', 'none');
plot(axR, s, fLine, 'k', 'LineWidth', 2);
xlabel(axR, 'Arc length $s$'); ylabel(axR, '$f(\mathbf{r}(s))$')
xlim(axR, [0 s(end)]); ylim(axR, [0 1.05*max(fLine)])

%% Build UI
sslider = app.addControl('slider', '$s = $', 1, 1, @updatePlot, ...
    'Default', 0, 'Min', 0, 'Max', max(s));

redraw(0)

%% Callback
    function updatePlot(~, ~)
        redraw(sslider.Value)
    end

%% Main Draw update function.
    function redraw(sval)
        n = max(1, sum(s <= sval));   % last path index with arc length <= s
        set(trail, 'XData', xp(1:n), 'YData', yp(1:n), 'ZData', zp(1:n))
        set(point, 'XData', xp(n), 'YData', yp(n), 'ZData', zp(n))
        set(area, 'XData', [s(1:n), s(n), 0], 'YData', [fLine(1:n), 0, 0])
        title(axR, sprintf('Line Integral Along Path: $\\int f\\,ds$ so far $= %.3f$', Icum(n)))
        drawnow limitrate
    end

end