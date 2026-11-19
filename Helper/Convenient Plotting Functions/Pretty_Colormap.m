function cmap = Pretty_Colormap(name, NLevels)
%% Fast, cached drop-in for cmocean(name) and cmocean(name, NLevels)
% cmocean.m keeps the RGB tables of all 22 colormaps inside a ~500 kB text
% file, and MATLAB parses that whole file the first time it is called in a
% session. Pretty_Colormap reads the same tables from the small binary file
% cmocean_cache.mat once and keeps them in memory, so later calls are free.
%
%% Syntax
%
% cmap = Pretty_Colormap('balance')      % 256 x 3, same as cmocean('balance')
% cmap = Pretty_Colormap('solar', 12)    % 12 levels, same as cmocean('solar',12)
% cmap = Pretty_Colormap('-algae')       % leading '-' flips the map
% Pretty_Colormap('amp')                 % no output: applies to gca, like cmocean
% colormap(app.ax, Pretty_Colormap('amp'))   % preferred: name the axes
%
% Anything the cache cannot do (for example 'pivot' or 'negative') is passed
% on to cmocean itself, so the result is always the same as cmocean's.
%
% Inputs:
%
% name     - colormap name or its first three letters (as cmocean).
% NLevels  - optional number of colour levels (default 256).
%
% Outputs:
%
% cmap     - NLevels x 3 RGB array.
%
%% Author Info
%
% Written by Claude for Dr Matthew Harris, assistant professor at
% Clarkson University, for MA 231: Calculus 3, following the style of his
% Math-Visualizations scripts. Colormap data: Kristen Thyng's cmocean (MIT).

arguments
    name     {mustBeTextScalar}
    NLevels  double = 256
end

persistent maps
if isempty(maps)
    cacheFile = fullfile(fileparts(mfilename('fullpath')), 'cmocean_cache.mat');
    if isfile(cacheFile)
        maps = load(cacheFile);
    else
        maps = struct();   % no cache: every call falls back to cmocean
    end
end

name = char(name);
flip = startsWith(name, '-');
if flip
    name = name(2:end);
end

% Match on the first three letters, exactly as cmocean does
key = '';
fields = fieldnames(maps);
for i = 1:numel(fields)
    if strncmpi(fields{i}, name, 3) || (strncmpi(name, 'dem', 3) && strcmp(fields{i}, 'topo'))
        key = fields{i};
        break
    end
end

if isempty(key)
    % Unknown to the cache: let cmocean handle (or report) it
    if flip, name = ['-' name]; end
    cmap = cmocean(name, NLevels);
else
    cmap = maps.(key);
    if flip
        cmap = flipud(cmap);
    end
    if NLevels ~= size(cmap, 1)
        cmap = interp1(1:size(cmap,1), cmap, linspace(1, size(cmap,1), NLevels), 'linear');
    end
end

% Match cmocean's behaviour when called without an output
if nargout == 0
    colormap(gca, cmap)
    clear cmap
end
end
