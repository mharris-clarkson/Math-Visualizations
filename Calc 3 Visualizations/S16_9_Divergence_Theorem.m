function S16_9_Divergence_Theorem()
%% Divergence theorem on a ball of radius R: iiint_E div F dV = iint_S F . n dS.
%  Left:  div F on the three coordinate slices through the ball, inside a
%         wire-frame sphere, or (Volume button) a volume picture of div F:
%         red clouds where the field spreads out, blue where it piles up.
%         The title shows the volume integral.
%  Right: the sphere S colored by F . n, with the outward unit normals
%         (black) and F (magenta). The title shows the flux.
%  Both integrals are computed with Gauss-Legendre quadrature, which is
%  exact for these polynomial fields, so the two titles always agree.
%    R slider               - radius of the ball
%    Previous / Next        - step through several vector fields
%    Vectors button         - hide/show the arrows on the sphere
%    Volume button          - swap the slices for the volume picture
%                             (redrawn whenever the axes are rotated)
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
% Vector fields to step through: name (LaTeX, no $) and components
fields = struct( ...
    'name', {'\langle x^2 - y,\ y^2 - z,\ z^2 - x \rangle', ...
             '\langle x,\ y,\ z \rangle', ...
             '\langle z,\ y,\ x \rangle', ...
             '\langle x^3,\ y^3,\ z^3 \rangle'}, ...
    'F1', {@(x,y,z) x.^2 - y, @(x,y,z) x, @(x,y,z) z, @(x,y,z) x.^3}, ...
    'F2', {@(x,y,z) y.^2 - z, @(x,y,z) y, @(x,y,z) y, @(x,y,z) y.^3}, ...
    'F3', {@(x,y,z) z.^2 - x, @(x,y,z) z, @(x,y,z) x, @(x,y,z) z.^3});
fieldIdx = 1;       % field shown first

R0   = 1;           % starting radius
Rmin = 0.25;        % radius slider range
Rmax = 1.5;
nQuad    = 16;      % quadrature points in rho and phi (2*nQuad in theta)
nSphere  = 40;      % display grid for the sphere
arrowFrac = 0.35;   % arrow length as a fraction of R

% Volume picture (same look as S16_9_Divergence_Volume_Render)
volN       = 48;              % grid points per side of the volume
volNr      = 60;              % rays across the radius
volNt      = 120;             % rays around the circle
volGamma   = 0.8;             % opacity = |div F|^volGamma
volOpacity = 0.35;            % overall opacity scale
volBg      = [0.8 0.8 0.8];   % background behind the ball
cmapRB     = [linspace(0,1,256)' zeros(256,1) linspace(1,0,256)'];   % blue (sink) to red (source)

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Divergence theorem', 2);
axL = app.ax(1);  axR = app.ax(2);

%% Optional math functions for plot computations
% Divergence of field j with the helper partial derivatives
    function d = divF(j, x, y, z)
        d = Diffx_f(fields(j).F1, x, y, z) + Diffy_f(fields(j).F2, x, y, z) ...
          + Diffz_f(fields(j).F3, x, y, z);
    end

% F . n on the sphere of radius rad at unit-sphere points (nx, ny, nz)
    function v = fluxDensity(j, rad, nx, ny, nz)
        x = rad*nx;  y = rad*ny;  z = rad*nz;
        v = fields(j).F1(x,y,z).*nx + fields(j).F2(x,y,z).*ny + fields(j).F3(x,y,z).*nz;
    end

%% Precompute math for updates
% Quadrature on the unit ball / unit sphere (R only rescales it)
[rq, wr] = gaussLegendre(nQuad, 0, 1);
[pq, wp] = gaussLegendre(nQuad, 0, pi);
tq = (0:2*nQuad-1).' * pi/nQuad;   wt = pi/nQuad;   % periodic: equal weights
[Rr, Pp, Tt] = ndgrid(rq, pq, tq);
[Wr, Wp, ~]  = ndgrid(wr, wp, tq);
Uvol = {Rr.*sin(Pp).*cos(Tt), Rr.*sin(Pp).*sin(Tt), Rr.*cos(Pp)};
Wvol = Wr .* Wp * wt .* Rr.^2 .* sin(Pp);         % rho^2 sin(phi) drho dphi dtheta
[P2, T2] = ndgrid(pq, tq);
[Wp2, ~] = ndgrid(wp, tq);
Usurf = {sin(P2).*cos(T2), sin(P2).*sin(T2), cos(P2)};
Wsurf = Wp2 * wt .* sin(P2);                      % sin(phi) dphi dtheta

