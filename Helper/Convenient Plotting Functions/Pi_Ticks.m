function Pi_Ticks(ax, whichAxis, step)
%% Put tick marks at multiples of pi with LaTeX labels (0, pi/2, pi, ...)
%
%% Syntax
%
% Pi_Ticks(app.ax, 'x')          % ticks every pi/2 across the current x-limits
% Pi_Ticks(app.ax, 'y', pi/4)    % ticks every pi/4 on the y axis
%
% Inputs:
%
% ax         - axes handle.
% whichAxis  - 'x', 'y' or 'z'.
% step       - spacing between ticks in radians (default pi/2).
%
%% Author Info
%
% Written by Claude for Dr Matthew Harris, assistant professor at
% Clarkson University, for MA 231: Calculus 3, following the style of his
% Math-Visualizations scripts.

arguments
    ax         matlab.graphics.axis.Axes
    whichAxis  {mustBeMember(whichAxis, {'x','y','z'})}
    step       (1,1) double {mustBePositive} = pi/2
end

lims  = ax.([upper(whichAxis) 'Lim']);
ticks = (ceil(lims(1)/step - 1e-9):floor(lims(2)/step + 1e-9)) * step;
labels = arrayfun(@(v) Pi_Label(v, 'MaxDen', 24), ticks, 'UniformOutput', false);

ax.([upper(whichAxis) 'Tick'])                = ticks;
ax.([upper(whichAxis) 'TickLabel'])           = labels;
ax.TickLabelInterpreter = 'latex';
end
