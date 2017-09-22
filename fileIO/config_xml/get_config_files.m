function [display_config_file,path_config_file,algo_config_files]=get_config_files(algos_names)

app_path_main=whereisEcho();
config_path=fullfile(app_path_main,'config');
display_config_file=fullfile(config_path,'display_config.xml');
path_config_file=fullfile(config_path,'path_config.xml');
if nargin==0
    algos=init_algos();
else
    algos=init_algos(algos_names);
end

algo_config_files=cell(1,numel(algos));
for i_algo=1:numel(algos)
    algo_config_files{i_algo}=fullfile(config_path,'algos',sprintf('%s.xml',algos(i_algo).Name));
end
