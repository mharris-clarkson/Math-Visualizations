function Run_Snapshots(outDir, options)
%% Fingerprint every visualization and save one .mat file per script
% Runs Snapshot_Visualization on every function file in the Calc 3 and
% Advanced folders and saves the result as <outDir>/<name>.mat, printing
% the status and timings. Scripts in Excluded_Visualizations.m, plain
% scripts, and scripts that wait for a person are skipped.
%
% To check that a code change does not change what is shown:
%   1. Fingerprint the code BEFORE the change. The easiest way is a clean
%      copy of the last commit, e.g. in a terminal:
%         git worktree add ../MV_before HEAD
%      then  Run_Snapshots('before', 'Root', '..\MV_before')
%   2. Make the change, then  Run_Snapshots('after')
%   3. Compare_Snapshots('before', 'after')
% A difference that also shows up when the SAME code is fingerprinted
% twice is run-to-run noise (animations, layouts that depend on timing).
% The first script of a fresh MATLAB session includes MATLAB's own
% warm-up, so its start-up time is too high (use 'Repeats', 2 or more).
%
%% Syntax
%
% Run_Snapshots('before')
% Run_Snapshots('after', 'Filter', "S15_*")
% Run_Snapshots('before', 'Root', 'C:\...\MV_before', 'Repeats', 2)
%
% Inputs:
%
% outDir     - folder for the .mat files (made if needed). A relative path
%              is inside Unit Tests/results, which git ignores.
% 'Root'     - repository root to test (default: the one holding this
%              file). A relative path is relative to the Unit Tests folder.
% 'Filter'   - file name pattern, e.g. "S16_*" (default "*").
% 'Repeats'  - start-ups per script; the fastest time is kept (default 2).
%
%% Author Info
%
% Written by Claude for Dr Matthew Harris, assistant professor at
% Clarkson University, for MA 231: Calculus 3, following the style of his
% Math-Visualizations scripts.

arguments
    outDir            {mustBeTextScalar}
    options.Root      {mustBeTextScalar} = fileparts(fileparts(mfilename('fullpath')))
    options.Filter    string = "*"
    options.Repeats   double = 2
end
here = fileparts(mfilename('fullpath'));
root = char(options.Root);
outDir = char(outDir);
if ~isAbsolute(outDir), outDir = fullfile(here, 'results', outDir); end
if ~isAbsolute(root),   root   = fullfile(here, root);   end

oldPath = addpath(genpath(fullfile(root, 'Helper')), here);
restorePath = onCleanup(@() path(oldPath));
if ~isfolder(outDir), mkdir(outDir); end

exNames = Excluded_Visualizations();
blocking = ["input(", "ginput", "uiwait", "waitforbuttonpress", "audiorecorder"];
dirs = ["Calc 3 Visualizations", "Advanced Engineering Mathematics Visualizations"];
for d = dirs
    L = dir(fullfile(root, d, '**', options.Filter + ".m"));
    for k = 1:numel(L)
        f = fullfile(L(k).folder, L(k).name);
        [~, n] = fileparts(f);
        if strcmpi(n, 'setup'), continue, end
        if any(strcmpi(exNames, n + ".m"))
            fprintf('%-50s skipped (Excluded_Visualizations)\n', n); continue
        end
        code = regexprep(fileread(f), '%[^\n]*', '');
        if ~startsWith(strtrim(code), 'function') || contains(code, blocking)
            fprintf('%-50s skipped (plain script or waits for input)\n', n); continue
        end
        S = Snapshot_Visualization(f, 'Repeats', options.Repeats);
        save(fullfile(outDir, n + ".mat"), 'S');
        fprintf('%-50s %-5s start-up %6.3fs  slowest action %6.3fs  %s\n', ...
            n, S.Status, S.Startup, max([0 S.ActionTimes]), S.Message);
    end
end
end

function tf = isAbsolute(p)
tf = startsWith(p, filesep) || ~isempty(regexp(p, '^[A-Za-z]:', 'once'));
end
