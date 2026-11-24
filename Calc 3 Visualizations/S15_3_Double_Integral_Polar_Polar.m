function S15_3_Double_Integral_Polar_Polar()
%% Double Integral over a Curvy Region -- Polar Riemann Wedges
% Approximates the double integral of a bump function over a circular
% leaf-shaped region with solid polar wedges (centered at (xc,yc)),
% keeping only the ones whose center lies inside the region. Companion to
% S15_3_Double_Integral_Polar_Cartesian, which approximates the same
% integral with axis-aligned prisms instead -- both share
% DoubleIntegralCurvyEngine. Buttons hide/show the center dots and show
% the surface f only over the region.
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

%% User parameters for math objects
xc = -1; yc = 0;   % polar center

r2 = @(x,y) x.^2 + y.^2;
f  = @(x,y) 2*exp(1)*exp(1 ./ (r2(x,y)-1 + (r2(x,y)>=1)));
f  = @(x,y) (r2(x,y)<1) .* f(x,y);

N0 = 1; Nmax = 25;   % radial bins (angular bins = 4x radial bins)
nFace = 8;           % arc resolution per wedge edge for the largest wedges
                     % (small wedges use fewer points, see buildCells)

%% Region boundary: circle centered at (xc,yc), passing through the origin
t = linspace(0, 2*pi, 400);
Xc = cos(t) + xc;
Yc = sin(t) + yc;
posX     = Xc >= 0;
Xc(posX) = linspace(0, max(Xc), nnz(posX));
Xb = Xc - Xc(1);
Yb = Yc - Yc(1);
Xb(end+1) = Xb(1);
Yb(end+1) = Yb(1);

Rmax      = max(hypot(Xb-xc, Yb-yc));
thetaLims = [0, 2*pi];

pad   = 0.25;
xlims = [min(Xb)-pad, max(Xb)+pad];
ylims = [min(Yb)-pad, max(Yb)+pad];

% Which wedge centers lie in the region, remembered for every N_r already
% visited (inpolygon is the slowest step of a slider move)
insideCache = cell(1, Nmax);

%% Run the shared engine
run('setup.m')
DoubleIntegralCurvyEngine('Polar Riemann Approximation', ...
    f, Xb, Yb, xlims, ylims, [150, 75], N0, Nmax, '$N_r = $', @buildCells, ...
    'DotsButton', true, 'MaskButton', true)

%% Grid-specific cell builder: polar wedges, fully vectorized (no
% per-cell loop -- the original looped over every candidate wedge; here
% every inside wedge's polygon is built with one shot of array math).
function [layers, X, Y, Z, titleStr] = buildCells(Nr, exactIntegral)
    Ntheta = 4*Nr;
    dr  = Rmax/Nr;
    dth = diff(thetaLims)/Ntheta;

    r  = ((1:Nr)-0.5)*dr;
    th = thetaLims(1) + ((1:Ntheta)-0.5)*dth;
    [RR, TT] = meshgrid(r, th);        % Ntheta x Nr: rows=theta, cols=radius
    Xs = xc + RR.*cos(TT);
    Ys = yc + RR.*sin(TT);
    Zs = f(Xs, Ys);

    if isempty(insideCache{Nr})
        insideCache{Nr} = find(inpolygon(Xs(:), Ys(:), Xb, Yb));
    end
    linIdx      = insideCache{Nr};
    [jIdx, iIdx] = ind2sub(size(RR), linIdx);   % jIdx=theta bin, iIdx=radial bin
    n = numel(linIdx);

    X = Xs(linIdx); Y = Ys(linIdx); Z = Zs(linIdx);
    integral_approx = sum(Z.*RR(linIdx))*dr*dth;

    % Each wedge's top face is a 2*nArc-gon: an inner arc at rIn followed
    % by an outer arc at rOut (reversed), both spanning [th1,th1+dth].
    % (Named rIn/rOut, not r1/r2: this is a nested function, so 'r2' here
    % would overwrite the r2 function handle of the main function.)
    rIn  = (iIdx-1)*dr;
    rOut = iIdx*dr;
    th1 = thetaLims(1) + (jIdx-1)*dth;
    % Points per arc: about one per 6 degrees of arc, between 2 and nFace
    % (a tiny wedge looks the same with 2 points as with 8, at a quarter
    % of the vertices)
    nArc  = min(nFace, max(2, ceil(rad2deg(dth)/6) + 1));
    thLoc = th1 + dth*linspace(0, 1, nArc);    % n x nArc

    Xin  = xc + rIn.*cos(thLoc);   Yin  = yc + rIn.*sin(thLoc);
    Xout = xc + rOut.*cos(thLoc);  Yout = yc + rOut.*sin(thLoc);
    Xp = [Xin, fliplr(Xout)];                  % n x 2*nArc
    Yp = [Yin, fliplr(Yout)];
    Zp = repmat(Z, 1, 2*nArc);

    % Solid wedges: the same outline at the top (height Z) and at the
    % bottom (z = 0), joined by side walls, as in the Cartesian prisms
    m = 2*nArc;                                % outline points per wedge
    M = m*n;                                   % top vertices in total
    Vtop = [reshape(Xp.', [], 1), reshape(Yp.', [], 1), reshape(Zp.', [], 1)];
    V    = [Vtop; Vtop(:,1:2), zeros(M, 1)];   % rows M+1..2M: bottom copy
    topFaces    = reshape(1:M, m, n).';
    bottomFaces = topFaces + M;
    % Side wall between outline points j and j+1 (wrapping to 1) of each wedge
    a = (0:n-1).'*m + (1:m);                   % n x m
    b = (0:n-1).'*m + [2:m, 1];
    sideFaces = [a(:), b(:), b(:) + M, a(:) + M];
    layers = struct('Faces',     {bottomFaces, sideFaces, topFaces}, ...
                    'Vertices',  {V, V, V}, ...
                    'FaceAlpha', {0.25, 0.6, 0.85});

    % splitlines: a newline inside one LaTeX string does not start a new
    % line; '$|$' because a bare | in LaTeX text mode prints as a dash
    titleStr = splitlines(sprintf(['Polar Riemann Approximation\n' ...
        'Radial bins = %d   Wedges inside = %d\nApprox = %.6f   $|$   Exact = %.6f'], ...
        Nr, n, integral_approx, exactIntegral));
end

end