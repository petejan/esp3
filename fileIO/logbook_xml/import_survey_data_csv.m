function surv_data_struct=import_survey_data_csv(FileN,Voyage,SurveyName)
surv_data_struct=[];

if exist(FileN,'file')==2
    surv_data_struct=csv2struct_perso(FileN);
    %{'Voyage' 'SurveyName' 'Filename' 'Snapshot' 'Stratum' 'Transect' 'StartTime' 'Comment' 'EndTime'}
    if any(~isfield(surv_data_struct,{'Filename' 'Snapshot' 'Stratum' 'Transect'}))
        surv_data_struct=[];
        warning('cannot find required fields in the *.csv file...');
        return;
    end
    
    if ~iscell(surv_data_struct.Stratum)
        idx_nan=isnan(surv_data_struct.Stratum);
        surv_data_struct.Stratum=replace_vec_per_cell(surv_data_struct.Stratum);
        surv_data_struct.Stratum(idx_nan)={''};
    end
    
 
    
    surv_data_struct.SurvDataObj=cell(1,length(surv_data_struct.Stratum));
    surv_data_struct.Voyage=cell(1,length(surv_data_struct.Stratum));
    surv_data_struct.Voyage(:)={Voyage};
    
    surv_data_struct.SurveyName=cell(1,length(surv_data_struct.Stratum));
    surv_data_struct.SurveyName(:)={SurveyName};
    surv_data_struct.Comment=cell(1,length(surv_data_struct.Stratum));
    surv_data_struct.Comment(:)={''};
    surv_data_struct.StartTime=zeros(1,length(surv_data_struct.Stratum));
    surv_data_struct.EndTime=ones(1,length(surv_data_struct.Stratum));
    
    for i=1:length(surv_data_struct.Stratum)

        surv_data_struct.SurvDataObj{i}=survey_data_cl(...
            'Voyage',surv_data_struct.Voyage{i},...
            'SurveyName',surv_data_struct.SurveyName{i},...
            'Snapshot',surv_data_struct.Snapshot(i),...
            'Stratum',surv_data_struct.Stratum{i},...
            'Transect',surv_data_struct.Transect(i),...
            'StartTime',0,...
            'EndTime',1);
        
    end
    
end
