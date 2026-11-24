function Fourier_Series_Demo()
%% Plots a function along with fourier sum approximations of it. Previous /
%  Next buttons flip between several classical functions (square wave,
%  sawtooth, triangle wave, rectified sine, parabola, pulse). The last
%  slider step is N -> infinity: it shows what the partial sums converge
%  to, which is f(t) where f is continuous and the average of the two
%  one-sided limits at every jump (red dots), including the jump of the
%  periodic extension at t = -pi and pi. The Gibbs overshoot of the finite
%  sums never shrinks, but it squeezes into the jumps and disappears.
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 330: Advanced Engineering Mathematics.

close all

%% User parameters for math objects

% Functions on one period [-pi, pi]. Each row is {name (title), f}. Each f
% must be vectorized (use .*, .^ and logical masks). Add or remove rows
% freely; the Previous / Next buttons cycle through them in order.
funcs = {
    'Square wave',          @(t) -1*(t<0) + 1*(t>=0);
    'Sawtooth $f(t) = t$',  @(t) t;
    'Triangle wave $f(t) = |t|$', @(t) abs(t);
    'Half-wave rectified sine $f(t) = \max(\sin t, 0)$', @(t) max(sin(t), 0);
    'Parabola $f(t) = t^2$', @(t) t.^2;
    'Pulse: $f(t) = 1$ for $|t| < \pi/2$', @(t) 1.0*(abs(t) < pi/2);
    };
func0 = 1;        % function shown when the figure opens

t = linspace(-pi,pi,10000);
Max_N = 100; % maximum number of fourier modes

% Line widths
lwF   = 2.5;      % f(t)
lwSum = 2;        % finite Fourier sums
lwLim = 3;        % the N -> infinity limit

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure("Fourier Series Demo", 1);


%% Precompute fourier coefficients

% Find needed period from user function
T = (t(end)-t(1));
w0 = 2*pi/T;
k  = (1:Max_N).';

% Per-function data, computed the first time a function is shown and
% then kept (so flipping back and forth is instant)
nF   = size(funcs, 1);
data = cell(1, nF);

    function D = functionData(iF)
        if ~isempty(data{iF}), D = data{iF}; return, end
        f  = funcs{iF, 2};
        fT = f(t) + 0*t;                       % +0*t lets f be a constant

        % Fourier coefficients - FFT would be faster but this is more
        % insightful for students
        a0 = (2/T) * trapz(t, fT);
        a  = zeros(1, Max_N);
        b  = zeros(1, Max_N);
        for n = 1:Max_N
            a(n) = (2/T) * trapz(t, fT.*cos(n*w0*t));
            b(n) = (2/T) * trapz(t, fT.*sin(n*w0*t));
        end

        % All partial sums at once: row n is a0/2 + sum_{k<=n} (a_k cos + b_k sin).
        % The constant term is a0/2 because a0 = (2/T) int f dt (with a0 alone the
        % offset of any f with non-zero mean was doubled). Precomputing makes each
        % slider move a table look-up instead of an N-term loop.
        D.fT = fT;
        D.Partial_Sums = a0/2 + cumsum(a.'.*cos(k*w0*t) + b.'.*sin(k*w0*t), 1);

        % The limit N -> infinity (pointwise): f where it is continuous, the
        % average of the one-sided limits at a jump. The periodic extension also
        % jumps from f(t(end)) to f(t(1)) at the ends of the period.
        jumpTol = 0.05*max(max(fT) - min(fT), eps);   % a change this big between samples is a jump
        jIdx    = find(abs(diff(fT)) > jumpTol);
        tJump   = (t(jIdx) + t(jIdx+1))/2;
        yJump   = (fT(jIdx) + fT(jIdx+1))/2;
        yEnd    = (fT(1) + fT(end))/2;                 % value of the series at t = -pi and pi
        if abs(fT(end) - fT(1)) > jumpTol
            tJump = [t(1), tJump, t(end)];
            yJump = [yEnd, yJump, yEnd];
        end
        % Limit curve with a break (NaN) at each jump, so no vertical line is drawn
        tLim = t;  yLim = fT;
        for jj = fliplr(jIdx)
            tLim = [tLim(1:jj), NaN, tLim(jj+1:end)];
            yLim = [yLim(1:jj), NaN, yLim(jj+1:end)];
        end
        D.tJump = tJump;  D.yJump = yJump;
        D.tLim  = tLim;   D.yLim  = yLim;

        % y limits that hold f and every partial sum (Gibbs overshoot included)
        lo  = min([fT, D.Partial_Sums(:).']);
        hi  = max([fT, D.Partial_Sums(:).']);
        pad = 0.08*max(hi - lo, eps);
        D.yl = [lo - pad, hi + pad];

        data{iF} = D;
    end

%% Make the initial plots (filled in by showFunction)
hF       = plot(app.ax(1), NaN, NaN, 'b', 'LineWidth', lwF);
hold(app.ax(1), "on");
f_approx = plot(app.ax(1), NaN, NaN, 'r', 'LineWidth', lwSum);
hJump    = plot(app.ax(1), NaN, NaN, 'ro', 'MarkerFaceColor', 'r', ...
    'MarkerSize', 10, 'Visible', 'off');       % limit values at the jumps
leg = legend(app.ax(1), [hF, f_approx], ...
    {'$f(t)$', 'Fourier approximation (finite sum)'}, 'Location', 'Best', 'AutoUpdate', 'off');


Pretty_Plot(app.ax)
xlabel(app.ax(1), '$t$')   % the variable is t, not x
set(app.ax(1), 'FontSize', 24)
xlim(app.ax(1), [t(1) t(end)])


%% Build UI
numGUI = 3;
NSlider = app.addControl('slider', '$N = $', 1, numGUI, @changeN,...
                'Number_format','%d','default', 1,'Min', 1, 'Max',Max_N,...
                'colOrRow','Row','Step',1,... % arrow click = one more mode
    'LimitLabel', '$N \to \infty$');

% Previous / Next function (the gallery index is app.galleryIdx)
app.addPrevNext(2, numGUI, nF, @showFunction, 'colOrRow', 'row');
app.galleryIdx = func0;

showFunction(func0)

%% Callbacks
% Switch to function iF: new f, limits and title, then redraw the sum
    function showFunction(iF)
        D = functionData(iF);
        set(hF,    'XData', t, 'YData', D.fT)
        set(hJump, 'XData', D.tJump, 'YData', D.yJump)
        ylim(app.ax(1), D.yl)
        title(app.ax(1), funcs{iF, 1})
        changeN()
    end

    function changeN(~,~)
        D = data{app.galleryIdx};
        if app.isAtLimit(NSlider)
            % N -> infinity: the function the partial sums converge to
            set(f_approx, 'XData', D.tLim, 'YData', D.yLim, 'LineWidth', lwLim)
            set(hJump, 'Visible', 'on')
            leg.String{2} = 'Fourier series ($N \to \infty$)';
        else
            N = round(NSlider.Value);
            set(f_approx, 'XData', t, 'YData', D.Partial_Sums(N, :), 'LineWidth', lwSum)
            set(hJump, 'Visible', 'off')
            leg.String{2} = 'Fourier approximation (finite sum)';
        end
    end




end
