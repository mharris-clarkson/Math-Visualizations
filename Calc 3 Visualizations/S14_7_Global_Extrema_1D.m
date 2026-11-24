function S14_7_Global_Extrema_1D()
%% Absolute Extrema on a Closed Interval (the Calc 1 version of S14_7_Global_Extrema)
% Finds the absolute max and min of f(x) on the closed interval [a, b]
% using the closed-interval method, with every step found automatically:
%   1) Interior:   critical points, where f'(x) = 0, with a < x < b
%   2) Endpoints:  x = a and x = b
% The largest / smallest value among these candidates is the absolute max /
% min. Not every critical point is a local max or min: the default f has a
% critical point that is also an inflection point (f' = 0 but f' does not
% change sign, so f keeps going down), the 1D cousin of a saddle point.
%
% Two views: f on [a, b] (top) and f' (bottom), where the first derivative
% test can be read off from the sign of f'. Buttons jump between the
% absolute max and min, or step through every candidate.
%
%% Author Info
%
% Written by Claude for Dr Matthew Harris, assistant professor at
% Clarkson University, for MA 231: Calculus 3, following the style of his
% Math-Visualizations scripts.

close all

%% User parameters for math objects
% Default: f'(x) = (x-1)^2 (x+1)(x-3), so x = -1 is a local max, x = 3 a
% local min, and x = 1 is a critical point AND an inflection point (double
% root of f'). f falls steeply on both sides of x = 1 (f' = -3 at x = 0 and
% x = 2) and flattens out completely at x = 1, so the pause is easy to see.
% Any f(x) written with elementwise operators (.*  ./  .^) works.
f = @(x) x.^5/5 - x.^4 + 2*x.^3/3 + 2*x.^2 - 3*x;

xWin   = [-1.8 4.0];   % window where f is drawn and critical points are searched
a      = -1.6;         % the closed interval [a, b]
b      =  3.8;
fpYLim = 6;            % f' plot shows -fpYLim..fpYLim

nS    = 2001;          % samples when searching for f' = 0
nPlot = 600;           % plot resolution
tanHalf = 0.6;         % half length of the horizontal tangent drawn at a critical point

colCurve  = [0.00 0.45 0.74];   % f and f': blue
colEnd    = [0.70 0.10 0.70];   % endpoints: purple
colFaint  = [0.75 0.75 0.75];   % f outside [a, b]

%% Automatically find every critical point of f in the window (once)
[critX, critNote] = findCriticalPoints(f, xWin, nS);

%% Sample f and f' over the window
xp  = linspace(xWin(1), xWin(2), nPlot);
fpl = f(xp);
dpl = Diff_f(f, xp);
inAB   = xp >= a & xp <= b;                 % y range from [a, b] only
fRange = [min(fpl(inAB)), max(fpl(inAB))];
padF   = 0.08*diff(fRange);

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('Absolute Extrema on a Closed Interval', 2, "col");   % f on top, f' below
axF = app.ax(1);  axD = app.ax(2);

%% View 1: f, faint over the whole window, bold on [a, b]
plot(axF, xp, fpl, '--', 'Color', colFaint, 'LineWidth', 1.5);
hF = plot(axF, NaN, NaN, '-', 'Color', colCurve, 'LineWidth', 4);
xline(axF, [a b], ':', 'Color', colEnd, 'LineWidth', 2);
hCritF = plot(axF, NaN, NaN, 'ko', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'w', ...
    'MarkerSize', 11, 'LineStyle', 'none');
hEndPt = plot(axF, NaN, NaN, 'd', 'MarkerFaceColor', colEnd, 'MarkerEdgeColor', 'w', ...
    'MarkerSize', 12, 'LineStyle', 'none');
xlim(axF, xWin);  ylim(axF, fRange + padF*[-1 1])
ylabel(axF, '$f(x)$')

%% View 2: f' with the zero line
yline(axD, 0, 'k-', 'LineWidth', 1);
plot(axD, xp, dpl, '-', 'Color', colCurve, 'LineWidth', 3);
xline(axD, [a b], ':', 'Color', colEnd, 'LineWidth', 2);
hCritD = plot(axD, NaN, NaN, 'ko', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'w', ...
    'MarkerSize', 11, 'LineStyle', 'none');
xlim(axD, xWin);  ylim(axD, fpYLim*[-1 1])
xlabel(axD, '$x$');  ylabel(axD, '$f''(x)$')

%% The selected candidate (created once, moved by selectCandidate)
selOpts = {'p', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'MarkerSize', 24, ...
    'LineWidth', 1.5, 'LineStyle', 'none'};
hTan  = plot(axF, NaN, NaN, 'r--', 'LineWidth', 2);    % horizontal tangent at a critical point
selF  = plot(axF, NaN, NaN, selOpts{:});
selD  = plot(axD, NaN, NaN, selOpts{:});
hSelD = xline(axD, xWin(1), 'r--', 'LineWidth', 1.5, 'Visible', 'off');

%% Candidates on [a, b] (filled in by setupCandidates)
cx = []; cf = []; ctype = {}; cnote = {}; nC = 0; idx = 1;

%% Build UI
NumControls = 2;
btnMaxMin = app.addControl('button', 'Jump to Absolute Min', 1, NumControls, @jumpMaxMin, ...
    'colOrRow', 'row');