% Volume grid on [-1, 1]^3
gvU = linspace(-1, 1, volN);
[xu, yu, zu] = ndgrid(gvU);
ru = sqrt(xu.^2 + yu.^2 + zu.^2);
tSteps = linspace(1, -1, volN);       % ray depths, front to back
volKey = [NaN NaN];                   % [field R] of the last built volume
Vint = [];  Aint = [];                % interpolants, made by buildVolume
volMode = false;
% The picture is drawn on a camera-facing disk, one ray per grid point
[rhoV, phiV] = meshgrid(linspace(0, 1, volNr), linspace(0, 2*pi, volNt));
aV = rhoV.*cos(phiV);  bV = rhoV.*sin(phiV);

% Display grids on the unit disk (slices) and unit sphere
[Rd, Td] = meshgrid(linspace(0, 1, 20), linspace(0, 2*pi, 49));
D1 = Rd.*cos(Td);  D2 = Rd.*sin(Td);  D0 = 0*Rd;
[Ts, Ps] = meshgrid(linspace(0, 2*pi, 2*nSphere), linspace(0, pi, nSphere));
S1 = sin(Ps).*cos(Ts);  S2 = sin(Ps).*sin(Ts);  S3 = cos(Ps);
[Ta, Pa] = meshgrid(linspace(0, 2*pi, 13), linspace(pi/8, 7*pi/8, 6));
Ta = Ta(:, 1:end-1);  Pa = Pa(:, 1:end-1);
A1 = sin(Pa(:)).*cos(Ta(:));  A2 = sin(Pa(:)).*sin(Ta(:));  A3 = cos(Pa(:));

%% Make the initial plots
% ---- Left: three slices of div F and a wire-frame sphere
hSlice = [surf(axL, D1, D2, D0, D0, 'EdgeColor', 'none', 'FaceColor', 'interp'), ...  % z = 0
          surf(axL, D0, D1, D2, D0, 'EdgeColor', 'none', 'FaceColor', 'interp'), ...  % x = 0
          surf(axL, D1, D0, D2, D0, 'EdgeColor', 'none', 'FaceColor', 'interp')];     % y = 0
[Tw, Pw] = meshgrid(linspace(0, 2*pi, 25), linspace(0, pi, 13));
Sw = {sin(Pw).*cos(Tw), sin(Pw).*sin(Tw), cos(Pw)};
hWire = surf(axL, Sw{:}, 'FaceColor', 'none', 'EdgeColor', [0.3 0.3 0.3], 'EdgeAlpha', 0.4);
setColor(axL, 1, '$\nabla\cdot\mathbf{F}$')
hVol = surf(axL, 0*aV, 0*aV, 0*aV, zeros([size(aV) 3]), ...
    'EdgeColor', 'none', 'FaceColor', 'interp', 'Visible', 'off');

% ---- Right: the sphere colored by F . n, with normals and F
hSphere = surf(axR, S1, S2, S3, 0*S3, 'EdgeColor', 'none', 'FaceColor', 'interp', 'FaceAlpha', 0.8);
setColor(axR, 1, '$\mathbf{F}\cdot\mathbf{n}$')
hNormal = quiver3(axR, A1, A2, A3, A1, A2, A3, 0, 'k', 'LineWidth', 1.2);
hField  = quiver3(axR, A1, A2, A3, A1, A2, A3, 0, 'm', 'LineWidth', 1.2);
legend(axR, [hNormal hField], {'$\mathbf{n}$', '$\mathbf{F}$'}, ...
    'Location', 'northeast')

