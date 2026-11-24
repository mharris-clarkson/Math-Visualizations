function Initial_Conditions()
%% Script showing how the initial conditions effect the solution to an
%  underdamped harmonic oscillator
%
%     y'' + 2 xi omega0 y' + omega0^2 y = 0,   y(0) = y0,  y'(0) = y1
%
%  The dot is y(0) and the thick arrow (with its dashed tangent line) is
%  the starting slope y'(0). A button between the two groups of sliders
%  adds a second solution with its own initial conditions, so two choices
%  can be compared on the same plot.
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

% Initial Conditions: solution 1 and solution 2
% Position
y0  = 1;    y0b = -2;
% Velocity
y1  = 0;    y1b = 3;

% Plot limits
t_Plot_range = [0, tmax];

% Look of the initial slope y'(0)
dt_arrow = 2.5;   % time length of the y'(0) arrow
dt_tan   = 5;     % time length of the dashed tangent line through (0, y(0))
col1 = [0.00 0.45 0.74];   % solution 1: blue
col2 = [0.85 0.33 0.10];   % solution 2: orange

%% ==== Below this we build the UI, compute the needed math functions for future updates and update ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Visualization of the effects of the Initial conditions',1); % Plots_to_test is an optional argument to allow for more subplots

% The differential equation (and its parameters) in the title
title(app.ax, {'Effect of the initial conditions on', ...
    ['$y'''' + 2\xi\omega_0 y'' + \omega_0^2 y = 0$, $\xi = ' num2str(xi) ...
     '$, $\omega_0 = ' num2str(omega0) '$']})

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

%plot y = 0
plot(app.ax, tPlot, 0*tPlot, '--k')

% One set of graphics per solution: curve, y(0) dot, dashed tangent line
% and y'(0) arrow. Created here (empty) and filled in by updatePlot.
Sol_plot = gobjects(1,2);  Tan_plot = gobjects(1,2);
Vel_Plot = gobjects(1,2);  Pos_plot = gobjects(1,2);
for s = 2:-1:1                         % solution 1 drawn last, on top
    if s == 1, col = col1; else, col = col2; end
    Sol_plot(s) = plot(app.ax, NaN, NaN, '-', 'Color', col, 'LineWidth', 2);
    Tan_plot(s) = plot(app.ax, NaN, NaN, '--', 'Color', col, 'LineWidth', 1.5);
    Vel_Plot(s) = quiver(app.ax, 0, 0, 0, 0, 0, 'Color', col, ...
        'LineWidth', 4, 'MaxHeadSize', 1);
    Pos_plot(s) = plot(app.ax, NaN, NaN, 'o', 'MarkerSize', 10, ...
        'MarkerFaceColor', col, 'MarkerEdgeColor', 'k');
end

%% Plot elements are done - Make pretty
Pretty_Plot(app.ax);
set(app.ax,'YLim',[-10,10])
xlim(app.ax, t_Plot_range)
xlabel(app.ax, '$t$'); ylabel(app.ax, '$y(t)$')

%% Precompute math for updates
% The ODE is linear, so y(t) = y(0)*u1(t) + y'(0)*u2(t) where u1 and u2
% solve it with (y,y') = (1,0) and (0,1). Solving those two once makes
% each slider move two vector multiplies instead of a new ode45 solve.
u1 = Harmonic_occ(1, 0);
u2 = Harmonic_occ(0, 1);

%% Build UI
% Column, read from the top: solution 1 sliders, the button, then the
% solution 2 sliders (hidden until the button is pressed)
NumControls = 5; % maximum number of controls

ySlider  = app.addControl('slider', '$y_1(0) = $',  5, NumControls, @updatePlot, ...
    'Default', y0, 'Min', -5, 'Max', 5);
ypSlider = app.addControl('slider', '$y_1''(0) = $', 4, NumControls, @updatePlot, ...
    'Default', y1, 'Min', -5, 'Max', 5);

btnSecond = app.addControl('button', '', 3, NumControls, @toggleSecond, ...
    'Toggle', ["Add a second solution", "Remove the second solution"]);

ySlider2  = app.addControl('slider', '$y_2(0) = $',  2, NumControls, @updatePlot, ...
    'Default', y0b, 'Min', -5, 'Max', 5, 'Visible', 'off');
ypSlider2 = app.addControl('slider', '$y_2''(0) = $', 1, NumControls, @updatePlot, ...
    'Default', y1b, 'Min', -5, 'Max', 5, 'Visible', 'off');

%% Functions for UI elements
% Show/hide the second solution and its two sliders (their labels follow)
    function toggleSecond(~,~)
        showSecond = logical(btnSecond.Value);
        set([ySlider2, ypSlider2], 'Visible', onoff(showSecond));
        set([Sol_plot(2), Tan_plot(2), Vel_Plot(2), Pos_plot(2)], 'Visible', onoff(showSecond));
        updateLegend(showSecond)
        updatePlot()
    end

% Legend for the solutions that are shown
    function updateLegend(showSecond)
        if showSecond
            legend(app.ax, [Sol_plot(1), Pos_plot(1), Vel_Plot(1), Sol_plot(2), Pos_plot(2), Vel_Plot(2)], ...
                {'Solution 1', '$y_1(0)$', '$y_1''(0)$', 'Solution 2', '$y_2(0)$', '$y_2''(0)$'}, ...
                'Location', 'northeast', 'FontSize', 18, 'AutoUpdate', 'off');
        else
            legend(app.ax, [Sol_plot(1), Pos_plot(1), Vel_Plot(1)], ...
                {'IVP solution', '$y(0)$', '$y''(0)$'}, ...
                'Location', 'northeast', 'FontSize', 18, 'AutoUpdate', 'off');
        end
    end

set([Sol_plot(2), Tan_plot(2), Vel_Plot(2), Pos_plot(2)], 'Visible', 'off');
updateLegend(false)
updatePlot()

%% Main Draw update function. All initial plot functions are updated below.
    function updatePlot(~,~)

        % Update data: initial conditions of both solutions
        Y0 = [ySlider.Value,  ySlider2.Value];
        Y1 = [ypSlider.Value, ypSlider2.Value];

        %% Update plots
        for k = 1:2
            % New curve by superposition of the two precomputed solutions
            set(Sol_plot(k), 'XData', tPlot, 'YData', Y0(k)*u1 + Y1(k)*u2);

            % y(0) dot, the y'(0) arrow and the tangent line with that slope
            set(Pos_plot(k), 'XData', 0, 'YData', Y0(k));
            set(Vel_Plot(k), 'XData', 0, 'YData', Y0(k), ...
                'UData', dt_arrow, 'VData', Y1(k)*dt_arrow);
            set(Tan_plot(k), 'XData', [0 dt_tan], 'YData', Y0(k) + Y1(k)*[0 dt_tan]);
        end

    end
end
