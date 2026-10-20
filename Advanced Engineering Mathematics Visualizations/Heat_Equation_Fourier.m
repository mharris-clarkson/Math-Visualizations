function Heat_Equation_Fourier()
%% Solves the 1D heat equation u_t = alpha*u_xx on [0,L] with a Fourier
%  series and plots truncated (partial sum) solutions.
%
%  Dirichlet:  u(0,t) = u(L,t) = 0     -> sine series
%              u = sum_n b_n sin(n*pi*x/L) exp(-alpha*(n*pi/L)^2 t)
%
%  Neumann:    u_x(0,t) = u_x(L,t) = 0 -> cosine series
%              u = a_0 + sum_n a_n cos(n*pi*x/L) exp(-alpha*(n*pi/L)^2 t)
%
%  Controls:
%     - Boundary condition toggle (Dirichlet / Neumann)
%     - Single mode / sum of modes toggle. Single mode plots only the n-th
%       mode with coefficient 1 (not the Fourier coefficient).
%     - Slider for the number of modes N (1 to Max_N)
%     - Slider for time t (0 to t_max). Pushing either toggle resets t = 0.
%
%% Author Info
%
% Written with Claude (Anthropic) for Dr Matthew Harris, assistant
% professor at Clarkson University, for MA 330: Advanced Engineering
% Mathematics.
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.

% Initial condition u(x,0) = f(x) on [0,L].
f = @(x) 1.0*(x > 0.25 & x < 0.75);        % box function
% Other examples:
 f = @(x) x.*(1-x);                        % parabola21
 f = @(x) x.^2;                            % parabola 1
% f = @(x) 1 - abs(2*x/1 - 1);             % hat function (for L = 1)
% f = @(x) sin(pi*x) + 0.5*sin(3*pi*x);    % exactly two Dirichlet modes
% f = @(x) 1.0*(x >= 0);                   % constant 1

L     = 1;      % Length of the rod. Domain is [0, L]
alpha = 0.01;   % Diffusivity in u_t = alpha*u_xx. Small enough that the
                % solution is still changing across the t = 0 to 10 slider
                % (with alpha = 1 everything has decayed by t ~ 0.1).

% Slider limits
N0    = 1;      % Initial number of modes
Max_N = 100;   % Maximum number of modes
t_max = 20;     % Maximum time

% Resolution
Nx   = 10001;    % Number of points used to plot the solution
Nfft = 2^15;    % Number of samples of f used by the FFT to compute the
                % coefficients. Keep it much larger than Max_N.

%% ==== Below this we build the UI, compute the needed math functions for future updates and update ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('1D Heat Equation: Fourier Series Solution', 1);
title(app.ax, app.fig.Name, 'Interpreter', 'latex')

%% Precompute Fourier coefficients and mode shapes
x      = linspace(0, L, Nx);
n      = 1:Max_N;
kn     = n*pi/L;              % spatial frequencies
lambda = alpha*kn.^2;         % decay rates of each mode
fx     = f(x) + 0*x;          % +0*x lets f be a constant

% Fourier coefficients from the FFT. Sampling f at the midpoints of Nfft
% equal cells turns the coefficient integrals into a cosine transform
% (DCT-II) and a sine transform (DST-II). Both are computed with fft of the
% even/odd extension of f to length 2*Nfft, then a phase shift. All
% Max_N coefficients come from two FFTs.
xm = ((1:Nfft) - 0.5)*L/Nfft;       % cell midpoints
fm = f(xm) + 0*xm;
ph = exp(-1i*pi*(0:Max_N)/(2*Nfft)); % phase shift for the half cell offset
Ze = fft([fm,  fliplr(fm)]);        % even extension -> cosine series
Zo = fft([fm, -fliplr(fm)]);        % odd extension  -> sine series
Ze = Ze(1:Max_N+1).*ph;
Zo = Zo(1:Max_N+1).*ph;

a0 =  real(Ze(1))     / (2*Nfft);   % Neumann constant mode (the average of f)
aN =  real(Ze(2:end)) / Nfft;       % Neumann (cosine) coefficients
bD = -imag(Zo(2:end)) / Nfft;       % Dirichlet (sine) coefficients

% Mode shapes evaluated on the plot grid. Each column is one mode. These
% and the coefficients above are all that the update function uses.
PhiD = sin(x(:)*kn);
PhiN = cos(x(:)*kn);

