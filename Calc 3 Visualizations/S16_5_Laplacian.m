function S16_5_Laplacian()
%% Visualizes the Laplacian with the heat equation.
%
%  The heat equation is solved on a square with insulated edges and stored
%  for every time step. A slider at the bottom steps through time and shows
%    Left   : the temperature T(x,y,t) as a surface
%    Middle : its gradient (arrows)
%    Right  : its Laplacian, the sum of the second derivatives of T
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
N  = 160;       % grid points in each direction
L  = 2;         % domain half-width
T  = 50;        % number of time steps
dt = 0.02;      % time step
QuiverStep = 7; % arrows are drawn on every QuiverStep-th grid point
C  = 0.5;       % arrow length: C * (current largest gradient / initial largest gradient)

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plots and all UI elements
app = uiFigure('Heat Equation: Temperature, Gradient and Laplacian', 3);
ax1 = app.ax(1); % temperature
ax2 = app.ax(2); % gradient
ax3 = app.ax(3); % Laplacian

%% Grid and initial condition
x = linspace(-L,L,N);
y = linspace(-L,L,N);
dx = x(2)-x(1);
dy = y(2)-y(1);

[xg,yg] = meshgrid(x,y);

f0 = 0.5*(cos(pi*xg/L) .* cos(pi*yg/L)) + 0.1;

%% Precompute math for updates
F = zeros(N,N,T);
F(:,:,1) = f0;

f = f0;

kx = (2*pi/(x(end)-x(1))) * [0:(N/2-1) (-N/2):-1];
ky = kx;
[KX,KY] = meshgrid(kx,ky);
LapK = -(KX.^2 + KY.^2);

for ti = 2:T
    f = applyNeumannBC(f);

    Fhat = fft2(f);
    Fhat = Fhat ./ (1 - dt * LapK);
    f = real(ifft2(Fhat));

    F(:,:,ti) = f;
end

% Initial fields and the scales used for the colors and the arrows
f_init = F(:,:,1);

[fx0,fy0] = gradient(f_init,dx,dy);
g0 = max(sqrt(fx0.^2 + fy0.^2),[],'all');   % baseline gradient magnitude

lap0 = lap(f_init,dx,dy);

fScale   = max(abs(f_init(:)));
lapScale = max(abs(lap0(:)));

%% Make the initial plots
% Left: temperature
h1 = surf(ax1,x,y,f_init);
shading(ax1,'flat')
colormap(ax1,cmocean('balance'))
colorbar(ax1);
clim(ax1,[-fScale fScale])

% Middle: gradient
rows = 1:QuiverStep:N;
q = quiver(ax2, xg(rows,rows), yg(rows,rows), fx0(rows,rows), fy0(rows,rows), 'k');
q.AutoScale = 'off';

% Right: Laplacian
h3 = imagesc(ax3,x,y,lap0);
set(ax3,'YDir','normal')
colormap(ax3,cmocean('balance'))
colorbar(ax3);
clim(ax3,[-lapScale lapScale])

%% Plot elements are done - Make pretty
Pretty_Plot(ax1);
Pretty_Plot(ax2);
Pretty_Plot(ax3);
axis(ax1,'image'); axis(ax2,'image'); axis(ax3,'image');
xlim(ax2,[-L L]); ylim(ax2,[-L L]);

xlabel(ax1,'$x$','Interpreter','latex'); ylabel(ax1,'$y$','Interpreter','latex'); zlabel(ax1,'$T$','Interpreter','latex');
xlabel(ax2,'$x$','Interpreter','latex'); ylabel(ax2,'$y$','Interpreter','latex');
xlabel(ax3,'$x$','Interpreter','latex'); ylabel(ax3,'$y$','Interpreter','latex');

title(ax1,'$T(x,y,t)$','Interpreter','latex','FontSize',18)
title(ax2,'$\nabla T$','Interpreter','latex','FontSize',18)
title(ax3,'$\nabla^2 T$','Interpreter','latex','FontSize',18)

%% Build UI
NumControls = 1;
tSlider = app.addControl('slider', '$t = $', 1, NumControls, @updatePlot, ...
    'Default', 1, 'Min', 1, 'Max', T, 'Number_format', '%d', 'colOrRow', 'row');
tSlider.SliderStep = [1/(T-1) 10/(T-1)];

% Equal panels. The gaps leave room for the colorbars on the left and right plots.
panelW = 0.22;
panelH = 0.62;
panelB = 0.22;
ax1.Position = [0.05, panelB, panelW, panelH];
ax2.Position = [0.40, panelB, panelW, panelH];
ax3.Position = [0.70, panelB, panelW, panelH];

updatePlot()

%% Functions for UI elements
%% Main Draw update function.
    function updatePlot(~, ~)
        tIdx = round(tSlider.Value);
        if tSlider.Value ~= tIdx
            tSlider.Value = tIdx;
        end

        ft = F(:,:,tIdx);

        set(h1,'CData',ft)
        set(h1,'ZData',ft)

        [fxt,fyt] = gradient(ft,dx,dy);

        gNow = max(sqrt(fxt.^2 + fyt.^2),[],'all');   % current gradient strength
        arrowScale = C * (gNow / g0);                 % scale(t) = C * g(t)/g0

        q.UData = fxt(rows,rows) * arrowScale;
        q.VData = fyt(rows,rows) * arrowScale;

        % Laplacian
        set(h3,'CData',lap(ft,dx,dy))

        drawnow limitrate
    end
end

%% Laplacian
function Lp = lap(f,dx,dy)

Lp = zeros(size(f));

Lp(:,2:end-1) = (f(:,3:end) - 2*f(:,2:end-1) + f(:,1:end-2))/dx^2;
Lp(2:end-1,:) = Lp(2:end-1,:) + ...
    (f(3:end,:) - 2*f(2:end-1,:) + f(1:end-2,:))/dy^2;

end

%% Neumann boundary condition (insulated edges)
function f = applyNeumannBC(f)

f(1,:)   = f(2,:);
f(end,:) = f(end-1,:);
f(:,1)   = f(:,2);
f(:,end) = f(:,end-1);

end