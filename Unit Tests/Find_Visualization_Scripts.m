function scripts = Find_Visualization_Scripts(options)
%% List every visualization .m file, as a struct usable as a TestParameter
% Field names are valid identifiers built from the file path; values are
% full paths. New files are picked up automatically, no list to maintain.
%
% Files in Excluded_Visualizations are still listed here on purpose:
% Exercise_Visualization reports them as "skipped" with the reason, so
% the results show they would normally have been run.
%
%% Syntax
%
% s = Find_Visualization_Scripts()                       % Calc 3 + Advanced only
% s = Find_Visualization_Scripts('IncludeWIP', true)     % also Work In progress
%                                                        % (only if the folder exists)
%
% Work In progress is never listed unless you ask for it with
% 'IncludeWIP', true, so the unit tests never touch those scripts.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%

arguments
    options.Root       {mustBeTextScalar} = fileparts(fileparts(mfilename('fullpath')))
    options.Folders    string = ["Calc 3 Visualizations", "Advanced Engineering Mathematics Visualizations"]
    % Work In progress is only tested when asked for (and the folder exists)
    options.IncludeWIP logical = false
    % Files that are not visualizations at all (never listed)
    options.Exclude    string = ["setup.m", "cmocean.m", "Code_Template.m", "Code_Template_Blank.m"]
end

folders = options.Folders;
if options.IncludeWIP
    % Only add the private work-in-progress folder when it exists, so the
    % same test runs on a public copy of the project without that folder.
    if isfolder(fullfile(options.Root, "Work In progress"))
        folders(end+1) = "Work In progress";
    else
        warning('Find_Visualization_Scripts:noWIP', ...
            'IncludeWIP is true but "Work In progress" was not found in %s. Skipping it.', options.Root);
    end
end
% Skip any listed folder that is not in this copy of the project
folders = folders(arrayfun(@(f) isfolder(fullfile(options.Root, f)), folders));

scripts = struct();
for f = folders
    files = dir(fullfile(options.Root, f, '**', '*.m'));
    for k = 1:numel(files)
        if any(strcmpi(files(k).name, options.Exclude)), continue, end
        full = fullfile(files(k).folder, files(k).name);
        rel  = erase(full, [char(options.Root) filesep]);
        if contains(rel, [filesep 'Helper' filesep]), continue, end   % helper copies in WIP
        % Short, readable test names: C3_..., AEM_..., WIP_... (max 63 chars)
        abbrev = regexprep(char(f), {'^Calc 3 Visualizations$', ...
            '^Advanced Engineering Mathematics Visualizations$', '^Work In progress$'}, ...
            {'C3', 'AEM', 'WIP'});
        [~, nm] = fileparts(files(k).name);
        key  = matlab.lang.makeValidName([abbrev '_' nm]);
        key  = key(1:min(end, namelengthmax - 4));
        key  = matlab.lang.makeUniqueStrings(key, fieldnames(scripts), namelengthmax);
        scripts.(key) = full;
    end
end
end
