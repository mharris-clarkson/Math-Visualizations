function S16_1_3_body_problem(masses, positions, velocities, timeStep)
%% Three-Body Problem (2D and 3D)
% Integrates Newtonian gravity for three bodies with ode45, once in the
% plane and once in space, then lets you scrub through time with a slider.
% The "View" button switches between the 2D and the 3D simulation and
% resets the time to the start. The "Vector Field" button shows the direction
% of the net gravitational force from all three bodies on a grid of points.
%
%   S16_1_3_body_problem(masses, positions, velocities, timeStep)
%     masses     1x3                 (default [1 1 1])
%     positions  3x2 [x y]   -> sets the 2D start (default [0 0; 1 0; 0.5 0.8])
%                3x3 [x y z] -> sets the 3D start (default [0 0 0; 1 0 0.1; 0.5 0.8 -0.05])
%     velocities 3x2 or 3x3, as for positions
%                (defaults [0 0; 0.5 0; -0.5 0.1] and [0 0 0; 0.5 0 0.1; -0.5 0.1 -0.05])
%     timeStep   scrubbing resolution (default 0.001)
%   Passing 3D (3x3) positions starts the figure in the 3D view.
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

close all

%% User parameters for math objects
if nargin < 4 || isempty(timeStep), timeStep = 0.001; end
if nargin < 1 || isempty(masses),   masses   = [1 1 1]; end

pos2 = [0 0; 1 0; 0.5 0.8];         vel2 = [0 0; 0.5 0; -0.5 0.1];               % 2D start
pos3 = [0 0 0; 1 0 0.1; 0.5 0.8 -0.05]; vel3 = [0 0 0; 0.5 0 0.1; -0.5 0.1 -0.05]; % 3D start
startIn3D = false;
if nargin >= 2 && ~isempty(positions)
    if size(positions, 2) == 3, pos3 = positions; startIn3D = true; else, pos2 = positions; end
end
if nargin >= 3 && ~isempty(velocities)
    if size(velocities, 2) == 3, vel3 = velocities; else, vel2 = velocities; end
end

G     = 1;        % gravitational constant (normalized units)
tspan = [0 10];    % simulation time span

% 2D view: plot limits and vector-field grid
axLim2 = [-1 2];  Nvf2 = 40;  vfLim2 = [-2 2];  arrowFrac2 = 0.03;
% 3D view: plot limits (= vector-field grid extent) and grid points (x, y, z)
vfX = [-1 2]; vfY = [-1 2]; vfZ = [-0.5 0.5];  vfN3 = [20 20 10];  arrowFrac3 = 0.02;

%% Each simulation is solved the first time its view is shown (see redraw)
tUniform = tspan(1):timeStep:tspan(end);
bx2 = []; by2 = []; bz2 = [];
bx3 = []; by3 = []; bz3 = [];

[xg2, yg2] = meshgrid(linspace(vfLim2(1), vfLim2(2), Nvf2));
[xg3, yg3, zg3] = meshgrid(linspace(vfX(1), vfX(2), vfN3(1)), ...
                           linspace(vfY(1), vfY(2), vfN3(2)), ...
                           linspace(vfZ(1), vfZ(2), vfN3(3)));

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('Three-Body Simulation', 1);
ax = app.ax(1);

Pretty_Plot(ax)
axis(ax, 'equal')

%% Static graphics
colors = 'rgb';
for k = 1:3
    trail(k) = plot3(ax, NaN, NaN, NaN, [colors(k) '-'], 'LineWidth', 1);
    body(k)  = plot3(ax, NaN, NaN, NaN, [colors(k) 'o'], 'MarkerSize', 8, 'MarkerFaceColor', colors(k));
end
quiver2D = quiver(ax, xg2, yg2, zeros(size(xg2)), zeros(size(yg2)), 'k', ...
    'AutoScale', 'off', 'Visible', 'off');
quiver3D = quiver3(ax, xg3, yg3, zg3, zeros(size(xg3)), zeros(size(yg3)), zeros(size(zg3)), ...
    'k', 'AutoScale', 'off', 'Visible', 'off');

%% Build UI
NumControls = 3;
sTime = app.addControl('slider', '$t = $', 1, NumControls, @updatePlot, ...
    'Default', tUniform(1), 'Min', tUniform(1), 'Max', tUniform(end), ...
    'Number_format', '%.3f', 'colOrRow', 'row');
btnView = app.addControl('button', '', 2, NumControls, @switchView, ...
    'Toggle', ["View: 2D", "View: 3D"], 'colOrRow', 'row');
btnVF = app.addControl('button', 'Vector Field', 3, NumControls, @updatePlot, ...
    'ColorChange', true, 'colOrRow', 'row');

btnView.Value = startIn3D;
setView()

