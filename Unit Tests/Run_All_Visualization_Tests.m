function T = Run_All_Visualization_Tests(options)
%% Run every visualization, push every control, and save a results table
% Same checks as Test_All_Visualizations, but collects one row per script
% (status, start-up time, slowest callback, errors, error trace, warnings)
% and writes them to an Excel file in Tests/results. Use it as the
% start-up benchmark too: re-run after a change and compare the columns.
%
% By default every script is tested. With 'OnlyNew', true only scripts
% that have not been tested before are run (see "Record" below).
%
% Files in Excluded_Visualizations.m (for example S16_5_Divergence, an
% endless animation, and Run_KHI_Sim, a long simulation) are not run.
% They still get a row with Status "skipped" and a message saying they
% would normally run and why they were skipped, and they are listed at
% the end of the printout.
%
% Record: every run (full or 'OnlyNew') adds the scripts it tested to
% Tests/results/last_run_record.mat. A script that FAILS is taken off the
% record (by default), so 'OnlyNew' tests it again until it passes.
%
%% Syntax
%
% T = Run_All_Visualization_Tests();                     % every script (Calc 3 + Advanced)
% T = Run_All_Visualization_Tests('OnlyNew', true);      % only scripts not tested before
% T = Run_All_Visualization_Tests('OnlyNew', true, 'IncludeModified', true);
%                                                        % new + edited since last test
% T = Run_All_Visualization_Tests('BaselineOnly', true); % mark all as tested, run nothing
% T = Run_All_Visualization_Tests('Reset', true);        % forget the record, then run
% T = Run_All_Visualization_Tests('IncludeWIP', true);   % also Work In progress
%                                                        % (local to Dr. Harris, manual only)
% T = Run_All_Visualization_Tests('Filter', "S15_*");    % only some files
% T = Run_All_Visualization_Tests('Files', paths);       % exactly these files
%
% Results files (in Tests/results):
%   visualization_test_results.xlsx      full runs
%   new_visualization_test_results.xlsx  'OnlyNew' runs
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
arguments
    options.OnlyNew         logical = false   % false: run every script
    options.IncludeModified logical = false   % with OnlyNew: also re-test edited scripts
    options.RetryFailures   logical = true    % failed scripts are taken off the record
    options.BaselineOnly    logical = false   % record current scripts as tested, run nothing
    options.Reset           logical = false   % delete the record first
    % Work In progress is only tested when asked for (and the folder exists)
    options.IncludeWIP      logical = false
    options.Filter          string  = "*"
    options.SliderPoints    double  = [0:0.25:1]
    options.OutFile         string  = ""
    options.Files           string  = string.empty   % full paths; skips the folder search
end
here = fileparts(mfilename('fullpath'));
root = fileparts(here);
oldPath = addpath(genpath(fullfile(root, 'Helper')), here);
restorePath = onCleanup(@() path(oldPath));
resultsDir = fullfile(here, 'results');
if ~isfolder(resultsDir), mkdir(resultsDir); end
recordFile = fullfile(resultsDir, 'last_run_record.mat');

%% Which scripts
if isempty(options.Files)
    S = Find_Visualization_Scripts('Root', root, 'IncludeWIP', options.IncludeWIP);
    paths = string(struct2cell(S));
else
    paths = options.Files(:);
end
rel = erase(paths, string(root) + filesep);       % paths relative to the project
modified = zeros(numel(paths), 1);                 % last edit time of each file
for k = 1:numel(paths)
    d = dir(paths(k));
    if ~isempty(d), modified(k) = d.datenum; end
end

%% Record of scripts already tested
if options.Reset && isfile(recordFile)
    delete(recordFile);
    fprintf('Record deleted: every script counts as new.\n');
end
record = loadRecord(recordFile);

if options.BaselineOnly
    record = addToRecord(record, rel, modified, repmat("baseline", numel(rel), 1));
    save(recordFile, 'record');
    fprintf('Recorded %d scripts as already tested. Nothing was run.\n', numel(rel));
    T = table();
    return
end

if options.OnlyNew
    if isempty(record.Files)
        fprintf('No record yet: every script counts as new.\n');
    else
        fprintf('Last run: %s (%d scripts on record)\n', string(record.LastRun), numel(record.Files));
    end
    [known, where] = ismember(rel, record.Files);
    pick = ~known;
    if options.IncludeModified
        edited = known;
        edited(known) = modified(known) > record.Modified(where(known)) + 1e-6;
        pick = pick | edited;
    end
    if ~any(pick)
        fprintf('No new scripts since %s. Nothing to test.\n', string(record.LastRun));
        T = table();
        return
    end
    paths = paths(pick);
    rel = rel(pick);
    modified = modified(pick);
    fprintf('%d new script(s) to test:\n', numel(paths));
    fprintf('  %s\n', rel);
    fprintf('\n');
