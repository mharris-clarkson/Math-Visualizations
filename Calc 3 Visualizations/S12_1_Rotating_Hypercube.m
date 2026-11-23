function S12_1_Rotating_Hypercube()
%% A 4D hypercube (tesseract) centred at the origin, rotated in 4D and shown
%  in 3D by a perspective projection along the w axis. The slider sets the
%  rotation angle theta and the Play button animates it. Each plane button
%  turns the rotation in one of the six coordinate planes of R^4 (xy, xz,
%  xw, yz, yw, zw) on or off. Try only the xw-plane: the "inner" cube
%  swings out and becomes the "outer" one, the 4D analogue of a square
%  turning edge-on. The distance slider moves the 4D viewer: close up the
%  perspective is strong, far away the inner and outer cubes overlap.
%  Edges are coloured by the axis they are parallel to, as in
%  S12_1_Rotating_Cube, so the w-edges (purple) join the two cubes.
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
% Hypercube vertices (16 corners), centred at the origin
vertices = [];
for i = 0:1
    for j = 0:1
        for k = 0:1
            for l = 0:1
                vertices = [vertices; i j k l]; %#ok<AGROW>
            end
        end
    end
end
vertices = vertices - 0.5;

% Rotation planes. Row [i j] rotates axis i toward axis j.
planeAxes = [1 2;   % xy
             1 3;   % xz
             1 4;   % xw
             2 3;   % yz
             2 4;   % yw
             3 4];  % zw
planeOn0  = [true true true false true false];   % xy, xz, xw, yw (as the original)

% Perspective projection 4D -> 3D (viewer on the w axis at w = distance)
distance0   = 2;        % starting viewer distance
distanceMin = 1.5;      % must stay above 1 (the largest |w| of a vertex)
distanceMax = 6;

% Animation
theta0      = 0;        % starting angle (degrees)
dTheta      = 360/400;  % degrees per frame (400 frames per full turn)
framePeriod = 0.03;     % seconds between frames (raise on slow computers)

% Look
axisNames  = 'xyzw';
edgeColors = [0.85 0.33 0.10;   % edges parallel to x
              0.00 0.45 0.74;   % edges parallel to y
              0.47 0.67 0.19;   % edges parallel to z
              0.49 0.18 0.56];  % edges parallel to w
lineWidth  = 2;

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Rotating Hypercube', 1);

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

% Perspective projection 4D -> 3D from a viewer at w = dist. Points with
% larger w are closer to the viewer and so drawn larger. The factor
% (dist - 1) is only a zoom: it keeps the picture inside [-1,1]^3 for
% every distance, so the axes never have to change.
    function P3 = project(P4, dist)
        P3 = P4(:,1:3) .* ((dist - 1) ./ (dist - P4(:,4)));
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

% Edges (connect vertices differing by 1 coordinate)
edges = [];
for a = 1:size(vertices,1)
    for b = a+1:size(vertices,1)
        if sum(abs(vertices(a,:) - vertices(b,:))) == 1
            edges = [edges; a b]; %#ok<AGROW>
        end
    end
end

% Sort the edges by the axis they are parallel to (the one coordinate
% that differs between their two vertices)
[~, edgeDir] = max(vertices(edges(:,1),:) ~= vertices(edges(:,2),:), [], 2);
edgesByDir   = cell(1, n);
for d = 1:n
    edgesByDir{d} = edges(edgeDir == d, :);
end

%% ============== Make the initial plots =================================
proj = project(vertices * totalRotation(deg2rad(theta0)).', distance0);

hEdges = gobjects(1, n);
for d = 1:n
    [X, Y, Z] = edgeLines(proj, edgesByDir{d});
    hEdges(d) = plot3(app.ax, X, Y, Z, 'Color', edgeColors(d,:), 'LineWidth', lineWidth);
end
legend(app.ax, hEdges, compose('edges parallel to $%s$', string(axisNames.')), ...
    'Location', 'northeast')

hTitle = title(app.ax, app.fig.Name);

% Fixed view so the hypercube does not jump while it turns
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
NumControls = 3 + nPlanes; % maximum number of controls

thetaSlider = app.addControl('slider', '$\theta = $', 1, NumControls, @updatePlot, ...
    'Default', theta0, 'Min', 0, 'Max', 360, ...
    'Number_format', '%.0f', 'AddToEnd', '$^\circ$');

distSlider = app.addControl('slider', 'Viewer distance $d = $', 2, NumControls, @updatePlot, ...
    'Default', distance0, 'Min', distanceMin, 'Max', distanceMax);

app.addControl('button', 'Play', 3, NumControls, @togglePlay, ...
    'Toggle', ["Play", "Pause"], 'ColorChange', true);

planeButtons = gobjects(1, nPlanes);
for p = 1:nPlanes
    planeButtons(p) = app.addControl('button', ...
        ['Rotate in $' axisNames(planeAxes(p,:)) '$-plane'], 3 + p, NumControls, ...
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
            hTitle.String = 'Rotating Hypercube (no rotation plane selected)';
        else
            hTitle.String = ['Rotating Hypercube in the ' strjoin(names, ', ') ' plane(s)'];
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
        proj    = project(rotated, distSlider.Value);
        for d = 1:n
            [X, Y, Z] = edgeLines(proj, edgesByDir{d});
            set(hEdges(d), 'XData', X, 'YData', Y, 'ZData', Z)
        end
    end
end
