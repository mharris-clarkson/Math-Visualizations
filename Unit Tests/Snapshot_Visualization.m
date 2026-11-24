function S = Snapshot_Visualization(scriptPath, options)
%% Record a fingerprint of everything one visualization draws
% Runs the visualization with its figure hidden and the random seed fixed,
% then moves every slider (to the fractions in SliderPoints) and clicks
% every LaTeX button twice. After start-up and after each action it
% records every graphics object in every figure with its data, colors,
% text, limits, visibility and positions (positions MATLAB places
% automatically, and hidden axes toolbars, are left out). Running timers
% are stopped after each action so animations give a stable snapshot.
%
% Two fingerprints of the same script (for example before and after a
% code change) are compared with Compare_Snapshots. Run_Snapshots does
% this for every script in a folder.
%
%% Syntax
%
% S = Snapshot_Visualization(p)
% S = Snapshot_Visualization(p, 'SliderPoints', [0 0.25 0.5 0.75 1], 'Repeats', 2)
%
% Inputs:
%
% scriptPath     - full path of the visualization file (a function file).
% 'SliderPoints' - slider positions as fractions of [Min, Max] (default [0 0.5 1]).
% 'Repeats'      - start the script this many times and keep the fastest
%                  start-up time (default 1).
%
% Outputs:
%
% S  - struct with fields Name, Status ("pass"/"fail"), Message, Startup
%      (s), Actions (labels), ActionTimes (s) and States (one fingerprint
%      per action, the first one after start-up).
%
%% Author Info
%
% Written by Claude for Dr Matthew Harris, assistant professor at
% Clarkson University, for MA 231: Calculus 3, following the style of his
% Math-Visualizations scripts.

arguments
    scriptPath {mustBeTextScalar}
    options.SliderPoints double = [0 0.5 1]
    options.Repeats      double = 1
end
scriptPath = char(scriptPath);
[folder, name] = fileparts(scriptPath);
S = struct('Name', string(name), 'Status', "pass", 'Message', "", ...
    'Startup', NaN, 'Actions', {{}}, 'States', {{}}, 'ActionTimes', []);

closeAll();
oldFolder = cd(folder);
restoreFolder = onCleanup(@() cd(oldFolder));
oldVis = get(groot, 'DefaultFigureVisible');
set(groot, 'DefaultFigureVisible', 'off');
restoreVis = onCleanup(@() set(groot, 'DefaultFigureVisible', oldVis));
oldWarn = warning('off', 'all');
restoreWarn = onCleanup(@() warning(oldWarn));

%% Start-up
times = zeros(1, options.Repeats);
try
    for rep = 1:options.Repeats
        closeAll();
        rng(0);
        t0 = tic;
        feval(name);
        drawnow
        times(rep) = toc(t0);
    end
catch err
    S.Status  = "fail";
    S.Message = string(err.message);
    closeAll();
    return
end
S.Startup = min(times);
record("start-up", 0);

%% Controls, in a stable order (top to bottom, then left to right)
figs  = findall(groot, 'Type', 'figure');
ctrls = findall(figs, 'Type', 'uicontrol');
sliders = ctrls(strcmp(get(ctrls, 'Style'), 'slider'));
btns = gobjects(0);
for k = 1:numel(ctrls)
    ud = ctrls(k).UserData;
    if isstruct(ud) && isfield(ud, 'ax') && strcmp(ctrls(k).Style, 'togglebutton')
        btns(end+1) = ctrls(k); %#ok<AGROW>
    end
end
sliders = sortByPos(sliders);
btns    = sortByPos(btns);

%% Exercise the controls
for s = sliders(:)'
    for p = options.SliderPoints
        if ~isvalid(s), break, end
        v = s.Min + p*(s.Max - s.Min);
        doAct(sprintf('slider %d -> %.3g', find(sliders == s), p), @() setAndCall(s, v));
    end
end
for b = btns(:)'
    for k = 1:2
        if ~isvalid(b), break, end
        doAct(sprintf('button %d click %d', find(btns == b), k), @() clickLatex(b));
    end
