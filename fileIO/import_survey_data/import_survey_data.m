function [filenames,survey_data]=import_survey_data(PathToFile,FileName)
survey_data=[];

if exist(fullfile(PathToFile,FileName),'file')==2
    surv_data_struct=csv2struct(fullfile(PathToFile,FileName));
    %Filename	SurveyName	Voyage	Snapshot	Stratum	Transect
    
    if isempty(find(isfield(surv_data_struct,{'Datapath' 'Voyage' 'SurveyName' 'Filename' 'Snapshot' 'Stratum' 'Transect'})==0, 1))
        filenames=surv_data_struct.Filename;
        for i=1:length(surv_data_struct.Filename)
            if iscell(surv_data_struct.Stratum)
                strat=surv_data_struct.Stratum{i};
            else
                strat=surv_data_struct.Stratum(i);
            end
            if ~isnumeric(surv_data_struct.Stratum(i))
                snap=[];
            else
                snap=surv_data_struct.Snapshot(i);
            end
            
            if ~isnumeric(surv_data_struct.Transect(i))
                trans=[];
            else
                trans=surv_data_struct.Transect(i);
            end
            
            survey_data=[survey_data survey_data_cl('SurveyName',surv_data_struct.SurveyName{i},...
                'Voyage',surv_data_struct.Voyage{i},...
                'Snapshot',snap,...
                'Stratum',strat,...
                'Transect',trans)];
        end
    else
        warning('cannot find required fields in the *.csv file...');
    end
    
    
end

end
