%% Adds the shared Helper folder (and its subfolders) to the MATLAB path.
%  The folder name is case sensitive on Linux and some macOS disks, so it
%  must be 'Helper' (capital H). This folder sits one level deeper than the
%  other visualization folders, hence the three fileparts calls.
%  Skips the work when the helpers are already on the path.
function setup()
    if exist('uiFigure', 'class') == 8 && exist('Pretty_Plot', 'file') == 2
        return
    end
    root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    addpath(genpath(fullfile(root, 'Helper')));
end
