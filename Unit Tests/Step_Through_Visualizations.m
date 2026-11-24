function report = Step_Through_Visualizations(options)
%% Run the visualizations one at a time; the next one starts when you close the figure
% Opens each visualization in turn. When every window it opened has been
% closed, the next one starts. An error is printed and the run moves on to
% the next file. Press Ctrl+C in the Command Window to stop.
%
%% Syntax
%
% Step_Through_Visualizations()                              % everything
% Step_Through_Visualizations('Filter', "S16_*")             % only some files
% Step_Through_Visualizations('StartAt', "S15_1_Double_Integral_Definition")
% Step_Through_Visualizations('StartAt', 20)                 % from the 20th file
% Step_Through_Visualizations('Skip', string.empty)          % skip nothing
% report = Step_Through_Visualizations(...)                  % table of what ran
%
% Inputs:
%
% 'Filter'     - file name pattern, e.g. "S14_*" (default "*").
% 'StartAt'    - file name or position in the list to start from.
% 'Skip'       - names to leave out (default: the long simulation and the
%                files that only play sound or write files).
% 'IncludeWIP' - also include the Work In progress folder (default false).
%
% Outputs:
%
% report - table with each file's name, folder, status and time open.
%
%% Author Info
%
% Written by Claude for Dr Matthew Harris, assistant professor at
% Clarkson University, for MA 231: Calculus 3, following the style of his
% Math-Visualizations scripts.

arguments
    options.Filter     string = "*"
    options.StartAt           = 1
    options.Skip       string = ["Run_KHI_Sim", "Callabrate_FFT", "Batch_Image_To_Audio", "Mario"]
    options.IncludeWIP logical = false
end
here = fileparts(mfilename('fullpath'));
root = fileparts(here);
oldPath = addpath(genpath(fullfile(root, 'Helper')), here);
restorePath = onCleanup(@() path(oldPath));
startFolder = pwd;
restoreFolder = onCleanup(@() cd(startFolder));

%% The list of files, in order
s = Find_Visualization_Scripts('IncludeWIP', options.IncludeWIP);
files = string(struct2cell(s));
[~, names] = fileparts(files);
keep = matches(names, wildcardPattern2regexp(options.Filter), 'IgnoreCase', true) ...
     & ~ismember(names, options.Skip);
files = files(keep);  names = names(keep);
if isempty(files)
    fprintf('No files match.\n');
    report = table();
    return
end

first = 1;
if isnumeric(options.StartAt)
    first = options.StartAt;
else
    hit = find(strcmpi(names, string(options.StartAt)), 1);
    if isempty(hit), error('StartAt: "%s" is not in the list.', options.StartAt); end
    first = hit;
end

n = numel(files);
Status = strings(n, 1);  Seconds = nan(n, 1);
closeAll();
fprintf('%d visualizations. Close the figure window(s) to go on, Ctrl+C to stop.\n\n', n - first + 1);

%% Run them one at a time
for k = first:n
    [folder, nm] = fileparts(files(k));
    fprintf('[%d/%d] %s\n', k, n, nm);
    cd(folder);
    t0 = tic;
    try
        code = regexprep(fileread(files(k)), '%[^\n]*', '');
        if startsWith(strtrim(code), 'function')
            feval(nm);
        else
            runScript(files(k));
        end
        drawnow
        Status(k) = "ok";
    catch err
        Status(k) = "error";
        fprintf(2, '   Error: %s\n', err.message);
    end
    % Wait until every window this file opened has been closed
    while true
        try
            figs = findall(groot, 'Type', 'figure');
        catch                                  % interrupted (e.g. by an animation timer)
            pause(0.2);
            continue
        end
        figs = figs(isvalid(figs));
        if isempty(figs), break, end
        waitfor(figs(1));
    end
    Seconds(k) = toc(t0);
    closeAll();
end

report = table(names, erase(fileparts(files), [root filesep]), Status, Seconds, ...
    'VariableNames', {'Name', 'Folder', 'Status', 'SecondsOpen'});
report = report(first:n, :);
fprintf('\nDone: %d ok, %d with errors.\n', nnz(report.Status == "ok"), nnz(report.Status == "error"));
end

%% ---------------- local functions ----------------
function runScript(p)
% Plain scripts run in their own workspace
run(p);
end

function closeAll()
t = timerfind;   % timers the visualizations made (hidden ones are left alone)
if ~isempty(t), stop(t); delete(t); end
close all force
end

function rx = wildcardPattern2regexp(pat)
% "S16_*" -> regular expression matching the whole name
rx = regexpPattern("^" + regexprep(regexptranslate('escape', pat), '\\\*', '.*') + "$");
end