% Store the two boundary condition options together. Index 1 = Dirichlet and
% index 2 = Neumann
coef   = {bD, aN};
Phi    = {PhiD, PhiN};
offset = [0, a0];
bcName = {'Dirichlet', 'Neumann'};

%% Optional math functions for plot computations
    function u = Heat_Solution(bc, oneMode, N, t)
        % Returns the (row vector) solution on the grid x at time t.
        if oneMode
            % Only mode N and scaled by 1 instead of the Fourier coefficient
            u = Phi{bc}(:, N) * exp(-lambda(N)*t);
        else
            % Sum of modes 1 to N
            u = offset(bc) + Phi{bc}(:, 1:N) * (coef{bc}(1:N).*exp(-lambda(1:N)*t)).';
        end
        u = u.';
    end

% y limits for the sum of modes view. Sample partial sums at t = 0 so the
% plot does not clip the Gibbs overshoot or the first few modes.
Ntry = unique(round(logspace(0, log10(Max_N), 30)));
yl   = zeros(2, 2);
for ibc = 1:2
    lo = min([fx, 0]);
    hi = max([fx, 0]);
    for iN = Ntry
        uTry = Heat_Solution(ibc, false, iN, 0);
        lo   = min(lo, min(uTry));
        hi   = max(hi, max(uTry));
    end
    pad = 0.08*(hi - lo);
    if pad == 0, pad = 1; end
    yl(ibc, :) = [lo - pad, hi + pad];
end

%% ============== Make the initial plots =================================
% Initial condition
hF = plot(app.ax, x, fx, 'k--', 'LineWidth', 1.5);

% Solution
hU = plot(app.ax, x, Heat_Solution(1, false, N0, 0), 'r', 'LineWidth', 2);

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
NumControls = 4; % maximum number of controls

% Toggles. The button text shows the current state.
btnBC = app.addControl('button', 'Dirichlet BCs', 4, NumControls, ...
    @changeToggle, 'ColorChange', true);

btnMode = app.addControl('button', 'Sum of modes', 3, NumControls, ...
    @changeToggle, 'ColorChange', true);

% Number of modes
NSlider = app.addControl('slider', '$N = $', 2, NumControls, @changeN, ...
    'Number_format', '%d', 'Default', N0, 'Min', 1, 'Max', Max_N);
% Arrow click moves one mode and clicking in the track moves ten
NSlider.SliderStep = [1/(Max_N-1), 10/(Max_N-1)];

% Time
tSlider = app.addControl('slider', '$t = $', 1, NumControls, @changeT, ...
    'Number_format', '%.2f', 'Default', 0, 'Min', 0, 'Max', t_max);

%% Functions for UI elements
    % Either toggle: reset the time slider to t = 0 and redraw
    function changeToggle(~,~)
        app.UpdateUISlider(tSlider, 0);
        updatePlot()
    end

    % Number of modes: snap the slider to an integer
    function changeN(~,~)
        NSlider.Value = round(NSlider.Value);
        updatePlot()
    end

    % Time
    function changeT(~,~)
        updatePlot()
    end

updatePlot()

%% Main Draw update function. All initial plot functions are updated below.
    function updatePlot(~,~)
        % Read the UI state
        bc      = double(btnBC.Value) + 1;     % 1 = Dirichlet, 2 = Neumann
        oneMode = logical(btnMode.Value);      % false = sum, true = single mode
        N       = round(NSlider.Value);
        t       = tSlider.Value;

        % Button text shows the current state
        btnBC.String = [bcName{bc} ' BCs'];
        if oneMode
            btnMode.String = 'Single mode';
        else
            btnMode.String = 'Sum of modes';
        end

        % Compute and plot the solution
        u = Heat_Solution(bc, oneMode, N, t);
        set(hU, 'XData', x, 'YData', u);

        % Axis limits, legend and title depend on the display type
        if oneMode
            ylim(app.ax, [-1.1, 1.1])
            leg.String = {'$f(x)$', '$e^{-\lambda_n t}\phi_n(x)$'};
            desc = sprintf('single mode $n = %d$', N);
        else
            ylim(app.ax, yl(bc, :))
            leg.String = {'$f(x)$', '$u_N(x,t)$'};
            desc = sprintf('sum of modes $n = 1$ to $%d$', N);
        end
        title(app.ax, sprintf('1D Heat Equation, %s BCs: %s, $t = %.2f$', ...
            bcName{bc}, desc, t), 'Interpreter', 'latex')
    end
end