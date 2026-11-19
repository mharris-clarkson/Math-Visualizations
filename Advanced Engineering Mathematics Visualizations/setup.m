%% Adds the shared Helper folder (and its subfolders) to the MATLAB path.
%  The folder name is case sensitive on Linux and some macOS disks.
%  Skips the work when the helpers are already on the path, so starting a
%  second visualization does not rebuild the path (addpath/genpath and the
%  path refresh that follows are a noticeable part of start-up).
function setup()
    if exist('uiFigure', 'class') == 8 && exist('Pretty_Plot', 'file') == 2
        return
    end
    root   = fileparts(fileparts(mfilename('fullpath')));
    addpath(genpath(fullfile(root, 'Helper')));
end
