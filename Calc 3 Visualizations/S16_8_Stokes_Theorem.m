function S16_8_Stokes_Theorem()
%% Stokes' theorem: circulation around C equals the flux of curl F through S.
%  Left:   a surface S bounded by the unit circle C, colored by the normal
%          component of curl F, with F (blue) and the unit normals (black).
%          The title shows iint_S curl F . dS.
%  Middle: C cut into N pieces of equal arc length (black polygon). At the
%          point at arc length s we draw F (blue), the unit tangent T (green)
%          and the part of F along it (red).
%  Right:  against arc length s, a box over each piece with height
%          F . dr / ds, so its area is F . dr (blue positive, red negative).
%          Boxes the point has passed are solid and the rest are faint, so
%          the area fills in as s grows; in the limit the boxes become the
%          area under the curve F . T. The black curve is the running total
%          up to s. The green line is the surface integral: the total at
%          s = L lands on it.
%    N slider       - number of pieces of C; at the right end N -> infinity
%                     (drawn with a very large N) gives the line integral
%    s slider       - arc length along C where the point sits
%    Surface button - swap S for another surface with the same boundary;
%                     the surface integral does not change.
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
F1 = @(x,y,z) -y + 0.8*x;                 % vector field F = <F1, F2, F3>
F2 = @(x,y,z)  x - 0.8*y;
F3 = @(x,y,z)  0.4*(x.^2 - y.^2);

% Boundary C: the unit circle in z = 0, counterclockwise seen from above
rC = @(t) [cos(t(:)), sin(t(:)), 0*t(:)];
tRange = [0 2*pi];      % parameter interval of C

% Surfaces over the unit disk that all have C as boundary, so each one
% must be 0 on x^2 + y^2 = 1. Add or change entries here.
surfNames = {'Dome $z = 1 - x^2 - y^2$', 'Flat disk $z = 0$', 'Bowl $z = -0.6(1 - x^2 - y^2)$'};
surfFuns  = {@(x,y) 1 - x.^2 - y.^2, @(x,y) 0*x, @(x,y) -0.6*(1 - x.^2 - y.^2)};
surfIdx   = 1;          % surface shown first

Nmax     = 60;          % largest finite N; the slider end is N -> infinity
Ninf     = 2000;        % N used to draw the limit
nR       = 30;          % surface grid: radial points
nT       = 60;          % surface grid: angular points
numPerRing = [1 6 10 14 18 20 24 28 32];   % arrows on the surface, ring by ring
arrowLen = 0.25;        % length of the arrows on the surface
cPos     = [0.2 0.4 0.8];    % blue: F . dr > 0 (F helps the motion)
cNeg     = [0.85 0.2 0.2];   % red:  F . dr < 0 (F opposes it)

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Stokes theorem', 3);
axL = app.ax(1);  axM = app.ax(2);  axR = app.ax(3);

%% Optional math functions for plot computations
% curl F . N dA in polar coordinates, N = <-z_x, -z_y, 1> (upward)
    function val = curlDotN(zf, r, th)
        x = r.*cos(th);  y = r.*sin(th);  z = zf(x, y);
        [k1, k2, k3] = curl_f(F1, F2, F3, x, y, z);
        val = (-k1.*Diffx_f(zf,x,y) - k2.*Diffy_f(zf,x,y) + k3) .* r;
    end

% Surface grid, color (curl F . unit normal) and the arrows for surface j
    function out = surfaceData(j)
        zf = surfFuns{j};
        out.Z = zf(Xs, Ys);
        [k1, k2, k3] = curl_f(F1, F2, F3, Xs, Ys, out.Z);
        fx = Diffx_f(zf, Xs, Ys);  fy = Diffy_f(zf, Xs, Ys);
        out.C = (-k1.*fx - k2.*fy + k3) ./ sqrt(1 + fx.^2 + fy.^2);

        za = zf(xa, ya);
        Fa = [F1(xa,ya,za), F2(xa,ya,za), F3(xa,ya,za)];
        Na = [-Diffx_f(zf,xa,ya), -Diffy_f(zf,xa,ya), ones(size(xa))];
        out.za = za;
        out.F  = arrowLen * Fa / max(vecnorm(Fa, 2, 2));
        out.N  = arrowLen * Na ./ vecnorm(Na, 2, 2);
    end

% F evaluated at the rows of P = [x y z]
Fat = @(P) [F1(P(:,1),P(:,2),P(:,3)), F2(P(:,1),P(:,2),P(:,3)), F3(P(:,1),P(:,2),P(:,3))];

