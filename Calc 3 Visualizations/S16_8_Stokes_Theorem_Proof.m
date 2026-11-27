function S16_8_Stokes_Theorem_Proof()
%% Why Stokes' theorem is true: the interior edges cancel.
%  The surface S: z = 1 - (x^2 + y^2)/2 over the square [-1,1]^2 (upward
%  normal) is cut into n^2 small patches, each shrunk a little so its own
%  boundary loop can be seen. Every edge of every patch is colored by its
%  line integral of F, with an arrow showing the direction it is traversed
%  (counterclockwise seen from above, as the upward normal requires).
%    - Every interior edge belongs to two patches that traverse it in
%      opposite directions, so its line integral is counted twice with
%      opposite signs (opposite colors, opposite arrows). They add to 0.
%    - So the sum of the circulations around all the patches is the line
%      integral around the outer boundary only: oint_C F . dr.
%    - Each patch's circulation is about (curl F . n) Delta S, so the same
%      sum is a Riemann sum for iint_S (curl F) . dS.
%  Controls: n (patches per side), how far the patches are shrunk, and a
%  button that cancels (fades out) the interior edges, leaving C.
%
%% Author Info
%
% Written by Dr Matthew Harris an assistant professor at
% Clarkson University, for MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
F1 = @(x,y,z) -y.^3;           % vector field F = <F1, F2, F3>
F2 = @(x,y,z) x.^3;
F3 = @(x,y,z) x.*z;
rS = @(u,v) [u; v; 1 - (u.^2 + v.^2)/2];   % surface r(u,v), u, v in [-1, 1]
uLims = [-1 1];
vLims = [-1 1];

n0      = 1;      % starting patches per side 
nMax    = 20;
Gap0 = 0;         % starting gap of each patch toward its centre
nQuad   = 10;     % Gauss-Legendre points per edge
nDraw   = 16;     % points used to draw each edge on the surface
lift    = 0.012;  % edges drawn this far above the surface
arrowFrac  = 0.35;   % arrow length as a fraction of the patch size
fadedAlpha = 0.07;   % interior edges once they cancel

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Stokes'' Theorem: Interior Edges Cancel', 1);
ax  = app.ax(1);
view(ax, -35, 38)
axis(ax, 'equal')

%% Optional math functions for plot computations
[gq, gw] = gaussLegendre(nQuad);
Fat  = @(P) [F1(P(1,:),P(2,:),P(3,:)); F2(P(1,:),P(2,:),P(3,:)); F3(P(1,:),P(2,:),P(3,:))];

% Unit upward normal of the surface at parameter points (u, v)
    function N = unitNormal(u, v)
        ru = Diff_f(@(s) rS(s, v), u);
        rv = Diff_f(@(s) rS(u, s), v);
        N  = cross(ru, rv, 1);
        N  = N ./ vecnorm(N, 2, 1);
    end

