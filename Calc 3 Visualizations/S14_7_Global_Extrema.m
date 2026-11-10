function S14_7_Global_Extrema()
%% Absolute Extrema on a Closed Region: Interior + Two 1D Boundary Problems
% Finds the absolute max and min of f(x,y) on the closed half disk
%       D:  x^2 + y^2 <= 1,  y >= 0
% using the closed-region method, with every step found automatically:
%   1) Interior:   points where grad f = 0                 (a 2D problem)
%   2) Edge A:     critical points of f(x,0),   -1 <= x <= 1      (a 1D problem!)
%   3) Arc  B:     critical points of f(cos t, sin t),  0 <= t <= pi  (a 1D problem!)
%   4) Corners:    (-1,0) and (1,0), the endpoints of both 1D problems
% The largest / smallest value among all of these candidates is the absolute
% max / min.
%
% Two views: the 3D graph of f over D (the region D is shaded on the floor),
% and the boundary "unrolled" into one variable s, where f is just a 1D function.
% Buttons jump between the absolute max and min, or step through every candidate.
%
%% Author Info
%
% Written by Claude for Dr Matthew Harris, assistant professor at
% Clarkson University, for MA 231: Calculus 3, following the style of his
% Math-Visualizations scripts.

close all

%% User parameters for math objects
% The default has an interior saddle, plus extrema on both 1D pieces of the
% boundary. Any f(x,y) written with elementwise operators (.*  ./  .^) works.
f = @(x,y) -0.5*x - x.^2 + 2*x.*y - 2*y.^2 + x.^3;

h      = 1e-5;    % finite-difference step for derivatives
nStart = 5;       % Newton starting points per direction (interior search)
nS     = 2001;    % samples per boundary piece when searching for f' = 0
nPlot  = 200;     % boundary plot resolution

colEdge   = [0.10 0.40 0.90];   % Edge A (y = 0):   blue
colArc    = [0.10 0.65 0.30];   % Arc B (circle):   green
colCorner = [0.70 0.10 0.70];   % corners:          purple

%% Automatically find and rank every candidate point
C = findCandidates(f, h, nStart, nS);
cx = [C.x];  cy = [C.y];  ctype = {C.type};  cnote = {C.note};
cf = f(cx, cy);
[cf, order] = sort(cf);                       % ascending: first = abs min, last = abs max
cx = cx(order); cy = cy(order); ctype = ctype(order); cnote = cnote(order);
nC = numel(cf);

%% Sample the region and boundary
[R, T] = meshgrid(linspace(0, 1, 50), linspace(0, pi, 100));
Xr = R.*cos(T);  Yr = R.*sin(T);  Fr = f(Xr, Yr);
fmin = min([Fr(:); cf(:)]);  fmax = max([Fr(:); cf(:)]);
zFloor = fmin - 0.15*(fmax - fmin);

xb = linspace(-1, 1, nPlot);   tb = linspace(0, pi, nPlot);
fA = f(xb, 0*xb);              fB = f(cos(tb), sin(tb));
types = {'interior', 'edge', 'arc', 'corner'};
mk = {'o', 's', '^', 'd'};
fc = {[0 0 0], colEdge, colArc, colCorner};

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('Absolute Extrema on the Half Disk', 2);
ax2 = app.ax(1);  ax3 = app.ax(2);
Pretty_Plot(app.ax)

%% View 1: the 3D graph of f over D, with the boundary curves lifted onto it
surf(ax2, Xr, Yr, Fr, 'EdgeColor', 'none', 'FaceAlpha', 0.9);
colormap(ax2, 'turbo'); clim(ax2, [fmin fmax])
qi = 1:nPlot-1;  qf = [qi; qi+1; nPlot+qi+1; nPlot+qi].';     % quad strip faces
patch(ax2, 'Faces', qf, 'Vertices', [xb(:) 0*xb(:) fA(:); xb(:) 0*xb(:) zFloor*ones(nPlot,1)], ...
    'FaceColor', colEdge, 'FaceAlpha', 0.25, 'EdgeColor', 'none');
