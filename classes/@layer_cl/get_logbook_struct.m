function surv_data_struct=get_logbook_struct(layer_obj)

[path_lay,~]=get_path_files(layer_obj);
file_name=fullfile(path_lay{1},'echo_logbook.csv');

if exist(file_name,'file')==0
    initialize_echo_logbook_file(path_lay{1});
end

surv_data_struct=import_survey_data(fullfile(path_lay{1},'echo_logbook.csv'));
end