% N pieces of C with equal arc length: F at each midpoint dotted with dr
    function out = lineData(nPieces)
        out.sE = linspace(0, L, nPieces+1).';            % arc length at the corners
        tE = sToT(out.sE);
        out.P  = rC(tE);                                  % nPieces+1 corners
        out.dr = diff(out.P, 1, 1);                       % nPieces steps
        out.sM = (out.sE(1:end-1) + out.sE(2:end))/2;     % arc length at midpoints
        out.F  = Fat(rC(sToT(out.sM)));
        out.dots = sum(out.F .* out.dr, 2);               % F . dr for each piece
        out.dens = out.dots ./ diff(out.sE);              % F . dr / ds (bar height)
        out.cum  = [0; cumsum(out.dots)];                 % running total at the corners
    end

%% Precompute math for updates
% Arc length along C, so the s slider can be turned into a parameter t
tGrid = linspace(tRange(1), tRange(2), 4001).';
sGrid = cumtrapz(tGrid, vecnorm(Diff_f(rC, tGrid), 2, 2));
L     = sGrid(end);                                  % length of C (2 pi here)
sToT  = @(s) interp1(sGrid, tGrid, s);

%% Make the initial plots
% Surface grid (polar) and the ring of arrow points
[Rg, Tg] = meshgrid(linspace(0, 1, nR), linspace(0, 2*pi, nT));
Xs = Rg.*cos(Tg);  Ys = Rg.*sin(Tg);
xa = [];  ya = [];
for ring = 1:numel(numPerRing)
    rr = (ring - 1) / numel(numPerRing);         % first ring is the center
    th = 2*pi*(1:numPerRing(ring)).' / numPerRing(ring);
    xa = [xa; rr*cos(th)];  ya = [ya; rr*sin(th)]; %#ok<AGROW>
end

% Surface integral for every surface (they should all agree)
surfInt = zeros(1, numel(surfFuns));
for j0 = 1:numel(surfFuns)
    surfInt(j0) = integral2(@(r,th) curlDotN(surfFuns{j0}, r, th), 0, 1, 0, 2*pi, ...
        'AbsTol', 1e-10);
end

% ---- Left panel: surface S
sd = surfaceData(surfIdx);
CL = rC(linspace(tRange(1), tRange(2), 400));
hSurf = surf(axL, Xs, Ys, sd.Z, sd.C, 'EdgeColor', 'none', 'FaceColor', 'interp');
plot3(axL, CL(:,1), CL(:,2), CL(:,3), 'k', 'LineWidth', 2);
hFS = quiver3(axL, xa, ya, sd.za, sd.F(:,1), sd.F(:,2), sd.F(:,3), 0, 'b', 'LineWidth', 1.2);
hNS = quiver3(axL, xa, ya, sd.za, sd.N(:,1), sd.N(:,2), sd.N(:,3), 0, 'g', 'LineWidth', 1.2);
%axis(axL, 'equal')
xlim(axL, [-1.2 1.2]); ylim(axL, [-1.2 1.2]); zlim(axL, [-0.8 1.3])
view(axL, -35, 25)

% ---- Middle panel: the line integral along C
N  = Ninf;                  % start at the limit
s  = L;                     % start with the whole curve
ld = lineData(N);
plot3(axM, CL(:,1), CL(:,2), CL(:,3), 'Color', [0.6 0.6 0.6], 'LineWidth', 1.5);
hPoly  = plot3(axM, NaN, NaN, NaN, 'k.-', 'LineWidth', 1, 'MarkerSize', 10);
hTrail = plot3(axM, NaN, NaN, NaN, 'Color', [0.8 0.5 0], 'LineWidth', 4);
hDot   = plot3(axM, NaN, NaN, NaN, 'o', 'MarkerFaceColor', [1 0.6 0], ...
    'MarkerSize', 12, 'MarkerEdgeColor', 'k', 'LineWidth', 2);
hF = quiver3(axM, 0, 0, 0, 0, 0, 0, 0, 'b', 'LineWidth', 2.5);
hT = quiver3(axM, 0, 0, 0, 0, 0, 0, 0, 'g', 'LineWidth', 2.5);
hP = quiver3(axM, 0, 0, 0, 0, 0, 0, 0, 'r', 'LineWidth', 2.5);
legend(axM, [hF hT hP], {'$\mathbf{F}$', '$\mathbf{T}$', ...
    '$(\mathbf{F}\cdot\mathbf{T})\,\mathbf{T}$'}, 'Location', 'northeast', 'Interpreter', 'latex')