app.addControl('button', 'Next Candidate (by value)', 2, NumControls, @nextCandidate, ...
    'colOrRow', 'row');

% Stretch the f' plot up to just below the f plot's tick labels
drawnow limitrate
posF = axF.Position;
posD = axD.Position;
topD = posF(2) - axF.TightInset(2) - 0.02;
axD.Position(4) = topD - posD(2);

setupCandidates()

%% Callbacks
% Draw the bold part of f on [a, b], find and rank the candidates, and
% select the absolute max
function setupCandidates()
    in  = xp >= a & xp <= b;
    xin = [a, xp(in), b];
    set(hF, 'XData', xin, 'YData', f(xin))

    % Candidates: critical points strictly inside (a, b), and the endpoints
    tol = 1e-9;
    keep  = critX > a + tol & critX < b - tol;
    cx    = [critX(keep), a, b];
    ctype = [repmat({'critical'}, 1, nnz(keep)), {'endpoint', 'endpoint'}];
    cnote = [critNote(keep), {'left endpoint $x = a$', 'right endpoint $x = b$'}];
    cf    = f(cx);
    [cf, order] = sort(cf);              % ascending: first = abs min, last = abs max
    cx = cx(order);  ctype = ctype(order);  cnote = cnote(order);
    nC = numel(cf);

    isCrit = strcmp(ctype, 'critical');
    set(hCritF, 'XData', cx(isCrit),  'YData', cf(isCrit))
    set(hCritD, 'XData', cx(isCrit),  'YData', zeros(1, nnz(isCrit)))
    set(hEndPt, 'XData', cx(~isCrit), 'YData', cf(~isCrit))

    idx = nC;                            % start on the absolute max
    selectCandidate(idx)
end

function jumpMaxMin(~, ~)
    if idx == nC, idx = 1; else, idx = nC; end
    selectCandidate(idx)
end

function nextCandidate(~, ~)
    idx = mod(idx, nC) + 1;
    selectCandidate(idx)
end

%% Move the highlight to candidate k in both views and update the text
function selectCandidate(k)
    set(selF, 'XData', cx(k), 'YData', cf(k))
    set(selD, 'XData', cx(k), 'YData', min(max(Diff_f(f, cx(k)), -fpYLim), fpYLim))
    set(hSelD, 'Value', cx(k), 'Visible', 'on')

    % Horizontal tangent line at a critical point
    if strcmp(ctype{k}, 'critical')
        set(hTan, 'XData', cx(k) + tanHalf*[-1 1], 'YData', cf(k)*[1 1])
    else
        set(hTan, 'XData', NaN, 'YData', NaN)
    end

    if k == nC, kind = 'ABSOLUTE MAX'; elseif k == 1, kind = 'ABSOLUTE MIN'; else, kind = sprintf('Candidate %d of %d', k, nC); end
    title(axF, {sprintf('%s: $f = %.4f$ at $x = %.3f$', kind, cf(k), cx(k)), cnote{k}})
    app.fig.Name = sprintf('%s: f = %.4f at x = %.3f', kind, cf(k), cx(k));

    if idx == nC, btnMaxMin.String = 'Jump to Absolute Min'; else, btnMaxMin.String = 'Jump to Absolute Max'; end
    drawnow limitrate
end

end

%% ========================================================================
% Stateless helpers
% ========================================================================

function [xc, notes] = findCriticalPoints(f, xWin, nS)
% Every x in the window with f'(x) = 0, found numerically, with its type.
% A sign change of f' gives a max or min. A double root of f' (f' touches
% zero without crossing, as at an inflection point) has no sign change, so
% it is found instead as a zero of f'' where f' is also zero.
fp  = @(x) Diff_f(f, x);
fpp = @(x) Diff2_f(f, x);
xs  = linspace(xWin(1), xWin(2), nS);
xc  = [];

% Zeros of f' where it changes sign
d = fp(xs);
for i = find(d(1:end-1).*d(2:end) < 0)
    xc(end+1) = fzero(fp, [xs(i) xs(i+1)]); %#ok<AGROW>
end

% Zeros of f'' where f' is (numerically) zero too: f' touches zero
dd = fpp(xs);
for i = find(dd(1:end-1).*dd(2:end) < 0)
    x = fzero(fpp, [xs(i) xs(i+1)]);
    if abs(fp(x)) < 1e-6 && all(abs(xc - x) > 1e-6)
        xc(end+1) = x; %#ok<AGROW>
    end
end
xc = sort(xc);
xc(abs(xc) < 1e-7) = 0;   % avoid printing -0.000

% First derivative test: the sign of f' just left and right of each point
notes = cell(1, numel(xc));
delta = 1e-3;
for k = 1:numel(xc)
    sL = sign(fp(xc(k) - delta));
    sR = sign(fp(xc(k) + delta));
    if sL > 0 && sR < 0
        notes{k} = 'critical point ($f''=0$): local max, $f''$ changes from $+$ to $-$';
    elseif sL < 0 && sR > 0
        notes{k} = 'critical point ($f''=0$): local min, $f''$ changes from $-$ to $+$';
    else
        notes{k} = ['critical point ($f''=0$) AND inflection point: neither, ' ...
                    '$f''$ does not change sign'];
    end
end
end