end
closeAll();

%% ---------------- nested helpers ----------------
    function doAct(label, fcn)
        rng(1);
        try
            t1 = tic; fcn(); drawnow; dt = toc(t1);
            tm = timerfindall;
            if ~isempty(tm), stop(tm); end
        catch err
            dt = NaN; label = [label ' ERROR: ' err.message];
        end
        record(string(label), dt);
    end

    function record(label, dt)
        S.Actions{end+1}     = label;
        S.ActionTimes(end+1) = dt;
        S.States{end+1}      = fingerprint(findall(groot, 'Type', 'figure'));
    end
end

%% ---------------- local functions ----------------
function h = sortByPos(h)
if isempty(h), return, end
P = zeros(numel(h), 2);
for k = 1:numel(h)
    if isstruct(h(k).UserData) && isfield(h(k).UserData, 'ax_position')
        pp = h(k).UserData.ax_position;
    else
        pp = h(k).Position;
    end
    P(k, :) = round(pp(1:2), 3);
end
[~, i] = sortrows([-P(:,2) P(:,1)]);
h = h(i);
end

function F = fingerprint(figs)
% Every graphics object with the properties that decide what is shown
props = {'Visible','XData','YData','ZData','CData','UData','VData','WData', ...
    'Vertices','Faces','FaceColor','EdgeColor','Color','String','FaceAlpha', ...
    'EdgeAlpha','AlphaData','LineWidth','LineStyle','Marker','MarkerSize', ...
    'MarkerFaceColor','MarkerEdgeColor','XLim','YLim','ZLim','CLim','View', ...
    'Colormap','DataAspectRatio','Interpreter','FontSize','HorizontalAlignment', ...
    'VerticalAlignment','Value','Min','Max','Location','Units'};
skipClasses = {'matlab.ui.container.Menu', 'matlab.ui.container.Toolbar', ...
    'matlab.ui.controls.AxesToolbar', 'matlab.ui.container.toolbar.PushTool', ...
    'matlab.ui.container.toolbar.ToggleTool', 'matlab.ui.container.toolbar.ToggleSplitTool'};
F = struct('Type', {}, 'Path', {}, 'Props', {});
for f = figs(:)'
    objs = findall(f);
    for k = 1:numel(objs)
        o = objs(k);
        if any(cellfun(@(c) isa(o, c), skipClasses)), continue, end
        e.Type = class(o);
        e.Path = pathOf(o);
        p = struct();
        for j = 1:numel(props)
            if isprop(o, props{j})
                try
                    v = o.(props{j});
                    if isa(v, 'function_handle') || (isobject(v) && ~isstring(v)), continue, end
                    p.(props{j}) = v;
                catch
                end
            end
        end
        % Positions MATLAB places automatically (titles, axis labels) vary
        % from run to run, so only positions set by the script are kept
        if isprop(o, 'Position') && ~isa(o, 'matlab.ui.Figure')
            autoPos = isprop(o, 'PositionMode') && strcmp(o.PositionMode, 'auto');
            if ~autoPos
                try, p.Position = o.Position; catch, end
            end
        end
        e.Props = p;
        F(end+1) = e; %#ok<AGROW>
    end
end
end

function s = pathOf(o)
s = class(o);
p = o.Parent;
while ~isempty(p) && ~isa(p, 'matlab.ui.Root')
    s = [class(p) '/' s]; %#ok<AGROW>
    p = p.Parent;
end
end

function setAndCall(h, v)
h.Value = v;
cb = h.Callback;
if isa(cb, 'function_handle')
    cb(h, []);
elseif iscell(cb)
    cb{1}(h, [], cb{2:end});
end
end

function clickLatex(b)
% Same path as a mouse click on a uicontrol_Latex button
ax = b.UserData.ax;
fcn = ax.ButtonDownFcn;
fcn(ax, []);
end

function closeAll()
t = timerfindall;
if ~isempty(t), stop(t); delete(t); end
close all force
end
