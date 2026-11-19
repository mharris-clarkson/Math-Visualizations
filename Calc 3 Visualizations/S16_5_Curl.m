function S16_5_Curl()
%% Visualizes the curl of a vector field as local rotation.
%
%  The background is the curl dQ/dx - dP/dy of F = (P, Q), shown with the
%  cmocean balance map (white = zero curl). Each paddle wheel spins at half
%  the curl at its center (counterclockwise for positive curl, clockwise for
%  negative), so it stops where the curl is zero. The arrows in the ring
%  around each wheel are the field itself, which shows WHY it turns: the
%  field pushes harder on one side of the wheel than on the other.
%  The wheels can be dragged. The buttons at the bottom switch the field.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
% Each field F = (P, Q) comes with its exact curl dQ/dx - dP/dy.
fieldNames = {'Shear', 'Rotation', 'Curl-free'};
fieldsP    = {@(x,y) 0*x,      @(x,y) -y,      @(x,y) x};
fieldsQ    = {@(x,y) x.^2,     @(x,y)  x,      @(x,y) y};
fieldsCurl = {@(x,y) 2*x,      @(x,y) 2+0*x,   @(x,y) 0*x};

lims = [-2 2];                       % window for both x and y
pts  = [-1 0; 0 0; 1 0];             % starting wheel centers
spin = 0.10;                         % radians per frame at curl = 2 (spin is curl/2)
framePause = 0.03;                   % seconds between frames
wheelFrac  = 0.045;                  % wheel arm length as a fraction of the smaller panel side
nRing      = 8;                      % arrows in the ring around each wheel
ringFrac   = 1.9;                    % ring radius in wheel arm lengths
nCols      = 17;                     % background field arrows across the plot
arrowFrac  = 0.9;                    % longest background arrow as a fraction of the grid spacing
grabPixels = 30;                     % how close a click must be to grab a wheel

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Curl and Local Rotation', 1);
ax  = app.ax(1);

%% Make the initial plots
nW = size(pts, 1);                   % number of wheels
ang = zeros(nW, 1);                  % current angle of each wheel

% Curl heat map (no transparency, so the colors match the colorbar)
xvec = linspace(lims(1), lims(2), 300);
yvec = linspace(lims(1), lims(2), 300);
[Xg, Yg] = meshgrid(xvec, yvec);
% One color range shared by all fields: 1.125 times the largest curl of any field.
% A field with a weaker curl (like the rotation) then shows undersaturated colors.
climAll = 0;
for j = 1:numel(fieldsCurl)
    climAll = max(climAll, max(abs(reshape(fieldsCurl{j}(Xg, Yg), [], 1))));
end
climAll = 1.125*max(climAll, 1);
hImg = imagesc(ax, xvec, yvec, zeros(300));
set(ax, 'YDir', 'normal');
colormap(ax, Pretty_Colormap('balance'));
cb = colorbar(ax, 'Location', 'eastoutside');
cb.Label.String = '$\mathrm{curl}\,\vec{F}$';
cb.Label.Interpreter = 'latex';
cb.Label.FontSize = 18;

hField = gobjects(0);                % background field, drawn by buildField
kF = 1;                              % pixels per unit of F, set by buildField

% Wheels, their hubs, the rings of field arrows and the curl readouts
hArm  = gobjects(nW, 2);
hHub  = gobjects(nW, 1);
hRing = gobjects(nW, 1);
hTxt  = gobjects(nW, 1);
for i = 1:nW
    hRing(i) = quiver(ax, NaN(nRing,1), NaN(nRing,1), NaN(nRing,1), NaN(nRing,1), 0, ...
        'Color', 'k', 'LineWidth', 1.6, 'MaxHeadSize', 0.6, 'AutoScale', 'off');
    hArm(i,1) = plot(ax, [NaN NaN], [NaN NaN], 'k-', 'LineWidth', 3);
    hArm(i,2) = plot(ax, [NaN NaN], [NaN NaN], 'k-', 'LineWidth', 3);
    hHub(i)   = plot(ax, NaN, NaN, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 5);
    hTxt(i)   = text(ax, 0, 0, '', 'Interpreter', 'latex', 'FontSize', 16, ...
        'HorizontalAlignment', 'center', 'BackgroundColor', 'w', 'EdgeColor', 'none', 'Margin', 1);
end
lastTxt = repmat({''}, nW, 1);       % cache so the slow latex text only changes when the value does

%% Plot elements are done - Make pretty
Pretty_Plot(ax);
grid(ax, 'off')
xlim(ax, lims); ylim(ax, lims)       % fills the panel, aspect ratio is not preserved
xlabel(ax, '$x$', 'Interpreter', 'latex')
ylabel(ax, '$y$', 'Interpreter', 'latex')
title(ax, 'Curl of $\vec{F}$ and local rotation (drag the wheels)', ...
    'Interpreter', 'latex', 'FontSize', 15)

%% Build UI
NumControls = numel(fieldNames);
btns = cell(1, NumControls);
for j = 1:NumControls
    btns{j} = app.addControl('button', fieldNames{j}, j, NumControls, @(~,~) setField(j), 'ColorChange', true, 'colOrRow', 'row');
end

ax.Position = [0.07, 0.22, 0.78, 0.68]; % the colorbar follows the axes

%% Dragging state
dragging = false;
dragIdx  = 0;
set(app.fig, 'WindowButtonDownFcn',   @mouseDown);
set(app.fig, 'WindowButtonUpFcn',     @mouseUp);
set(app.fig, 'WindowButtonMotionFcn', @mouseMove);
app.fig.SizeChangedFcn = @(~,~) buildField();

%% Pick the first field and draw everything
fP = []; fQ = []; fCurl = [];
drawnow
setField(1);

