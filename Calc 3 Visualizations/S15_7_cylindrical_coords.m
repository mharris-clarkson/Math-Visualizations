function S15_7_cylindrical_coords()
%% Cylindrical Coordinates Region
% Draws the six bounding surfaces of the cylindrical "box"
% rmin <= r <= rmax, thetamin <= theta <= thetamax, zmin <= z <= zmax,
% with sliders for each bound.
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

close all

%% User parameters for math objects
rmin = 0;  rmax = 2;
thetamin = 0;  thetamax = pi/2;
zmin = 0;  zmax = 2;
nr = 40; nt = 60; nz = 40;   % grid points per direction

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('Cylindrical Coordinates', 1);
ax = app.ax(1);

Pretty_Plot(ax)
axis(ax, 'equal')
xlabel(ax, 'x'); ylabel(ax, 'y'); zlabel(ax, 'z')
view(ax, 3)
colormap(ax, parula)

%% Static graphics (created once; updated in place)
mk = @() surf(ax, NaN(2), NaN(2), NaN(2), NaN(2), 'EdgeColor', 'none', 'FaceColor', 'interp');
hBot = mk(); hTop = mk(); hOut = mk(); hIn = mk(); hTmin = mk(); hTmax = mk();
camlight(ax)
lighting(ax, 'gouraud')

%% Build UI
nC = 6;
s1 = app.addControl('slider', '$r_{min} = $',       1, nC, @updatePlot, 'Default', rmin,     'Min', 0,  'Max', 5,    'Number_format', '%.2f');
s2 = app.addControl('slider', '$r_{max} = $',       2, nC, @updatePlot, 'Default', rmax,     'Min', 0,  'Max', 5,    'Number_format', '%.2f');
s3 = app.addControl('slider', '$\theta_{min} = $',  3, nC, @updatePlot, 'Default', thetamin, 'Min', 0,  'Max', 2*pi, 'Number_format', '%.2f');
s4 = app.addControl('slider', '$\theta_{max} = $',  4, nC, @updatePlot, 'Default', thetamax, 'Min', 0,  'Max', 2*pi, 'Number_format', '%.2f');
s5 = app.addControl('slider', '$z_{min} = $',       5, nC, @updatePlot, 'Default', zmin,     'Min', -5, 'Max', 5,    'Number_format', '%.2f');
s6 = app.addControl('slider', '$z_{max} = $',       6, nC, @updatePlot, 'Default', zmax,     'Min', -5, 'Max', 5,    'Number_format', '%.2f');

redraw(rmin, rmax, thetamin, thetamax, zmin, zmax)

%% Callback
function updatePlot(~, ~)
    redraw(s1.Value, s2.Value, s3.Value, s4.Value, s5.Value, s6.Value)
end

%% Redraw: updates all six surfaces in place
function redraw(rmin, rmax, thmin, thmax, zmin, zmax)
    r  = linspace(rmin, rmax, nr);
    th = linspace(thmin, thmax, nt);
    z  = linspace(zmin, zmax, nz);

    % Top & bottom (colored by r)
    [R, TH] = meshgrid(r, th);
    X = R.*cos(TH);  Y = R.*sin(TH);
    setSurf(hBot, X, Y, zmin*ones(size(X)), R)
    setSurf(hTop, X, Y, zmax*ones(size(X)), R)

    % Outer & inner cylinders (colored by z)
    [TH, Z] = meshgrid(th, z);
    setSurf(hOut, rmax*cos(TH), rmax*sin(TH), Z, Z)
    setSurf(hIn,  rmin*cos(TH), rmin*sin(TH), Z, Z)

    % Theta walls (colored by r)
    [R, Z] = meshgrid(r, z);
    setSurf(hTmin, R*cos(thmin), R*sin(thmin), Z, R)
    setSurf(hTmax, R*cos(thmax), R*sin(thmax), Z, R)

    drawnow limitrate
end

end

%% Stateless helper
function setSurf(h, X, Y, Z, C)
set(h, 'XData', X, 'YData', Y, 'ZData', Z, 'CData', C)
end