patch(ax2, 'Faces', qf, 'Vertices', [cos(tb(:)) sin(tb(:)) fB(:); cos(tb(:)) sin(tb(:)) zFloor*ones(nPlot,1)], ...
    'FaceColor', colArc, 'FaceAlpha', 0.25, 'EdgeColor', 'none');
hEdgeL(1) = plot3(ax2, xb, 0*xb, fA, 'Color', colEdge, 'LineWidth', 4);
hArcL(1)  = plot3(ax2, cos(tb), sin(tb), fB, 'Color', colArc, 'LineWidth', 4);
fill3(ax2, [xb cos(tb)], [0*xb sin(tb)], zFloor*ones(1, 2*nPlot), [0.85 0.85 0.85], ...
    'FaceAlpha', 0.6, 'EdgeColor', 'k', 'LineStyle', '--')   % the region D, shaded on the floor
text(ax2, 0, 0.3, zFloor, 'Region D', 'HorizontalAlignment', 'center', 'FontWeight', 'bold')
text(ax2, 0, -0.08, zFloor, 'Edge A (1D)', 'Color', colEdge, 'HorizontalAlignment', 'center', 'FontWeight', 'bold')
text(ax2, 0, 1.08, zFloor, 'Arc B (1D)', 'Color', colArc, 'HorizontalAlignment', 'center', 'FontWeight', 'bold')
xlabel(ax2, 'x'); ylabel(ax2, 'y'); zlabel(ax2, 'z = f(x,y)')
view(ax2, -120, 28); xlim(ax2, [-1.1 1.1]); ylim(ax2, [-0.1 1.1]); zlim(ax2, [zFloor, fmax + 0.05*(fmax - fmin)])
pbaspect(ax2, [2 1.1 1])

%% View 2: the boundary unrolled into one variable s, where f is a 1D function
% s in [0,2]: Edge A from (-1,0) to (1,0);   s in [2, 2+pi]: Arc B from (1,0) round to (-1,0)
hEdgeL(2) = plot(ax3, xb + 1, fA, 'Color', colEdge, 'LineWidth', 3);
hArcL(2)  = plot(ax3, 2 + tb, fB, 'Color', colArc, 'LineWidth', 3);
xline(ax3, 2, 'k:');
set(ax3, 'XTick', [0 2 2+pi], 'XTickLabel', {'(-1,0)', '(1,0)', '(-1,0)'})
xlim(ax3, [-0.1 2+pi+0.1])
pad = 0.12*(max([fA fB]) - min([fA fB]));
ylim(ax3, [min([fA fB]) - pad, max([fA fB]) + pad])
xlabel(ax3, 's = position along the boundary:  Edge A, then Arc B')
ylabel(ax3, 'f on the boundary')
text(ax3, 1, max([fA fB]) + 0.5*pad, 'Edge A', 'Color', colEdge, 'HorizontalAlignment', 'center', 'FontWeight', 'bold')
text(ax3, 2 + pi/2, max([fA fB]) + 0.5*pad, 'Arc B', 'Color', colArc, 'HorizontalAlignment', 'center', 'FontWeight', 'bold')

%% Candidate markers in all three views (one object per marker type)
for q = 1:4
    m = strcmp(ctype, types{q});
    plot3(ax2, cx(m), cy(m), cf(m), mk{q}, 'MarkerFaceColor', fc{q}, 'MarkerEdgeColor', 'w', 'MarkerSize', 11, 'LineStyle', 'none');
    if q > 1                       % boundary candidates also appear on the 1D graph
        sx = []; sy = [];
        for k = find(m)
            s = bdryS(cx(k), cy(k), ctype{k});
            sx = [sx, s];  sy = [sy, repmat(cf(k), 1, numel(s))]; %#ok<AGROW>
        end
        plot(ax3, sx, sy, mk{q}, 'MarkerFaceColor', fc{q}, 'MarkerEdgeColor', 'w', 'MarkerSize', 11, 'LineStyle', 'none');
    end
