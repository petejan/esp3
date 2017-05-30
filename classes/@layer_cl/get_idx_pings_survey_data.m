 function idx_pings_surveydata=get_idx_pings_survey_data(layer_obj,freq)
        trans_obj=layer_obj.get_trans(freq);
        time_trans=trans_obj.get_transceiver_time();
        if isempty(layer_obj.SurveyDataID)
            idx_start=1;
            idx_end=numel(time_trans);
        else
            tmin=nan;
            tmax=nan;
            for i=1:length(layer_obj.SurveyDataID)
                tmax=nanmax(tmax,layer_obj.SurveyData{layer_obj.SurveyDataID(i)}.EndTime);
                tmin=nanmin(tmin,layer_obj.SurveyData{layer_obj.SurveyDataID(i)}.StartTime);
            end
            [~,idx_start]=nanmin(abs(time_trans-tmin));
            [~,idx_end]=nanmin(abs(time_trans-tmax));
        end
        idx_pings_surveydata=idx_start:idx_end;
    end