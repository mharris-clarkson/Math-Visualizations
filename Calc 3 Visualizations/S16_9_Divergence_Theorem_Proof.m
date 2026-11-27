function S16_9_Divergence_Theorem_Proof()
%% Why the divergence theorem is true: the interior faces cancel.
%  The box E is cut into n^3 small boxes, drawn pulled apart. Every face of
%  every small box is colored by its outward flux of F, with an arrow
%  showing that flux (pointing out of the box when positive, in when
%  negative).
%    - Every interior face belongs to two boxes with opposite outward
%      normals, so its flux is counted twice with opposite signs: the two
%      copies have opposite colors and the same arrow (what leaves one box
%      enters its neighbor). They add to 0.
%    - So the sum of the fluxes out of all the small boxes is the flux
%      through the boundary faces only: iint_S F . dS.
%    - Each small box's flux is about div F(center) * Delta V, so the same
%      sum is a Riemann sum for iiint_E div F dV.
%  Controls: n (boxes per side), the gap between the boxes, and a button
%  that cancels (fades out) the interior faces, leaving the boundary.
%
%% Author Info
%
% Written by Dr Matthew Harris an assistant professor at
% Clarkson University, for MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
F1 = @(x,y,z) x.^3 - y;        % vector field F = <F1, F2, F3>
F2 = @(x,y,z) y.^2 - z;
F3 = @(x,y,z) z.^2 - x;
Ebox = [-1 1; -1 1; 0 1];      % the solid E: [xmin xmax; ymin ymax; zmin zmax]

n0     = 1;      % starting boxes per side
nMax   = 10;
gap0   = 0;      % starting gap (fraction of the distance from the centre)
nQuad  = 6;      % Gauss-Legendre points per direction on each face
arrowFrac  = 0.9;    % longest arrow as a fraction of the box size
fadedAlpha = 0.06;   % interior faces once they cancel

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Divergence Theorem: Interior Faces Cancel', 1);
ax  = app.ax(1);
view(ax, -38, 24)
axis(ax, 'equal')

%% Optional math functions for plot computations
Fc   = {F1, F2, F3};
divF = @(x,y,z) Diffx_f(F1,x,y,z) + Diffy_f(F2,x,y,z) + Diffz_f(F3,x,y,z);
[gq, gw] = gaussLegendre(nQuad);
Ecenter  = mean(Ebox, 2).';

% Every face of every small box: corners, outward normal, flux, owner box
    function D = buildFaces(n)
        e = {linspace(Ebox(1,1), Ebox(1,2), n+1), ...
             linspace(Ebox(2,1), Ebox(2,2), n+1), ...
             linspace(Ebox(3,1), Ebox(3,2), n+1)};
        h  = (Ebox(:,2) - Ebox(:,1)).'/n;
        nf = 6*n^3;
        D.corners  = zeros(4, 3, nf);
        D.center   = zeros(nf, 3);
        D.normal   = zeros(nf, 3);
        D.flux     = zeros(nf, 1);
        D.interior = false(nf, 1);
        D.pairKey  = zeros(nf, 1);
        D.box      = zeros(nf, 1);
        D.boxCenter = zeros(n^3, 3);
        D.h = h;
        q = 0;  b = 0;
        for i = 1:n
            for j = 1:n
                for k = 1:n
                    b  = b + 1;
                    idx = [i j k];
                    lo = [e{1}(i) e{2}(j) e{3}(k)];
                    hi = lo + h;
                    D.boxCenter(b,:) = (lo + hi)/2;
                    for a = 1:3
                        oth = setdiff(1:3, a);
                        for s = [-1 1]
                            q = q + 1;
                            fixed = lo(a)*(s < 0) + hi(a)*(s > 0);
                            plane = idx(a) + (s > 0);          % index of the face's plane
                            % corners (counterclockwise in the two other axes)
                            C = zeros(4, 3);
                            C(:, a) = fixed;
                            C(:, oth(1)) = [lo(oth(1)) hi(oth(1)) hi(oth(1)) lo(oth(1))];
                            C(:, oth(2)) = [lo(oth(2)) lo(oth(2)) hi(oth(2)) hi(oth(2))];
                            D.corners(:,:,q) = C;
                            D.center(q,:) = mean(C, 1);
                            D.normal(q, a) = s;
                            % outward flux: s * double integral of F_a over the face
                            [U, V] = meshgrid(lo(oth(1)) + (gq+1)/2*h(oth(1)), lo(oth(2)) + (gq+1)/2*h(oth(2)));
                            P = zeros(numel(U), 3);
                            P(:, a) = fixed;  P(:, oth(1)) = U(:);  P(:, oth(2)) = V(:);
                            W = gw(:)*gw(:).';
                            D.flux(q) = s * sum(W(:) .* Fc{a}(P(:,1), P(:,2), P(:,3))) * h(oth(1))*h(oth(2))/4;
                            D.interior(q) = plane > 1 && plane < n + 1;
                            ij = idx(oth);
                            D.pairKey(q) = sub2ind([3, n+1, n, n], a, plane, ij(1), ij(2));
                            D.box(q) = b;
                        end
                    end
                end
            end
        end
    end