end
% (the corner (-1,0) is the start AND end of the boundary loop, so it shows at both ends of the 1D graph)

%% The selected candidate (created once, moved by selectCandidate)
selOpts = {'p', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'MarkerSize', 24, 'LineWidth', 1.5, 'LineStyle', 'none'};
sel3  = plot3(ax2, NaN, NaN, NaN, selOpts{:});
stem3 = plot3(ax2, [NaN NaN], [NaN NaN], [NaN NaN], 'r--', 'LineWidth', 1.5);
sel1d = plot(ax3, NaN, NaN, selOpts{:});

%% Build UI
btnMaxMin = app.addControl('button', 'Jump to Absolute Min', 1, 2, @jumpMaxMin);
btnNext   = app.addControl('button', 'Next Candidate (by value)', 2, 2, @nextCandidate);

idx = nC;                 % start on the absolute max
selectCandidate(idx)

%% Callbacks
function jumpMaxMin(~, ~)
    if idx == nC, idx = 1; else, idx = nC; end
    selectCandidate(idx)
end

function nextCandidate(~, ~)
    idx = mod(idx, nC) + 1;
    selectCandidate(idx)
end

%% Move the highlight to candidate k in all three views and update the text
function selectCandidate(k)
    set(sel3, 'XData', cx(k), 'YData', cy(k), 'ZData', cf(k))
    set(stem3, 'XData', [cx(k) cx(k)], 'YData', [cy(k) cy(k)], 'ZData', [zFloor cf(k)])
    s = bdryS(cx(k), cy(k), ctype{k});
    set(sel1d, 'XData', s, 'YData', repmat(cf(k), 1, numel(s)))

    % Thicken the 1D piece(s) the selected point lives on
    onEdge = any(strcmp(ctype{k}, {'edge', 'corner'}));
    onArc  = any(strcmp(ctype{k}, {'arc', 'corner'}));
    wBase = [4 3];
    for q = 1:2
        hEdgeL(q).LineWidth = wBase(q) + 4*onEdge;
        hArcL(q).LineWidth  = wBase(q) + 4*onArc;
    end

    if k == nC, kind = 'ABSOLUTE MAX'; elseif k == 1, kind = 'ABSOLUTE MIN'; else, kind = sprintf('Candidate %d of %d', k, nC); end
    title(ax2, sprintf('%s:   f = %.4f   at (%.3f, %.3f)\n%s', kind, cf(k), cx(k), cy(k), cnote{k}), 'Interpreter', 'none')
    if isempty(s), where = 'selected point is interior: it is not on this boundary graph';
    else,          where = 'selected point is on the boundary: only this 1D graph matters'; end
    title(ax3, sprintf('Boundary only: f is a function of ONE variable s\n%s', where), 'Interpreter', 'none')
    app.fig.Name = sprintf('%s: f = %.4f at (%.3f, %.3f)', kind, cf(k), cx(k), cy(k));

    if idx == nC, btnMaxMin.String = 'Jump to Absolute Min'; else, btnMaxMin.String = 'Jump to Absolute Max'; end
    drawnow limitrate
end

end

%% ========================================================================
% Stateless helpers
% ========================================================================

function C = findCandidates(f, h, nStart, nS)
% All candidates for the absolute extrema of f on the half disk, found numerically.
fx = @(x,y) (f(x+h,y) - f(x-h,y))/(2*h);
fy = @(x,y) (f(x,y+h) - f(x,y-h))/(2*h);
C = struct('x', {}, 'y', {}, 'type', {}, 'note', {});

