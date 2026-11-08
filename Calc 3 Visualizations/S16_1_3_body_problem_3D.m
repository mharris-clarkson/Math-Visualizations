function S16_1_3_body_problem_3D(masses, positions, velocities, timeStep)
%% Three-Body Problem in 3D
% Integrates Newtonian gravity for three bodies in 3D with ode45, then lets
% you scrub through time with a slider. A toggle shows the net gravitational
% force direction from all three bodies on a 3D grid of points.
%
%   L26_3_body_problem_3D(masses, positions, velocities, timeStep)
%     masses     1x3        (default [1 1 1])
%     positions  3x3 [x y z] (default [0 0 0; 1 0 0.1; 0.5 0.8 -0.05])
%     velocities 3x3 [x y z] (default [0 0 0; 0.5 0 0.1; -0.5 0.1 -0.05])
%     timeStep   scrubbing resolution (default 0.001)
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

close all

%% User parameters for math objects
if nargin < 4 || isempty(timeStep),   timeStep = 0.001; end
if nargin < 3 || isempty(velocities), velocities = [0 0 0; 0.5 0 0.1; -0.5 0.1 -0.05]; end
if nargin < 2 || isempty(positions),  positions = [0 0 0; 1 0 0.1; 0.5 0.8 -0.05]; end
if nargin < 1 || isempty(masses),     masses = [1 1 1]; end

G     = 1;        % gravitational constant (normalized units)
tspan = [0 5];    % simulation time span
vfN   = [20 20 10];                       % vector-field grid points (x, y, z)
vfX = [-1 2]; vfY = [-1 2]; vfZ = [-0.5 0.5];   % vector-field grid extent (= plot limits)
arrowFrac = 0.02; % arrow length as a fraction of the axis width

%% Solve the ODE, then interpolate onto a uniform time grid
y0 = [positions(1,:) velocities(1,:) positions(2,:) velocities(2,:) positions(3,:) velocities(3,:)]';
[t, Y] = ode45(@(t,y) threeBodyODE(y, G, masses), tspan, y0);

tUniform = tspan(1):timeStep:tspan(end);
Yi = interp1(t, Y, tUniform);
bx = Yi(:, [1 7 13]);    % x of bodies 1..3, one row per time step
by = Yi(:, [2 8 14]);
bz = Yi(:, [3 9 15]);

[xg, yg, zg] = meshgrid(linspace(vfX(1), vfX(2), vfN(1)), ...
                        linspace(vfY(1), vfY(2), vfN(2)), ...
                        linspace(vfZ(1), vfZ(2), vfN(3)));

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('3D Three-Body Simulation', 1);
ax = app.ax(1);

Pretty_Plot(ax)
axis(ax, 'equal')
xlabel(ax, 'X'); ylabel(ax, 'Y'); zlabel(ax, 'Z')
xlim(ax, vfX); ylim(ax, vfY); zlim(ax, vfZ)
view(ax, 45, 30)

%% Static graphics (created once; updated in place)
colors = 'rgb';
for k = 1:3
    trail(k) = plot3(ax, NaN, NaN, NaN, [colors(k) '-'], 'LineWidth', 1);
    body(k)  = plot3(ax, bx(1,k), by(1,k), bz(1,k), [colors(k) 'o'], 'MarkerSize', 8, 'MarkerFaceColor', colors(k));
end
quiverPlot = quiver3(ax, xg, yg, zg, zeros(size(xg)), zeros(size(yg)), zeros(size(zg)), ...
    'k', 'AutoScale', 'off', 'Visible', 'off');

%% Build UI
sTime = app.addControl('slider', '$t = $', 1, 2, @updatePlot, ...
    'Default', tUniform(1), 'Min', tUniform(1), 'Max', tUniform(end), 'Number_format', '%.3f');
btnVF = app.addControl('button', 'Vector Field', 2, 2, @updatePlot, 'ColorChange', true);

redraw(tUniform(1))

%% Callback
function updatePlot(~, ~)
    redraw(sTime.Value)
end

%% Redraw: moves bodies, extends trails, and (if on) recomputes the vector field
function redraw(tval)
    idx = min(max(round((tval - tUniform(1))/timeStep) + 1, 1), numel(tUniform));
    for j = 1:3
        set(body(j),  'XData', bx(idx,j), 'YData', by(idx,j), 'ZData', bz(idx,j))
        set(trail(j), 'XData', bx(1:idx,j), 'YData', by(1:idx,j), 'ZData', bz(1:idx,j))
    end

    showVF = logical(btnVF.Value);
    if showVF
        % Net force from all three bodies at every grid point at once
        Fx = zeros(size(xg));  Fy = Fx;  Fz = Fx;
        for j = 1:3
            dx = bx(idx,j) - xg;  dy = by(idx,j) - yg;  dz = bz(idx,j) - zg;
            d3 = (sqrt(dx.^2 + dy.^2 + dz.^2) + 1e-5).^3;
            Fx = Fx + G*masses(j)*dx./d3;
            Fy = Fy + G*masses(j)*dy./d3;
            Fz = Fz + G*masses(j)*dz./d3;
        end
        mag = sqrt(Fx.^2 + Fy.^2 + Fz.^2) + 1e-12;
        scale = arrowFrac*diff(ax.XLim);
        set(quiverPlot, 'UData', scale*Fx./mag, 'VData', scale*Fy./mag, 'WData', scale*Fz./mag)
    end
    quiverPlot.Visible = onoff(showVF);

    drawnow limitrate
end

end

%% Stateless helpers
function dydt = threeBodyODE(y, G, m)
r = [y(1:3) y(7:9) y(13:15)];      % 3x3 positions (one column per body)
v = [y(4:6) y(10:12) y(16:18)];    % 3x3 velocities
a = zeros(3, 3);
for i = 1:3
    for j = [1:i-1, i+1:3]
        d = r(:,j) - r(:,i);
        a(:,i) = a(:,i) + G*m(j)*d/norm(d)^3;
    end
end
dydt = [v(:,1); a(:,1); v(:,2); a(:,2); v(:,3); a(:,3)];
end

function s = onoff(tf)
if tf
    s = 'on';
else
    s = 'off';
end
end
