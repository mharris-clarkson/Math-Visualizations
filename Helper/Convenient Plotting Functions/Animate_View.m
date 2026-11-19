function Animate_View(ax, az, el, options)
%% Smoothly rotate the camera of an axes to a new view [az, el]
% This function rotates the camera from the current view to a new one 
% over a given time span. It replaces a few local functions that were 
% previously used. Uses 'drawnow limitrate' so the animation never 
% queues up frames on slow computers.
%
%% Syntax
%
% Animate_View(app.ax, 90, 0)                       % side view in 1 s
% Animate_View(app.ax, 45, 30, 'Duration', 0.5)
%
% Inputs:
%
% ax          - axes handle.
% az, el      - target azimuth and elevation in degrees.
% 'Duration'  - total time in seconds (default 1).
% 'Frames'    - number of frames (default 50).
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.

arguments
    ax                 matlab.graphics.axis.Axes
    az                 (1,1) double
    el                 (1,1) double
    options.Duration   (1,1) double = 1
    options.Frames     (1,1) double = 50
end

[az0, el0] = view(ax);
azs = linspace(az0, az, options.Frames);
els = linspace(el0, el, options.Frames);
dt  = options.Duration / options.Frames;
for k = 1:options.Frames
    if ~isvalid(ax), return, end   % figure closed mid-animation
    view(ax, azs(k), els(k))
    drawnow limitrate
    pause(dt)
end
end
