function S15_3_Double_Integral_Polar_Polar()
%% Double Integral over a Curvy Region -- Polar Riemann Wedges
% Approximates the double integral of a bump function over a circular
% leaf-shaped region with polar wedges (centered at (xc,yc)), keeping
% only the ones whose center lies inside the region. Companion to
% L20_S15_3_Double_Integral_Polar_Cartesian, which approximates the same
% integral with axis-aligned prisms instead -- both share
% DoubleIntegralCurvyEngine.
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

N0 = 1; Nmax = 100;   % radial bins (angular bins = 4x radial bins)
nFace = 8;           % arc resolution per wedge edge

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

%% Run the shared engine
run('setup.m')
DoubleIntegralCurvyEngine('Polar Riemann Approximation', ...
    f, Xb, Yb, xlims, ylims, [150, 75], N0, Nmax, '$N_r = $', @buildCells)

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

    inside      = inpolygon(Xs(:), Ys(:), Xb, Yb);
    linIdx      = find(inside);
    [jIdx, iIdx] = ind2sub(size(RR), linIdx);   % jIdx=theta bin, iIdx=radial bin
    n = numel(linIdx);

    X = Xs(linIdx); Y = Ys(linIdx); Z = Zs(linIdx);
    integral_approx = sum(Z.*RR(linIdx))*dr*dth;

    % Each wedge's top face is a 2*nFace-gon: an inner arc at r1 followed
    % by an outer arc at r2 (reversed), both spanning [th1,th1+dth].
    r1  = (iIdx-1)*dr;
    r2  = iIdx*dr;
    th1 = thetaLims(1) + (jIdx-1)*dth;
    thLoc = th1 + dth*linspace(0, 1, nFace);   % n x nFace

    Xin  = xc + r1.*cos(thLoc);  Yin  = yc + r1.*sin(thLoc);
    Xout = xc + r2.*cos(thLoc);  Yout = yc + r2.*sin(thLoc);
    Xp = [Xin, fliplr(Xout)];                  % n x 2*nFace
    Yp = [Yin, fliplr(Yout)];
    Zp = repmat(Z, 1, 2*nFace);

    V = [reshape(Xp.', [], 1), reshape(Yp.', [], 1), reshape(Zp.', [], 1)];
    Faces = reshape(1:2*nFace*n, 2*nFace, n).';
    layers = struct('Faces', Faces, 'Vertices', V, 'FaceAlpha', 0.85);

    titleStr = sprintf(['Polar Riemann Approximation\n' ...
        'Radial bins = %d   Wedges inside = %d\nApprox = %.6f   |   Exact = %.6f'], ...
        Nr, n, integral_approx, exactIntegral);
end

end