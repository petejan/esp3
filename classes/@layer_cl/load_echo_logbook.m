function load_echo_logbook(layers_obj)

survey_data_struct_lay=[];
pathtofile=cell(1,length(layers_obj));

for ilay=1:length(layers_obj)
    [pathtofile{ilay},~,~]=fileparts(layers_obj(ilay).Filename{1});
end

pathtofile=unique(pathtofile);

for ip=1:length(pathtofile)
    file=fullfile(pathtofile{ip},'echo_logbook.xml');
    if exist(file,'file')==0
        initialize_echo_logbook_file(pathtofile{ip});
    end
    survey_data_struct_temp=import_survey_data_xml(file);
    if ~isempty(survey_data_struct_temp)
        survey_data_struct_lay=[survey_data_struct_lay survey_data_struct_temp];
    end
end

fields=fieldnames(survey_data_struct_lay);

if ~isempty(survey_data_struct_lay)
    survey_data_struct=survey_data_struct_lay(1);
    if length(survey_data_struct_lay)>1
        for is=2:length(survey_data_struct_lay)
            for ui=1:length(fields)
                survey_data_struct.(fields{ui})=[survey_data_struct.(fields{ui});survey_data_struct_lay(is).(fields{ui})];
            end
        end
    end
else
    survey_data_struct=[];
end

layers_obj.add_survey_data(survey_data_struct);
layers_obj.update_echo_logbook_file();


end