%% Precompute math for updates
volInt = integral3(divF, Ebox(1,1), Ebox(1,2), Ebox(2,1), Ebox(2,2), Ebox(3,1), Ebox(3,2), ...
    'AbsTol', 1e-10, 'RelTol', 1e-10);
D = buildFaces(n0);

%% Make the initial plots
hInt = patch(ax, 'Faces', [], 'Vertices', zeros(0,3), 'FaceColor', 'flat', ...
    'EdgeColor', [0.3 0.3 0.3], 'FaceAlpha', 0.85, 'LineWidth', 0.5);
hBnd = patch(ax, 'Faces', [], 'Vertices', zeros(0,3), 'FaceColor', 'flat', ...
    'EdgeColor', 'k', 'FaceAlpha', 0.85, 'LineWidth', 1);
hArrInt = quiver3(ax, NaN, NaN, NaN, NaN, NaN, NaN, 0, 'Color', [0.15 0.15 0.15], ...
    'LineWidth', 2, 'MaxHeadSize', 0.8);
hArrBnd = quiver3(ax, NaN, NaN, NaN, NaN, NaN, NaN, 0, 'Color', 'k', ...
    'LineWidth', 2.2, 'MaxHeadSize', 0.8);
colormap(ax, Pretty_Colormap('balance'))
cb = colorbar(ax);
cb.Label.String = 'outward flux of $\mathbf{F}$ through the face';
cb.Label.Interpreter = 'latex';
cb.Label.FontSize = ax.FontSize;
xl = Ebox(1,:) + [-1 1]*0.9*diff(Ebox(1,:));
yl = Ebox(2,:) + [-1 1]*0.9*diff(Ebox(2,:));
zl = Ebox(3,:) + [-1 1]*0.9*diff(Ebox(3,:));
xlim(ax, xl); ylim(ax, yl); zlim(ax, zl)

%% Build UI
NumControls = 3;
sN = app.addControl('slider', 'Boxes per side $n = $', 1, NumControls, @changeN, ...
    'Default', n0, 'Min', 1, 'Max', nMax, 'Number_format', '%d', 'Step', 1, 'colOrRow', 'row');
sGap = app.addControl('slider', 'Gap $= $', 2, NumControls, @(~,~) drawGeometry(), ...
    'Default', gap0, 'Min', 0, 'Max', 1, 'colOrRow', 'row');
btnCancel = app.addControl('button', '', 3, NumControls, @(~,~) drawStyle(), ...
    'ColorChange', true, 'colOrRow', 'row', ...
    'Toggle', ["Cancel interior faces", "Show interior faces"]);

% Room above the plot for the three-line title
ax.Position(4) = ax.Position(4) - 0.08;

