function S16_5_Divergence()
%% Visualizes divergence with a transport system of particles.
%
%  The color is the divergence of the field: positive (a source) and
%  negative (a sink). Particles are released around circle A, follow the
%  field, and are put back at A when they reach circle B or leave the window.
%  The slider at the bottom sets the number of particles.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
a   = 1.2;      % source strength
b   = 1.2;      % sink strength
eps = 0.15;     % constant drift to the right
dt  = 0.02;     % time step

% Number of particles slider
N_min  = 50;
N_max  = 20000;
N_base = 2000;  % starting value

Grid_cut = 4;   % arrows are drawn on every Grid_cut-th grid point
R = 0.05;       % radius of the two circles
RA.center = [-0.4 0];   % particles are released here
RB.center = [1.38 0];   % particles are removed here

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Divergence: Transport System', 1);
app.fig.WindowState = 'maximized'; % open full screen
ax  = app.ax(1);

%% Make the initial plots
[xg,yg] = meshgrid(linspace(-1,2,60),linspace(-1,1,60));
[u,v] = VF(xg,yg,a,b,eps);

dx = xg(1,2)-xg(1,1);
dy = yg(2,1)-yg(1,1);

[dudx,~] = gradient(u,dx,dy);
[~,dvdy] = gradient(v,dx,dy);
divF = dudx + dvdy;

% Domain box
xmin = min(min(xg)); xmax = max(max(xg));
ymin = min(min(yg)); ymax = max(max(yg));

hImg = imagesc(ax, linspace(xmin,xmax,60), linspace(ymin, ymax,60), divF);
set(ax,'YDir','normal')
colormap(ax, Pretty_Colormap('balance'));
colorbar(ax);
set(hImg,'AlphaData',0.55);

hold(ax,'on')
% do on smaller grid
quiver(ax, xg(1:Grid_cut:end,1:Grid_cut:end), ...
           yg(1:Grid_cut:end,1:Grid_cut:end), ...
           u(1:Grid_cut:end,1:Grid_cut:end), ...
           v(1:Grid_cut:end,1:Grid_cut:end), 'k');

% Regions
theta = linspace(0,2*pi,200);
plot(ax, RA.center(1)+R*cos(theta), RA.center(2)+R*sin(theta), 'k','LineWidth',2);
plot(ax, RB.center(1)+R*cos(theta), RB.center(2)+R*sin(theta), 'k','LineWidth',2);

% Particles
N = N_base;
x = RA.center(1) + 0.2*randn(N,1);
y = RA.center(2) + 0.2*randn(N,1);
hPts = plot(ax, x, y, '.k', 'MarkerSize', 10);
hold(ax,'off')

%% Plot elements are done - Make pretty
Pretty_Plot(ax);
axis(ax,'equal')
xlim(ax,[xmin xmax]); ylim(ax,[ymin ymax]);
xlabel(ax,'$x$')
ylabel(ax,'$y$')
title(ax,'Transport System Showing Divergence (Color)','FontSize',16)

%% Build UI
NumControls = 1;
nSlider = app.addControl('slider', '$N = $', 1, NumControls, @updateN, ...
    'Default', N_base, 'Min', N_min, 'Max', N_max, 'Number_format', '%d', 'colOrRow', 'row');

%% Animation: runs until the figure is closed
while ishghandle(app.fig)

    [vx,vy] = VF(x,y,a,b,eps);

    x = x + dt*vx;
    y = y + dt*vy;

    % Exit region: particles that reach circle B are released again at circle A
    inB = (x-RB.center(1)).^2 + (y-RB.center(2)).^2 < R^2;
    x(inB) = RA.center(1) + 0.2*randn(sum(inB),1);
    y(inB) = RA.center(2) + 0.2*randn(sum(inB),1);

    % Box reset: particles that leave the window are released again at circle A
    outBox = (x < xmin | x > xmax | y < ymin | y > ymax);
    x(outBox) = RA.center(1) + 0.2*randn(sum(outBox),1);
    y(outBox) = RA.center(2) + 0.2*randn(sum(outBox),1);

    if ~ishghandle(hPts)   % the figure was closed during this frame
        break
    end
    set(hPts,'XData',x,'YData',y);
    pause(0.05)
end

%% Functions for UI elements
% Change the number of particles: add new ones at circle A or drop the extras
    function updateN(~, ~)
        newN = round(nSlider.Value);
        if nSlider.Value ~= newN
            nSlider.Value = newN;
        end
        if newN > N
            x = [x; RA.center(1) + 0.2*randn(newN - N, 1)];
            y = [y; RA.center(2) + 0.2*randn(newN - N, 1)];
        elseif newN < N
            x = x(1:newN);
            y = y(1:newN);
        end
        N = newN;
    end
end

%% Vector field
function [vx,vy] = VF(x,y,a,b,eps)

rs2 = x.^2 + y.^2;
Fsx = a*x .* exp(-rs2);
Fsy = a*y .* exp(-rs2);

rk2 = (x-1).^2 + y.^2;
Fkx = -b*(x-1) .* exp(-rk2);
Fky = -b*y .* exp(-rk2);

vx = Fsx + Fkx + eps;
vy = Fsy + Fky;

end