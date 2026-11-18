function r = Exercise_Visualization(scriptPath, options)
%% Run one visualization and push every slider and button it creates.
% Used by Test_All_Visualizations (unit test) and
% Run_All_Visualization_Tests (spreadsheet of results). It:
%   1. runs the script/function with figures hidden and times start-up,
%   2. finds every uicontrol in every figure it made,
%   3. moves each slider to Min, the middle and Max (by default) and runs
%      its callback, clicks each LaTeX button twice (on, then back off),
%      fires raw push/toggle buttons, check boxes and pop-up menus,
%   4. records errors, warnings (e.g. "Unable to interpret LaTeX string")
%      and the time each callback takes, then closes everything.
%
%% Syntax
%
% r = Exercise_Visualization('C:\...\Calc 3 Visualizations\S13_3_Arc_Length.m')
% r = Exercise_Visualization(p, 'SliderPoints', [0 0.25 0.5 0.75 1])
% r = Exercise_Visualization(p, 'IgnoreExclusions', true)   % run an excluded file anyway
%
% Files named in Excluded_Visualizations (infinite animations, long
% simulations) are not run: they come back with Status "skipped" and a
% Message saying they would normally run and why they were skipped.
%
% Outputs:
%
% r  - struct with fields Name, Folder, Status ("pass"/"fail"/"skipped"),
%      Message, StartupTime, NumSliders, NumButtons, NumOther,
%      ControlErrors, Warnings, SlowestCallback, SlowestControl,
%      NotExercised, ErrorTrace (the error report MATLAB would print,
%      one entry per error, trimmed to the frames inside the script).
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.

arguments
    scriptPath        {mustBeTextScalar}
    options.SliderPoints  double  = [0 0.5 1]   % fractions of [Min, Max]
    options.ClickButtons  logical = true
    options.MaxActions    double  = 400         % safety cap per script
    options.Hidden        logical = true        % build figures off-screen
    options.IgnoreExclusions logical = false    % true: also run files in Excluded_Visualizations
    options.SkipPatterns  string  = ["input(", "ginput", "uigetfile", "uiputfile", ...
        "uiwait", "waitforbuttonpress", "audiorecorder", "recordblocking", ...
        "keyboard", "inputdlg", "questdlg", "clear all", "clear classes"]
end

scriptPath = char(scriptPath);
[folder, name] = fileparts(scriptPath);
r = struct('Name', string(name), 'Folder', string(folder), 'Status', "pass", ...
    'Message', "", 'StartupTime', NaN, 'NumSliders', 0, 'NumButtons', 0, ...
    'NumOther', 0, 'ControlErrors', strings(0,1), 'Warnings', strings(0,1), ...
    'SlowestCallback', 0, 'SlowestControl', "", 'NotExercised', "", ...
    'ErrorTrace', strings(0,1));

%% Skip files listed in Excluded_Visualizations (say so, with the reason)
if ~options.IgnoreExclusions
    [exNames, exReasons] = Excluded_Visualizations();
    hitEx = strcmpi(exNames, [name '.m']);
    if any(hitEx)
        r.Status  = "skipped";
        r.Message = "SKIPPED (excluded): would normally run, but " + exReasons(find(hitEx, 1)) + ...
            ". Listed in Excluded_Visualizations.m";
        return
    end
end

%% Skip files that block waiting for a person (or would wipe the runner)
src = fileread(scriptPath);
code = regexprep(src, '%[^\n]*', '');             % ignore comments
hit = options.SkipPatterns(arrayfun(@(p) contains(code, p), options.SkipPatterns));
if ~isempty(hit)
    r.Status  = "skipped";
    r.Message = "SKIPPED (automatic): would normally run, but contains " + strjoin(hit, ", ") + ...
        " (needs a person or clears the test runner)";
    return
end

%% Clean start
closeAll();
oldFolder = cd(folder);                           % relative loads (images, .mat) work
restoreFolder = onCleanup(@() cd(oldFolder));
lastwarn('');
oldWarn = warning('off', 'backtrace');
restoreWarn = onCleanup(@() warning(oldWarn));
if options.Hidden
    oldVis = get(groot, 'DefaultFigureVisible');
    set(groot, 'DefaultFigureVisible', 'off');
    restoreVis = onCleanup(@() set(groot, 'DefaultFigureVisible', oldVis));
