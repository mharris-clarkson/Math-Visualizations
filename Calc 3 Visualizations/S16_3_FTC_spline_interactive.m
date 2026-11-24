function S16_3_FTC_spline_interactive()
%% Fundamental Theorem of Calculus for line integrals, with a path you can reshape.
%
%  Potential:  f(x,y) = x^2/2 + y^2/3
%  Field:      F = grad f = [ x, 2y/3 ]
%
%  Two paths go from A to B. Path 1 is the straight segment and Path 2 is a
%  spline through control points that you can drag.
%
%    Left   : the field F = grad f and both paths in the xy-plane. Drag the
%             diamonds to reshape Path 2.
%    Middle : the potential surface with both paths lifted onto it. The black
%             curves are level sets of f.
%    Right  : F . dr/dsigma versus the normalized arc length sigma = s/L
%             (sigma runs from 0 at A to 1 at B on every path, and
%             F . dr/dsigma = L F . T). The area under each curve is the line
%             integral of F along that path. By the Fundamental Theorem both
%             areas equal f(B) - f(A), no matter which path is chosen. The
%             exact values in the legend are computed symbolically when the
%             Symbolic Math Toolbox is available.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
% Potential f and its gradient field F = [Fx, Fy].
% If you change f also update the formula in the surface title below.
f  = @(x,y) x.^2/2 + y.^2/3;
Fx = @(x,y) x;
Fy = @(x,y) 2*y/3;

% End points of the paths
A = [-1, 0];
B = [ 1, 1];

% Control points of the spline for Path 2 (drag these in the plot)
cpts = [-0.5, 0.30;
         0.0, 1.40;
         0.5, 0.60];

NFINE = 1000; % points used along each path

% Colors
C1 = [0.10 0.25 0.80]; % Path 1
C2 = [0.80 0.10 0.10]; % Path 2
CG = [0.00 0.60 0.20]; % Fundamental Theorem highlight