%% Callbacks
function updatePlot(~, ~)
    redraw(sTime.Value)
end

function switchView(~, ~)
    sTime.Value = tUniform(1);   % restart from t = 0
    setView()
end

%% Axis limits and camera for the current view, then redraw
function setView()
    if btnView.Value          % 3D
        xlim(ax, vfX); ylim(ax, vfY); zlim(ax, vfZ)
        view(ax, 45, 30)
    else                      % 2D
        xlim(ax, axLim2); ylim(ax, axLim2); zlim(ax, [-1 1])
        view(ax, 2)
    end
    redraw(sTime.Value)
end

%% Main Draw update function.
function redraw(tval)
    is3D = logical(btnView.Value);
    if is3D
        if isempty(bx3)
            [bx3, by3, bz3] = simulateBodies(pos3, vel3, masses, G, tspan, tUniform);
        end
        bx = bx3; by = by3; bz = bz3;
    else
        if isempty(bx2)
            [bx2, by2, bz2] = simulateBodies(pos2, vel2, masses, G, tspan, tUniform);
        end
        bx = bx2; by = by2; bz = bz2;
    end

    idx = min(max(round((tval - tUniform(1))/timeStep) + 1, 1), numel(tUniform));
    for j = 1:3
        set(body(j),  'XData', bx(idx,j),   'YData', by(idx,j),   'ZData', bz(idx,j))
        set(trail(j), 'XData', bx(1:idx,j), 'YData', by(1:idx,j), 'ZData', bz(1:idx,j))
    end

    showVF = logical(btnVF.Value);
    if showVF && is3D
        % Net force from all three bodies at every 3D grid point at once
        Fx = zeros(size(xg3));  Fy = Fx;  Fz = Fx;
        for j = 1:3
            dx = bx(idx,j) - xg3;  dy = by(idx,j) - yg3;  dz = bz(idx,j) - zg3;
            d3 = (sqrt(dx.^2 + dy.^2 + dz.^2) + 1e-5).^3;
            Fx = Fx + G*masses(j)*dx./d3;
            Fy = Fy + G*masses(j)*dy./d3;
            Fz = Fz + G*masses(j)*dz./d3;
        end
        mag = sqrt(Fx.^2 + Fy.^2 + Fz.^2) + 1e-12;
        scale = arrowFrac3*diff(ax.XLim);
        set(quiver3D, 'UData', scale*Fx./mag, 'VData', scale*Fy./mag, 'WData', scale*Fz./mag)
    elseif showVF
        % Net force from all three bodies at every 2D grid point at once
        Fx = zeros(size(xg2));  Fy = Fx;
        for j = 1:3
            dx = bx(idx,j) - xg2;  dy = by(idx,j) - yg2;
            d3 = (sqrt(dx.^2 + dy.^2) + 1e-5).^3;
            Fx = Fx + G*masses(j)*dx./d3;
            Fy = Fy + G*masses(j)*dy./d3;
        end
        mag = sqrt(Fx.^2 + Fy.^2) + 1e-12;
        scale = arrowFrac2*diff(ax.XLim);
        set(quiver2D, 'UData', scale*Fx./mag, 'VData', scale*Fy./mag)
    end
    quiver3D.Visible = onoff(showVF && is3D);
    quiver2D.Visible = onoff(showVF && ~is3D);

    drawnow limitrate
end

end

%% Stateless helpers
function [bx, by, bz] = simulateBodies(pos, vel, m, G, tspan, tUniform)
% Three-body problem in 2D or 3D with ode45; coordinates on tUniform with
% one row per time and one column per body (bz = 0 in 2D)
d  = size(pos, 2);
y0 = reshape([pos vel].', [], 1);          % [pos1 vel1 pos2 vel2 pos3 vel3]
opts = odeset('RelTol', 1e-9, 'AbsTol', 1e-9);
sol  = ode45(@(t,y) threeBodyODE(y, G, m, d), tspan, y0, opts);
Y  = deval(sol, tUniform).';
S  = reshape(Y, numel(tUniform), 2*d, 3);   % time x coord x body
bx = squeeze(S(:, 1, :));
by = squeeze(S(:, 2, :));
if d == 3
    bz = squeeze(S(:, 3, :));
else
    bz = zeros(size(bx));
end
end

function dydt = threeBodyODE(y, G, m, d)
% Newtonian gravity between three bodies in d dimensions (d = 2 or 3)
S = reshape(y, 2*d, 3);       % one column per body: [position; velocity]
r = S(1:d, :);
v = S(d+1:end, :);
a = zeros(d, 3);
for i = 1:3
    for j = [1:i-1, i+1:3]
        dr = r(:,j) - r(:,i);
        a(:,i) = a(:,i) + G*m(j)*dr/norm(dr)^3;
    end
end
dydt = reshape([v; a], [], 1);
end