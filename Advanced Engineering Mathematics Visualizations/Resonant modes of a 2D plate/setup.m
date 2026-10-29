function setup()
    root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    addpath(genpath(fullfile(root, 'helper')));
end