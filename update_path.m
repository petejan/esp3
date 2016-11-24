
function update_path(path)
addpath(path);
addpath(genpath(fullfile(path, 'processing')));
addpath(genpath(fullfile(path, 'classes')));
addpath(genpath(fullfile(path, 'algos')));
addpath(genpath(fullfile(path, 'display')));
addpath(genpath(fullfile(path, 'fileIO')));
addpath(genpath(fullfile(path, 'icons')));
addpath(genpath(fullfile(path, 'mapping')));
addpath(genpath(fullfile(path, 'external_toolboxes')));
sqlite_file=ls(fullfile(path,'java','sqlite*.jar'));
javaclasspath(fullfile(path,'java',sqlite_file(1,:)));
%to connect to an existing db: 
%conn = database('D:\Docs\Data misc\tan1505\hull\ek60','','','org.sqlite.JDBC','jdbc:sqlite:D:\Docs\Data misc\tan1505\hull\ek60\echo_logbook.db');
end
