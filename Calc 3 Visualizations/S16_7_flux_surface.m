function S16_7_flux_surface()
%% Visualizes the surface integral of the vector field f F over the saddle
%  S: r(u,v) = <u, v, u^2 - v^2>, (u,v) in D = [-2,2] x [-2,2] (so x = u,
%  y = v), with upward normal:
%
%    iint_S (f F) . dS = iint_S f F . n dS = iint_D f F . (r_u x r_v) dA
%
%  where F = <-2y, 2x, 1>, n is the unit normal and r_u x r_v = <-2u, 2v, 1>.
%  The surface is colored by the flux per unit area (white = f F runs along
%  S, the two colors = f F crosses S upward or downward), and the title
%  shows the value of the integral. Black arrows are f F.
%    Flatten button - animates S down onto the region D in the plane z = 0
%                     (and back up on the next click). Each patch keeps its
%                     flux while its area shrinks from dS to
%                     dA = dS/|r_u x r_v|, so the color deepens from
%                     f F . n on S to f F . (r_u x r_v) on D. The orange
%                     patch dS lands on its dashed shadow dA.
%    f button       - switch the weight f between 1 and e^{-x^2-y^2} + 0.1.
%    Normals button - show/hide the unit normals n (blue).
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
% Surface r(u,v) = <u, v, g(u,v)> over D (u = x, v = y), and its normal
% N = r_u x r_v with r_u = <1,0,g_u>, r_v = <0,1,g_v>: N = <-g_u, -g_v, 1>
xlims = [-2 2];
ylims = [-2 2];
gSurf = @(x,y) x.^2 - y.^2;
NxF   = @(x,y) -2*x;
NyF   = @(x,y)  2*y;

% Vector field F and the two choices of weight f: field k is f_k F
Fx   = @(x,y) -2*y;
Fy   = @(x,y)  2*x;
Fz   = @(x,y)  ones(size(x));
damp = {@(x,y) ones(size(x)), ...                 % f = 1
        @(x,y) exp(-x.^2 - y.^2) + 0.1};          % f = e^{-x^2-y^2} + 0.1
fieldNames = {'$f = 1$', '$f = e^{-x^2-y^2} + 0.1$'};

% Grid and arrows
nGrid = 80;    % surface grid points per side
skip  = 10;    % arrows on every skip-th grid point

% Flattening animation
flattenTime = 1;   % seconds for a full flatten or un-flatten

% Sample patch dS (and its shadow dA): square of half width h around (x0, y0)
x0 = 1;  y0 = 0.5;  h = 0.25;
patchColor = [1 0.5 0];

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Flux through a surface', 1);
ax  = app.ax(1);

%% Optional math functions for plot computations
% f F . (r_u x r_v) for weight k (the integrand of the double integral over D)
    function v = FdotN(k, x, y)
        v = damp{k}(x,y) .* (Fx(x,y).*NxF(x,y) + Fy(x,y).*NyF(x,y) + Fz(x,y));
    end

%% Precompute math for updates
% Grid and surface
[x, y] = meshgrid(linspace(xlims(1), xlims(2), nGrid), linspace(ylims(1), ylims(2), nGrid));
z = gSurf(x, y);

% While flattening, z = (1 - lam) g(x,y) and |N_lam| = dS_lam/dA goes from
% |N| (lam = 0, the surface S) down to 1 (lam = 1, the flat region D)
Nxy2 = NxF(x,y).^2 + NyF(x,y).^2;
NlenLam = @(lam) sqrt((1 - lam)^2 * Nxy2 + 1);

% Flux per unit area of the moving surface is f F . (r_u x r_v) / |N_lam|
nFields = numel(damp);
FN   = cell(1, nFields);    % f F . (r_u x r_v): density per unit area of D
flux = zeros(1, nFields);
cMax = zeros(1, nFields);   % fixed color range per field
for k = 1:nFields
    FN{k}   = FdotN(k, x, y);
    flux(k) = integral2(@(xx,yy) FdotN(k, xx, yy), xlims(1), xlims(2), ylims(1), ylims(2));
    cMax(k) = max(abs(FN{k}(:)));
end

% Arrows: one length scale for both fields (set by f = 1)
iq = 1:skip:nGrid;
xq = x(iq,iq);  yq = y(iq,iq);  zq = z(iq,iq);
spacing = skip * diff(xlims)/(nGrid - 1);
F1len   = sqrt(Fx(xq,yq).^2 + Fy(xq,yq).^2 + Fz(xq,yq).^2);
kF      = 0.9*spacing / max(F1len(:));     % longest arrow = 90% of the spacing
U = cell(1, nFields); V = U; W = U;
for k = 1:nFields
    U{k} = kF * damp{k}(xq,yq) .* Fx(xq,yq);
    V{k} = kF * damp{k}(xq,yq) .* Fy(xq,yq);
    W{k} = kF * damp{k}(xq,yq) .* Fz(xq,yq);
end
nLenArrow = 0.6*spacing;                   % length of the unit normal arrows
NlenQ = sqrt(NxF(xq,yq).^2 + NyF(xq,yq).^2 + 1);
nxq = nLenArrow * NxF(xq,yq) ./ NlenQ;
nyq = nLenArrow * NyF(xq,yq) ./ NlenQ;
nzq = nLenArrow ./ NlenQ;

% Outline of the sample patch
sideT = linspace(-h, h, 15);
px = x0 + [sideT,  h*ones(1,15), fliplr(sideT), -h*ones(1,15)];
py = y0 + [-h*ones(1,15), sideT,  h*ones(1,15), fliplr(sideT)];
pz = gSurf(px, py);
NlenP = sqrt(NxF(x0,y0)^2 + NyF(x0,y0)^2 + 1);   % stretch factor at the patch
lift  = 0.03;   % outline raised slightly above the surface

