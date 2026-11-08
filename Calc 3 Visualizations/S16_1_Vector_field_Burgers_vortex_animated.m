function S16_1_Vector_field_Burgers_vortex_animated()
%% Burgers vortex velocity field with particle paths. A slider at the bottom
%  of the plot sets the time t: the particles sit at their position at time
%  t and the path each particle has traced out up to t is drawn behind it.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
a     = 1;      % strain rate
Gamma = 10;     % circulation
nu    = 0.01;   % viscosity

% Vector field grid
gridLims = [-2, 2, -2, 2, 0, 8];  % [xmin xmax ymin ymax zmin zmax]
gridN    = 16;                    % points per direction for the quiver plot
scaleFactor = 0.05;               % arrow length scale

% Particles
N = 50;                           % number of particles

% Time stepping (particle paths are precomputed with these)
dt = 0.02;
Nt = 200;
t0 = 0;                           % initial slider time

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Burgers Vortex: Velocity Field and Particle Paths', 1);
title(app.ax,app.fig.Name,'Interpreter','latex')

%% Optional math functions for plot computations
% Velocity field (u,v,w) of the Burgers vortex at the points (xx,yy,zz)
    function [u, v, w] = vel(xx, yy, zz)
        rr      = sqrt(xx.^2 + yy.^2) + 1e-6;       % avoid /0 on the axis
        u_r     = -(a/2)*rr;
        u_theta = (Gamma./(2*pi*rr)) .* (1 - exp(-a*rr.^2/(4*nu)));
        u = u_r.*(xx./rr) - u_theta.*(yy./rr);
        v = u_r.*(yy./rr) + u_theta.*(xx./rr);
        w = a*zz;
    end

%% ============== Make the initial plots =================================
% Vector field on a regular grid
[x,y,z] = meshgrid(linspace(gridLims(1),gridLims(2),gridN), ...
                   linspace(gridLims(3),gridLims(4),gridN), ...
                   linspace(gridLims(5),gridLims(6),gridN));
[u,v,w] = vel(x,y,z);

quiver3(app.ax, x, y, z, u*scaleFactor, v*scaleFactor, w*scaleFactor, ...
    'LineWidth', 1.2, 'Color', 'k', 'AutoScale', 'off');

% Initial particle positions
theta  = 2*pi*rand(N,1);
radius = 1.5 + 0.2*randn(N,1);

px = radius .* cos(theta);
py = radius .* sin(theta);
pz = 0.5 + 0.5*randn(N,1);

%% Precompute math for updates
% Particle paths for every time step. Column k holds the particle positions
% at time (k-1)*dt, so the slider only has to look up columns.
PX = zeros(N, Nt+1);  PY = PX;  PZ = PX;
PX(:,1) = px;  PY(:,1) = py;  PZ(:,1) = pz;
for k = 1:Nt
    [up, vp, wp] = vel(px, py, pz);

    px = px + up*dt;
    py = py + vp*dt;
    pz = pz + wp*dt;

    PX(:,k+1) = px;
    PY(:,k+1) = py;
    PZ(:,k+1) = pz;
end

% Particle markers and path lines. The paths are one line object with NaN
% breaks between particles, which is much lighter than N separate lines.
[Xp, Yp, Zp]  = pathData(1);
Particles     = plot3(app.ax, PX(:,1), PY(:,1), PZ(:,1), 'b.', 'MarkerSize', 12);
Paths         = plot3(app.ax, Xp, Yp, Zp, 'b-', 'LineWidth', 1);

% Fix the view to the region of interest
axis(app.ax, gridLims)
axis(app.ax, 'equal')
view(app.ax, 3)

%% Build UI
NumControls = 1; % maximum number of controls

% Time slider along the bottom of the plot
tSlider = app.addControl('slider', 'Time $t = $', 1, NumControls, @updatePlot, ...
    'colOrRow', 'row', 'Default', t0, 'Min', 0, 'Max', Nt*dt);

% Draw the initial state
updatePlot();

%% Functions for UI elements
% Path data (NaN separated) for all particles from the start up to step k
    function [Xk, Yk, Zk] = pathData(k)
        sep = nan(1, N);
        Xk = reshape([PX(:,1:k).'; sep], [], 1);
        Yk = reshape([PY(:,1:k).'; sep], [], 1);
        Zk = reshape([PZ(:,1:k).'; sep], [], 1);
    end

%% Main Draw update function. All initial plot functions are updated below.
    function updatePlot(~,~)
        % Slider time -> nearest precomputed step
        step = round(tSlider.Value/dt) + 1;
        step = min(max(step, 1), Nt+1);

        % Update particles
        set(Particles, 'XData', PX(:,step), 'YData', PY(:,step), 'ZData', PZ(:,step))

        % Update the paths traced out up to time t
        [Xk, Yk, Zk] = pathData(step);
        set(Paths, 'XData', Xk, 'YData', Yk, 'ZData', Zk)
    end
end
