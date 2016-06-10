function survey_obj_str=list_survey(survey_obj_vec)
    survey_obj_str=cell(1,length(survey_obj_vec));

    for ii=1:length(survey_obj_vec)
        survey_obj_str{ii}=sprintf('%s_%s',survey_obj_vec(ii).SurvInput.Infos.SurveyName,survey_obj_vec(ii).SurvInput.Infos.Voyage);
    end

end