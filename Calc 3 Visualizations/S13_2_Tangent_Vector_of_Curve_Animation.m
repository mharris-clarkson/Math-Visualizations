function S13_2_Tangent_Vector_of_Curve_Animation()
%% Animates a tangent vector traveling along four classic 3D space curves:
%  a torus spiral, trefoil knot, figure-8 knot, and piriform curve.
%  A Play/Pause button controls the animation and a button cycles curves.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
tangent_scale = 10;  % visual scale factor for tangent arrows
nPoints       = 200; % resolution of each curve
curveIdx      = 1;   % which curve to start on (1=Torus, 2=Trefoil, 3=Fig-8, 4=Piriform)
curveNames    = {'Torus Spiral', 'Trefoil Knot', 'Figure-8 Knot', 'Piriform Curve'};

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Tangent Vector Animation', 1);
view(app.ax, 3)
axis(app.ax, 'equal')

%% Optional math functions for plot computations
% Points on curve idx and its tangent vectors r'(t), drawn at
% tangent_scale*dt times their length
    function [x, y, z, dx, dy, dz] = getCurve(idx)
        t = linspace(0, 2*pi, nPoints);
        switch idx
            case 1  % Torus spiral
                R = 3; a = 1; nTwists = 2;
                r = @(t) [(R + a*cos(nTwists*t)).*cos(t); ...
                          (R + a*cos(nTwists*t)).*sin(t); ...
                          a*sin(nTwists*t)];
            case 2  % Trefoil knot
                r = @(t) [sin(t) + 2*sin(2*t); cos(t) - 2*cos(2*t); -sin(3*t)];
            case 3  % Figure-8 knot
                r = @(t) [(2 + cos(2*t)).*cos(3*t); (2 + cos(2*t)).*sin(3*t); sin(4*t)];
            case 4  % Piriform curve
                a = 1.5;
                r = @(t) [a*(1 - cos(t)); a*sin(t).*(1 - cos(t)); cos(2*t)];
        end
        P = r(t);
        V = Diff_f(r, t) * tangent_scale * (t(2) - t(1));
        x = P(1,:);  y = P(2,:);  z = P(3,:);
        dx = V(1,:); dy = V(2,:); dz = V(3,:);
    end

%% Make the initial plots
[x, y, z, dx, dy, dz] = getCurve(curveIdx);
hLine           = plot3(app.ax, x, y, z, 'b', 'LineWidth', 2);
hpoint          = plot3(app.ax, x(1), y(1), z(1),'.r','MarkerSize',40);
hArrow          = quiver3(app.ax, x(1), y(1), z(1), dx(1), dy(1), dz(1), ...
    0, 'r', 'LineWidth', 2);
title(app.ax, curveNames{curveIdx})

%% Animation state
frameIdx  = 1;
isPlaying = false;

animTimer = timer('ExecutionMode', 'fixedRate', ...
    'Period',       0.05, ...
    'TimerFcn',     @timerStep, ...
    'StopFcn',      @timerStopped);

app.fig.DeleteFcn = @(~,~) cleanupTimer();

%% Build UI
NumControls = 2;

btnPlay  = app.addControl('button', 'Play', 1, NumControls, @togglePlay);
btnCurve = app.addControl('button', ...
    ['Curve: ' curveNames{curveIdx}], 2, NumControls, @nextCurve);

%% Functions for UI elements
    function togglePlay(~, ~)
        if isPlaying
            stopTimer();
            btnPlay.String = 'Play';
        elseif isvalid(animTimer)
            isPlaying = true;
            btnPlay.String = 'Pause';
            start(animTimer);
        end
    end

    function nextCurve(~, ~)
        wasPlaying = isPlaying;
        stopTimer();

        curveIdx = mod(curveIdx, 4) + 1;
        [x, y, z, dx, dy, dz] = getCurve(curveIdx);
        frameIdx     = 1;

        set(hLine,  'XData', x,    'YData', y,    'ZData', z);
        set(hpoint, 'XData', x(1), 'YData', y(1), 'ZData', z(1));
        set(hArrow, 'XData', x(1), 'YData', y(1), 'ZData', z(1), ...
            'UData', dx(1), 'VData', dy(1), 'WData', dz(1));
        title(app.ax, curveNames{curveIdx})
        btnCurve.String = ['Curve: ' curveNames{curveIdx}];

        if wasPlaying && isvalid(animTimer)
            isPlaying = true;
            btnPlay.String = 'Pause';
            start(animTimer);
        end
    end

    function timerStep(~, ~)
        if ~isvalid(app.fig); stopTimer(); return; end
        frameIdx = mod(frameIdx, nPoints) + 1;
        set(hpoint, 'XData', x(frameIdx), 'YData', y(frameIdx), 'ZData', z(frameIdx));
        set(hArrow, 'XData', x(frameIdx), 'YData', y(frameIdx), 'ZData', z(frameIdx), ...
            'UData', dx(frameIdx), 'VData', dy(frameIdx), 'WData', dz(frameIdx));
    end

    function timerStopped(~, ~)
        isPlaying = false;
    end

    function stopTimer()
        if isvalid(animTimer) && strcmp(animTimer.Running, 'on')
            stop(animTimer);
        end
        isPlaying = false;
    end

    function cleanupTimer()
        if isvalid(animTimer)
            stop(animTimer);
            delete(animTimer);
        end
        isPlaying = false;
    end
end