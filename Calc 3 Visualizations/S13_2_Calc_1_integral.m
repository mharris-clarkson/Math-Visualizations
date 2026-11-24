function S13_2_Calc_1_integral()
%% Script showing the idea behind the definition of the calc 1 integral.
%  The area under a curve is approximated by N rectangles. A slider sets N
%  and three buttons pick the sample points (left, midpoint or right).
%  The last slider step is the limit N -> infinity: the rectangles are
%  replaced by the exact (green) area under the curve and the title shows
%  its value, so students see the Riemann sums turn into the integral.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all;

%% ================== User parameters =====================
f = @(x) (abs(x)<1) .* exp(-1./max(1-x.^2, eps));
xlims = [-1.2,1.2];

color1    = [0 0 0.6];
color2    = [0.6 0 0];
areaColor = [0.2 0.7 0.2];   % green area shown at N -> infinity

N_min  = 5;
N_max  = 100;                % largest finite N; one step further is N -> infinity

%% Load libraries
run('setup.m')

%% Build app
app = uiFigure('Visualization of the Definition for $\int_a^b f(x)dx$',1);
title(app.ax,app.fig.Name)
view(app.ax,0,90)
x = linspace(xlims(1), xlims(2), 200);
f_DAT = f(x);

plot(app.ax, x, f_DAT, 'k','LineWidth',2)

ylim(app.ax,[min(f_DAT(:))*1.1, max(f_DAT(:))*1.1]);
xlim(app.ax,xlims);

Pretty_Plot(app.ax);

%% Exact value and green area (computed and drawn once, shown at the limit)
a = xlims(1);
b = xlims(2);
exactArea = integral(f, a, b);

xFill = linspace(a, b, 400);
yFill = f(xFill);
hArea = patch(app.ax, [xFill, fliplr(xFill)], [yFill, zeros(size(yFill))], areaColor, ...
    'FaceAlpha', 0.35, 'EdgeColor', 'none', 'Visible', 'off');

%% Rectangles and sample points (one object each, updated in place)
hRects = patch(app.ax, 'Faces', 1:4, 'Vertices', NaN(4,2), 'FaceColor', 'flat', ...
    'FaceVertexCData', color1, 'FaceAlpha', 0.4, 'EdgeColor', 'k', 'LineWidth', 1);
hDots  = plot(app.ax, NaN, NaN, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6);

%% State variables
Method = 'Midpoint';

%% ================= UI =====================
NumControls = 4;

% Slider: N_min ... N_max, then one extra step that stands for N -> infinity
NSlider = app.addControl('slider', '$N = $', 1, NumControls, @updatePlot,...
    'default', N_min,'Min', N_min, 'Max', N_max + 1,'Number_format','%d',...
    'Step', 1, 'LimitLabel', '$N \to \infty$');

app.addControl('button','Left Sum',2,NumControls,@(~,~) setMethod('Left'));
app.addControl('button','Midpoint Rule',3,NumControls,@(~,~) setMethod('Midpoint'));
app.addControl('button','Right Sum',4,NumControls,@(~,~) setMethod('Right'));

%% Helper to change method
function setMethod(m)
    Method = m;
    updatePlot();
end

%% Initial draw
updatePlot();

%% ================= MAIN UPDATE =====================
function updatePlot(~,~)

    % Last slider step: the limit. Show the exact area instead of rectangles.
    if app.isAtLimit(NSlider)
        hRects.Visible = 'off';
        hDots.Visible  = 'off';
        hArea.Visible  = 'on';
        title(app.ax, sprintf(['$N \\to \\infty$: every %s sum becomes ' ...
            '$\\int_a^b f(x)\\,dx = %.4f$'], lower(Method), exactArea))
        return
    end
    hRects.Visible = 'on';
    hDots.Visible  = 'on';
    hArea.Visible  = 'off';

    N  = round(NSlider.Value);
    dx = (b - a)/N;

    xL   = a + (0:N-1)*dx;
    xR   = xL + dx;
    xMid = xL + dx/2;

    switch Method
        case 'Left'
            xSample = xL;
        case 'Right'
            xSample = xR;
        otherwise
            xSample = xMid;
    end

    r = f(xSample);
    set(hDots, 'XData', xSample, 'YData', r)

    % Rectangles: 4 corners each, alternating colours, all in one patch
    V = [xL(:) zeros(N,1); xR(:) zeros(N,1); xR(:) r(:); xL(:) r(:)];
    F = (1:N)' + [0, N, 2*N, 3*N];
    C = repmat([color1; color2], ceil(N/2), 1);
    % Faces cleared first so they never index past the new vertices
    set(hRects, 'Faces', [], 'Vertices', V, 'Faces', F, 'FaceVertexCData', C(1:N,:))

    title(app.ax, sprintf(['%s sum, $N = %d$: $%.4f$ ' ...
        '(exact $\\int_a^b f(x)\\,dx = %.4f$)'], Method, N, sum(r)*dx, exactArea))
end

end