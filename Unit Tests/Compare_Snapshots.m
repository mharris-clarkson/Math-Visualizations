function ok = Compare_Snapshots(beforeDir, afterDir, names, options)
%% Compare two sets of visualization fingerprints made by Run_Snapshots
% For every script that has a .mat file in both folders, checks that the
% same objects were drawn with the same properties after start-up and
% after every control action. Text and settings must be identical;
% numbers must agree to a relative tolerance. Prints SAME (with the
% start-up and slowest-action times before -> after) or DIFFERS with the
% first differences found. Hidden axes toolbars are ignored.
%
%% Syntax
%
% ok = Compare_Snapshots('before', 'after')
% ok = Compare_Snapshots('before', 'after', ["S16_8_Stokes_Theorem", "S13_3_Arc_Length"])
% ok = Compare_Snapshots('before', 'after', [], 'Tol', 1e-9)
%
% Inputs:
%
% beforeDir, afterDir - folders of .mat files (a relative path is inside
%                       Unit Tests/results, as in Run_Snapshots).
% names               - scripts to compare (default: all found in both).
% 'Tol'               - relative tolerance for numbers (default 1e-6).
% 'MaxShown'          - differences printed per script (default 25).
%
% Outputs:
%
% ok  - true when every compared script is the same.
%
%% Author Info
%
% Written by Claude for Dr Matthew Harris, assistant professor at
% Clarkson University, for MA 231: Calculus 3, following the style of his
% Math-Visualizations scripts.

arguments
    beforeDir {mustBeTextScalar}
    afterDir  {mustBeTextScalar}
    names     string = string.empty
    options.Tol      double = 1e-6
    options.MaxShown double = 25
end
resultsDir = fullfile(fileparts(mfilename('fullpath')), 'results');
beforeDir = char(beforeDir);  afterDir = char(afterDir);
if ~isAbsolute(beforeDir), beforeDir = fullfile(resultsDir, beforeDir); end
if ~isAbsolute(afterDir),  afterDir  = fullfile(resultsDir, afterDir);  end
if isempty(names)
    A = dir(fullfile(beforeDir, '*.mat'));
    B = dir(fullfile(afterDir, '*.mat'));
    names = intersect(string(erase({A.name}, '.mat')), string(erase({B.name}, '.mat')));
end

ok = true;
nSame = 0;
for n = names(:)'
    A = load(fullfile(beforeDir, n + ".mat")).S;
    B = load(fullfile(afterDir,  n + ".mat")).S;
    msgs = strings(0);
    if A.Status ~= B.Status
        msgs(end+1) = "status " + A.Status + " -> " + B.Status + " " + B.Message; %#ok<AGROW>
    end
    if numel(A.States) ~= numel(B.States)
        msgs(end+1) = sprintf("number of states %d -> %d", numel(A.States), numel(B.States)); %#ok<AGROW>
    end
    for s = 1:min(numel(A.States), numel(B.States))
        FA = dropToolbar(A.States{s});  FB = dropToolbar(B.States{s});
        if numel(FA) ~= numel(FB)
            msgs(end+1) = sprintf("[%s] object count %d -> %d", A.Actions{s}, numel(FA), numel(FB)); %#ok<AGROW>
            continue
        end
        for k = 1:numel(FA)
            if ~strcmp(FA(k).Type, FB(k).Type)
                msgs(end+1) = sprintf("[%s] object %d type %s -> %s", A.Actions{s}, k, FA(k).Type, FB(k).Type); %#ok<AGROW>
                break
            end
            pa = FA(k).Props;  pb = FB(k).Props;
            fn = union(fieldnames(pa), fieldnames(pb));
            for j = 1:numel(fn)
                f = fn{j};
                if ~isfield(pa, f) || ~isfield(pb, f) || ~same(pa.(f), pb.(f), options.Tol)
                    msgs(end+1) = sprintf("[%s] %s #%d .%s differs", A.Actions{s}, FA(k).Type, k, f); %#ok<AGROW>
                end
            end
        end
    end
    if isempty(msgs)
        nSame = nSame + 1;
        fprintf('%-50s SAME     start-up %.3fs -> %.3fs   slowest action %.3fs -> %.3fs\n', n, ...
            A.Startup, B.Startup, max([0 A.ActionTimes]), max([0 B.ActionTimes]));
    else
        ok = false;
        fprintf('%-50s DIFFERS (%d)\n', n, numel(msgs));
        fprintf('    %s\n', msgs(1:min(end, options.MaxShown)));
    end
end
fprintf('\n%d of %d scripts the same\n', nSame, numel(names));
end

function tf = isAbsolute(p)
tf = startsWith(p, filesep) || ~isempty(regexp(p, '^[A-Za-z]:', 'once'));
end

function F = dropToolbar(F)
if isempty(F), return, end
F = F(~contains(string({F.Path}), "Toolbar"));
end

function tf = same(a, b, tol)
if (isnumeric(a) && isnumeric(b)) || (islogical(a) && islogical(b))
    if ~isequal(size(a), size(b)), tf = false; return, end
    a = double(a);  b = double(b);
    na = isnan(a);  nb = isnan(b);
    if ~isequal(na, nb), tf = false; return, end
    a = a(~na);  b = b(~nb);
    if isempty(a), tf = true; return, end
    fa = isfinite(a);
    scale = max([1; abs(reshape(a(fa), [], 1))]);
    tf = isequal(isinf(a), isinf(b)) && isequal(a(~fa), b(~fa)) && ...
         all(abs(a(fa) - b(fa)) <= tol*scale);
else
    tf = isequal(a, b);
end
end