% Light, neutral colormap for the potential surface
surfMap = [linspace(0.96, 0.50, 256)', linspace(0.97, 0.55, 256)', linspace(0.99, 0.66, 256)'];
nLevels = 12; % number of black level curves of f on the surface

% Field arrows (gray so the paths stand out)
nCols     = 9;    % field arrows across the plot
arrowFrac = 0.9;  % longest arrow / grid spacing on screen
fieldGray = [0.55 0.55 0.55];

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plots and all UI elements
app = uiFigure('Fundamental Theorem of Calculus for Line Integrals', 3);
axF = app.ax(1); % field and paths in the xy-plane
axS = app.ax(2); % potential surface
axB = app.ax(3); % areas under F . dr/dsigma

% Dragging the control points should not pan or zoom the plot
disableDefaultInteractivity(axF)
axF.Toolbar = [];

%% Optional math functions for plot computations
% Catmull-Rom spline through the points pts (one point per row) with about N samples in total
    function [px, py] = CR(pts, N)
        p  = [2*pts(1,:) - pts(2,:); pts; 2*pts(end,:) - pts(end-1,:)];
        M  = size(p,1) - 3;
        nS = max(2, round(N/M));
        px = [];
        py = [];
        for s = 1:M
            p0 = p(s,:); p1 = p(s+1,:); p2 = p(s+2,:); p3 = p(s+3,:);
            tv = linspace(0, 1, nS + 1);
            if s < M
                tv(end) = []; % the next segment starts here
            end
            t2 = tv.^2;
            t3 = tv.^3;
            px = [px, .5*(2*p1(1) + (-p0(1)+p2(1))*tv + (2*p0(1)-5*p1(1)+4*p2(1)-p3(1)).*t2 + (-p0(1)+3*p1(1)-3*p2(1)+p3(1)).*t3)]; %#ok<AGROW>
            py = [py, .5*(2*p1(2) + (-p0(2)+p2(2))*tv + (2*p0(2)-5*p1(2)+4*p2(2)-p3(2)).*t2 + (-p0(2)+3*p1(2)-3*p2(2)+p3(2)).*t3)]; %#ok<AGROW>
        end
    end

% Pieces of the line integral along a path given by points (px,py):
%   sEdge - normalized arc length sigma = s/L at each point (0 at A, 1 at B)
%   sMid  - normalized arc length at the middle of each piece
%   ft    - F . dr/dsigma on each piece, which equals L (F . T)
%   I     - the line integral of F along the path = sum of ft*dsigma
% The area of a piece under ft is ft*dsigma = F . dr, so the total area is I.
    function [sEdge, sMid, ft, I] = pathTerms(px, py)
        dx = diff(px);
        dy = diff(py);
        ds = hypot(dx, dy);
        keep = ds > 1e-9; % drop zero-length pieces
        dx = dx(keep);
        dy = dy(keep);
        ds = ds(keep);
        mx = 0.5*(px(1:end-1) + px(2:end));
        my = 0.5*(py(1:end-1) + py(2:end));
        mx = mx(keep);
        my = my(keep);
        dsigma = ds/sum(ds);
        dw = Fx(mx,my).*dx + Fy(mx,my).*dy;
        ft = dw./dsigma;
        sEdge = [0; cumsum(dsigma)];
        sMid  = 0.5*(sEdge(1:end-1) + sEdge(2:end));
        I = sum(dw);
    end

% LaTeX fraction for a number (without the Symbolic Math Toolbox)
    function str = ratLatex(v)
        [num, den] = rat(v);
        if den == 1
            str = sprintf('%d', num);
        else
            str = ['\frac{', sprintf('%d', num), '}{', sprintf('%d', den), '}'];
        end
    end

%% ============== Make the initial plots =================================
% Values for the Fundamental Theorem
fA = f(A(1), A(2));
fB = f(B(1), B(2));
FTC_val = fB - fA;

% Exact values as LaTeX strings: symbolic if available, else nearest fractions
useSym = license('test', 'Symbolic_Toolbox') && ~isempty(ver('symbolic'));
isGradient = false;
if useSym
    % The Fundamental Theorem needs F = grad f. Check it symbolically.
    symX = sym('x', 'real');
    symY = sym('y', 'real');
    symT = sym('t', 'real');
    gradDiff = simplify(gradient(f(symX,symY), [symX, symY]) - [Fx(symX,symY); Fy(symX,symY)]);
    isGradient = all(isAlways(gradDiff == 0));
end
if useSym && isGradient
    symA = sym(A);
    symB = sym(B);
    symfA = f(symA(1), symA(2));
    symfB = f(symB(1), symB(2));
    symFTC = symfB - symfA;
    % Path 1: integrate F . dr directly along the straight segment
    symx1 = symA(1) + symT*(symB(1) - symA(1));
    symy1 = symA(2) + symT*(symB(2) - symA(2));
    symI1 = int(Fx(symx1,symy1)*diff(symx1,symT) + Fy(symx1,symy1)*diff(symy1,symT), symT, 0, 1);
    % Path 2: any path from A to B gives f(B) - f(A) since F = grad f
    fAstr  = latex(symfA);
    fBstr  = latex(symfB);
    FTCstr = latex(symFTC);
    I1str  = latex(simplify(symI1));
    I2str  = FTCstr;
else
    fAstr  = ratLatex(fA);
    fBstr  = ratLatex(fB);
    FTCstr = ratLatex(FTC_val);
    I1str  = FTCstr;
    I2str  = FTCstr;
end

% Path 1: the straight segment from A to B (never changes)
t1  = linspace(0, 1, NFINE)';
p1x = A(1) + t1*(B(1) - A(1));
p1y = A(2) + t1*(B(2) - A(2));
[sE1, sM1, ft1] = pathTerms(p1x, p1y);

dragging = 0; % index of the control point being dragged (0 = none)

%% ---- Left panel: field and paths ----
hField = gobjects(0); % drawn by buildField
plot(axF, A(1), A(2), 'ks', 'MarkerFaceColor', 'k', 'MarkerSize', 9);
plot(axF, B(1), B(2), 'k^', 'MarkerFaceColor', 'k', 'MarkerSize', 9);
text(axF, A(1)-0.18, A(2)-0.13, '$A$', 'FontSize', 20);
text(axF, B(1)+0.07, B(2)-0.13, '$B$', 'FontSize', 20);

h2p1  = plot(axF, p1x, p1y, '-', 'Color', C1, 'LineWidth', 3);
h2p2  = plot(axF, NaN, NaN, '-', 'Color', C2, 'LineWidth', 3);
hDiam = plot(axF, NaN, NaN, 'd', 'Color', C2, 'MarkerFaceColor', C2, 'MarkerSize', 11);
hFieldLeg = plot(axF, NaN, NaN, '-', 'Color', fieldGray, 'LineWidth', 1.3); % legend entry

%% ---- Middle panel: potential surface, level curves and lifted paths ----
[xg, yg] = meshgrid(linspace(-1.5,1.5,80), linspace(-0.5,1.9,80));
Zg = f(xg, yg);
surf(axS, xg, yg, Zg, 'EdgeColor', 'none', 'FaceColor', 'interp', ...
    'FaceLighting', 'gouraud', 'AmbientStrength', 0.6, ...
    'DiffuseStrength', 0.7, 'SpecularStrength', 0.05);
colormap(axS, surfMap);
light(axS, 'Position', [-1 -3 4], 'Style', 'infinite');

% Level curves of f, slightly above the surface
liftEps = 0.01*max(Zg(:));
levels  = linspace(0, max(Zg(:)), nLevels + 2);
levels  = levels(2:end-1);
Cm = contourc(xg(1,:), yg(:,1)', Zg, levels);
cx = [];
cy = [];
cz = [];
ic = 1;
while ic < size(Cm, 2)
    nPts = Cm(2, ic);
    cx = [cx, Cm(1, ic+1:ic+nPts), NaN]; %#ok<AGROW>
    cy = [cy, Cm(2, ic+1:ic+nPts), NaN]; %#ok<AGROW>
    cz = [cz, Cm(1, ic)*ones(1, nPts) + liftEps, NaN]; %#ok<AGROW>
    ic = ic + nPts + 1;
end
plot3(axS, cx, cy, cz, '-', 'Color', [0.25 0.25 0.25], 'LineWidth', 0.8);

% Points A and B on the surface
plot3(axS, A(1), A(2), fA + liftEps, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 8);
plot3(axS, B(1), B(2), fB + liftEps, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 8);
text(axS, A(1)-0.18, A(2), fA+0.08, '$A$', 'FontSize', 20);
text(axS, B(1)+0.06, B(2), fB+0.08, '$B$', 'FontSize', 20);

h3p1 = plot3(axS, NaN, NaN, NaN, '-', 'Color', C1, 'LineWidth', 3);
h3p2 = plot3(axS, NaN, NaN, NaN, '-', 'Color', C2, 'LineWidth', 3);

%% ---- Right panel: F . dr/dsigma versus normalized arc length with the areas shaded ----
yline(axB, 0, 'k-', 'LineWidth', 1.2);
hArea1 = patch(axB, NaN, NaN, C1, 'FaceAlpha', 0.30, 'EdgeColor', 'none');
hArea2 = patch(axB, NaN, NaN, C2, 'FaceAlpha', 0.30, 'EdgeColor', 'none');
hW1 = plot(axB, sM1, ft1, '-', 'Color', C1, 'LineWidth', 2.5);
hW2 = plot(axB, NaN, NaN, '-', 'Color', C2, 'LineWidth', 2.5);

%% Plot elements are done - Make pretty
Pretty_Plot(axF);
Pretty_Plot(axS);
Pretty_Plot(axB);

xlim(axF, [-1.75 1.75]); ylim(axF, [-0.55 2.05])
xlim(axS, [-1.7 1.7]);   ylim(axS, [-0.6 2.0]);   view(axS, 0, 26)

zlabel(axS, '$f$')
xlabel(axB, 'Normalized arc length $\sigma=s/L$')
ylabel(axB, '$\mathbf{F}\cdot\frac{d\mathbf{r}}{d\sigma}$')

title(axF, {'Field $\mathbf{F}=\nabla f$ and Two Paths from $A$ to $B$', ...
    'Drag the diamonds to reshape Path $C_2$'}, 'FontSize', 16)
title(axS, {'Potential Surface $f(x,y)=\frac{x^2}{2}+\frac{y^2}{3}$', ...
    'Paths Lifted onto the Surface, Level Curves in Black'}, 'FontSize', 16)
title(axB, {'Line Integral of $\mathbf{F}$ = Potential at $B$ $-$ Potential at $A$', ...
    'Shaded area under each curve $=\int_C \mathbf{F}\cdot d\mathbf{r}$'}, 'FontSize', 15)

% The right legend shows the exact value of each line integral
legend(axF, [hFieldLeg, h2p1, h2p2, hDiam], ...
    {'$\mathbf{F}=\nabla f$', 'Path $C_1$ (line)', 'Path $C_2$ (spline)', 'Control points'}, 'Location', 'northwest', 'FontSize', 13, 'AutoUpdate', 'off');
legend(axB, [hW1, hW2], ...
    {['Path $C_1$: $\int_{C_1}\mathbf{F}\cdot d\mathbf{r}=', I1str, '$'], ...
     ['Path $C_2$: $\int_{C_2}\mathbf{F}\cdot d\mathbf{r}=', I2str, '$']}, 'Location', 'southeast', 'FontSize', 14, 'AutoUpdate', 'off');

%% Build UI
% Three equal panels
panelW = 0.275;
panelH = 0.74;
panelB = 0.12;
panelGap = 0.047;
panelX0  = 0.045;
axF.Position = [panelX0,                         panelB, panelW, panelH];
axS.Position = [panelX0 +   (panelW + panelGap), panelB, panelW, panelH];
axB.Position = [panelX0 + 2*(panelW + panelGap), panelB, panelW, panelH];

% Fundamental Theorem box in the headroom above the right plot's curves
boxH = 0.19; % fraction of the plot height
axBox = axes(app.fig, 'Units', 'normalized', ...
    'Position', [axB.Position(1), axB.Position(2) + axB.Position(4)*(1 - boxH), axB.Position(3), axB.Position(4)*boxH], ...
    'XLim', [0 1], 'YLim', [0 1], 'Visible', 'off', 'HitTest', 'off', 'PickableParts', 'none');
patch(axBox, [0 1 1 0], [0 0 1 1], [0.88 0.97 0.88], 'EdgeColor', CG, 'LineWidth', 2);
text(axBox, 0.5, 0.5, ...
    {'$\int_C \nabla f\cdot d\mathbf{r} = f(B)-f(A)$', ...
     ['$= ', fBstr, ' - ', fAstr, ' = ', FTCstr, '$']}, 'FontSize', 16, ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

% Drag the control points of Path 2 with the mouse
set(app.fig, 'WindowButtonDownFcn', @onDown, ...
             'WindowButtonMotionFcn', @onMove, ...
             'WindowButtonUpFcn', @onUp);

% The field depends on the panel's pixel size, so redraw it on resize
app.fig.SizeChangedFcn = @(~,~) buildField();
drawnow
buildField();

updatePlot()

%% Functions for UI elements
% Field arrows on a grid that is even on screen, scaled in pixels so they
% point the way F does on screen and never touch
    function buildField()
        delete(hField(isgraphics(hField)))
        pos  = getpixelposition(axF);
        ppuX = pos(3)/diff(xlim(axF));    % pixels per data unit in x
        ppuY = pos(4)/diff(ylim(axF));    % pixels per data unit in y
        if ~(ppuX > 0 && ppuY > 0)
            return
        end
        xs = linspace(-1.4, 1.4, nCols);
        hp = (xs(2) - xs(1))*ppuX;        % grid spacing in pixels
        dy = hp/ppuY;                     % the same spacing on screen in y
        ys = (ceil(-0.4/dy):floor(1.8/dy))*dy;
        [xq, yq] = meshgrid(xs, ys);
        u = Fx(xq, yq);
        v = Fy(xq, yq);
        k = arrowFrac*hp/max(hypot(u(:), v(:))); % pixels per unit of F
        hField = quiver(axF, xq, yq, k*u/ppuX, k*v/ppuY, 0, ...
            'Color', fieldGray, 'LineWidth', 1.3, 'MaxHeadSize', 0.6, 'AutoScale', 'off');
        uistack(hField, 'bottom')
    end

    function onDown(~, ~)
        cp = get(axF, 'CurrentPoint');
        xy = cp(1,1:2);
        xl = xlim(axF);
        yl = ylim(axF);
        if xy(1) < xl(1) || xy(1) > xl(2) || xy(2) < yl(1) || xy(2) > yl(2)
            return
        end
        % Distance in fractions of the plot size
        d = hypot((cpts(:,1) - xy(1))/diff(xl), (cpts(:,2) - xy(2))/diff(yl));
        [dmin, idx] = min(d);
        if dmin < 0.04
            dragging = idx;
        end
    end

    function onMove(~, ~)
        if dragging == 0
            return
        end
        cp = get(axF, 'CurrentPoint');
        xy = cp(1,1:2);
        xl = xlim(axF);
        yl = ylim(axF);
        % Keep the point inside the plot
        xy(1) = max(xl(1) + 0.02*diff(xl), min(xl(2) - 0.02*diff(xl), xy(1)));
        xy(2) = max(yl(1) + 0.02*diff(yl), min(yl(2) - 0.02*diff(yl), xy(2)));
        cpts(dragging,:) = xy;
        updatePlot()
    end

    function onUp(~, ~)
        dragging = 0;
    end

%% Main Draw update function. All initial plot functions are updated below.
    function updatePlot(~, ~)
        [p2x, p2y] = CR([A; cpts; B], NFINE);
        p2x = p2x(:);
        p2y = p2y(:);
        [sE2, sM2, ft2] = pathTerms(p2x, p2y);

        %% Update plots
        set(h2p2,  'XData', p2x, 'YData', p2y);
        set(hDiam, 'XData', cpts(:,1), 'YData', cpts(:,2));

        set(h3p1, 'XData', p1x, 'YData', p1y, 'ZData', f(p1x,p1y) + liftEps);
        set(h3p2, 'XData', p2x, 'YData', p2y, 'ZData', f(p2x,p2y) + liftEps);

        set(hW2,    'XData', sM2, 'YData', ft2);
        set(hArea1, 'XData', [sE1(1); sM1; sE1(end)], 'YData', [0; ft1; 0]);
        set(hArea2, 'XData', [sE2(1); sM2; sE2(end)], 'YData', [0; ft2; 0]);

        % Headroom at the top for the Fundamental Theorem box
        allFT = [ft1; ft2];
        lo = min([0; allFT]);
        hi = max([0; allFT]);
        span = max(hi - lo, eps);
        xlim(axB, [0 1])
        ylim(axB, [lo - 0.08*span, hi + 0.35*span])

        drawnow limitrate
    end
end