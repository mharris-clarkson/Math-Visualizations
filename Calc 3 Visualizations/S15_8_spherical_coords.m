function S15_8_spherical_coords()
%% Spherical Coordinates Region
% Draws the bounding surfaces of the spherical "box"
% rhomin <= rho <= rhomax, thetamin <= theta <= thetamax,
% phimin <= phi <= phimax, with sliders for each bound.
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

close all

%% User parameters for math objects
rhomin = 0;  rhomax = 2;
thetamin = 0;  thetamax = pi/2;
phimin = 0;  phimax = pi/2;
nrho = 40; nt = 60; np = 40;   % grid points per direction
tol = 1e-6;                    % bounds closer than this to a degenerate case hide the surface

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('Spherical Coordinates', 1);
ax = app.ax(1);

Pretty_Plot(ax)
axis(ax, 'equal')
xlabel(ax, 'x'); ylabel(ax, 'y'); zlabel(ax, 'z')
view(ax, 3)
colormap(ax, parula)

%% Static graphics (created once; updated in place, shown/hidden as needed)
mk = @(varargin) surf(ax, NaN(2), NaN(2), NaN(2), NaN(2), 'EdgeColor', 'none', 'FaceColor', 'interp', varargin{:});
hOut  = mk('FaceAlpha', 0.5);
hIn   = mk();
hTmin = mk();  hTmax = mk();
hPmin = mk();  hPmax = mk();
camlight(ax)
lighting(ax, 'gouraud')

%% Build UI
nC = 6;
s1 = app.addControl('slider', '$\rho_{min} = $',   1, nC, @updatePlot, 'Default', rhomin,   'Min', 0, 'Max', 5,    'Number_format', '%.2f');
s2 = app.addControl('slider', '$\rho_{max} = $',   2, nC, @updatePlot, 'Default', rhomax,   'Min', 0, 'Max', 5,    'Number_format', '%.2f');
s3 = app.addControl('slider', '$\theta_{min} = $', 3, nC, @updatePlot, 'Default', thetamin, 'Min', 0, 'Max', 2*pi, 'Number_format', '%.2f');
s4 = app.addControl('slider', '$\theta_{max} = $', 4, nC, @updatePlot, 'Default', thetamax, 'Min', 0, 'Max', 2*pi, 'Number_format', '%.2f');
s5 = app.addControl('slider', '$\phi_{min} = $',   5, nC, @updatePlot, 'Default', phimin,   'Min', 0, 'Max', pi,   'Number_format', '%.2f');
s6 = app.addControl('slider', '$\phi_{max} = $',   6, nC, @updatePlot, 'Default', phimax,   'Min', 0, 'Max', pi,   'Number_format', '%.2f');

redraw(rhomin, rhomax, thetamin, thetamax, phimin, phimax)

%% Callback
function updatePlot(~, ~)
    redraw(s1.Value, s2.Value, s3.Value, s4.Value, s5.Value, s6.Value)
end

%% Redraw: updates all six surfaces in place and toggles their visibility
function redraw(rmin, rmax, thmin, thmax, pmin, pmax)
    rho = linspace(rmin, rmax, nrho);
    th  = linspace(thmin, thmax, nt);
    ph  = linspace(pmin, pmax, np);

    % Outer & inner spheres (colored by rho)
    [TH, PH] = meshgrid(th, ph);
    setSphere(hOut, rmax*ones(size(TH)), TH, PH, rmax*ones(size(TH)))
    setSphere(hIn,  rmin*ones(size(TH)), TH, PH, rmin*ones(size(TH)))

    % Theta walls
    [R, PH] = meshgrid(rho, ph);
    setSphere(hTmin, R, thmin*ones(size(R)), PH, R)
    setSphere(hTmax, R, thmax*ones(size(R)), PH, R)

    % Phi walls (cones)
    [R, TH] = meshgrid(rho, th);
    setSphere(hPmin, R, TH, pmin*ones(size(R)), R)
    setSphere(hPmax, R, TH, pmax*ones(size(R)), R)

    thetaWalls = abs(thmax - thmin) > tol && abs(thmax - thmin - 2*pi) > tol;
    set(hOut,  'Visible', onoff(rmax > tol))
    set(hIn,   'Visible', onoff(rmin > tol))
    set([hTmin hTmax], 'Visible', onoff(thetaWalls))
    set(hPmin, 'Visible', onoff(pmin > tol))
    set(hPmax, 'Visible', onoff(pmax < pi - tol))

    drawnow limitrate
end

end

%% Stateless helpers
function setSphere(h, R, TH, PH, C)
set(h, 'XData', R.*sin(PH).*cos(TH), 'YData', R.*sin(PH).*sin(TH), ...
    'ZData', R.*cos(PH), 'CData', C)
end

function s = onoff(tf)
if tf
    s = 'on';
else
    s = 'off';
end
end