end

%% 1. Start-up
isFunction = ~isempty(regexp(strtrim(code), '^function\s', 'once'));
try
    t0 = tic;
    if isFunction
        feval(name);
    else
        runScript(scriptPath);
    end
    drawnow
    r.StartupTime = toc(t0);
catch err
    r.Status  = "fail";
    r.Message = "Start-up error: " + string(err.message) + locationOf(err);
    r.ErrorTrace(end+1, 1) = "[start-up]" + newline + traceOf(err);
    closeAll();
    return
end
r.Warnings = [r.Warnings; takeWarning("start-up")];

%% 2. Find every control
figs = findall(groot, 'Type', 'figure');
if isempty(figs)
    r.Message = "No figure was created";
    return
end
ctrls  = findall(figs, 'Type', 'uicontrol');
styles = strings(numel(ctrls), 1);
for k = 1:numel(ctrls), styles(k) = string(ctrls(k).Style); end
isLatexBtn = false(numel(ctrls), 1);
for k = 1:numel(ctrls)
    ud = ctrls(k).UserData;
    isLatexBtn(k) = isstruct(ud) && isfield(ud, 'ax') && styles(k) == "togglebutton";
end
isSlider  = styles == "slider";
sliders   = ctrls(isSlider);
latexBtns = ctrls(isLatexBtn);
others    = ctrls(~isLatexBtn & ~isSlider & ~ismember(styles, ["text" "frame" "edit"]));
r.NumSliders = numel(sliders);
r.NumButtons = numel(latexBtns);
r.NumOther   = numel(others);

% Mouse-driven figures (drag points, click to place) cannot be exercised
% automatically; list them so they get a manual check.
mouse = strings(0);
for f = figs(:)'
    if ~isempty(f.WindowButtonDownFcn) || ~isempty(f.WindowButtonMotionFcn) ...
            || ~isempty(f.WindowScrollWheelFcn) || ~isempty(f.KeyPressFcn)
        mouse(end+1) = "figure mouse/keyboard callbacks"; %#ok<AGROW>
    end
end
clickable = findall(figs, '-property', 'ButtonDownFcn');
nClick = 0;
for k = 1:numel(clickable)
    h = clickable(k);
    if isempty(h.ButtonDownFcn) || isa(h, 'matlab.ui.Figure'), continue, end
    inControl = strcmp(h.Tag, 'uiFigureControl') || ...
        (isprop(h, 'Parent') && isprop(h.Parent, 'Tag') && strcmp(h.Parent.Tag, 'uiFigureControl'));
    if ~inControl, nClick = nClick + 1; end
end
if nClick > 0
    mouse(end+1) = nClick + " object(s) with ButtonDownFcn";
end
r.NotExercised = strjoin(unique(mouse), "; ");

%% 3. Exercise the controls
nActions = 0;

% Sliders: Min, middle, Max (or the requested fractions)
for s = sliders(:)'
    for p = options.SliderPoints
        if nActions >= options.MaxActions || ~isvalid(s), break, end
        v = s.Min + p*(s.Max - s.Min);
        act(s, sprintf('slider %s = %.4g', describe(s), v), @() setAndCall(s, v));
    end
end

% LaTeX buttons: click (on) then click again (back to the start state)
if options.ClickButtons
    for b = latexBtns(:)'
        for k = 1:2
            if nActions >= options.MaxActions || ~isvalid(b), break, end
            act(b, sprintf('button "%s" click %d', describe(b), k), @() clickLatex(b));
        end
    end
    % Raw uicontrols (scripts not yet ported to uiFigure)
    for c = others(:)'
        if nActions >= options.MaxActions || ~isvalid(c), break, end
        switch c.Style
            case {'popupmenu', 'listbox'}
                n = max(1, numel(cellstr(c.String)));
                for k = 1:n
                    act(c, sprintf('%s "%s" item %d', c.Style, describe(c), k), ...
                        @() setAndCall(c, k));
                end
            case {'togglebutton', 'checkbox', 'radiobutton'}
                for k = 1:2
                    act(c, sprintf('%s "%s" click %d', c.Style, describe(c), k), ...
                        @() setAndCall(c, double(~c.Value)));
                end
            otherwise   % pushbutton
                act(c, sprintf('%s "%s"', c.Style, describe(c)), @() callCallback(c));
        end
    end
