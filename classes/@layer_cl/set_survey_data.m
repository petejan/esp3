function set_survey_data(layer_obj,surv_data_obj)


if ~iscell(surv_data_obj)
    surv_data_obj={surv_data_obj};
end

for i_cell=1:length(surv_data_obj)

    if ~isempty(surv_data_obj{i_cell})
        if (surv_data_obj{i_cell}.StartTime)==0
            surv_data_obj{i_cell}.StartTime(i_cell)=layer_obj.Transceivers(1).Data.Time(1);
        end
        if (surv_data_obj{i_cell}.EndTime)==1
            surv_data_obj{i_cell}.EndTime=layer_obj.Transceivers(1).Data.Time(end);
        end
    end
end

layer_obj.SurveyData=surv_data_obj;

end