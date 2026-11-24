function Wave_Equation_Fourier()
%% Solves the 1D wave equation u_tt = c^2*u_xx on [0,L] with a Fourier
%  series and plots truncated (partial sum) solutions. The initial
%  velocity is always zero: u_t(x,0) = 0, so only u(x,0) = f(x) is chosen.
%
%  Each end has its own boundary condition (Dirichlet u = 0 or Neumann
%  u_x = 0), which gives four families of eigenfunctions phi_n(x):
%
%     x = 0      x = L      phi_n(x)                       k_n
%     Dirichlet  Dirichlet  sin(k_n x)                     n*pi/L
%     Neumann    Dirichlet  cos(k_n x)                     (n-1/2)*pi/L
%     Dirichlet  Neumann    sin(k_n x)                     (n-1/2)*pi/L
%     Neumann    Neumann    cos(k_n x), plus constant a_0  n*pi/L
%
%  With u_t(x,0) = 0 every mode oscillates as cos(omega_n*t), omega_n = c*k_n:
%
%  u(x,t) = [a_0] + sum_n c_n phi_n(x) cos(c*k_n*t)
%
%  (The N-N constant mode a_0 has zero initial velocity so it stays fixed.)
%
%  Controls:
%     - Initial condition button (cycles through the list ICs below)
%     - Left and right boundary condition toggles (independent)
%     - Single mode / sum of modes toggle. Single mode plots only the n-th
%       mode with coefficient 1 (not the Fourier coefficient).
%     - Slider for the number of modes N (1 to Max_N). The last step stands
%       for N -> infinity and sums all Nfft modes with an inverse FFT.
%     - Slider for time t (0 to t_max). Pushing any toggle or the initial
%       condition button resets t = 0.
%
%% Author Info
%
% Written with Claude (Anthropic) for Dr Matthew Harris, assistant
% professor at Clarkson University, for MA 330: Advanced Engineering
% Mathematics.
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
L = 1;          % length of the string, domain [0, L]
c = 1;          % wave speed

% Initial conditions u(x,0) = f(x), u_t(x,0) = 0: {button label, vectorized f}
ICs = {
    'Narrow pulse', @(x) exp(-5000*(x-L/2).^2);   
    '$x(L-x)$', @(x) x.*(L-x);
    'Hat',      @(x) 1-abs(2*x/L-1);
    'Two modes',@(x) sin(pi*x/L)+0.5*sin(3*pi*x/L);
    'Constant', @(x) 1+0*x;
    '$x^2$',    @(x) x.^2
    };
IC0 = 1;        % starting initial condition

N0    = 1;      % starting number of modes
Max_N = 100;    % slider maximum; shown as N -> infinity (all Nfft modes)
t_max = 4*L/c;  % two periods of the D-D fundamental

Nx   = 3001;    % plot points
Nfft = 2^15;    % FFT samples = modes used for N -> infinity (>> Max_N)

%% ==== Below this we build the UI, compute the needed math functions for future updates and update ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('1D Wave Equation: Fourier Series Solution', 1);
title(app.ax, app.fig.Name)

%% Grids and mode shapes
x   = linspace(0, L, Nx);
n   = 1:Max_N;
nIC = size(ICs, 1);

% Family index = 1 + (left is Neumann) + 2*(right is Neumann)
%   1: D-D    2: N-D    3: D-N    4: N-N
kk     = {n*pi/L, (n-0.5)*pi/L, (n-0.5)*pi/L, n*pi/L};
isCos  = [false, true, false, true];
shift  = [0, 0.5, 0.5, 0];          % n - shift = k_n*L/pi
bcName = {'Dirichlet', 'Neumann'};

Phi   = cell(1, 4);                 % mode shapes, one column per mode
omega = cell(1, 4);
for i = 1:4
    if isCos(i)
        Phi{i} = cos(x(:)*kk{i});
    else
        Phi{i} = sin(x(:)*kk{i});
    end
    omega{i} = c*kk{i}(:);          % angular frequencies
end

