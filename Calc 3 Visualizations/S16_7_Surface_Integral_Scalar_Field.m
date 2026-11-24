function S16_7_Surface_Integral_Scalar_Field()
%% Surface integral of a scalar field by tangent planes.
%  The saddle S: z = x^2 - y^2 is colored by f(x,y) = exp(-x^2-y^2+sin(pi y)).
%  The square [-2,2]^2 is cut into an N x N grid. On each cell we draw the
%  tangent plane at the cell center, colored by f at that center, with its
%  center point (yellow), unit normal (blue) and the unit r_x, r_y
%  directions (green). The title compares
%      sum f(x_c,y_c) sqrt(1 + f_x^2 + f_y^2) dx dy   ->   iint_S f dS
%  and the same sum with f = 1, which gives the surface area.
%    N slider       - number of cells per side (N^2 tangent planes)
%    Vectors button - hide/show the center points and arrows (faster for large N)
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
f_surf  = @(x,y) x.^2 - y.^2;                      % geometry of S
f_color = @(x,y) exp(-x.^2 - y.^2 + sin(pi*y));    % scalar field f on S

xlims = [-2 2]; ylims = [-2 2];
resHigh  = 150;   % resolution of the reference surface (drawing only)
resLow0  = 1;     % initial N
resMax   = 31;    % largest N on the slider
arrowLen = 0.2;   % length of the normal / r_x / r_y arrows
zLift    = 0.01;  % planes drawn this far above S

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Surface integral of a scalar field', 1);
ax  = app.ax(1);

%% Optional math functions for plot computations
% Surface element dS/dA = sqrt(1 + f_x^2 + f_y^2)
dSdA = @(x,y) sqrt(1 + Diffx_f(f_surf,x,y).^2 + Diffy_f(f_surf,x,y).^2);

% "Exact" values by adaptive quadrature
IntegralTrue = integral2(@(x,y) f_color(x,y).*dSdA(x,y), ...
    xlims(1), xlims(2), ylims(1), ylims(2), 'AbsTol', 1e-8);
AreaTrue     = integral2(dSdA, xlims(1), xlims(2), ylims(1), ylims(2), 'AbsTol', 1e-8);

%% Make the initial plots
% Reference surface colored by f
[XH, YH] = meshgrid(linspace(xlims(1), xlims(2), resHigh), ...
                    linspace(ylims(1), ylims(2), resHigh));
ZH = f_surf(XH, YH);
CH = f_color(XH, YH);
surf(ax, XH, YH, ZH, CH, 'FaceAlpha', 0.8, 'EdgeColor', 'none');

cb = Pretty_Color_Positive(ax, CH);
cb.Label.String = '$f(x,y)$';
cb.Label.Interpreter = 'latex';

% Tangent planes, centre dots and vectors
c = computeCells(resLow0);
planePatch = patch(ax, 'Faces', c.Faces, 'Vertices', c.Vertices, ...
    'FaceVertexCData', c.fc, 'FaceColor', 'flat', 'EdgeColor', 'k');
centerDots = plot3(ax, c.xc, c.yc, c.zc, 'ko', 'MarkerFaceColor', 'y', ...
    'MarkerSize', 6, 'LineStyle', 'none');
normalArrows = quiver3(ax, c.xc, c.yc, c.zc, c.n(:,1), c.n(:,2), c.n(:,3), 0, ...
    'Color', 'b', 'LineWidth', 1.2);
fxArrows = quiver3(ax, c.xc, c.yc, c.zc, c.tx(:,1), c.tx(:,2), c.tx(:,3), 0, ...
    'Color', 'g', 'LineWidth', 1.2);
fyArrows = quiver3(ax, c.xc, c.yc, c.zc, c.ty(:,1), c.ty(:,2), c.ty(:,3), 0, ...
    'Color', 'g', 'LineWidth', 1.2);
vectorHandles = [centerDots, normalArrows, fxArrows, fyArrows];

%% Plot elements are done - Make pretty
axis(ax, 'equal')
xlim(ax, xlims); ylim(ax, ylims)
view(ax, -38, 20)
setTitle(resLow0, c)

%% Precompute math for updates
Ncurrent = resLow0;

%% Build UI
NumControls = 2;
sRes = app.addControl('slider', '$N = $', 1, NumControls, @updatePlot, ...
    'Default', resLow0, 'Min', 1, 'Max', resMax, 'Number_format', '%d', ...
    'Step', 1, 'colOrRow', 'row');
