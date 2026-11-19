%% Function that adds the project folders to the temporary working path.
function setup()
    root  = fileparts(mfilename('fullpath'));
    parts = strsplit(genpath(root), pathsep);
    % Work In Progress is a local folder of files to be ported 
    keep  = parts(~contains(parts, [filesep 'Work In progress']) & ...
                  ~contains(parts, [filesep '.git']) & ~cellfun(@isempty, parts));
    addpath(strjoin(keep, pathsep));
end
