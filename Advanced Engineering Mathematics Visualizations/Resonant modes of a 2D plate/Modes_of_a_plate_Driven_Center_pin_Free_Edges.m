%% =========================================================================
%  CENTRE-DRIVEN CHLADNI PLATE: free edges + driver mass at the centre
%
%  PDE:     D*biharmonic(w) + rho*T*w_tt = 0
%  Edges:   FREE (natural BCs of the plate energy)
%  Centre:  point mass  mu*(rho*T*L^2)  (bolt / washer / rested plate mass)
%
%  Two symmetry classes of the square plate are computed exactly:
%    A1 : symmetric about both midlines AND both diagonals.  Nonzero centre
%         motion, so the driver excites these directly (and the driver mass
%         shrinks the inner nodal ring around the bolt).
%    B1 : symmetric about the midlines, ANTI-symmetric about the diagonals.
%         Nodal diagonals through the centre, zero centre motion: the driver
%         mass does not touch them.  A perfectly centred point drive does not
%         excite them, but an imperfect/off-centre mount does -- your 2.61 kHz
%         diamond-lattice photo is one of these.
%
%  Rayleigh-Ritz, tensor Legendre basis w = sum c_ij P_i(x) P_j(y):
%        K c = omega^2 (M + mu*mPlate*c0*c0') c
%% =========================================================================

close all
clear
clc
setup
%% -- physical parameters --------------------------------------------------

L   = 0.24;          % side [m]
T   = 0.0005;        % thickness [m]
E   = 70e9;
nu  = 0.33;
rho = 2700;
mu  = 0.0387; % Percent of weight on center point (Pin vs full plate)

D      = E*T^3/(12*(1-nu^2));
m      = rho*T;
mPlate = m*L^2;   

%% -- basis / quadrature ---------------------------------------------------

P = 30;                        % Legendre polynomials per direction
Q = P + 2;
[xi, wq] = gauss_legendre(Q);
[B0, B1, B2] = legendre_basis(P, xi);

s  = 2/L;
Wq = diag(wq);
A  = @(Ba,a,Bb,b) (L/2) * s^(a+b) * (Ba.' * Wq * Bb);

A00 = A(B0,0,B0,0);  A02 = A(B0,0,B2,2);  A20 = A(B2,2,B0,0);
A11 = A(B1,1,B1,1);  A22 = A(B2,2,B2,2);

% unknown ordering: index (i-1)*P + j  <->  P_i(x) P_j(y)
Kfull = D * ( kron(A00,A22) + kron(A22,A00) ...
            + nu*( kron(A02,A20) + kron(A20,A02) ) ...
            + 2*(1-nu)*kron(A11,A11) );
Mfull = m * kron(A00,A00);

[b0c,~,~] = legendre_basis(P, 0);
c0 = kron(b0c, b0c).';                     % basis values at the plate center

%% -- symmetry-adapted subspaces ------------------------------------------

SA = sym_subspace(P, +1);                  % A1
SB = sym_subspace(P, -1);                  % B1

Ka = SA.'*Kfull*SA;  Ka = (Ka+Ka.')/2;   Ma = SA.'*Mfull*SA;  Ma = (Ma+Ma.')/2;
Kb = SB.'*Kfull*SB;  Kb = (Kb+Kb.')/2;   Mb = SB.'*Mfull*SB;  Mb = (Mb+Mb.')/2;
csA = SA.'*c0;       csB = SB.'*c0;        % csB is ~0: no centre motion


%% -- final eigenproblems --------------------------------------------------

