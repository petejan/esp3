function load_echo_logbook_db(layers_obj)

survey_data_struct_lay=[];
pathtofile=cell(1,length(layers_obj));
incomplete=0;
for ilay=1:length(layers_obj)
    [pathtofile{ilay},~,~]=fileparts(layers_obj(ilay).Filename{1});
end

pathtofile=unique(pathtofile);

for ip=1:length(pathtofile)
    fileN=fullfile(pathtofile{ip},'echo_logbook.xml');
    if exist(fileN,'file')==0
        initialize_echo_logbook_dbfile(pathtofile{ip},0);
    end
    
    dbconn=sqlite(fullfile(pathtofile{ip},'echo_logbook.db'));
    
    
    close(dbconn);
    
    files_db=dbconn.fecth('select Filename from logbook');
    
    dir_raw=dir(fullfile(pathtofile{ip},'*.raw'));
    dir_asl=dir(fullfile(pathtofile{ip},'*A'));
    
    list_raw=union({dir_raw(:).name},{dir_asl(:).name});

    if nansum(cellfun(@(x) nansum(strcmpi(files_db,strtrim(x))),list_raw)==0)>0
        incomplete=1;
        fprintf('%s incomplete, we''ll update it\n',fileN);
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
end

layers_obj.add_survey_data_db(survey_data_struct);

if incomplete>0
    layers_obj.update_echo_logbook_dbfile;
end

end