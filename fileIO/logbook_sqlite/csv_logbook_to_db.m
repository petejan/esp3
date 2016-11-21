function csv_logbook_to_db(path_f,csv_file,Voyage,SurveyName)

if exist(fullfile(path_f,csv_file),'file')==0
    return;
end


surv_data_struct=import_survey_data_csv(fullfile(path_f,csv_file),Voyage,SurveyName);

if isempty(surv_data_struct)
    return;
end

survey_data_struct_to_sqlite(path_f,surv_data_struct);


end