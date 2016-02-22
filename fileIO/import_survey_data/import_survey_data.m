function surv_data_struct=import_survey_data(PathToFile,FileName)
surv_data_struct=[];

if exist(fullfile(PathToFile,FileName),'file')==2
    surv_data_struct=csv2struct(fullfile(PathToFile,FileName));
    
    if ~isempty(find(isfield(surv_data_struct,{'Datapath' 'Voyage' 'SurveyName' 'Filename' 'Snapshot' 'Stratum' 'Transect' 'StartTime' 'EndTime'})==0, 1))
        surv_data_struct=[];
        warning('cannot find required fields in the *.csv file...');
    end
    
    if ~iscell(surv_data_struct.Voyage)
        surv_data_struct.Voyage=replace_vec_per_cell(surv_data_struct.Voyage);
    end
    
    if ~iscell(surv_data_struct.SurveyName)
        surv_data_struct.SurveyName=replace_vec_per_cell(surv_data_struct.SurveyName);
    end
    
    if ~iscell(surv_data_struct.Stratum)
        surv_data_struct.Stratum=replace_vec_per_cell(surv_data_struct.Stratum);
    end
    
end