%% Precompute Fourier coefficients of every IC for all four BC pairs
% f is sampled at the midpoints of Nfft cells, so every coefficient is a
% sum that two FFTs evaluate for all modes at once:
%   A_m = sum_j f_j exp(i*pi*m*(j-1/2)/M),       m = 0..M       (integer k)
%   B_m = sum_j f_j exp(i*pi*(m-1/2)*(j-1/2)/M), m = 1..M       (half integer k)
% Real parts give the cosine integrals and imaginary parts the sine ones.
M  = Nfft;
xm = ((1:M) - 0.5)*L/M;
j  = 1:M;

cf  = cell(nIC, 4);                 % coefficients c_n (length M)
a0v = zeros(1, nIC);                % N-N constant mode
fxs = cell(1, nIC);                 % f on the plot grid
for ic = 1:nIC
    fxs{ic} = ICs{ic,2}(x) + 0*x;
    [cf(ic,:), a0v(ic)] = Fourier_Coefs(ICs{ic,2});
end

%% Optional math functions for plot computations
    function [cfs, a0] = Fourier_Coefs(fun)
        fm = fun(xm) + 0*xm;
        A  = 2*M*ifft(fm, 2*M);
        A  = A(1:M+1) .* exp(1i*pi*(0:M)/(2*M));
        B  = 2*M*ifft(fm .* exp(1i*pi*(j-1)/(2*M)), 2*M);
        B  = B(1:M) .* exp(1i*pi*(j-0.5)/(2*M));
        a0  = real(A(1))/M;
        cfs = {(2/M)*imag(A(2:end)).', ...   % D-D: sin(n*pi*x/L)
               (2/M)*real(B).', ...          % N-D: cos((n-1/2)*pi*x/L)
               (2/M)*imag(B).', ...          % D-N: sin((n-1/2)*pi*x/L)
               (2/M)*real(A(2:end)).'};      % N-N: cos(n*pi*x/L)
    end

% Solution on x at time t from modes 1 to N (N <= Max_N)
    function u = Wave_Solution(ic, fam, oneMode, N, t)
        if oneMode
            if isCos(fam)
                phi = cos(kk{fam}(N)*x);
            else
                phi = sin(kk{fam}(N)*x);
            end
            u = phi * cos(omega{fam}(N)*t);
        else
            w  = cf{ic,fam}(1:N) .* cos(omega{fam}(1:N)*t);
            u  = Phi{fam}(:, 1:N) * w;
            if fam == 4
                u = u + a0v(ic);
            end
            u = u.';
        end
    end

% Solution on xm at time t from all M modes, summed with an inverse FFT
    function u = Wave_Solution_Full(ic, fam, oneMode, t)
        kf = ((1:M) - shift(fam))*pi/L;
        if oneMode
            if isCos(fam)
                u = cos(kf(M)*xm);
            else
                u = sin(kf(M)*xm);
            end
            u = u * cos(c*kf(M)*t);
            return
        end
        d = cf{ic,fam}.' .* cos(c*kf*t);
        if shift(fam) == 0
            if fam == 1
                d(M) = d(M)/2;   % last sine vector has twice the norm
            end
            g = [0, d] .* exp(1i*pi*(0:M)/(2*M));
            if fam == 4
                g(1) = a0v(ic);
            end
            Z = 2*M*ifft(g, 2*M);
            Z = Z(1:M);
        else
            h = d .* exp(1i*pi*((1:M)-0.5)/(2*M));
            Z = 2*M*ifft(h, 2*M);
            Z = Z(1:M) .* exp(1i*pi*((1:M)-1)/(2*M));
        end
        if isCos(fam)
            u = real(Z);
        else
            u = imag(Z);
        end
    end

    function u = Solve(ic, fam, oneMode, N, t)
        if N >= Max_N
            u = Wave_Solution_Full(ic, fam, oneMode, t);
        else
            u = Wave_Solution(ic, fam, oneMode, N, t);
        end
    end

% y limits for the sum of modes view: |u| <= max|f|, plus room for the
% Gibbs overshoot (up to 18% of max|f|)
yl   = cell(nIC, 4);
for ic = 1:nIC
    for fam = 1:4
        yl{ic,fam} = [-1.2,1.2]*max(abs(fxs{ic}));
    end
end

%% ============== Make the initial plots =================================
icIdx = IC0;

hF = plot(app.ax, x, fxs{icIdx}, 'k--', 'LineWidth', 1.5);
hU = plot(app.ax, x, Solve(icIdx, 1, false, N0, 0), 'r', 'LineWidth', 2);

%% Plot elements are done - Make pretty
leg = legend(app.ax, '$f(x)$', '$u_N(x,t)$', 'Location', 'best', 'FontSize', 18);
ylabel(app.ax, '$u(x,t)$')
xlim(app.ax, [0, L])

%% Build UI
NumControls = 6;

tSlider = app.addControl('slider', '$t = $', 1, NumControls, @(~,~) updateTime(), ...
    'Number_format', '%.2f', 'Default', 0, 'Min', 0, 'Max', t_max);
tSlider.SliderStep = [0.01/t_max, 0.1/t_max];
addlistener(tSlider, 'ContinuousValueChange', @(~,~) updateTime());

NSlider = app.addControl('slider', '$N = $', 2, NumControls, @changeN, ...
    'Number_format', '%d', 'Default', N0, 'Min', 1, 'Max', Max_N, ...
    'LimitLabel', '$N \to \infty$');
NSlider.SliderStep = [1/(Max_N-1), 10/(Max_N-1)];

btnMode = app.addControl('button', 'Sum of modes', 3, NumControls, ...
    @changeToggle, 'ColorChange', true);

btnR = app.addControl('button', 'Right: Dirichlet', 4, NumControls, ...
    @changeToggle, 'ColorChange', true);

btnL = app.addControl('button', 'Left: Dirichlet', 5, NumControls, ...
    @changeToggle, 'ColorChange', true);

btnIC = app.addControl('button', ['IC: ' ICs{icIdx,1}], 6, NumControls, ...
    @changeIC);

%% Functions for UI elements
    function changeToggle(~,~)
        app.UpdateUISlider(tSlider, 0);
        updatePlot()
    end

    function changeIC(~,~)
        icIdx = mod(icIdx, nIC) + 1;
        set(hF, 'YData', fxs{icIdx});
        app.UpdateUISlider(tSlider, 0);
        updatePlot()
    end

    function changeN(~,~)
        NSlider.Value = round(NSlider.Value);
        updatePlot()
    end

updatePlot()

%% Draw update functions. All initial plot functions are updated below.
% Only the curve changes with t
    function updateTime(~,~)
        fam = 1 + double(btnL.Value) + 2*double(btnR.Value);
        set(hU, 'YData', Solve(icIdx, fam, logical(btnMode.Value), ...
            round(NSlider.Value), tSlider.Value));
        drawnow limitrate
    end

    function updatePlot(~,~)
        bcL     = double(btnL.Value);          % 0 = Dirichlet, 1 = Neumann
        bcR     = double(btnR.Value);
        fam     = 1 + bcL + 2*bcR;
        oneMode = logical(btnMode.Value);
        N       = round(NSlider.Value);
        t       = tSlider.Value;
        isFull  = N >= Max_N;

        btnL.String  = ['Left: '  bcName{bcL+1}];
        btnR.String  = ['Right: ' bcName{bcR+1}];
        btnIC.String = ['IC: ' ICs{icIdx,1}];
        if oneMode
            btnMode.String = 'Single mode';
        else
            btnMode.String = 'Sum of modes';
        end

        if isFull
            xg = xm;
            N  = M;
        else
            xg = x;
        end
        set(hU, 'XData', xg, 'YData', Solve(icIdx, fam, oneMode, N, t));

        if oneMode
            ylim(app.ax, [-1.1, 1.1])
            leg.String = {'$f(x)$', '$\cos(\omega_n t)\phi_n(x)$'};
            desc = sprintf('single mode $n = %d$', N);
        else
            ylim(app.ax, yl{icIdx,fam})
            if isFull
                leg.String = {'$f(x)$', '$u(x,t)$'};
                desc = 'sum of all modes, $N \to \infty$';
            else
                leg.String = {'$f(x)$', '$u_N(x,t)$'};
                desc = sprintf('sum of modes $n = 1$ to $%d$', N);
            end
        end
        title(app.ax, sprintf('1D Wave Equation, %s at $x=0$, %s at $x=L$: %s', ...
            bcName{bcL+1}, bcName{bcR+1}, desc))
        drawnow limitrate
    end
end