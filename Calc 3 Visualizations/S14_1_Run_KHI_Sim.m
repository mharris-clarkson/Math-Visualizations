%% Kelvin-Helmholtz Instability: Nonlinear Double-Jet Simulation
%
% Solves the 2D nonlinear vorticity-streamfunction equations:
%
%   d(omega)/dt + u * d(omega)/dx + v * d(omega)/dy = nu * Laplacian(omega)
%   Laplacian(psi) = -omega
%   u = d(psi)/dy,   v = -d(psi)/dx
%
% Numerical scheme:
%   - Spatial:   Pseudo-spectral (FFT) with 2/3-rule dealiasing
%   - Temporal:  RK4 with CFL-adaptive timestep
%   - BCs:       Doubly periodic (required by spectral method)
%
% Reference: https://eng.libretexts.org/Bookshelves/Civil_Engineering/
%            All_Things_Flow_-_Fluid_Mechanics_for_the_Natural_Sciences_(Smyth)/
%            07%3A_Vortices/7.02%3A_Vortex_dynamics_in_a_homogeneous%2C_inviscid_fluid

clc; clear; close all;


%% =========================================================================
%  PARAMETERS
%  =========================================================================

% --- Grid ---
Nx = 180;  Ny = 180;   % Grid points (180 is suboptimal for FFT but keeps file <50 MB)
Lx = 10;   Ly = 10;    % Domain size

% --- Time ---
dt_max          = 0.25; % Maximum allowed timestep
tmax            = 30;   % End time
T_plot_and_save = 0.5;  % Output interval (plots + saves)

% --- Flow ---
U0 = 2;             % Peak jet velocity
Re = 500 * 1.25;    % Reynolds number (Re ~500–625 captures both KHI and vortex roll-up)
nu = 1 / Re;        % Kinematic viscosity

% --- Jet geometry ---
y0    = Ly / 4;     % Jet centerline offset from y=0 (symmetric pair)
n     = 1;          % Number of KH wavelengths in domain
k0    = 2*pi*n/Lx;  % Streamwise wavenumber of fastest-growing mode
delta = 0.01 / k0;  % Shear-layer thickness (thin -> fast KHI onset)

% --- Initial perturbation ---
amp = 1e-3;         % Amplitude of vortex-sheet perturbation

% --- I/O ---
save_data = false;
plot_data = true;
filename  = 'KH_data.mat';


%% =========================================================================
%  GRID
%  =========================================================================

x = linspace(0,  Lx,    Nx+1);  x(end) = [];   % Periodic: drop repeated endpoint
y = linspace(-Ly/2, Ly/2, Ny+1);  y(end) = [];
[X, Y] = meshgrid(x, y);


%% =========================================================================
%  WAVENUMBERS
%  =========================================================================

kx = (2*pi/Lx) * [0:Nx/2-1, -Nx/2:-1];
ky = (2*pi/Ly) * [0:Ny/2-1, -Ny/2:-1];
[KX, KY] = meshgrid(kx, ky);

K2      = KX.^2 + KY.^2;
K2(1,1) = 1;   % Avoid division by zero at the zero mode


%% =========================================================================
%  INITIAL CONDITIONS
%  =========================================================================

% Base flow: symmetric pair of hyperbolic-tangent shear layers
psi_base = U0 * delta * sign(Y) .* ...
           ( log(cosh((y0 - abs(Y)) / delta)) - log(cosh(y0 / delta)) );

% Perturbation: fastest-growing KH mode (Gaussian cross-stream envelope)
psi_pert = amp * cos(k0 * X) .* exp(-(Y / delta).^2);

% Total streamfunction
psi = psi_base + psi_pert;

% Initial vorticity in spectral space: omega_hat = -K^2 * psi_hat
omega      = -K2 .* fft2(psi);
omega(1,1) = 0;   % Zero mean vorticity

% Velocity (used for CFL at first step)
psi_hat    = -omega ./ K2;
psi_hat(1,1) = 0;
u = real(ifft2( 1i*KY .* psi_hat));
v = real(ifft2(-1i*KX .* psi_hat));


%% =========================================================================
%  DEALIASING MASK (2/3 rule)
%  =========================================================================

kx_cut  = floor(Nx/3);
ky_cut  = floor(Ny/3);
dealias = ones(Ny, Nx);
dealias(ky_cut+1 : end-ky_cut, :) = 0;
dealias(:, kx_cut+1 : end-kx_cut) = 0;


%% =========================================================================
%  STORAGE ALLOCATION
%  =========================================================================

if save_data
    num_snapshots = round(tmax / T_plot_and_save);
    U_store    = zeros(Ny, Nx, num_snapshots);
    V_store    = zeros(Ny, Nx, num_snapshots);
    VORT_store = zeros(Ny, Nx, num_snapshots);
    T_store    = zeros(1,  num_snapshots);
    snap_idx   = 1;
