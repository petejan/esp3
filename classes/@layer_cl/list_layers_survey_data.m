function output=list_layers_survey_data(layers)

output=[];
nb_survd=0;
for it=1:length(layers)
    [curr_folder,~,~]=fileparts(layers(it).Filename{1});
    
    if ~isempty(layers(it).SurveyData)
        for is=1:length(layers(it).SurveyData)
            nb_survd=nb_survd+1;
            survd=layers(it).get_survey_data('Idx',is);
            if isempty(survd)&&length(length(layers(it).SurveyData))>1
                nb_survd=nb_survd-1;
                continue;
            elseif isempty(survd)
                survd=survey_data_cl();
            end
            output.SurveyName{nb_survd}=survd.SurveyName;
            output.Voyage{nb_survd}=survd.Voyage;
            output.Snapshot(nb_survd)=survd.Snapshot;
            output.Stratum{nb_survd}=survd.Stratum;
            output.Transect(nb_survd)=survd.Transect;
            output.EndTime(nb_survd)=survd.EndTime;
            output.StartTime(nb_survd)=survd.StartTime;
            output.Layer_idx(nb_survd)=it;
            output.Folder{nb_survd}=curr_folder;
        end
    else
        nb_survd=nb_survd+1;
        survd=survey_data_cl(); 
        output.SurveyName{nb_survd}=survd.SurveyName;
        output.Voyage{nb_survd}=survd.Voyage;
        output.Snapshot(nb_survd)=survd.Snapshot;
        output.Stratum{nb_survd}=survd.Stratum;
        output.Transect(nb_survd)=survd.Transect;
        output.EndTime(nb_survd)=survd.EndTime;
        output.StartTime(nb_survd)=survd.StartTime;
        output.Layer_idx(nb_survd)=it;
        output.Folder{nb_survd}=curr_folder;
        
    end
    
    
end



end