%% Animation: the wheels turn until the window is closed
while ishghandle(app.fig)
    drawWheels();
    drawnow limitrate
    pause(framePause)
end

%% Functions for UI elements
% Switch to field number idx: new curl map, new colorbar range, new arrows.
    function setField(idx)
        fP = fieldsP{idx};
        fQ = fieldsQ{idx};
        fCurl = fieldsCurl{idx};
        curlGrid = fCurl(Xg, Yg);
        set(hImg, 'CData', curlGrid);
        clim(ax, climAll*[-1 1]); % same symmetric range for every field, so white is zero curl
        % Only the active button is highlighted (the class's ColorChange look)
        for b = 1:numel(btns)
            btns{b}.Value = (b == idx);
            btns{b}.UserData.setColor(b == idx);
        end
        buildField();
        drawWheels();
    end

% Background field on a grid that is even ON SCREEN. The vectors are
% converted to pixels first so each arrow points the way F really points on
% screen even though the aspect ratio is not preserved.
    function buildField()
        delete(hField(isgraphics(hField)))
        if isempty(fP)
            return
        end
        bfPos = getpixelposition(ax);
        bfX = bfPos(3)/diff(xlim(ax));   % pixels per data unit in x
        bfY = bfPos(4)/diff(ylim(ax));   % pixels per data unit in y
        if ~(bfX > 0 && bfY > 0)
            return
        end
        bfxs = linspace(lims(1), lims(2), nCols);
        bfhp = (bfxs(2) - bfxs(1))*bfX;  % grid spacing in pixels
        bfdy = bfhp/bfY;                 % the same spacing on screen in y
        bfys = (ceil(lims(1)/bfdy):floor(lims(2)/bfdy))*bfdy;
        [bfxq, bfyq] = meshgrid(bfxs, bfys);
        bfu = fP(bfxq, bfyq);
        bfv = fQ(bfxq, bfyq);
        kF = arrowFrac*bfhp/max(max(hypot(bfu(:), bfv(:))), eps); % pixels per unit of F
        hField = quiver(ax, bfxq, bfyq, kF*bfu/bfX, kF*bfv/bfY, 0, ...
            'Color', [0.3 0.3 0.3], 'LineWidth', 1.1, 'MaxHeadSize', 0.6, 'AutoScale', 'off');
        % keep the heat map at the bottom, then the field, then the wheels
        uistack(hField, 'bottom')
        uistack(hImg, 'bottom')
        uistack(hRing, 'top')
        uistack(hArm(:), 'top')
        uistack(hHub, 'top')
        uistack(hTxt, 'top')
    end

% Turn the wheels a little and place all wheel graphics. Sizes are set in
% pixels so a wheel stays round even though the axes are not equal.
    function drawWheels()
        if isempty(fCurl) || ~ishghandle(ax)
            return
        end
        dwPos = getpixelposition(ax);
        dwX = dwPos(3)/diff(xlim(ax));
        dwY = dwPos(4)/diff(ylim(ax));
        dwL = wheelFrac*min(dwPos(3), dwPos(4)); % wheel arm length in pixels
        dwPhi = (0:nRing-1)'*2*pi/nRing;
        for i = 1:nW
            cx = pts(i,1);
            cy = pts(i,2);
            curlHere = fCurl(cx, cy);
            ang(i) = mod(ang(i) + spin*curlHere/2, 2*pi); % a wheel spins at half the curl
            wc = cos(ang(i));
            ws = sin(ang(i));

            % The two arms of the wheel
            set(hArm(i,1), 'XData', cx + dwL*wc*[-1 1]/dwX, 'YData', cy + dwL*ws*[-1 1]/dwY);
            set(hArm(i,2), 'XData', cx - dwL*ws*[-1 1]/dwX, 'YData', cy + dwL*wc*[-1 1]/dwY);
            set(hHub(i),   'XData', cx, 'YData', cy);

            % Ring of field arrows around the wheel
            rx = cx + ringFrac*dwL*cos(dwPhi)/dwX;
            ry = cy + ringFrac*dwL*sin(dwPhi)/dwY;
            ru = fP(rx, ry);
            rv = fQ(rx, ry);
            set(hRing(i), 'XData', rx, 'YData', ry, 'UData', kF*ru/dwX, 'VData', kF*rv/dwY);

            % Live value of the curl at the wheel
            str = ['$\mathrm{curl}=', sprintf('%.2f', curlHere), '$'];
            if ~strcmp(str, lastTxt{i})
                set(hTxt(i), 'String', str);
                lastTxt{i} = str;
            end
            set(hTxt(i), 'Position', [cx, cy + (ringFrac+1.2)*dwL/dwY + 0.02, 0]);
        end
    end

% Click detection is in pixels so it works for any axes shape
    function mouseDown(~, ~)
        cp = ax.CurrentPoint(1, 1:2);
        if cp(1) < lims(1) || cp(1) > lims(2) || cp(2) < lims(1) || cp(2) > lims(2)
            return
        end
        mdPos = getpixelposition(ax);
        mdX = mdPos(3)/diff(xlim(ax));
        mdY = mdPos(4)/diff(ylim(ax));
        dpx = hypot((pts(:,1) - cp(1))*mdX, (pts(:,2) - cp(2))*mdY);
        [minD, k] = min(dpx);
        if minD < grabPixels
            dragging = true;
            dragIdx = k;
        end
    end

    function mouseUp(~, ~)
        dragging = false;
        dragIdx = 0;
    end

    function mouseMove(~, ~)
        if dragging
            cp = ax.CurrentPoint(1, 1:2);
            pts(dragIdx, :) = min(max(cp, lims(1)), lims(2)); % stay inside the axes
        end
    end
end