end

if ~isempty(r.ControlErrors)
    r.Status  = "fail";
    r.Message = numel(r.ControlErrors) + " control error(s)";
elseif ~isempty(r.Warnings)
    r.Message = numel(r.Warnings) + " warning(s)";
end
closeAll();

%% ---------------- nested helpers ----------------
    function act(h, label, fcn)
        nActions = nActions + 1;
        lastwarn('');
        try
            t1 = tic;
            fcn();
            drawnow
            dt = toc(t1);
            if dt > r.SlowestCallback
                r.SlowestCallback = dt;
                r.SlowestControl  = string(label);
            end
        catch err
            r.ControlErrors(end+1, 1) = string(label) + ": " + string(err.message) + locationOf(err);
            r.ErrorTrace(end+1, 1) = "[" + string(label) + "]" + newline + traceOf(err);
        end
        r.Warnings = [r.Warnings; takeWarning(label)];
        if ~isvalid(h) && isempty(findall(groot, 'Type', 'figure'))
            nActions = options.MaxActions;   % the figure was closed: stop
        end
    end
end

%% ---------------- local functions ----------------
function runScript(p)
% Runs a plain script in its own workspace so it cannot touch the runner.
run(p);
end

function setAndCall(h, v)
h.Value = v;
callCallback(h);
end

function callCallback(h)
cb = h.Callback;
if isempty(cb)
    return
elseif isa(cb, 'function_handle')
    cb(h, []);
elseif iscell(cb)
    cb{1}(h, [], cb{2:end});
else
    evalin('base', cb);
end
end

function clickLatex(b)
% Same path as a real mouse click on a uicontrol_Latex button
ax = b.UserData.ax;
fcn = ax.ButtonDownFcn;
if isa(fcn, 'function_handle')
    fcn(ax, []);
else
    callCallback(b);
end
end

function s = describe(h)
s = '';
if isstruct(h.UserData) && isfield(h.UserData, 'label') && isgraphics(h.UserData.label)
    s = h.UserData.label.String;
elseif isstruct(h.UserData) && isfield(h.UserData, 'name')
    s = char(h.UserData.name);
end
if isempty(s), s = h.String; end
if iscell(s), s = strjoin(s, '|'); end
s = char(s);
if numel(s) > 40, s = [s(1:40) '...']; end
end

function w = takeWarning(where)
[msg, id] = lastwarn;
w = strings(0,1);
if ~isempty(msg)
    w = string(where) + ": " + string(msg);
    if ~isempty(id), w = w + " [" + string(id) + "]"; end
end
lastwarn('');
end

function s = locationOf(err)
s = "";
if ~isempty(err.stack)
    s = sprintf(" (%s line %d)", err.stack(1).name, err.stack(1).line);
end
end

function s = traceOf(err)
% The error report MATLAB prints in the Command Window ("Error using ...",
% "Error in ... (line N)"), without hyperlinks. Frames that belong to this
% test runner are cut off so only the script's own call chain is left.
s = string(getReport(err, 'extended', 'hyperlinks', 'off'));
lines = splitlines(s);
cut = find(startsWith(strtrim(lines), "Error in Exercise_Visualization") | ...
           startsWith(strtrim(lines), "Error in run ") | ...
           startsWith(strtrim(lines), "Error in run>"), 1);
if ~isempty(cut) && cut > 1
    lines = lines(1:cut-1);
end
s = strtrim(strjoin(lines, newline));
end

function closeAll()
t = timerfindall;
if ~isempty(t)
    stop(t);
    delete(t);
end
close all force
end
