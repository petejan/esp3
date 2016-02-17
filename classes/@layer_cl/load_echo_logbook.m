function load_echo_logbook(layer_obj)

if exist(fullfile(layer_obj.PathToFile,'echo_logbook.csv'),'file')==0
    initialize_echo_logbook_file(layer_obj.PathToFile);
end

[filenames,survey_data]=import_survey_data(layer_obj.PathToFile,'echo_logbook.csv');
layer_obj.add_survey_data(survey_data,filenames);
    
end