%% Plot elements are done - Make pretty
lim = Rmax + 0.6;
for axi = [axL axR]
    xlim(axi, [-lim lim]); ylim(axi, [-lim lim]); zlim(axi, [-lim lim])
    view(axi, 35, 25)
end

%% Build UI
NumControls = 5;
sR = app.addControl('slider', '$R = $', 1, NumControls, @updatePlot, ...
    'Default', R0, 'Min', Rmin, 'Max', Rmax, 'colOrRow', 'row');
app.addPrevNext(2, NumControls, numel(fields), @selectField, 'colOrRow', 'row');
btnVec = app.addControl('button', '', 4, NumControls, @updatePlot, ...
    'Toggle', ["Hide vectors", "Show vectors"], 'colOrRow', 'row');
btnVol = app.addControl('button', '', 5, NumControls, @toggleVolume, ...
    'Toggle', ["Volume view", "Slice view"], 'ColorChange', true, 'colOrRow', 'row');

% Redraw the volume picture whenever the left axes are rotated
addlistener(axL, 'View', 'PostSet', @(~,~) viewChanged());

updatePlot()

%% Functions for UI elements
% Centered colormap, colorbar and its LaTeX label
    function setColor(axh, data, labelStr)
        cb = Pretty_Color_Centered(axh, data);
        cb.Label.Interpreter = 'latex';   % before String
        cb.Label.String = labelStr;
    end

    function selectField(j)
        fieldIdx = j;
        updatePlot()
    end

% Swap the left panel between the slices and the volume picture
    function toggleVolume(~, ~)
        volMode = logical(btnVol.Value);
        set(hSlice, 'Visible', onoff(~volMode))
        set(hVol,   'Visible', onoff(volMode))
        if volMode
            axL.Color = volBg;
        else
            axL.Color = 'w';
        end
        updatePlot()
    end

    function viewChanged()
        if volMode
            renderVolume()
        end
    end

%% Volume picture
% Scaled div F on the volume grid and its opacity
    function buildVolume(j, R)
        D = divF(j, R*xu, R*yu, R*zu);
        D = D / max(max(abs(D(:))), eps);       % normalize over the cube
        D(ru > 1) = 0;
        Abase = (abs(D) .* max(1 - ru, 0)).^volGamma;
        Vint = griddedInterpolant({gvU, gvU, gvU}, D,     'linear', 'nearest');
        Aint = griddedInterpolant({gvU, gvU, gvU}, Abase, 'linear', 'nearest');
        volKey = [j R];
    end

% Blend color and opacity front to back along one ray per disk point
    function renderVolume()
        [azd, eld] = view(axL);
        az = deg2rad(azd);  el = deg2rad(eld);
        c  = [sin(az)*cos(el), -cos(az)*cos(el), sin(el)];   % toward the camera
        u  = [cos(az), sin(az), 0];                          % right on screen
        w  = cross(c, u);                                    % up on screen

        a = aV(:);  b = bV(:);
        Cacc = zeros(numel(a), 3);
        Aacc = zeros(numel(a), 1);
        for t = tSteps
            px = a*u(1) + b*w(1) + t*c(1);
            py = a*u(2) + b*w(2) + t*c(2);
            pz = a*u(3) + b*w(3) + t*c(3);
            alpha = min(1, volOpacity * Aint(px, py, pz));
            ci  = round((Vint(px, py, pz) + 1) / 2 * 255) + 1;   % colors span [-1, 1]
            ci  = min(max(ci, 1), 256);
            wgt = (1 - Aacc) .* alpha;
            Cacc = Cacc + wgt .* cmapRB(ci, :);
            Aacc = Aacc + wgt;
            if all(Aacc > 0.99), break, end
        end
        col = Cacc + (1 - Aacc) .* volBg;      % blend with the background

        R = sR.Value;
        set(hVol, 'XData', R*(aV*u(1) + bV*w(1)), ...
                  'YData', R*(aV*u(2) + bV*w(2)), ...
                  'ZData', R*(aV*u(3) + bV*w(3)), ...
                  'CData', reshape(col, [size(aV) 3]))
        drawnow limitrate
    end

