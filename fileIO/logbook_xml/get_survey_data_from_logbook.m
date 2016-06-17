function survey_data=get_survey_data_from_logbook(file_full)%file_full is the full filename with path (str)

[path_f,file_name,file_ext]=fileparts(file_full);

file=[file_name,file_ext];
file_name=fullfile(path_f,'echo_logbook.xml');

if exist(file_name,'file')==0
    initialize_echo_logbook_file(path_f);
end

surv_data_struct=import_survey_data_xml(file_name);
idx_surv_data=find(strcmp(file,surv_data_struct.Filename));

survey_data=cell(1,length(idx_surv_data));
for i=1:length(idx_surv_data)
    
        if surv_data_struct.StartTime(idx_surv_data(i))==0
            start_time=0;
        else
            start_time=datenum(num2str(surv_data_struct.StartTime(idx_surv_data(i))),'yyyymmddHHMMSS');
        end
        
        if surv_data_struct.EndTime(idx_surv_data(i))==1
            end_time=1;
        else
            end_time=datenum(num2str(surv_data_struct.EndTime(idx_surv_data(i))),'yyyymmddHHMMSS');
        end


    survey_data{i}=survey_data_cl('Voyage',surv_data_struct.Voyage{idx_surv_data(i)},'SurveyName',surv_data_struct.SurveyName{idx_surv_data(i)},...
        'Snapshot',surv_data_struct.Snapshot(idx_surv_data(i)),'Stratum',surv_data_struct.Stratum{idx_surv_data(i)},'Transect',surv_data_struct.Transect(idx_surv_data(i)),...
        'StartTime',start_time,'EndTime',end_time);
end

end