%axis(axM, 'equal')
xlim(axM, [-1.6 1.6]); ylim(axM, [-1.6 1.6]); zlim(axM, [-0.5 1.5])
view(axM, -35, 25)

% ---- Right panel: F . dr / ds and the running total against arc length
% Boxes over each piece (height F . dr / ds, so area F . dr), as in
% S16_4_Greens_theorem: solid once the point has passed them, faint ahead.
% Order: passed +, ahead +, passed -, ahead -. In the limit the boxes are so
% thin that they fill the area under the curve.
boxCol   = {cPos, cPos, cNeg, cNeg};
boxAlpha = [0.60 0.15 0.60 0.15];
hBox = gobjects(1, 4);
for gi = 1:4
    hBox(gi) = patch(axR, NaN(4,1), NaN(4,1), boxCol{gi}, ...
        'FaceAlpha', boxAlpha(gi), 'EdgeColor', 'k', 'LineWidth', 0.6);
end
hDens = plot(axR, NaN, NaN, 'Color', cPos, 'LineWidth', 2.5);   % limit: the curve F . T
hCum  = plot(axR, NaN, NaN, 'k', 'LineWidth', 2.5);
hNow  = plot(axR, NaN, NaN, 'ko', 'MarkerFaceColor', [1 0.6 0], 'MarkerSize', 10, 'LineWidth', 1.5);
yline(axR, 0, 'k--', 'LineWidth', 1);
hTarget = yline(axR, surfInt(surfIdx), 'g--', 'LineWidth', 3, ...
    'Label', '$\int\!\!\int_S (\nabla\times\mathbf{F})\cdot d\mathbf{S}$', ...
    'Interpreter', 'latex', 'LabelHorizontalAlignment', 'left', 'FontSize', 16);
xlim(axR, [0 L])
xlabel(axR, 'arc length $s$', 'Interpreter', 'latex')
ylabel(axR, '$\mathbf{F}\cdot\mathbf{T}$ and running total', 'Interpreter', 'latex')
zlabel(axR, '')

%% Build UI
NumControls = 3;
sN = app.addControl('slider', '$N = $', 1, NumControls, @changeN, ...
    'Default', Nmax + 1, 'Min', 2, 'Max', Nmax + 1, 'Number_format', '%d', 'Step', 1, ...
    'LimitLabel', '$N \to \infty$', 'LimitValue', Ninf, 'colOrRow', 'row');
sS = app.addControl('slider', 'Arc length $s = $', 2, NumControls, @changeS, ...
    'Default', L, 'Min', 0, 'Max', L, 'colOrRow', 'row');
btnSurf = app.addControl('button', 'Next surface', 3, NumControls, @nextSurface, ...
    'colOrRow', 'row');

drawSurface()
drawPieces()
drawStep()

%% Functions for UI elements
    function changeN(~, ~)
        newN = app.getValue(sN);      % Ninf at the right end of the slider
        if newN == N
            return
        end
        N  = newN;
        ld = lineData(N);
        drawPieces()
        drawStep()
    end

    function changeS(~, ~)
        s = sS.Value;
        drawStep()
    end

    function nextSurface(~, ~)
        surfIdx = mod(surfIdx, numel(surfFuns)) + 1;
        drawSurface()
    end

%% Main Draw update functions.
% Left panel: surface, its color and arrows (only when the surface changes)
    function drawSurface()
        sd = surfaceData(surfIdx);
        set(hSurf, 'ZData', sd.Z, 'CData', sd.C)
        cbL = Pretty_Color_Centered(axL, sd.C);
        cbL.Limits = [-6,6];
        cbL.Label.Interpreter = 'latex';
        cbL.Label.String = '$(\nabla\times\mathbf{F})\cdot\mathbf{n}$';
        set(hFS, 'ZData', sd.za, 'UData', sd.F(:,1), 'VData', sd.F(:,2), 'WData', sd.F(:,3))
        set(hNS, 'ZData', sd.za, 'UData', sd.N(:,1), 'VData', sd.N(:,2), 'WData', sd.N(:,3))
        title(axL, {surfNames{surfIdx}, ...
            sprintf('$\\int\\!\\!\\int_S (\\nabla\\times\\mathbf{F})\\cdot d\\mathbf{S} = %.4f$', surfInt(surfIdx))}, ...
            'Interpreter', 'latex')
        hTarget.Value = surfInt(surfIdx);
        drawStep()                    % right-panel title quotes the surface integral
    end