%% Main Draw update function.
    function updatePlot(~, ~)
        R = sR.Value;
        j = fieldIdx;

        % Both sides of the theorem
        volInt  = R^3 * sum(divF(j, R*Uvol{1}, R*Uvol{2}, R*Uvol{3}) .* Wvol, 'all');
        surfInt = R^2 * sum(fluxDensity(j, R, Usurf{:}) .* Wsurf, 'all');
        volInt(abs(volInt) < 1e-9)   = 0;      % avoid -0.0000
        surfInt(abs(surfInt) < 1e-9) = 0;

        set(hWire, 'XData', R*Sw{1}, 'YData', R*Sw{2}, 'ZData', R*Sw{3})
        if volMode
            if ~isequal(volKey, [j R])
                buildVolume(j, R)
            end
            renderVolume()
            colormap(axL, cmapRB);  clim(axL, [-1 1])
            cb = colorbar(axL);
            cb.Label.Interpreter = 'latex';
            cb.Label.String = '$\nabla\cdot\mathbf{F}$ (scaled)';
            leftName = 'Volume picture of $\nabla\cdot\mathbf{F}$ in the ball $E$';
        else
            dZ = divF(j, R*D1, R*D2, D0);
            dX = divF(j, D0, R*D1, R*D2);
            dY = divF(j, R*D1, D0, R*D2);
            set(hSlice(1), 'XData', R*D1, 'YData', R*D2, 'ZData', D0,   'CData', dZ)
            set(hSlice(2), 'XData', D0,   'YData', R*D1, 'ZData', R*D2, 'CData', dX)
            set(hSlice(3), 'XData', R*D1, 'YData', D0,   'ZData', R*D2, 'CData', dY)
            setColor(axL, [dZ(:); dX(:); dY(:)], '$\nabla\cdot\mathbf{F}$')
            leftName = '$\nabla\cdot\mathbf{F}$ on three slices of the ball $E$';
        end
        title(axL, {leftName, ...
            sprintf('$\\int\\!\\!\\int\\!\\!\\int_E \\nabla\\cdot\\mathbf{F}\\,dV = %.4f$', volInt)})

        Cs = fluxDensity(j, R, S1, S2, S3);
        set(hSphere, 'XData', R*S1, 'YData', R*S2, 'ZData', R*S3, 'CData', Cs)
        setColor(axR, Cs, '$\mathbf{F}\cdot\mathbf{n}$')
        title(axR, {['$\mathbf{F} = ' fields(j).name '$'], ...
            sprintf('$\\int\\!\\!\\int_S \\mathbf{F}\\cdot\\mathbf{n}\\,dS = %.4f$', surfInt)})

        showVec = ~btnVec.Value;
        set([hNormal hField], 'Visible', onoff(showVec))
        if showVec
            L  = arrowFrac * R;
            xa = R*A1;  ya = R*A2;  za = R*A3;
            Fa = [fields(j).F1(xa,ya,za), fields(j).F2(xa,ya,za), fields(j).F3(xa,ya,za)];
            Fa = L * Fa / max(max(vecnorm(Fa, 2, 2)), eps);
            set(hNormal, 'XData', xa, 'YData', ya, 'ZData', za, ...
                'UData', L*A1, 'VData', L*A2, 'WData', L*A3)
            set(hField, 'XData', xa, 'YData', ya, 'ZData', za, ...
                'UData', Fa(:,1), 'VData', Fa(:,2), 'WData', Fa(:,3))
        end
    end

end

%% Stateless helper
% Gauss-Legendre nodes x and weights w on [a, b] (Golub-Welsch)
function [x, w] = gaussLegendre(n, a, b)
k = 1:n-1;
beta = k ./ sqrt(4*k.^2 - 1);
[V, D] = eig(diag(beta, 1) + diag(beta, -1));
[x, idx] = sort(diag(D));
w = 2 * V(1, idx).'.^2;
x = (b - a)/2 * x + (a + b)/2;
w = (b - a)/2 * w;
end