% Line integral of F along the image of the parameter segment A -> B
    function L = edgeIntegral(A, B)
        t  = (gq.' + 1)/2;                               % nodes on [0, 1]
        g  = @(t) rS(A(1) + t*(B(1) - A(1)), A(2) + t*(B(2) - A(2)));
        L  = sum(sum(Fat(g(t)) .* Diff_f(g, t), 1) .* gw.')/2;
    end

% Every edge of every patch: parameter endpoints, line integral, owner patch
    function D = buildEdges(n)
        ue = linspace(uLims(1), uLims(2), n+1);
        ve = linspace(vLims(1), vLims(2), n+1);
        ne = 4*n^2;
        D.A = zeros(ne, 2);  D.B = zeros(ne, 2);
        D.val = zeros(ne, 1);  D.interior = false(ne, 1);
        D.pairKey = zeros(ne, 1);  D.patch = zeros(ne, 1);
        D.center = zeros(n^2, 2);
        D.du = diff(uLims)/n;  D.dv = diff(vLims)/n;
        q = 0;  p = 0;
        for i = 1:n
            for j = 1:n
                p = p + 1;
                C = [ue(i) ve(j); ue(i+1) ve(j); ue(i+1) ve(j+1); ue(i) ve(j+1)];   % counterclockwise
                D.center(p,:) = mean(C, 1);
                % edge k goes C(k) -> C(k+1); key identifies the segment
                keys = [sub2ind([2 n+1 n+1], 1, i, j), sub2ind([2 n+1 n+1], 2, i+1, j), ...
                        sub2ind([2 n+1 n+1], 1, i, j+1), sub2ind([2 n+1 n+1], 2, i, j)];
                inner = [j > 1, i+1 < n+1, j+1 < n+1, i > 1];
                for k = 1:4
                    q = q + 1;
                    D.A(q,:) = C(k,:);
                    D.B(q,:) = C(mod(k, 4) + 1, :);
                    D.val(q) = edgeIntegral(D.A(q,:), D.B(q,:));
                    D.interior(q) = inner(k);
                    D.pairKey(q) = keys(k);
                    D.patch(q) = p;
                end
            end
        end
    end

%% Precompute math for updates
% iint_S (curl F) . dS = iint (curl F) . (r_u x r_v) du dv
    function val = curlDotN(u, v)
        uu = u(:).';  vv = v(:).';
        r  = rS(uu, vv);
        ru = Diff_f(@(s) rS(s, vv), uu);
        rv = Diff_f(@(s) rS(uu, s), vv);
        [c1, c2, c3] = curl_f(F1, F2, F3, r(1,:), r(2,:), r(3,:));
        val = reshape(sum([c1; c2; c3] .* cross(ru, rv, 1), 1), size(u));
    end
surfInt = integral2(@curlDotN, uLims(1), uLims(2), vLims(1), vLims(2), 'AbsTol', 1e-10, 'RelTol', 1e-10);
D = buildEdges(n0);

%% Make the initial plots
[Us, Vs] = meshgrid(linspace(uLims(1), uLims(2), 40), linspace(vLims(1), vLims(2), 40));
Ps = rS(Us(:).', Vs(:).');
surf(ax, reshape(Ps(1,:), size(Us)), reshape(Ps(2,:), size(Us)), reshape(Ps(3,:), size(Us)), ...
    'FaceColor', [0.85 0.85 0.85], 'FaceAlpha', 0.35, 'EdgeColor', 'none');
hFill = patch(ax, 'Faces', [], 'Vertices', zeros(0,3), 'FaceColor', [0.70 0.70 0.70], ...
    'FaceAlpha', 0.35, 'EdgeColor', 'none');
hInt = patch(ax, 'Faces', [], 'Vertices', zeros(0,3), 'FaceColor', 'none', ...
    'EdgeColor', 'flat', 'LineWidth', 3);
hBnd = patch(ax, 'Faces', [], 'Vertices', zeros(0,3), 'FaceColor', 'none', ...
    'EdgeColor', 'flat', 'LineWidth', 3.5);
hArrInt = quiver3(ax, NaN, NaN, NaN, NaN, NaN, NaN, 0, 'Color', [0.15 0.15 0.15], ...
    'LineWidth', 1.4, 'MaxHeadSize', 1.2);
hArrBnd = quiver3(ax, NaN, NaN, NaN, NaN, NaN, NaN, 0, 'Color', 'k', ...
    'LineWidth', 1.6, 'MaxHeadSize', 1.2);
% The boundary curve C (unshrunk), shown once the interior edges cancel
corners = [uLims(1) vLims(1); uLims(2) vLims(1); uLims(2) vLims(2); uLims(1) vLims(2); uLims(1) vLims(1)];
tc = linspace(0, 1, 60).';
CP = zeros(0, 3);  CArrP = zeros(4, 3);  CArrA = zeros(4, 3);
for k = 1:4
    uu = corners(k,1) + tc*(corners(k+1,1) - corners(k,1));
    vv = corners(k,2) + tc*(corners(k+1,2) - corners(k,2));
    P  = (rS(uu.', vv.') + lift*unitNormal(uu.', vv.')).';
    CP = [CP; P]; %#ok<AGROW>
    dP = P(32,:) - P(28,:);
    CArrA(k,:) = 0.3*dP/norm(dP);
    CArrP(k,:) = P(30,:) - CArrA(k,:)/2;
end
hC = plot3(ax, CP(:,1), CP(:,2), CP(:,3), 'k-', 'LineWidth', 2.5, 'Visible', 'off');
hArrC = quiver3(ax, CArrP(:,1), CArrP(:,2), CArrP(:,3), CArrA(:,1), CArrA(:,2), CArrA(:,3), 0, ...
    'Color', 'k', 'LineWidth', 2.5, 'MaxHeadSize', 2, 'Visible', 'off');
colormap(ax, Pretty_Colormap('balance'))
cb = colorbar(ax);
cb.Label.String = 'line integral of $\mathbf{F}$ along the edge';
cb.Label.Interpreter = 'latex';
cb.Label.FontSize = ax.FontSize;
xlim(ax, uLims + [-0.1 0.1]); ylim(ax, vLims + [-0.1 0.1]); zlim(ax, [-0.1 1.1])

%% Build UI
NumControls = 3;
sN = app.addControl('slider', 'Patches per side $n = $', 1, NumControls, @changeN, ...
    'Default', n0, 'Min', 1, 'Max', nMax, 'Number_format', '%d', 'Step', 1, 'colOrRow', 'row');
sGap = app.addControl('slider', 'Gap $= $', 2, NumControls, @(~,~) drawGeometry(), ...
    'Default', Gap0, 'Min', 0, 'Max', 0.1, 'colOrRow', 'row');
btnCancel = app.addControl('button', '', 3, NumControls, @(~,~) drawStyle(), ...
    'ColorChange', true, 'colOrRow', 'row', ...
    'Toggle', ["Cancel interior edges", "Show interior edges"]);

% Room above the plot for the three-line title
ax.Position(4) = ax.Position(4) - 0.08;

drawAll()

%% Functions for UI elements
    function changeN(~, ~)
        n = round(sN.Value);
        if size(D.center, 1) ~= n^2
            D = buildEdges(n);
            drawAll()
        end
    end

    function drawAll()
        clim(ax, max(abs(D.val))*[-1 1] + [-eps eps]);
        drawGeometry()
        drawStyle()
    end

% Shrink each patch toward its centre and draw its edges, fill and arrows
    function drawGeometry()
        g  = sGap.Value;
        ne = numel(D.val);
        t  = linspace(0, 1, nDraw);
        Vx = zeros(nDraw*ne, 3);  Cv = zeros(nDraw*ne, 1);
        arrowP = zeros(ne, 3);    arrowA = zeros(ne, 3);
        aLen = arrowFrac*min(D.du, D.dv);
        for q = 1:ne
            c  = D.center(D.patch(q), :);
            A  = c + (1 - g)*(D.A(q,:) - c);
            B  = c + (1 - g)*(D.B(q,:) - c);
            uu = A(1) + t*(B(1) - A(1));
            vv = A(2) + t*(B(2) - A(2));
            P  = rS(uu, vv) + lift*unitNormal(uu, vv);
            rows = (q-1)*nDraw + (1:nDraw);
            Vx(rows,:) = P.';
            Cv(rows)   = D.val(q);
            m  = round(nDraw/2);
            dP = P(:, m+1) - P(:, m-1);
            arrowA(q,:) = aLen * dP.' / norm(dP);
            arrowP(q,:) = P(:, m).' - arrowA(q,:)/2;
        end
        segs = (1:nDraw-1).' + (0:ne-1)*nDraw;                 % segment start rows
        segOwner = repmat(1:ne, nDraw-1, 1);
        isInt = D.interior(segOwner(:));
        S = [segs(:), segs(:) + 1];
        set(hInt, 'Faces', [], 'Vertices', Vx, 'FaceVertexCData', Cv, 'Faces', S(isInt,:));
        set(hBnd, 'Faces', [], 'Vertices', Vx, 'FaceVertexCData', Cv, 'Faces', S(~isInt,:));
        setQuiver(hArrInt, arrowP(D.interior,:), arrowA(D.interior,:));
        setQuiver(hArrBnd, arrowP(~D.interior,:), arrowA(~D.interior,:));

        % Light fill inside each shrunk patch: its own outline, in order
        np = size(D.center, 1);
        Fp = zeros(np, 4*(nDraw-1));
        for p = 1:np
            eq = find(D.patch == p);
            idx = [];
            for k = eq.'
                idx = [idx, (k-1)*nDraw + (1:nDraw-1)]; %#ok<AGROW>
            end
            Fp(p,:) = idx;
        end
        set(hFill, 'Faces', [], 'Vertices', Vx, 'Faces', Fp);
        updateTitle()
    end

% Interior edges visible, or faded out once they cancel
    function drawStyle()
        if btnCancel.Value
            set(hInt, 'EdgeAlpha', fadedAlpha)
            hArrInt.Visible = 'off';
        else
            set(hInt, 'EdgeAlpha', 1)
            hArrInt.Visible = 'on';
        end
        set([hC, hArrC], 'Visible', btnCancel.Value);
        updateTitle()
    end

%% Main Draw update function.
    function updateTitle()
        n        = round(sqrt(size(D.center, 1)));
        total    = sum(D.val);
        bndInt   = sum(D.val(~D.interior));
        pairSums = accumarray(findgroups(D.pairKey(D.interior)), D.val(D.interior));
        nPairs   = numel(pairSums);
        maxPair  = max([0; abs(pairSums)]);

        circ     = accumarray(D.patch, D.val);
        [~, pk]  = max(abs(circ));
        c        = D.center(pk,:);
        approx   = curlDotN(c(1), c(2)) * D.du * D.dv;

        line1 = sprintf('$%d^2 = %d$ patches: sum of the circulations around all of them $= %.4f$', n, n^2, total);
        if nPairs == 0
            line2 = 'One patch: all its edges are on the boundary $C$ (increase $n$ to see edges cancel)';
        elseif btnCancel.Value
            line2 = sprintf(['Interior edges cancel (%d pairs, largest pair sum $%s$), ' ...
                'leaving the boundary: $\\oint_C \\mathbf{F}\\cdot d\\mathbf{r} = %.4f$'], nPairs, sciTeX(maxPair), bndInt);
        else
            line2 = sprintf(['%d interior edges are each traversed twice, in opposite directions ' ...
                '(opposite colors and arrows)'], nPairs);
        end
        line3 = sprintf(['$\\int\\!\\!\\int_S (\\nabla\\times\\mathbf{F})\\cdot d\\mathbf{S} = %.4f$ \\quad ' ...
            'one patch: circulation $%.4f \\approx (\\nabla\\times\\mathbf{F})\\cdot\\mathbf{n}\\,\\Delta S = %.4f$'], ...
            surfInt, circ(pk), approx);
        title(ax, {line1, line2, line3}, 'FontSize', 14)
    end
end

%% Stateless helpers
function setQuiver(h, P, A)
if isempty(P)
    set(h, 'XData', NaN, 'YData', NaN, 'ZData', NaN, 'UData', NaN, 'VData', NaN, 'WData', NaN)
else
    set(h, 'XData', P(:,1), 'YData', P(:,2), 'ZData', P(:,3), ...
        'UData', A(:,1), 'VData', A(:,2), 'WData', A(:,3))
end
end

function [x, w] = gaussLegendre(n)
% Gauss-Legendre nodes and weights on [-1, 1] (Golub-Welsch)
k = 1:n-1;
beta = k ./ sqrt(4*k.^2 - 1);
[V, D] = eig(diag(beta, 1) + diag(beta, -1));
[x, idx] = sort(diag(D));
w = 2 * V(1, idx).'.^2;
end

function s = sciTeX(x)
% x in LaTeX scientific notation, e.g. 3\times10^{-17}
if x == 0
    s = '0';
else
    e = floor(log10(x));
    s = [sprintf('%.0f', x/10^e) '\times10^{' sprintf('%d', e) '}'];
end
end
