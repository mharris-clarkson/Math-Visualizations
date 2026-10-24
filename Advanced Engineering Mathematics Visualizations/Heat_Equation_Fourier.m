function Heat_Equation_Fourier()
%% Solves the 1D heat equation u_t = alpha*u_xx on [0,L] with a Fourier
%  series and plots truncated (partial sum) solutions.
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
%  u(x,t) = [a_0] + sum_n c_n phi_n(x) exp(-alpha*k_n^2*t)
%
%  Controls:
%     - Initial condition button (cycles through the list ICs below)
%     - Left and right boundary condition toggles (independent)
%     - Single mode / sum of modes toggle. Single mode plots only the n-th
%       mode with coefficient 1 (not the Fourier coefficient).
%     - Slider for the number of modes N (1 to Max_N). Putting the slider
%       at Max_N switches to ALL the modes the FFT grid can hold (N = Nfft)
%       summed with an inverse FFT. The N label shows that value until the
%       slider is moved again.
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

L     = 1;      % Length of the rod. Domain is [0, L]
alpha = 0.01;   % Diffusivity in u_t = alpha*u_xx. Small enough that the
                % solution is still changing across the t = 0 to 10 slider
                % (with alpha = 1 everything has decayed by t ~ 0.1).

% Initial conditions u(x,0) = f(x) on [0,L]. Each row is {button label, f}.
% Each f must be vectorized (use .*, .^, ./ and logical masks). Add or
% remove rows freely. The button cycles through the rows in order.
ICs = {
    'Box',      @(x) 1.0*(x>0.25*L & x<0.75*L);
    '$x(L-x)$', @(x) x.*(L-x);
    'Hat',      @(x) 1-abs(2*x/L-1);
    'Two modes',@(x) sin(pi*x/L)+0.5*sin(3*pi*x/L);
    'Constant', @(x) 1+0*x;
    '$x^2$',    @(x) x.^2
    };
IC0 = 1;        % Row of ICs used when the figure opens

% Slider limits
N0    = 1;      % Initial number of modes
Max_N = 100;    % Maximum number of modes on the slider. At this value the
                % plot switches to all Nfft modes (see below).
t_max = 20;     % Maximum time

% Resolution
Nx   = 3001;    % Number of points used to plot the solution
Nfft = 2^15;    % Number of samples of f used by the FFT to compute the
                % coefficients. This is also the number of modes the grid
                % can hold, so it is the N used when the slider is at Max_N.
                % Keep it much larger than Max_N.

% Modes with exp(-lambda_n*t) < exp(-decay_tol) (about 2e-16) are skipped
% when summing, which makes the sum much cheaper once t > 0.
decay_tol = 36;

%% ==== Below this we build the UI, compute the needed math functions for future updates and update ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('1D Heat Equation: Fourier Series Solution', 1);
title(app.ax, app.fig.Name, 'Interpreter', 'latex')

%% Grids and mode shapes (these do not depend on the initial condition)
x   = linspace(0, L, Nx);
n   = 1:Max_N;
nIC = size(ICs, 1);

% Family index = 1 + (left is Neumann) + 2*(right is Neumann)
%   1: D-D    2: N-D    3: D-N    4: N-N
kk     = {n*pi/L, (n-0.5)*pi/L, (n-0.5)*pi/L, n*pi/L};  % spatial frequencies
isCos  = [false, true, false, true];
shift  = [0, 0.5, 0.5, 0];          % n - shift = k_n*L/pi
bcName = {'Dirichlet', 'Neumann'};

% Mode shapes (each column is one mode) and decay rates. The Fourier
% coefficients are applied at update time so every IC shares these.
Phi    = cell(1, 4);
lambda = cell(1, 4);
for i = 1:4
    if isCos(i)
        Phi{i} = cos(x(:)*kk{i});
    else
        Phi{i} = sin(x(:)*kk{i});
    end
    lambda{i} = alpha*kk{i}(:).^2;  % column of decay rates
end

%% Precompute Fourier coefficients of every IC for all four BC pairs
% Sample f at the midpoints of Nfft equal cells. With these samples every
% coefficient integral, int f(x) exp(i*k*x) dx, is a sum that two FFTs
% evaluate for all modes at once:
%   A_m = sum_j f_j exp(i*pi*m*(j-1/2)/M),       m = 0..M       (integer k)
%   B_m = sum_j f_j exp(i*pi*(m-1/2)*(j-1/2)/M), m = 1..M       (half integer k)
% Real parts give the cosine integrals and imaginary parts the sine ones.
% All M = Nfft coefficients are kept. The slider uses the first Max_N and
% the full grid view uses all of them.
M  = Nfft;
xm = ((1:M) - 0.5)*L/M;             % cell midpoints
j  = 1:M;

cf  = cell(nIC, 4);                 % coefficient columns c_n (length M)
a0v = zeros(1, nIC);                % N-N constant mode (average of f)
fxs = cell(1, nIC);                 % f on the plot grid
for ic = 1:nIC
    fxs{ic} = ICs{ic,2}(x) + 0*x;   % +0*x lets f be a constant
    [cf(ic,:), a0v(ic)] = Fourier_Coefs(ICs{ic,2});
