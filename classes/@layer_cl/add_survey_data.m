function add_survey_data(layer,survey_data_struct)
%'Datapath' 'Voyage' 'SurveyName' 'Filename' 'Snapshot' 'Stratum' 'Transect' 'StartTime' 'EndTime'

[idx_files,idx_loaded,idx_missing]=find_survey_data(layer.Filename,survey_data_struct);

surv_data=cell(1,length(idx_loaded));
for i=1:length(surv_data)
    if isempty(idx_loaded{i})
        surv_data{i}=[];
        continue;
    end
    start_time=survey_data_struct.StartTime(idx_loaded{i}(1));
    end_time=survey_data_struct.EndTime(idx_loaded{i}(1));
    
    if start_time==0
        start_time=layer.Transceivers(1).Data.Time(1);
    else
        start_time=datenum(num2str(end_time),'yyyymmddHHMMSS');
    end
    
    if end_time==1
        end_time=layer.Transceivers(1).Data.Time(end);
    else
        end_time=datenum(num2str(end_time),'yyyymmddHHMMSS');
    end
    
    surv_temp=survey_data_cl();
    surv_temp.Voyage=survey_data_struct.Voyage{idx_loaded{i}(1)};
    surv_temp.SurveyName=survey_data_struct.SurveyName{idx_loaded{i}(1)};
    surv_temp.Snapshot=survey_data_struct.Snapshot(idx_loaded{i}(1));
    surv_temp.Stratum=survey_data_struct.Stratum{idx_loaded{i}(1)};
    surv_temp.Transect=survey_data_struct.Transect(idx_loaded{i}(1));
    surv_temp.StartTime=start_time;
    surv_temp.EndTime=end_time;
    
    surv_data{i}=surv_temp;
end

layer.set_survey_data(surv_data);

end