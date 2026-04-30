%% Function that adds all current dirs to temp working path
function setup()
    root = fileparts(mfilename('fullpath'));
    addpath(genpath(root));
end