btnVec = app.addControl('button', '', 2, NumControls, @toggleVectors, ...
    'Toggle', ["Hide vectors", "Show vectors"], 'colOrRow', 'row');
setSliderLabel(resLow0)

%% Functions for UI elements
    function toggleVectors(~, ~)
        showVec = ~btnVec.Value;
        set(vectorHandles, 'Visible', onoff(showVec))
        if showVec
            updateArrows(c)   % not updated while hidden
        end
    end

    function setSliderLabel(N)
        sRes.UserData.label.String = sprintf('$N = %d$ (%d planes)', N, N^2);
    end

    function setTitle(N, cc)
        title(ax, { ...
            sprintf('$\\int\\!\\!\\int_S f\\,dS$: exact $= %.5f$, sum $= %.5f$, planes $= %d$', ...
                IntegralTrue, cc.Sf, N^2), ...
            sprintf('Area of $S$: exact $= %.5f$, sum $= %.5f$', AreaTrue, cc.SA)})
        app.fig.Name = sprintf('Integral: exact = %.5f, approx = %.5f, planes = %d', ...
            IntegralTrue, cc.Sf, N^2);
    end

    function updateArrows(cc)
        set(centerDots, 'XData', cc.xc, 'YData', cc.yc, 'ZData', cc.zc)
        set(normalArrows, 'XData', cc.xc, 'YData', cc.yc, 'ZData', cc.zc, ...
            'UData', cc.n(:,1),  'VData', cc.n(:,2),  'WData', cc.n(:,3))
        set(fxArrows, 'XData', cc.xc, 'YData', cc.yc, 'ZData', cc.zc, ...
            'UData', cc.tx(:,1), 'VData', cc.tx(:,2), 'WData', cc.tx(:,3))
        set(fyArrows, 'XData', cc.xc, 'YData', cc.yc, 'ZData', cc.zc, ...
            'UData', cc.ty(:,1), 'VData', cc.ty(:,2), 'WData', cc.ty(:,3))
    end

%% Main Draw update function.
    function updatePlot(~, ~)
        N = app.getValue(sRes);
        setSliderLabel(N)
        if N == Ncurrent
            return
        end
        Ncurrent = N;

        c = computeCells(N);
        set(planePatch, 'Faces', c.Faces, 'Vertices', c.Vertices, ...
            'FaceVertexCData', c.fc)
        if ~btnVec.Value
            updateArrows(c)
        end
        setTitle(N, c)
        drawnow limitrate
    end

%% Geometry for an N x N grid of tangent planes
    function cc = computeCells(N)
        dx = (xlims(2)-xlims(1))/N;
        dy = (ylims(2)-ylims(1))/N;
        [I, J] = ndgrid(1:N, 1:N);
        x0 = xlims(1) + (I(:)-1)*dx;   x1 = x0 + dx;
        y0 = ylims(1) + (J(:)-1)*dy;   y1 = y0 + dy;
        xc = (x0+x1)/2;  yc = (y0+y1)/2;  zc = f_surf(xc, yc);
        dfdx = Diffx_f(f_surf, xc, yc);
        dfdy = Diffy_f(f_surf, xc, yc);

        % Tangent-plane corners, one row per cell: [x0 x1 x1 x0], [y0 y0 y1 y1]
        xq = [x0 x1 x1 x0];
        yq = [y0 y0 y1 y1];
        zq = zc + zLift + dfdx.*(xq - xc) + dfdy.*(yq - yc);

        nCells = N^2;
        cc.Vertices = [reshape(xq.', [], 1), reshape(yq.', [], 1), reshape(zq.', [], 1)];
        cc.Faces    = reshape(1:4*nCells, 4, nCells).';
        cc.fc = f_color(xc, yc);                   % one color per plane
        cc.xc = xc;  cc.yc = yc;  cc.zc = zc + zLift;

        one = ones(nCells, 1);  zer = zeros(nCells, 1);
        cc.n  = unitRows([-dfdx, -dfdy, one]) * arrowLen;   % normal r_x x r_y
        cc.tx = unitRows([one, zer, dfdx])    * arrowLen;   % r_x
        cc.ty = unitRows([zer, one, dfdy])    * arrowLen;   % r_y

        dS   = dx*dy*sqrt(1 + dfdx.^2 + dfdy.^2);           % area of each plane
        cc.SA = sum(dS);                                     % surface area
        cc.Sf = sum(cc.fc .* dS);                             % surface integral of f
    end

end

%% Stateless helper
function V = unitRows(V)
V = V ./ sqrt(sum(V.^2, 2));
end
