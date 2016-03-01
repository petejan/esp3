function surv_data_struct=load_logbook_to_struct(path_f)

file_name=fullfile(path_f,'echo_logbook.csv');

if exist(file_name,'file')==0
    initialize_echo_logbook_file(path_f);
end

surv_data_struct=import_survey_data(fullfile(path_f,'echo_logbook.csv'));

end