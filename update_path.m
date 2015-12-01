
function update_path(path)
addpath(path);
addpath(genpath(fullfile(path, 'acoustic')));
addpath(genpath(fullfile(path, 'classes')));
addpath(genpath(fullfile(path, 'algos')));
addpath(genpath(fullfile(path, 'GUI_parts')));
addpath(genpath(fullfile(path, 'esp2')));
addpath(genpath(fullfile(path, 'export')));
addpath(genpath(fullfile(path, 'fileIO')));
addpath(genpath(fullfile(path, 'icons')));
addpath(genpath(fullfile(path, 'general')));
addpath(genpath(fullfile(path, 'mapping')));
addpath(genpath(fullfile(path, 'signal_processing')));
addpath(genpath(fullfile(path, 'external_toolboxes')));
end
