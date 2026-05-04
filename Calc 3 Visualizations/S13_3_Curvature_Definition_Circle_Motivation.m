function S13_3_Curvature_Definition_Circle_Motivation()
%% Motivates the definition of curvature using a circle of adjustable
%  radius. Shows the unit tangent T and its derivative dT/ds along the
%  arc-length parameterized circle, demonstrating that kappa = 1/r.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
r_val = 2;   % initial radius
s0    = 0;   % initial arc-length position

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Curvature Motivation: Circle', 1);
axis(app.ax, 'equal')
xlim(app.ax, [-5.5 5.5])
ylim(app.ax, [-5.5 5.5])

%% Optional math functions for plot computations
    function [rVec, Tvec, Nvec, kappa] = circleVectors(r, s)
        theta = s / r;
        rVec  = [r*cos(theta); r*sin(theta)];
        Tvec  = [-sin(theta); cos(theta)];       % unit tangent
        Nvec  = [-cos(theta)/r; -sin(theta)/r];  % dT/ds (curvature vector)
        kappa = 1 / r;
    end

%% Make the initial plots
% Full circle
t      = linspace(0, 2*pi, 100);
hCurve = plot(app.ax, r_val*cos(t), r_val*sin(t), 'b', 'LineWidth', 2);

% Initial Frenet vectors
[r0, T, N, kappa] = circleVectors(r_val, s0);
hPoint = plot(app.ax, r0(1), r0(2), '.r', 'MarkerSize', 24);
hT     = quiver(app.ax, r0(1), r0(2), T(1), T(2), 0, ...
    'r', 'LineWidth', 2, 'MaxHeadSize', 2);
hN     = quiver(app.ax, r0(1), r0(2), N(1), N(2), 0, ...
    'm', 'LineWidth', 2, 'MaxHeadSize', 2);

legend(app.ax, [hT, hN], {'$\vec{T}$', '$d\vec{T}/ds$'}, ...
    'Interpreter', 'latex', 'FontSize', 16)
title(app.ax, sprintf('Curvature $\\kappa = %.3f$', kappa), 'Interpreter', 'latex')

%% Precompute math for updates
s_max = 2*pi*r_val; % total arc length of circle

%% Build UI
NumControls = 2;

sSlider = app.addControl('slider', '$s = $', 1, NumControls, @updateS, ...
    'Default', s0, 'Min', 0, 'Max', s_max);

rSlider = app.addControl('slider', '$r = $', 2, NumControls, @updateR, ...
    'Default', r_val, 'Min', 0.5, 'Max', 5);

%% Functions for UI elements
    function updateS(~, ~)
        s = sSlider.Value;
        redraw(r_val, s);
    end

    function updateR(~, ~)
        r_val = rSlider.Value;
        s_max = 2*pi*r_val;

        % Rescale s slider to new arc length, keeping proportional position
        s_new = 0;
        app.UpdateUISlider(sSlider, s_new, 'Min', 0, 'Max', s_max);

        % Redraw circle
        set(hCurve, 'XData', r_val*cos(t), 'YData', r_val*sin(t));
        redraw(r_val, s_new);
    end

    function redraw(r, s)
        [r0, T, N, kappa] = circleVectors(r, s);
        set(hPoint, 'XData', r0(1), 'YData', r0(2));
        set(hT, 'XData', r0(1), 'YData', r0(2), 'UData', T(1), 'VData', T(2));
        set(hN, 'XData', r0(1), 'YData', r0(2), 'UData', N(1), 'VData', N(2));
        title(app.ax, sprintf('Curvature $\\kappa = %.3f$', kappa), 'Interpreter', 'latex')
    end

%% Main Draw update function.
% (Handled directly in updateS / updateR above)
end