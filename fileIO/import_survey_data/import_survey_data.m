function surv_data_struct=import_survey_data(FileN)
surv_data_struct=[];

if exist(FileN,'file')==2
    surv_data_struct=csv2struct_perso(FileN);
    
    if ~isempty(find(isfield(surv_data_struct,{'Voyage' 'SurveyName' 'Filename' 'Snapshot' 'Stratum' 'Transect' 'StartTime' 'EndTime'})==0, 1))
        surv_data_struct=[];
        warning('cannot find required fields in the *.csv file...');
        return;
    end
    
    if ~iscell(surv_data_struct.Voyage)
        idx_nan=isnan(surv_data_struct.Voyage);
        surv_data_struct.Voyage=replace_vec_per_cell(surv_data_struct.Voyage);
        surv_data_struct.Voyage(idx_nan)={''};
    end
    
    if ~iscell(surv_data_struct.SurveyName)
        idx_nan=isnan(surv_data_struct.SurveyName);
        surv_data_struct.SurveyName=replace_vec_per_cell(surv_data_struct.SurveyName);
        surv_data_struct.SurveyName(idx_nan)={''};
    end
    
    if ~iscell(surv_data_struct.Stratum)
        idx_nan=isnan(surv_data_struct.Stratum);
        surv_data_struct.Stratum=replace_vec_per_cell(surv_data_struct.Stratum);
        surv_data_struct.Stratum(idx_nan)={''};
    end
    
    surv_data_struct.SurvDataObj=cell(1,length(surv_data_struct.Stratum));
    for i=1:length(surv_data_struct.Stratum)
                    if surv_data_struct.StartTime(i)==0
                        st=0;
                    else
                        st=datenum(num2str(surv_data_struct.StartTime(i)),'yyyymmddHHMMSS');
                    end
                    
                    if surv_data_struct.EndTime(i)==1
                        et=1;
                    else
                        et=datenum(num2str(surv_data_struct.EndTime(i)),'yyyymmddHHMMSS');
                    end

        
        surv_data_struct.SurvDataObj{i}=survey_data_cl(...
            'Voyage',surv_data_struct.Voyage{i},...
            'SurveyName',surv_data_struct.SurveyName{i},...
            'Snapshot',surv_data_struct.Snapshot(i),...
            'Stratum',surv_data_struct.Stratum{i},...
            'Transect',surv_data_struct.Transect(i),...
            'StartTime',st,...
            'EndTime',et);
        
    end
    
end