[freqA, UA, driveA] = class_modes(Ka, Ma + mu*mPlate*(csA*csA.'), csA, 40);
[freqB, UB, driveB] = class_modes(Kb, Mb + mu*mPlate*(csB*csB.'), csB, 40);

%% -- evaluate mode shapes on a square grid ---------------------------------------

N  = 241;
x  = linspace(0, L, N);
[Bp, ~, ~] = legendre_basis(P, (2*x/L - 1).');

PhiA = zeros(N,N,size(UA,2));
for k = 1:size(UA,2)
    C = reshape(SA*UA(:,k), P, P);   Wk = Bp*C*Bp.';   PhiA(:,:,k) = Wk/max(abs(Wk(:)));
end
PhiB = zeros(N,N,size(UB,2));
for k = 1:size(UB,2)
    C = reshape(SB*UB(:,k), P, P);   Wk = Bp*C*Bp.';   PhiB(:,:,k) = Wk/max(abs(Wk(:)));
end

%% -- SAND-STYLE DISPLAY ---------------------------------------------------

sigma = 0.05;                        % sand "width" around nodal lines
sand  = @(W) exp(-(W/sigma).^2);



figure()
for k = 1:30
    subplot(5,6,k)
    imagesc(x, x, sand(PhiA(:,:,k))); axis xy equal tight off; colormap(gray)
    title(sprintf('A1 #%d | %.0f Hz', k, freqA(k)), 'FontSize', 8)
end
sgtitle('A1 modes (centre-driven), sand view')

figure()
for k = 1:30
    subplot(5,6,k)
    imagesc(x, x, sand(PhiB(:,:,k))); axis xy equal tight off; colormap(gray)
    title(sprintf('B1 #%d | %.0f Hz', k, freqB(k)), 'FontSize', 8)
end
sgtitle('B1 modes (nodal diagonals, no centre motion), sand view')



%% loop through plots
% figure
% for k = 1:30
%          imagesc(x, x, sand(PhiA(:,:,k))); axis xy equal tight off; colormap(gray)
%         title(sprintf('A1 #%d | %.0f Hz', k, freqA(k)), 'FontSize', 8)
%         pause
% end
% for k = 1:30
%     imagesc(x, x, sand(PhiB(:,:,k))); axis xy equal tight off; colormap(gray)
%     title(sprintf('B1 #%d | %.0f Hz', k, freqB(k)), 'FontSize', 8)
%     pause
% end

%% Animation for a mode
% Pick mode
mode_number = 4;
A_or_B = "A";

% playback params
playbackHz  = 0.5;
duration    = 60; % Time in s

% Process choice
if upper(A_or_B) == "A"
    modeShape = PhiA(:,:,mode_number);
    modeFrequency = freqA(mode_number);
else
    modeShape = PhiB(:,:,mode_number);
    modeFrequency = freqB(mode_number);
end

% Initial plot
figure
ax = axes;
% plot wave object
ani_wave_plot = surf(ax, x, x, modeShape);
view(-20,25)
set(gca, 'CLim', [-1 1])
set(gca, 'ZLim', [-1.5 1.5])
shading interp
colormap(ax, cmocean('balance'))



% Animation
t0 = tic;
while ishandle(ani_wave_plot) && toc(t0) < duration
    phase = 2*pi*playbackHz*toc(t0);
    set(ani_wave_plot, 'ZData', modeShape*cos(phase))
    title(ax, sprintf('mode %d | %.0f Hz (shown at %.1f Hz)', ...
        mode_number, modeFrequency, playbackHz))
    drawnow limitrate
end
%% =========================================================================
%  LOCAL FUNCTIONS
%% =========================================================================

function S = sym_subspace(P, sgn)
% x-even, y-even polynomial products, symmetric (sgn=+1) or antisymmetric
% (sgn=-1) under x<->y
    ev = 1:2:P;
    cols = [];
    for a = 1:numel(ev)
        for b = a:numel(ev)
            if a == b && sgn < 0, continue, end
            c = zeros(P*P,1);
            c((ev(a)-1)*P + ev(b)) = 1;
            c((ev(b)-1)*P + ev(a)) = sgn;
            if a == b, c((ev(a)-1)*P + ev(a)) = 1; end
            cols = [cols, c/norm(c)];      %#ok<AGROW>
        end
    end
    S = cols;
end

function f = class_freqs(K, M, n)
    lam = sort(real(eig(K, M)));
    lam = lam(lam > 1);
    f = sqrt(lam(1:n)) / (2*pi);
end

function [f, U, drive] = class_modes(K, M, cs, n)
    [U, Lam] = eig(K, M);
    lam = real(diag(Lam));
    [lam, ix] = sort(lam);
    U = U(:,ix);
    keep = lam > 1;
    lam = lam(keep);  U = U(:,keep);
    lam = lam(1:n);   U = U(:,1:n);
    for k = 1:n
        U(:,k) = U(:,k) / sqrt(U(:,k).' * M * U(:,k));
    end
    f = 5/3*sqrt(lam)/(2*pi);
    drive = ((cs.'*U).^2).' ./ lam;
end

function r = pick(fa, fb, cls, idx)
    r = zeros(numel(idx),1);
    for j = 1:numel(idx)
        if cls(j) == 'A', r(j) = fa(idx(j)); else, r(j) = fb(idx(j)); end
    end
end

function [x, w] = gauss_legendre(n)
    k    = 1:n-1;
    beta = k ./ sqrt(4*k.^2 - 1);
    J    = diag(beta,1) + diag(beta,-1);
    [Vj, Dj] = eig(J);
    [x, ix]  = sort(diag(Dj));
    w = 2 * (Vj(1,ix).^2).';
end

function [B0, B1, B2] = legendre_basis(P, xi)
% Legendre P_0..P_{P-1} and 1st/2nd derivatives at points xi (one row each)
    xi = xi(:);
    nx = numel(xi);
    B0 = zeros(nx,P);  B1 = zeros(nx,P);  B2 = zeros(nx,P);
    B0(:,1) = 1;
    if P > 1, B0(:,2) = xi; B1(:,2) = 1; end
    for n = 1:P-2
        B0(:,n+2) = ((2*n+1)*xi.*B0(:,n+1) - n*B0(:,n)) / (n+1);
        B1(:,n+2) = B1(:,n) + (2*n+1)*B0(:,n+1);
        B2(:,n+2) = B2(:,n) + (2*n+1)*B1(:,n+1);
    end
end