% Animation state: lam = 0 is the surface S, lam = 1 the flat region D
lam = 0;
isAnimating = false;

%% Make the initial plots
% Surface colored by the flux density
surfH = surf(ax, x, y, z, FN{1}./NlenLam(0), 'EdgeColor', 'none', 'FaceColor', 'interp', ...
    'FaceAlpha', 0.85);

cb = Pretty_Color_Centered(ax, FN{1});
cb.Label.Interpreter    = 'latex';
cb.TickLabelInterpreter = 'latex';
cb.Label.FontSize       = ax.FontSize;

% Field and unit normals (normals start hidden)
hField  = quiver3(ax, xq, yq, zq, U{1}, V{1}, W{1}, 0, 'k', ...
    'LineWidth', 1.2, 'MaxHeadSize', 0.5);
hNormal = quiver3(ax, xq, yq, zq, nxq, nyq, nzq, 0, 'b', ...
    'LineWidth', 1.5, 'MaxHeadSize', 0.5, 'Visible', 'off');

% Sample patch dS on the surface and its shadow dA in the plane z = 0
hdS = plot3(ax, px, py, pz + lift, '-', 'Color', patchColor, 'LineWidth', 3);
hdA = plot3(ax, px, py, zeros(size(px)), 'k--', 'LineWidth', 2);
tdS = text(ax, x0, y0, gSurf(x0,y0) + 0.5, '$dS$', 'Color', patchColor, ...
    'FontSize', ax.FontSize, 'HorizontalAlignment', 'center');
tdA = text(ax, x0 + h, y0 - h, 0, ' $dA$', 'FontSize', ax.FontSize, ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');

leg = legend(ax, [hField, hdS, hdA], ...
    {'$f\vec{F}$, $\vec{F} = \langle -2y,\, 2x,\, 1 \rangle$', 'patch $dS$ on $S$', ...
     sprintf('shadow $dA$: $dS \\approx |\\vec{r}_u\\times\\vec{r}_v|\\,dA = %.2f\\,dA$', NlenP)}, ...
    'AutoUpdate', 'off');

%% Plot elements are done - Make pretty
Pretty_Plot(ax);
grid(ax, 'on')
view(ax, 3)
axis(ax, [xlims ylims -4 4])
axis(ax, 'vis3d')
hTitle = title(ax, '');

%% Build UI
NumControls = 3;

btnFlat = app.addControl('button', '', 1, NumControls, @animateFlatten, ...
    'colOrRow', 'row', ...
    'Toggle', ["Flatten onto $z = 0$", "Un-flatten"]);

btnField = app.addControl('button', '', 2, NumControls, @updatePlot, ...
    'colOrRow', 'row', ...
    'Toggle', string(fieldNames));

btnNormals = app.addControl('button', '', 3, NumControls, @toggleNormals, ...
    'colOrRow', 'row', ...
    'Toggle', ["Show normals $\vec{n}$", "Hide normals $\vec{n}$"]);

% Layout: plot, colorbar beside it, legend in one row below the plot
ax.Position = [0.08, 0.18, 0.72, 0.66];
cb.Position = [0.82, 0.24, 0.015, 0.54];
leg.Orientation = 'horizontal';
drawnow limitrate
leg.Position(1:2) = [0.45 - leg.Position(3)/2, 0.085];

updatePlot();

%% Functions for UI elements
    function toggleNormals(~, ~)
        hNormal.Visible = onoff(btnNormals.Value);
    end

% Move lam toward the button's target (1 = flat, 0 = surface) over
% flattenTime seconds; a click during the animation reverses it
    function animateFlatten(~, ~)
        if isAnimating, return, end
        isAnimating = true;
        tFrame = tic;
        while isvalid(app.fig)
            target = double(btnFlat.Value);
            step   = toc(tFrame)/flattenTime;
            tFrame = tic;
            if lam < target
                lam = min(lam + step, target);
            else
                lam = max(lam - step, target);
            end
            updatePlot();
            drawnow
            if lam == target && double(btnFlat.Value) == target
                break
            end
        end
        isAnimating = false;
    end

%% Main Draw update function.
    function updatePlot(~, ~)
        if ~isvalid(app.fig), return, end
        iF = 1 + btnField.Value;          % which weight f

        C = FN{iF} ./ NlenLam(lam);

        set(surfH,   'ZData', (1 - lam)*z, 'CData', C);
        set(hField,  'ZData', (1 - lam)*zq, 'UData', U{iF}, 'VData', V{iF}, 'WData', W{iF});
        set(hNormal, 'ZData', (1 - lam)*zq);
        set(hdS,     'ZData', (1 - lam)*pz + lift);
        tdS.Position(3) = (1 - lam)*gSurf(x0, y0) + 0.5;

        clim(ax, cMax(iF)*[-1 1]);

        if lam == 1
            cb.Label.String = '$f\vec{F}\cdot(\vec{r}_u\times\vec{r}_v)$ per unit area of $D$';
            tdS.String  = '$dA$';
            tdA.Visible = 'off';
        elseif lam == 0
            cb.Label.String = '$f\vec{F}\cdot\vec{n}$ per unit area of $S$';
            tdS.String  = '$dS$';
            tdA.Visible = 'on';
        else
            cb.Label.String = 'flux per unit area';
            tdS.String  = '$dS$';
            tdA.Visible = 'on';
        end

        hTitle.String = { ...
            '$\int\int_S (f\vec{F})\cdot d\vec{S} = \int\int_S f\vec{F}\cdot\vec{n}\,dS$', ...
            ['$= \int\int_D f\vec{F}\cdot(\vec{r}_u\times\vec{r}_v)\,dA = ' sprintf('%.3f', flux(iF)) '$']};
    end
end