end


%% =========================================================================
%  TIME LOOP
%  =========================================================================

t      = 0;
step   = 0;
t_next = T_plot_and_save;

figure('Position', [100, 100, 900, 400])

while t <= tmax

    step = step + 1;

    % --- CFL-adaptive timestep ---
    dx = x(2) - x(1);
    dy = y(2) - y(1);
    dt = min([ 0.5*dx/max(abs(u(:))), ...
               0.5*dy/max(abs(v(:))), ...
               dt_max ]);

    % Snap to output time to align saves/plots exactly
    if t + dt > t_next
        dt = t_next - t;
    end

    % --- RK4 integration ---
    omega = rk4_step(omega, u, v, K2, KX, KY, dealias, nu, dt);
    t = t + dt;

    % --- Output at scheduled times ---
    if t >= t_next

        % Recover physical fields from updated vorticity
        psi_hat    = -omega ./ K2;
        psi_hat(1,1) = 0;
        u    = real(ifft2( 1i*KY .* psi_hat));
        v    = real(ifft2(-1i*KX .* psi_hat));
        vort = real(ifft2(omega));
        vel  = sqrt(u.^2 + v.^2);

        % Save snapshot
        if save_data
            U_store   (:,:,snap_idx) = u;
            V_store   (:,:,snap_idx) = v;
            VORT_store(:,:,snap_idx) = vort;
            T_store   (snap_idx)     = t;
            save(filename, 'x','y','U_store','V_store','VORT_store','T_store', '-v7.3');
            fprintf('Saved snapshot %d at t = %.2f\n', snap_idx, t);
            snap_idx = snap_idx + 1;
        end

        % Plot
        if plot_data
            plot_fields(x, y, vel, u, v, vort, t)
        end

        t_next = t_next + T_plot_and_save;
    end

    fprintf('Step %4d | t = %7.4f | dt = %.5f\n', step, t, dt);
end

% Final save
if save_data
    save(filename, 'x','y','U_store','V_store','VORT_store','T_store', '-v7.3');
end


%% =========================================================================
%  LOCAL FUNCTIONS
%  =========================================================================

function omega_new = rk4_step(omega0, u, v, K2, KX, KY, dealias, nu, dt)
%RK4_STEP  One RK4 step for the spectral vorticity equation.
%
%  All fields are in spectral space except u and v (physical, used only to
%  seed the first velocity evaluation; subsequent stages recompute from psi).

    k = zeros(size(omega0), 'like', omega0);  % preallocate stage array (single slot, reused)
    k_all = zeros([size(omega0), 4]);

    w = omega0;
    for s = 1:4

        % Stage initial condition
        switch s
            case 1,  w = omega0;
            case {2,3}, w = omega0 + 0.5 * k_all(:,:,s-1);
            case 4,  w = omega0 + k_all(:,:,s-1);
        end

        % Streamfunction and velocity
        psi_s        = -w ./ K2;
        psi_s(1,1)   = 0;
        u_s = real(ifft2( 1i*KY .* psi_s));
        v_s = real(ifft2(-1i*KX .* psi_s));

        % Vorticity gradients (physical space)
        wx = real(ifft2(1i*KX .* w));
        wy = real(ifft2(1i*KY .* w));

        % Dealiased nonlinear advection
        adv_hat = fft2(u_s.*wx + v_s.*wy) .* dealias;

        % RHS: advection + diffusion
        k_all(:,:,s) = dt * (-adv_hat - nu * K2 .* w);
    end

    omega_new = omega0 + (k_all(:,:,1) + 2*k_all(:,:,2) + 2*k_all(:,:,3) + k_all(:,:,4)) / 6;
end


function plot_fields(x, y, vel, u, v, vort, t)
%PLOT_FIELDS  Two-panel snapshot: velocity magnitude + vorticity.

    clf

    % Panel 1: velocity magnitude with quivers
    subplot(1,2,1)
    pcolor(x, y, vel);  shading flat;  axis xy equal
    cmocean('amp');  colorbar
    hold on
    stride = 16;
    quiver(x(1:stride:end), y(1:stride:end), ...
           u(1:stride:end, 1:stride:end), ...
           v(1:stride:end, 1:stride:end), 'k')
    xlim([0, x(end)]);  ylim([y(1), y(end)])
    title(sprintf('Velocity magnitude, t = %.2f', t))
    set(gca, 'FontSize', 18)

    % Panel 2: vorticity
    subplot(1,2,2)
    imagesc(x, y, vort);  axis xy equal
    cmocean('balance');  colorbar
    xlim([0, x(end)]);  ylim([y(1), y(end)])
    title('Vorticity (KH structures)')
    set(gca, 'FontSize', 18)

    drawnow
end