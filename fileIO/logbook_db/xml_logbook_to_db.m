function xml_logbook_to_db(xml_file)

if exist(xml_file,'file')==0
    return;
end

surv_data_struct=import_survey_data_xml(xml_file);

if isempty(surv_data_struct)
    return;
end

[path_f,~,~]=fileparts(xml_file);
survey_data_struct_to_sqlite(path_f,surv_data_struct);

end