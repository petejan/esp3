function output=list_layers_survey_data(layers)


nb_survd=0;
for it=1:length(layers)
    for is=1:length(layers(it).SurveyData)
        nb_survd=nb_survd+1;
        survd=layers(it).get_survey_data('Idx',is);
        if isempty(survd)
            nb_survd=nb_survd-1;
        end
        output.SurveyName{nb_survd}=survd.SurveyName;
        output.Voyage{nb_survd}=survd.Voyage;
        output.Snapshot(nb_survd)=survd.Snapshot;
        output.Stratum{nb_survd}=survd.Stratum;
        output.Transect(nb_survd)=survd.Transect;
        output.EndTime(nb_survd)=survd.EndTime;
        output.StartTime(nb_survd)=survd.StartTime;
        output.Layer_idx(nb_survd)=it;
    end
    
end



end