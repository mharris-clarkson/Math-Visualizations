function St_Petersburg_Paradox()
%% Simulates the St. Petersburg paradox. In one game a fair coin is flipped
%  until it lands heads. If the first heads comes on flip k the payout is
%  2^k dollars, which happens with probability 2^(-k). The expected payout
%
%     E[payout] = sum_{k=1}^{inf} 2^k * 2^(-k) = 1 + 1 + 1 + ... = infinity
%
%  is a divergent series, yet almost every single game pays only a few
%  dollars.
%
%   Left  : running average payout after the first n games (log scale in
%           n), with the curve log_2(n) for comparison. The average never
%           settles down: it keeps creeping up, roughly like log_2(n), and
%           jumps whenever a rare, enormous payout happens.
%   Right : the payout of every game (log scale), with the largest one
%           marked in red. The jumps on the left line up with these.
%
%  A slider along the bottom sets the number of games n. The Reroll button
%  plays a fresh set of games.
%
%% Author Info
%
% Written by Claude for Dr Matthew Harris, assistant professor at
% Clarkson University, for MA 330: Advanced Engineering Mathematics,
% following the style of his
% Math-Visualizations scripts.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
nMax = 1000000;   % largest number of games on the slider
n0   = 1000;      % initial number of games

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('St. Petersburg Paradox', 2);
axAvg = app.ax(1);
axPay = app.ax(2);

%% Optional math functions for plot computations
% Play N games. For u uniform on (0,1), k = ceil(-log2(u)) gives
% P(k) = 2^(-k) for k = 1, 2, 3, ..., which is the flip of the first heads.
    function [payout, flips] = play_games(N)
        flips  = ceil(-log2(rand(1, N)));
        payout = 2.^flips;
    end

%% Precompute math for updates
% All nMax games are played once per roll; the slider chooses how many to show
[Payout, Flips] = play_games(nMax);
RunningAvg      = cumsum(Payout) ./ (1:nMax);
games           = 1:nMax;

%% Make the initial plots
% Running average (left), drawn at 400 log-spaced points
gRef = unique(round(logspace(0, log10(nMax), 400)));
hRef = plot(axAvg, gRef, log2(gRef), 'k--', 'LineWidth', 1.5);
hAvg = plot(axAvg, NaN, NaN, 'b-', 'LineWidth', 2);
set(axAvg, 'XScale', 'log')
xlabel(axAvg, 'Number of games $n$')
ylabel(axAvg, 'Average payout (\$)')
legend(axAvg, [hAvg, hRef], {'Running average payout', '$\log_2 n$'}, 'Location', 'northwest')

% Payout of every game (right)
hPay = plot(axPay, NaN, NaN, '.', 'Color', [0.3 0.3 0.3], 'MarkerSize', 8);
hMax = plot(axPay, NaN, NaN, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 9);
set(axPay, 'YScale', 'log')
xlabel(axPay, 'Game number')
ylabel(axPay, 'Payout $2^k$ (\$)')

%% Build UI
NumControls = 2;

nSlider = app.addControl('slider', 'Games $n = $', 1, NumControls, @updatePlot, ...
    'Default', n0, 'Min', 1, 'Max', nMax, 'Number_format', '%d', 'colOrRow', 'row');

app.addControl('button', 'Reroll', 2, NumControls, @reroll, 'colOrRow', 'row');

updatePlot();

%% Functions for UI elements
    % Play a fresh set of games and redraw with the same n
    function reroll(~, ~)
        [Payout, Flips] = play_games(nMax);
        RunningAvg      = cumsum(Payout) ./ (1:nMax);
        updatePlot();
    end

%% Main Draw update function.
    function updatePlot(~, ~)
        n = max(1, round(nSlider.Value));

        % Running average after each of the first n games
        set(hAvg, 'XData', games(1:n), 'YData', RunningAvg(1:n))
        xlim(axAvg, [1, max(n, 2)])
        ylim(axAvg, [0, 1.1*max([RunningAvg(1:n), log2(max(n, 2))])])

        % Payouts of the first n games, largest one marked
        [biggest, iBig] = max(Payout(1:n));
        set(hPay, 'XData', games(1:n), 'YData', Payout(1:n))
        set(hMax, 'XData', iBig, 'YData', biggest)
        xlim(axPay, [0, max(n, 2)])
        ylim(axPay, [1, 2*biggest])

        title(axAvg, splitlines(sprintf(['Average payout after $n = %d$ games: \\$%.2f\n' ...
            'Expected payout per game $= \\sum_{k=1}^{\\infty} 2^k \\cdot 2^{-k} = \\infty$'], ...
            n, RunningAvg(n))))
        title(axPay, splitlines(sprintf(['Largest payout: \\$%d in game %d ' ...
            '(first heads on flip %d)\nMedian payout: \\$%d'], ...
            biggest, iBig, Flips(iBig), round(median(Payout(1:n))))))
    end
end