end

%% Optional math functions for plot computations
    function [cfs, a0] = Fourier_Coefs(fun)
        % c_n = (2/L)*int f*phi_n dx for the four families, from two FFTs
        fm = fun(xm) + 0*xm;
        A  = 2*M*ifft(fm, 2*M);     % zero padded to 2M so exponents are pi*m*(j-1)/M
        A  = A(1:M+1) .* exp(1i*pi*(0:M)/(2*M));
        B  = 2*M*ifft(fm .* exp(1i*pi*(j-1)/(2*M)), 2*M);
        B  = B(1:M) .* exp(1i*pi*(j-0.5)/(2*M));
        a0  = real(A(1))/M;
        cfs = {(2/M)*imag(A(2:end)).', ...   % D-D: sin(n*pi*x/L)
               (2/M)*real(B).', ...          % N-D: cos((n-1/2)*pi*x/L)
               (2/M)*imag(B).', ...          % D-N: sin((n-1/2)*pi*x/L)
               (2/M)*real(A(2:end)).'};      % N-N: cos(n*pi*x/L)
    end

    function u = Heat_Solution(ic, fam, oneMode, N, t)
        % Returns the (row vector) solution on the grid x at time t using
        % modes 1 to N (N <= Max_N).
        if oneMode
            % Only mode N and scaled by 1 instead of the Fourier coefficient
            if isCos(fam)
                phi = cos(kk{fam}(N)*x);
            else
                phi = sin(kk{fam}(N)*x);
            end
            u = phi * exp(-lambda{fam}(N)*t);
        else
            % Sum of modes 1 to N. Lambda grows with n so only modes below
            % the cutoff still matter at time t.
            Nd = min(N, floor(sqrt(decay_tol/(alpha*t))*L/pi + shift(fam)));
            w  = cf{ic,fam}(1:Nd) .* exp(-lambda{fam}(1:Nd)*t);
            u  = Phi{fam}(:, 1:Nd) * w;
            if fam == 4
                u = u + a0v(ic);
            end
            u = u.';
        end
    end

    function u = Heat_Solution_Full(ic, fam, oneMode, t)
        % Returns the (row vector) solution on the FFT grid xm at time t
        % using ALL M modes the grid can hold. The sum over n is an inverse
        % FFT of the decayed coefficients so no mode matrix is needed.
        kf = ((1:M) - shift(fam))*pi/L;          % k_n for n = 1..M
        if oneMode
            % Highest mode only, scaled by 1
            if isCos(fam)
                u = cos(kf(M)*xm);
            else
                u = sin(kf(M)*xm);
            end
            u = u * exp(-alpha*kf(M)^2*t);
            return
        end
        d = cf{ic,fam}.' .* exp(-alpha*kf.^2*t); % c_n*exp(-lambda_n t)
        if shift(fam) == 0
            % Integer k: phi_n(xm_j) is Re/Im of exp(i*pi*n*(j-1/2)/M)
            if fam == 1
                d(M) = d(M)/2;   % last sine vector has twice the norm of the others
            end
            g = [0, d] .* exp(1i*pi*(0:M)/(2*M));     % n = 0..M
            if fam == 4
                g(1) = a0v(ic);                       % constant mode
            end
            Z = 2*M*ifft(g, 2*M);
            Z = Z(1:M);
        else
            % Half integer k: factor out exp(i*pi*(j-1)/(2M))
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
        % Slider at Max_N means use every mode the grid can hold
        if N >= Max_N
            u = Heat_Solution_Full(ic, fam, oneMode, t);
        else
            u = Heat_Solution(ic, fam, oneMode, N, t);
        end
    end

% y limits for the sum of modes view. Sample partial sums at t = 0 so the
% plot does not clip the Gibbs overshoot or the first few modes.
Ntry = unique(round(logspace(0, log10(Max_N), 30)));
yl   = cell(nIC, 4);
for ic = 1:nIC
    for fam = 1:4
        lo = min([fxs{ic}, 0]);
        hi = max([fxs{ic}, 0]);
        for iN = Ntry
            uTry = Heat_Solution(ic, fam, false, iN, 0);
            lo   = min(lo, min(uTry));
            hi   = max(hi, max(uTry));
        end
        uTry = Heat_Solution_Full(ic, fam, false, 0);   % all modes
        lo   = min(lo, min(uTry));
        hi   = max(hi, max(uTry));
        pad = 0.08*(hi - lo);
        if pad == 0, pad = 1; end
        yl{ic,fam} = [lo - pad, hi + pad];
    end
end

%% ============== Make the initial plots =================================
icIdx = IC0;     % Row of ICs currently shown

% Initial condition
hF = plot(app.ax, x, fxs{icIdx}, 'k--', 'LineWidth', 1.5);

% Solution
hU = plot(app.ax, x, Solve(icIdx, 1, false, N0, 0), 'r', 'LineWidth', 2);

%% Plot elements are done - Make pretty
leg = legend(app.ax, '$f(x)$', '$u_N(x,t)$');
set(leg, 'Interpreter', 'latex')
leg.Location = "best";
set(leg, 'FontSize', 18)

Pretty_Plot(app.ax);
xlabel(app.ax, '$x$', 'Interpreter', 'latex')
ylabel(app.ax, '$u(x,t)$', 'Interpreter', 'latex')
xlim(app.ax, [0, L])

%% Build UI
NumControls = 6; % maximum number of controls

% Time. Arrow click = 0.1 and clicking the track = 1 for t_max = 20.
tSlider = app.addControl('slider', '$t = $', 1, NumControls, @changeT, ...
    'Number_format', '%.2f', 'Default', 0, 'Min', 0, 'Max', t_max);
tSlider.SliderStep = [0.01/t_max, 0.1/t_max];
% Also update while the slider is being dragged
addlistener(tSlider, 'ContinuousValueChange', @(~,~) updateTime());

% Number of modes
NSlider = app.addControl('slider', '$N = $', 2, NumControls, @changeN, ...
    'Number_format', '%d', 'Default', N0, 'Min', 1, 'Max', Max_N);
% Arrow click moves one mode and clicking in the track moves ten
NSlider.SliderStep = [1/(Max_N-1), 10/(Max_N-1)];

% Toggles. The button text shows the current state.
btnMode = app.addControl('button', 'Sum of modes', 3, NumControls, ...
    @changeToggle, 'ColorChange', true);

btnR = app.addControl('button', 'Right: Dirichlet', 4, NumControls, ...
    @changeToggle, 'ColorChange', true);

btnL = app.addControl('button', 'Left: Dirichlet', 5, NumControls, ...
    @changeToggle, 'ColorChange', true);

% Initial condition. Each click moves to the next row of ICs.
btnIC = app.addControl('button', ['IC: ' ICs{icIdx,1}], 6, NumControls, ...
    @changeIC);

%% Functions for UI elements
    % Any toggle: reset the time slider to t = 0 and redraw
    function changeToggle(~,~)
        app.UpdateUISlider(tSlider, 0);
        updatePlot()
    end

    % Initial condition: go to the next IC, reset t = 0 and redraw
    function changeIC(~,~)
        icIdx = mod(icIdx, nIC) + 1;
        set(hF, 'YData', fxs{icIdx});
        app.UpdateUISlider(tSlider, 0);
        updatePlot()
    end

    % Number of modes: snap the slider to an integer. Setting Value resets
    % the N label, which is how the label goes back to normal once the
    % slider has moved off Max_N.
    function changeN(~,~)
        NSlider.Value = round(NSlider.Value);
        updatePlot()
    end

    % Time: only the curve changes so skip the title, legend and limits
    function changeT(~,~)
        updateTime()
    end

updatePlot()

%% Draw update functions. All initial plot functions are updated below.
    % Cheap update used when only time changes
    function updateTime(~,~)
        fam = 1 + double(btnL.Value) + 2*double(btnR.Value);
        set(hU, 'YData', Solve(icIdx, fam, logical(btnMode.Value), ...
            round(NSlider.Value), tSlider.Value));
        drawnow limitrate
    end

    % Full update used when a toggle, the IC or the number of modes changes
    function updatePlot(~,~)
        % Read the UI state
        bcL     = double(btnL.Value);          % 0 = Dirichlet, 1 = Neumann
        bcR     = double(btnR.Value);
        fam     = 1 + bcL + 2*bcR;
        oneMode = logical(btnMode.Value);      % false = sum, true = single mode
        N       = round(NSlider.Value);
        t       = tSlider.Value;
        isFull  = N >= Max_N;                  % slider at its maximum

        % Button text shows the current state
        btnL.String  = ['Left: '  bcName{bcL+1}];
        btnR.String  = ['Right: ' bcName{bcR+1}];
        btnIC.String = ['IC: ' ICs{icIdx,1}];
        if oneMode
            btnMode.String = 'Single mode';
        else
            btnMode.String = 'Sum of modes';
        end

        % Compute and plot the solution. The full view lives on the FFT grid.
        if isFull
            xg = xm;
            N  = M;
            NSlider.UserData.label.String = sprintf('$N = $%d', M);
        else
            xg = x;
        end
        set(hU, 'XData', xg, 'YData', Solve(icIdx, fam, oneMode, N, t));

        % Axis limits, legend and title depend on the display type
        if oneMode
            ylim(app.ax, [-1.1, 1.1])
            leg.String = {'$f(x)$', '$e^{-\lambda_n t}\phi_n(x)$'};
            desc = sprintf('single mode $n = %d$', N);
        else
            ylim(app.ax, yl{icIdx,fam})
            leg.String = {'$f(x)$', '$u_N(x,t)$'};
            desc = sprintf('sum of modes $n = 1$ to $%d$', N);
        end
        title(app.ax, sprintf('1D Heat Equation, %s at $x=0$, %s at $x=L$: %s', ...
            bcName{bcL+1}, bcName{bcR+1}, desc), 'Interpreter', 'latex')
        drawnow limitrate
    end
end