drawAll()

%% Functions for UI elements
    function changeN(~, ~)
        n = round(sN.Value);
        if size(D.boxCenter, 1) ~= n^3
            D = buildFaces(n);
            drawAll()
        end
    end

    function drawAll()
        clim(ax, max(abs(D.flux))*[-1 1] + [-eps eps]);
        drawGeometry()
        drawStyle()
    end

% Pull the boxes apart and place the faces and arrows
    function drawGeometry()
        gap   = sGap.Value;
        shift = gap * (D.boxCenter(D.box,:) - Ecenter);       % one shift per face
        nf    = numel(D.flux);
        V     = reshape(permute(D.corners, [1 3 2]), 4*nf, 3) + repelem(shift, 4, 1);
        Fall  = reshape(1:4*nf, 4, nf).';
        isInt = D.interior;
        set(hInt, 'Faces', [], 'Vertices', V, 'Faces', Fall(isInt,:), 'FaceVertexCData', D.flux(isInt));
        set(hBnd, 'Faces', [], 'Vertices', V, 'Faces', Fall(~isInt,:), 'FaceVertexCData', D.flux(~isInt));

        % Arrow = flux times the outward normal: out of the box if positive
        L   = arrowFrac*min(D.h) / max(max(abs(D.flux)), eps);
        P   = D.center + shift;
        A   = L * D.flux .* D.normal;
        P   = P - A/2;                                           % centred on the face
        setQuiver(hArrInt, P(isInt,:), A(isInt,:));
        setQuiver(hArrBnd, P(~isInt,:), A(~isInt,:));
        updateTitle()
    end

% Interior faces visible, or faded out once they cancel
    function drawStyle()
        cancelled = logical(btnCancel.Value);
        if cancelled
            set(hInt, 'FaceAlpha', fadedAlpha, 'EdgeAlpha', 0.15)
            hArrInt.Visible = 'off';
        else
            set(hInt, 'FaceAlpha', 0.85, 'EdgeAlpha', 1)
            hArrInt.Visible = 'on';
        end
        updateTitle()
    end

%% Main Draw update function.
    function updateTitle()
        n        = round(nthroot(size(D.boxCenter, 1), 3));
        total    = sum(D.flux);
        bndFlux  = sum(D.flux(~D.interior));
        keys     = D.pairKey(D.interior);
        pairSums = accumarray(findgroups(keys), D.flux(D.interior));
        nPairs   = numel(pairSums);
        maxPair  = max([0; abs(pairSums)]);

        boxFlux  = accumarray(D.box, D.flux);
        [~, bk]  = max(abs(boxFlux));
        c        = D.boxCenter(bk,:);
        divBox   = divF(c(1), c(2), c(3)) * prod(D.h);

        line1 = sprintf('$%d^3 = %d$ boxes: sum of all their outward fluxes $= %.4f$', n, n^3, total);
        if nPairs == 0
            line2 = 'One box: all its faces are on the boundary $S$ (increase $n$ to see faces cancel)';
        elseif btnCancel.Value
            line2 = sprintf(['Interior faces cancel (%d pairs, largest pair sum $%s$), ' ...
                'leaving the boundary: $\\int\\!\\!\\int_S \\mathbf{F}\\cdot d\\mathbf{S} = %.4f$'], nPairs, sciTeX(maxPair), bndFlux);
        else
            line2 = sprintf(['%d interior faces are each counted twice, with opposite normals ' ...
                '(opposite colors, same arrow)'], nPairs);
        end
        line3 = sprintf(['$\\int\\!\\!\\int\\!\\!\\int_E \\nabla\\cdot\\mathbf{F}\\,dV = %.4f$ \\quad ' ...
            'one box: flux $%.4f \\approx \\nabla\\cdot\\mathbf{F}(\\mathrm{center})\\,\\Delta V = %.4f$'], ...
            volInt, boxFlux(bk), divBox);
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
