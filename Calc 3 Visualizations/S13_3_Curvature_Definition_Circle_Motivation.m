function S13_3_Curvature_Definition_Circle_Motivation()
%% Motivates the definition of curvature using a circle of adjustable
%  radius. Shows the unit tangent T and its derivative dT/ds along the
%  arc-length parameterized circle, demonstrating that kappa = 1/r.
%  The s slider reads in multiples of pi (e.g. s = 1.25 pi). Changing r
%  sends the point back to s = 0.
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.
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
cosT   = cos(t); sinT = sin(t);   % unit circle, scaled by r on updates
hCurve = plot(app.ax, r_val*cosT, r_val*sinT, 'b', 'LineWidth', 2);

% Initial Frenet vectors
[r0, T, N, kappa] = circleVectors(r_val, s0);
hPoint = plot(app.ax, r0(1), r0(2), '.r', 'MarkerSize', 24);
hT     = quiver(app.ax, r0(1), r0(2), T(1), T(2), 0, ...
    'r', 'LineWidth', 2, 'MaxHeadSize', 2);
hN     = quiver(app.ax, r0(1), r0(2), N(1), N(2), 0, ...
    'm', 'LineWidth', 2, 'MaxHeadSize', 2);

legend(app.ax, [hT, hN], {'$\vec{T}$', '$d\vec{T}/ds$'}, ...
    'Interpreter', 'latex', 'FontSize', 16)
% Keep the title handle: setting its String is much faster than title()
hTitle = title(app.ax, sprintf('Curvature $\\kappa = %.3f$', kappa));

%% Precompute math for updates
% None

%% Build UI
NumControls = 2;

% The s slider holds s/pi, so its label reads as a decimal multiple of pi
% ('$s = $' + '1.25' + '$\pi$' -> s = 1.25 pi). One lap is s = 2 pi r.
sSlider = app.addControl('slider', '$s = $', 1, NumControls, @updateS, ...
    'Default', s0/pi, 'Min', 0, 'Max', 2*r_val, ...
    'Number_format', '%.2f', 'AddToEnd', '$\pi$');

rSlider = app.addControl('slider', '$r = $', 2, NumControls, @updateR, ...
    'Default', r_val, 'Min', 0.5, 'Max', 5);

%% Functions for UI elements
    function updateS(~, ~)
        s = pi*sSlider.Value;      % slider holds s/pi
        redraw(r_val, s);
    end

    function updateR(~, ~)
        r_val = rSlider.Value;

        % Send the point back to s = 0. Setting Value first (0 is inside
        % any range) and then Max avoids app.UpdateUISlider, which sets the
        % value twice (two LaTeX label redraws) and calls drawnow.
        sSlider.Value = 0;
        sSlider.Max   = 2*r_val;      % one lap is s = 2 pi r (slider holds s/pi)

        % Redraw circle
        set(hCurve, 'XData', r_val*cosT, 'YData', r_val*sinT);
        redraw(r_val, 0);
    end

    function redraw(r, s)
        [r0, T, N, kappa] = circleVectors(r, s);
        set(hPoint, 'XData', r0(1), 'YData', r0(2));
        set(hT, 'XData', r0(1), 'YData', r0(2), 'UData', T(1), 'VData', T(2));
        set(hN, 'XData', r0(1), 'YData', r0(2), 'UData', N(1), 'VData', N(2));
        hTitle.String = sprintf('Curvature $\\kappa = %.3f$', kappa);
    end

%% Main Draw update function.
% (Handled directly in updateS / updateR above)
end