function S16_9_Divergence_Volume_Render()
%% Smooth volume rendering of div F inside the unit ball.
%  For F = <x^2 - y, y^2 - z, z^2 - x>, div F = 2x + 2y + 2z. The value of
%  div F (scaled to [-1, 1]) sets the color (blue sink to red source), and
%  the opacity grows with |div F| and fades toward the sphere, so the
%  regions where the field spreads out or piles up glow like clouds.
%
%  This reproduces the volshow picture inside a normal figure, with no
%  toolbox: every pixel is a ray through the volume that blends color and
%  opacity front to back (the same method volshow uses), and the result is
%  shown as an image, which every graphics card draws.
%    Drag on the picture - rotate (draws a quick low-resolution preview)
%    Azimuth / Elevation - set the viewing direction exactly
%    Opacity slider      - overall opacity scale
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
F1 = @(x,y,z) x.^2 - y;        % vector field F = <F1, F2, F3>
F2 = @(x,y,z) y.^2 - z;
F3 = @(x,y,z) z.^2 - x;

N         = 60;                % grid points per side of the volume
gammaA    = 0.8;               % opacity = |div F|^gammaA: below 1 lifts faint regions
opacity0  = 0.35;              % overall opacity scale
bgColor   = [0.8 0.8 0.8];     % background (solid, no gradient)
cmapRB    = [linspace(0,1,256)' zeros(256,1) linspace(1,0,256)'];   % blue (sink) to red (source)

az0 = 45;   el0 = 20;          % starting view (degrees, as in view(az, el)); side-on to grad(div F)
nPix     = 260;                % picture resolution (pixels per side)
nPixDrag = 110;                % resolution while dragging (keeps rotation smooth)
dragRate = 0.4;                % degrees of rotation per pixel dragged

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Divergence inside the ball', 1);
ax  = app.ax(1);
app.fig.Color = bgColor;

%% Optional math functions for plot computations
divF = @(x,y,z) Diffx_f(F1,x,y,z) + Diffy_f(F2,x,y,z) + Diffz_f(F3,x,y,z);

%% Precompute math for updates
% Volume data, exactly as in the volshow version
gv = linspace(-1, 1, N);
[x, y, z] = ndgrid(gv);                 % ndgrid order (x, y, z) for griddedInterpolant
DIV = divF(x, y, z);
r = sqrt(x.^2 + y.^2 + z.^2);
DIV = DIV / max(abs(DIV(:)));           % normalize
V = DIV;
V(r > 1) = 0;                           % keep continuity outside the ball
Abase = (abs(V) .* max(1 - r, 0)).^gammaA;   % opacity before the overall scale

% Interpolants for sampling along the rays (0 outside the cube)
Vint = griddedInterpolant({gv, gv, gv}, V,     'linear', 'nearest');
Aint = griddedInterpolant({gv, gv, gv}, Abase, 'linear', 'nearest');
vRange = [min(V(:)), max(V(:))];        % colormap spans the data range, as volshow does

% Ray depths: only the ball can be seen, one sample per voxel spacing
tSteps = linspace(1, -1, N);            % front (camera side) to back

%% Make the initial plots
hImg = image(ax, [-1.1 1.1], [-1.1 1.1], repmat(reshape(bgColor, 1, 1, 3), 2, 2));
set(ax, 'YDir', 'normal')
axis(ax, 'image', 'off')
disableDefaultInteractivity(ax)
colormap(ax, cmapRB);  clim(ax, vRange)
cb = colorbar(ax);
cb.Label.Interpreter = 'latex';         % before String: TeX cannot read \mathbf
cb.Label.String = '$\nabla\cdot\mathbf{F}$ (scaled)';

%% Plot elements are done - Make pretty
title(ax, '$\nabla\cdot\mathbf{F}$ inside the unit ball, $\mathbf{F} = \langle x^2 - y,\ y^2 - z,\ z^2 - x \rangle$', ...
    'Interpreter', 'latex')

%% Build UI
NumControls = 3;
sAz = app.addControl('slider', 'Azimuth $= $', 1, NumControls, @(~,~) render(nPix), ...
    'Default', az0, 'Min', -180, 'Max', 180, 'Number_format', '%.0f', 'AddToEnd', '$^\circ$', ...
    'colOrRow', 'row');
sEl = app.addControl('slider', 'Elevation $= $', 2, NumControls, @(~,~) render(nPix), ...
    'Default', el0, 'Min', -90, 'Max', 90, 'Number_format', '%.0f', 'AddToEnd', '$^\circ$', ...
    'colOrRow', 'row');
sOp = app.addControl('slider', 'Opacity: ', 3, NumControls, @(~,~) render(nPix), ...
    'Default', opacity0, 'Min', 0.05, 'Max', 1, 'colOrRow', 'row');

% Drag to rotate
dragging = false;  lastPt = [0 0];
hImg.ButtonDownFcn            = @startDrag;
app.fig.WindowButtonMotionFcn = @dragMove;
app.fig.WindowButtonUpFcn     = @stopDrag;

render(nPix)

%% Functions for UI elements
    function startDrag(~, ~)
        dragging = true;
        lastPt = app.fig.CurrentPoint;
    end

    function dragMove(~, ~)
        if ~dragging
            return
        end
        pt = app.fig.CurrentPoint;
        d  = pt - lastPt;
        lastPt = pt;
        azNew = mod(sAz.Value - dragRate*d(1) + 180, 360) - 180;   % wrap to [-180, 180)
        elNew = min(max(sEl.Value - dragRate*d(2), -90), 90);
        sAz.Value = azNew;            % slider labels follow
        sEl.Value = elNew;
        render(nPixDrag)
    end

    function stopDrag(~, ~)
        if dragging
            dragging = false;
            render(nPix)              % full resolution when the mouse is let go
        end
    end

%% Main Draw update function.
% Cast one ray per pixel and blend color and opacity front to back
    function render(np)
        az = deg2rad(sAz.Value);  el = deg2rad(sEl.Value);
        op = sOp.Value;

        % Camera frame for view(az, el): c points toward the camera,
        % u to the right on screen, w up on screen
        c = [sin(az)*cos(el), -cos(az)*cos(el), sin(el)];
        u = [cos(az), sin(az), 0];
        w = cross(c, u);

        % Pixels; only those over the ball can pick up any color
        g = linspace(-1.1, 1.1, np);
        [a, b] = meshgrid(g, g);                 % a right, b up (row 1 at the bottom)
        hit = a.^2 + b.^2 <= 1;
        a = a(hit);  b = b(hit);

        Cacc = zeros(numel(a), 3);               % accumulated color
        Aacc = zeros(numel(a), 1);               % accumulated opacity
        for t = tSteps
            px = a*u(1) + b*w(1) + t*c(1);
            py = a*u(2) + b*w(2) + t*c(2);
            pz = a*u(3) + b*w(3) + t*c(3);
            alpha = min(1, op * Aint(px, py, pz));
            idx = round((Vint(px, py, pz) - vRange(1)) / diff(vRange) * 255) + 1;
            idx = min(max(idx, 1), 256);
            wgt = (1 - Aacc) .* alpha;           % front-to-back compositing
            Cacc = Cacc + wgt .* cmapRB(idx, :);
            Aacc = Aacc + wgt;
            if all(Aacc > 0.99), break, end      % every ray is already opaque
        end

        % Blend with the background and put the rays back into a picture
        img = repmat(reshape(bgColor, 1, 3), np*np, 1);
        img(hit, :) = Cacc + (1 - Aacc) .* bgColor;
        set(hImg, 'CData', reshape(img, np, np, 3))
        drawnow limitrate
    end

end
