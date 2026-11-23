function S12_1_Rotating_Cube()
%% A cube centred at the origin rotating in 3D. The slider sets the rotation
%  angle theta and the Play button animates it. Each plane button (xy, xz,
%  yz) turns the rotation in that coordinate plane on or off; every active
%  plane is rotated by the same angle theta, one after the other. Edges are
%  coloured by the axis they are parallel to, which sets up the 4D version
%  (S12_1_Rotating_Hypercube) where a fourth colour (w) appears.
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
% Cube vertices (8 corners), centred at the origin
vertices = [
    0 0 0;
    1 0 0;
    1 1 0;
    0 1 0;
    0 0 1;
    1 0 1;
    1 1 1;
    0 1 1
    ] - 0.5;

% Edges (connect vertices differing by 1 coordinate)
edges = [
    1 2; 2 3; 3 4; 4 1; % bottom face
    5 6; 6 7; 7 8; 8 5; % top face
    1 5; 2 6; 3 7; 4 8  % vertical edges
    ];

% Rotation planes. Row [i j] rotates axis i toward axis j.
planeAxes = [1 2;   % xy
             1 3;   % xz
             2 3];  % yz
planeOn0  = [true true true];   % which planes start switched on

% Animation
theta0      = 0;        % starting angle (degrees)
dTheta      = 360/200;  % degrees per frame (200 frames per full turn)
framePeriod = 0.03;     % seconds between frames (raise on slow computers)

% Look
axisNames  = 'xyz';
edgeColors = [0.85 0.33 0.10;   % edges parallel to x
              0.00 0.45 0.74;   % edges parallel to y
              0.47 0.67 0.19];  % edges parallel to z
lineWidth  = 3;

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Rotating Cube', 1);

%% Optional math functions for plot computations
% Rotation by angle t (radians) in the plane of axes i and j of R^n: the
% identity matrix except for the block [cos -sin; sin cos] in rows/cols i,j.
    function R = planeRotation(i, j, t)
        R = eye(n);
        R([i j], [i j]) = [cos(t) -sin(t); sin(t) cos(t)];
    end

% All active plane rotations, applied one after the other (list order)
    function R = totalRotation(t)
        R = eye(n);
        for iP = find(planeOn)
            R = planeRotation(planeAxes(iP,1), planeAxes(iP,2), t) * R;
        end
    end

% Line data for a set of edges, with NaN breaks between edges, so that all
% edges of one colour are a single line object (much lighter than one
% line per edge).
    function [X, Y, Z] = edgeLines(P, E)
        gap = nan(size(E,1), 1);
        X = reshape([P(E(:,1),1) P(E(:,2),1) gap].', [], 1);
        Y = reshape([P(E(:,1),2) P(E(:,2),2) gap].', [], 1);
        Z = reshape([P(E(:,1),3) P(E(:,2),3) gap].', [], 1);
    end

%% Precompute math for updates
n       = size(vertices, 2);   % dimension
nPlanes = size(planeAxes, 1);
planeOn = planeOn0;

% Sort the edges by the axis they are parallel to (the one coordinate
% that differs between their two vertices)
[~, edgeDir] = max(vertices(edges(:,1),:) ~= vertices(edges(:,2),:), [], 2);
edgesByDir   = cell(1, n);
for d = 1:n
    edgesByDir{d} = edges(edgeDir == d, :);
end

%% ============== Make the initial plots =================================
rotated = vertices * totalRotation(deg2rad(theta0)).';

hEdges = gobjects(1, n);
for d = 1:n
    [X, Y, Z] = edgeLines(rotated, edgesByDir{d});
    hEdges(d) = plot3(app.ax, X, Y, Z, 'Color', edgeColors(d,:), 'LineWidth', lineWidth);
end
legend(app.ax, hEdges, compose('edges parallel to $%s$', string(axisNames.')), ...
    'Location', 'northeast')

hTitle = title(app.ax, app.fig.Name);

% Fixed view so the cube does not jump while it turns
axis(app.ax, 'equal')
axis(app.ax, [-1 1 -1 1 -1 1])
view(app.ax, 3)
axis(app.ax, 'off')

%% Animation state
animTimer = timer('ExecutionMode', 'fixedRate', ...
    'Period',   framePeriod, ...
    'BusyMode', 'drop', ...       % skip frames rather than queue them
    'TimerFcn', @timerStep);

% Stop AND delete the timer when the figure is closed
app.fig.DeleteFcn = @(~,~) cleanupTimer();

%% Build UI
NumControls = 2 + nPlanes; % maximum number of controls

thetaSlider = app.addControl('slider', '$\theta = $', 1, NumControls, @updatePlot, ...
    'Default', theta0, 'Min', 0, 'Max', 360, ...
    'Number_format', '%.0f', 'AddToEnd', '$^\circ$');

app.addControl('button', 'Play', 2, NumControls, @togglePlay, ...
    'Toggle', ["Play", "Pause"], 'ColorChange', true);

planeButtons = gobjects(1, nPlanes);
for p = 1:nPlanes
    planeButtons(p) = app.addControl('button', ...
        ['Rotate in $' axisNames(planeAxes(p,:)) '$-plane'], 2 + p, NumControls, ...
        @planeToggled, 'ColorChange', true);
    planeButtons(p).Value = double(planeOn0(p));   % listener sets the highlight
end

% Draw the initial state
updateTitle();
updatePlot();

%% Functions for UI elements
% Turn a rotation plane on or off
    function planeToggled(~, ~)
        planeOn = logical([planeButtons.Value]);
        updateTitle();
        updatePlot();
    end

% Title lists the active planes (only redrawn when they change)
    function updateTitle()
        names = arrayfun(@(p) ['$' axisNames(planeAxes(p,:)) '$'], find(planeOn), ...
            'UniformOutput', false);
        if isempty(names)
            hTitle.String = 'Rotating Cube (no rotation plane selected)';
        else
            hTitle.String = ['Rotating Cube in the ' strjoin(names, ', ') ' plane(s)'];
        end
    end

% Play/Pause
    function togglePlay(src, ~)
        if ~isvalid(animTimer), return, end
        if src.Value && strcmp(animTimer.Running, 'off')
            start(animTimer);
        elseif ~src.Value && strcmp(animTimer.Running, 'on')
            stop(animTimer);
        end
    end

% One animation frame: advance the slider and redraw
    function timerStep(~, ~)
        if ~isvalid(app.fig), cleanupTimer(); return, end
        thetaSlider.Value = mod(thetaSlider.Value + dTheta, 360); % label follows
        updatePlot();
    end

% The timer may already be gone (e.g. a test teardown ran
% delete(timerfindall) before closing the figure), so check isvalid first.
    function cleanupTimer()
        if isvalid(animTimer)
            stop(animTimer);
            delete(animTimer);
        end
    end

%% Main Draw update function. All initial plot functions are updated below.
    function updatePlot(~, ~)
        rotated = vertices * totalRotation(deg2rad(thetaSlider.Value)).';
        for d = 1:n
            [X, Y, Z] = edgeLines(rotated, edgesByDir{d});
            set(hEdges(d), 'XData', X, 'YData', Y, 'ZData', Z)
        end
    end
end
