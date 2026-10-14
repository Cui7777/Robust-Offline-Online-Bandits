function setup
% Add public code folders without exposing private implementation files.
root=fileparts(mfilename('fullpath'));
addpath(fullfile(root,'algorithms'),fullfile(root,'utils'), ...
    fullfile(root,'experiments','synthetic'),fullfile(root,'experiments','real_world'), ...
    fullfile(root,'experiments','contextual'),fullfile(root,'tests'));
end