% 1) Interior critical points: Newton's method on grad f = 0 from a grid of starts
warnState = warning('off', 'MATLAB:singularMatrix');
warning('off', 'MATLAB:nearlySingularMatrix')
[X0, Y0] = meshgrid(linspace(-0.8, 0.8, nStart), linspace(0.15, 0.85, nStart));
found = zeros(0, 2);
for k = 1:numel(X0)
    v = [X0(k); Y0(k)];
    if v'*v >= 1, continue, end
    for it = 1:60
        step = hessAt(f, v(1), v(2)) \ [fx(v(1), v(2)); fy(v(1), v(2))];
        if ~all(isfinite(step)), break, end
        v = v - step;
        if norm(step) < 1e-12, break, end
    end
    if all(isfinite(v)) && norm([fx(v(1), v(2)); fy(v(1), v(2))]) < 1e-6 ...
            && v(2) > 1e-6 && v'*v < 1 - 1e-6 ...
            && (isempty(found) || all(vecnorm(found - v', 2, 2) > 1e-4))
        found(end+1, :) = v'; %#ok<AGROW>
    end
end
warning(warnState)
for k = 1:size(found, 1)
    C(end+1) = struct('x', found(k,1), 'y', found(k,2), 'type', 'interior', ...
        'note', ['interior critical point (grad f = 0): ' classify(hessAt(f, found(k,1), found(k,2)))]); %#ok<AGROW>
end

% 2) Edge A (y = 0): 1D problem g(x) = f(x,0); look for sign changes of g'(x)
dg = @(x) (f(x+h, 0*x) - f(x-h, 0*x))/(2*h);
xs = linspace(-1, 1, nS);  d = dg(xs);
for i = find(d(1:end-1).*d(2:end) < 0)
    x = fzero(dg, [xs(i) xs(i+1)]);
    C(end+1) = struct('x', x, 'y', 0, 'type', 'edge', ...
        'note', 'critical point of the 1D function f(x,0) along Edge A (y = 0)'); %#ok<AGROW>
end

% 3) Arc B: 1D problem g(t) = f(cos t, sin t), 0 <= t <= pi
dg = @(t) (f(cos(t+h), sin(t+h)) - f(cos(t-h), sin(t-h)))/(2*h);
ts = linspace(0, pi, nS);  d = dg(ts);
for i = find(d(1:end-1).*d(2:end) < 0)
    t = fzero(dg, [ts(i) ts(i+1)]);
    C(end+1) = struct('x', cos(t), 'y', sin(t), 'type', 'arc', ...
        'note', 'critical point of the 1D function f(cos t, sin t) along Arc B'); %#ok<AGROW>
end

% 4) Corners: the endpoints of both 1D problems
C(end+1) = struct('x', -1, 'y', 0, 'type', 'corner', 'note', 'corner (-1,0): endpoint of both 1D problems');
C(end+1) = struct('x',  1, 'y', 0, 'type', 'corner', 'note', 'corner (1,0): endpoint of both 1D problems');
end

function H = hessAt(f, x, y)
% Numerical Hessian of f at (x,y)
d = 1e-3;  f0 = f(x, y);
Hxx = (f(x+d, y) - 2*f0 + f(x-d, y))/d^2;
Hyy = (f(x, y+d) - 2*f0 + f(x, y-d))/d^2;
Hxy = (f(x+d, y+d) - f(x+d, y-d) - f(x-d, y+d) + f(x-d, y-d))/(4*d^2);
H = [Hxx Hxy; Hxy Hyy];
end

function cls = classify(H)
% Second-derivative test
D = det(H);
if D < -1e-8
    cls = 'saddle';
elseif D > 1e-8 && H(1,1) > 0
    cls = 'local min';
elseif D > 1e-8
    cls = 'local max';
else
    cls = 'test inconclusive';
end
end

function s = bdryS(x, y, type)
% Position(s) of a point on the unrolled boundary: Edge A is s = 0..2, Arc B is s = 2..2+pi
switch type
    case 'edge',   s = x + 1;
    case 'arc',    s = 2 + atan2(y, x);
    case 'corner'
        if x > 0, s = 2; else, s = [0, 2+pi]; end
    otherwise,     s = [];
end
end