% Pieces of C and the bars (only when N changes)
    function drawPieces()
        atLimit = app.isAtLimit(sN);
        if atLimit
            % The limit: no polygon, F . T as a smooth curve, boxes without outlines
            set(hPoly, 'Visible', 'off')
            set(hDens, 'XData', ld.sM, 'YData', ld.dens, 'Visible', 'on')
            set(hBox, 'EdgeColor', 'none')
            title(axM, 'Line integral along $C$', 'Interpreter', 'latex')
        else
            set(hPoly, 'XData', ld.P(:,1), 'YData', ld.P(:,2), 'ZData', ld.P(:,3), 'Visible', 'on')
            set(hDens, 'Visible', 'off')
            set(hBox, 'EdgeColor', 'k')
            title(axM, sprintf('$C$ cut into $N = %d$ pieces', N), 'Interpreter', 'latex')
        end
        lo = min([0; ld.dens; ld.cum]);
        hi = max([ld.dens; ld.cum; surfInt(:)]);
        ylim(axR, [lo - 0.1*(hi - lo), hi + 0.15*(hi - lo)])
    end

% Point at arc length s: trail, vectors, running total (continuous in s)
    function drawStep()
        ts = sToT(s);
        Pt = rC(linspace(tRange(1), ts, max(2, round(400*s/L))));
        set(hTrail, 'XData', Pt(:,1), 'YData', Pt(:,2), 'ZData', Pt(:,3))

        p    = rC(ts);
        Fk   = Fat(p);
        Tk   = Diff_f(rC, ts);  Tk = Tk / norm(Tk);
        proj = dot(Fk, Tk) * Tk;
        set(hDot, 'XData', p(1), 'YData', p(2), 'ZData', p(3))
        set(hF, 'XData', p(1), 'YData', p(2), 'ZData', p(3), 'UData', Fk(1),     'VData', Fk(2),     'WData', Fk(3))
        set(hT, 'XData', p(1), 'YData', p(2), 'ZData', p(3), 'UData', 0.6*Tk(1), 'VData', 0.6*Tk(2), 'WData', 0.6*Tk(3))
        set(hP, 'XData', p(1), 'YData', p(2), 'ZData', p(3), 'UData', proj(1),   'VData', proj(2),   'WData', proj(3))

        % Running total: exact at the corners, linear across each piece
        sx = [ld.sE(ld.sE < s); s];
        sy = interp1(ld.sE, ld.cum, sx);
        set(hCum, 'XData', sx, 'YData', sy)
        set(hNow, 'XData', s, 'YData', sy(end))

        % Color in the area as it is integrated. The piece the point is on
        % is split at s, so the coloring moves smoothly with the slider.
        x0 = ld.sE(1:end-1).';  x1 = ld.sE(2:end).';
        xs = min(max(s, x0), x1);                 % where s cuts each piece
        hgt = ld.dens.';  zer = zeros(size(hgt));
        isPos = hgt >= 0;
        Xp = [x0; xs; xs; x0];   Xa = [xs; x1; x1; xs];   % passed / ahead parts
        Yb = [zer; zer; hgt; hgt];
        done = xs > x0;   ahead = x1 > xs;
        mk = {isPos & done, isPos & ahead, ~isPos & done, ~isPos & ahead};
        Xg = {Xp, Xa, Xp, Xa};
        for g = 1:4
            set(hBox(g), 'XData', pickCols(Xg{g}, mk{g}), 'YData', pickCols(Yb, mk{g}))
        end

        if app.isAtLimit(sN)
            title(axR, {sprintf('$\\int_0^{%.2f} \\mathbf{F}\\cdot\\mathbf{T}\\,ds = %.4f$', s, sy(end)), ...
                sprintf('$\\oint_C \\mathbf{F}\\cdot d\\mathbf{r} = %.4f$, \\quad surface integral: $%.4f$', ...
                    ld.cum(end), surfInt(surfIdx))}, 'Interpreter', 'latex')
        else
            title(axR, {sprintf('Running sum to $s = %.2f$: $%.4f$', s, sy(end)), ...
                sprintf('all $N = %d$ pieces: $%.4f$, \\quad surface integral: $%.4f$', ...
                    N, ld.cum(end), surfInt(surfIdx))}, 'Interpreter', 'latex')
        end
        drawnow limitrate
    end

end

%% Stateless helper
% Columns of M selected by mask, or one column of NaN when nothing is selected
function Mo = pickCols(M, mask)
if any(mask)
    Mo = M(:, mask);
else
    Mo = NaN(size(M,1), 1);
end
end