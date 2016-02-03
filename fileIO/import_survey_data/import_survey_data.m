function [filenames,survey_data]=import_survey_data(PathToFile,FileName)
survey_data=[];
if exist(fullfile(PathToFile,FileName),'file')==2
    surv_data_struct=csv2struct(fullfile(PathToFile,FileName));
    %Filename	SurveyName	Voyage	Snapshot	Stratum	Transect	VerticalSlice
    
    if isempty(find(isfield(surv_data_struct,{'Filename','SurveyName','Voyage','Snapshot','Stratum','Transect','VerticalSlice'})==0, 1))
        filenames=surv_data_struct.Filename;
        for i=1:length(surv_data_struct.Filename)
            survey_data=[survey_data survey_data_cl('SurveyName',surv_data_struct.SurveyName{i},...
                'Voyage',surv_data_struct.Voyage{i},...
                'Snapshot',surv_data_struct.Snapshot(i),...
                'Stratum',surv_data_struct.Stratum(i),...
                'Transect',surv_data_struct.Transect(i),...
                'VerticalSlice',surv_data_struct.VerticalSlice(i))];
        end 
    else
        Warning('cannot find required fields in the *.csv file...');
    end
    
    
end

end
