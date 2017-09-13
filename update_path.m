
function update_path(path)
addpath(path);
addpath(genpath(fullfile(path, 'ressources')));
addpath(genpath(fullfile(path, 'processing')));
addpath(genpath(fullfile(path, 'classes')));
addpath(genpath(fullfile(path, 'algos')));
addpath(genpath(fullfile(path, 'display')));
addpath(genpath(fullfile(path, 'fileIO')));
addpath(genpath(fullfile(path, 'icons')));
addpath(genpath(fullfile(path, 'mapping')));
addpath(genpath(fullfile(path, 'external_toolboxes')));
end
