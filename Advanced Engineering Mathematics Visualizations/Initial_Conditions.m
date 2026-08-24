function Initial_Conditions()
%% Script showing how the initial conditions effect the solution to an
%  underdamped harmonic oscillator
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 330: Advanced Engineering Math.
close all;

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
% Non dimensional drag coefficient
xi = 0.2;
% Natural Freq
omega0 = 1;

% Time parameters
t0 = 0;
tmax = 25;

% Initial Conditions
% Position
y0 = 1;
% Velocity
y1 = 0;

% Plot limits
t_Plot_range = [0, tmax];

%% ==== Below this we build the UI, compute the needed math functions for future updates and update ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Visualization of the effects of the Initial conditions',1); % Plots_to_test is an optional argument to allow for more subplots
title(app.ax,app.fig.Name,'Interpreter','latex')

%% Optional math functions for plot computations

    function y_sol = Harmonic_occ(y0, y1)
        % Numerically solve the IVP
        % y'' + 2*xi*omega0*y' + omega0^2*y = 0
        % subject to y(0) = y0 and y'(0) = y1

        f = @(t,Y) [Y(2);
            -2*xi*omega0*Y(2) - omega0^2*Y(1)];

        Y0 = [y0; y1];

        [~, Y] = ode45(f, tPlot, Y0);

        y_sol = Y(:,1);
    end

%% ============== Make the initial plots =================================
% Function initiation
tPlot = linspace(t_Plot_range(1), t_Plot_range(2), 500);
y_sol = Harmonic_occ(y0, y1);


% Plot Solution
Sol_plot = plot(app.ax,tPlot,y_sol, ...
    'b','LineWidth',2);

% Plot y(0)
Pos_plot = plot(app.ax, 0,y0,...
    '.r','MarkerSize',24);

% Plot y'(0) arrow
dt_arrow = 1.0;          % time length of arrow
dy_arrow = y1*dt_arrow; % slope * dt

Vel_Plot = quiver(app.ax,0,y0,dt_arrow,dy_arrow,0, ...
    'r','LineWidth',2,'MaxHeadSize',0.5);

%plot y = 0
plot(app.ax, tPlot, 0*tPlot, '--k')


%% Plot elements are done - Make pretty
% Legend
leg = legend(app.ax,'IVP solution','$y(0)$','$y''(0)$');
set(leg, 'Interpreter','latex')
leg.Location ="best";
set(leg,'FontSize',18)
Pretty_Plot(app.ax);
set(app.ax,'YLim',[-10,10])

%% Precompute math for updates
% Light weight so skip

%% Build UI
NumControls = 2; % maximum number of controls

% dt
ySlider = app.addControl('slider', '$y(0) = $', 1, NumControls, @updatePlot_y,...
    'default', y0,'Min', -5, 'Max',5);
% Functionality
    function updatePlot_y(~,~)
        updatePlot()
    end

ypSlider = app.addControl('slider', '$y''(0) = $', 2, NumControls, @updatePlot_yp,...
    'default', y1,'Min', -5, 'Max',5);
% Functionality
    function updatePlot_yp(~,~)
        updatePlot()
    end

%% Functions for UI elements
% none

updatePlot()

%% Main Draw update function. All initial plot functions are updated below.
    function updatePlot(~,~)

        % Update data
        y0 = ySlider.Value;
        y1 = ypSlider.Value;

        %% Update plots

        % Solve and plot new curve
        y_sol = Harmonic_occ(y0, y1);
        set(Sol_plot,'XData',tPlot,'YData',y_sol);

        %plot new ICs
        set(Pos_plot,'YData',y0);

        set(Vel_Plot,'YData',y0,'VData',y1*dt_arrow);

    end
end