end

%% Test them
rows = cell(numel(paths), 1);
tested = false(numel(paths), 1);
n = 0;
for k = 1:numel(paths)
    p = char(paths(k));
    [~, nm] = fileparts(p);
    if ~matches(nm, wildcardPattern2regex(options.Filter)), continue, end
    fprintf('[%3d/%3d] %-55s', k, numel(paths), nm);
    r = Exercise_Visualization(p, 'SliderPoints', options.SliderPoints);
    fprintf('%-8s %6.2f s  %s\n', r.Status, r.StartupTime, r.Message);
    n = n + 1;
    tested(k) = true;
    rows{n} = {string(erase(r.Folder, [root filesep])), r.Name, r.Status, ...
        r.StartupTime, r.NumSliders, r.NumButtons, r.NumOther, ...
        r.SlowestCallback, r.SlowestControl, numel(r.ControlErrors), ...
        strjoin(r.ControlErrors, " || "), excelText(strjoin(r.ErrorTrace, newline + "----" + newline)), ...
        strjoin(r.Warnings, " || "), r.NotExercised, r.Message};
end

if n == 0
    warning('Run_All_Visualization_Tests:noFiles', ...
        'No script matched Filter "%s". Nothing was run.', options.Filter);
    T = table();
    return
end

rows = vertcat(rows{1:n});
T = cell2table(rows, 'VariableNames', {'Folder','File','Status','Startup_s', ...
    'Sliders','Buttons','OtherControls','SlowestCallback_s','SlowestControl', ...
    'NumErrors','Errors','ErrorTrace','Warnings','NeedsManualCheck','Message'});
fprintf('\n%d pass, %d fail, %d skipped. Total start-up %.1f s.\n', ...
    sum(T.Status == "pass"), sum(T.Status == "fail"), sum(T.Status == "skipped"), ...
    sum(T.Startup_s, 'omitnan'));

% Say which files would normally run but were skipped, and why
skipped = T(T.Status == "skipped", :);
if height(skipped) > 0
    fprintf('\nSkipped (would normally run) - check these by hand:\n');
    for i = 1:height(skipped)
        fprintf('  %-45s %s\n', skipped.File(i), skipped.Message(i));
    end
end

%% Update the record (rows of T are in the same order as tested files)
testedRel = rel(tested);
testedMod = modified(tested);
failed = T.Status == "fail";
if options.RetryFailures
    record = removeFromRecord(record, testedRel(failed));
    if any(failed)
        fprintf('\nTaken off the record (tested again by ''OnlyNew''): %s\n', ...
            strjoin(T.File(failed), ', '));
    end
    keep = ~failed;
else
    keep = true(height(T), 1);
end
record = addToRecord(record, testedRel(keep), testedMod(keep), T.Status(keep));
save(recordFile, 'record');

%% Save the results table
outFile = options.OutFile;
if strlength(outFile) == 0
    if options.OnlyNew
        outFile = fullfile(resultsDir, 'new_visualization_test_results.xlsx');
    else
        outFile = fullfile(resultsDir, 'visualization_test_results.xlsx');
    end
end
writetable(T, outFile);
fprintf('\nResults written to %s\n', outFile);
end

%% ---------------- local functions ----------------
function record = loadRecord(recordFile)
% Scripts already tested: relative path, file date when tested, status
if isfile(recordFile)
    rec = load(recordFile, 'record');
    record = rec.record;
else
    record = struct('Files', strings(0,1), 'Modified', zeros(0,1), ...
                    'Status', strings(0,1), 'LastRun', NaT);
end
end

function record = addToRecord(record, files, modified, status)
% Add or update entries, then stamp the time of this run
for k = 1:numel(files)
    j = find(record.Files == files(k), 1);
    if isempty(j)
        record.Files(end+1, 1)    = files(k);
        record.Modified(end+1, 1) = modified(k);
        record.Status(end+1, 1)   = status(k);
    else
        record.Modified(j) = modified(k);
        record.Status(j)   = status(k);
    end
end
record.LastRun = datetime('now');
end

function record = removeFromRecord(record, files)
% Take failed scripts off the record so 'OnlyNew' picks them up again
drop = ismember(record.Files, files);
record.Files(drop)    = [];
record.Modified(drop) = [];
record.Status(drop)   = [];
end

function s = excelText(s)
% An Excel cell holds at most 32,767 characters
maxLen = 32000;
if strlength(s) > maxLen
    s = extractBefore(s, maxLen) + newline + "... (trace cut to fit an Excel cell)";
end
end

function rx = wildcardPattern2regex(pat)
% "S15_*" -> regexpPattern('^S15_.*$')
rx = regexpPattern("^" + regexprep(regexptranslate('escape', pat), '\\\*', '.*') + "$");
end
