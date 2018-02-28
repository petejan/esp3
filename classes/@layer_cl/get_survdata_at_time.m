function [surv,idx_modif]=get_survdata_at_time(layer_obj,t_n)

idx_modif=0;

surv_to_modif=[];

surv_data_tot=layer_obj.SurveyData;

if isempty(surv_data_tot)
    surv=survey_data_cl();
    start_time=layer_obj.Transceivers(1).Time(1);
    end_time=layer_obj.Transceivers(1).Time(end);
else
    dt_before=nan(1,length(surv_data_tot));
    dt_after=nan(1,length(surv_data_tot));
    
    if length(surv_data_tot)>=1
        for is=1:length(surv_data_tot)
            surv_temp=layer_obj.get_survey_data('Idx',is);
            if ~isempty(surv_temp)
                dt_before(is)=t_n-surv_temp.StartTime;
                dt_after(is)=surv_temp.EndTime-t_n;
                if t_n>=surv_temp.StartTime&&t_n<=surv_temp.EndTime
                    surv_to_modif=surv_temp;
                    idx_modif=is;
                end
            end
        end
    end
    
    
    if ~isempty(surv_to_modif)
       surv=surv_to_modif;
        start_time=surv_to_modif.StartTime;
        end_time=surv_to_modif.EndTime;
    else
       surv=survey_data_cl();
        
        dt_before(dt_before<0)=nan;
        dt_after(dt_after<0)=nan;
        
        if ~any(~isnan(dt_before))
            start_time=layer_obj.Transceivers(1).Time(1);
        else
            [~,idx_start]=nanmin(dt_before);
            surv_temp=layer_obj.get_survey_data('Idx',idx_start);
            start_time=surv_temp.EndTime;
        end
        
        if ~any(~isnan(dt_after))
            end_time=layer_obj.Transceivers(1).Time(end);
        else
            [~,idx_end]=nanmin(dt_after);
            surv_temp=layer_obj.get_survey_data('Idx',idx_end);
            end_time=surv_temp.StartTime;
        end
    end
    
end

surv.StartTime=start_time;
surv.EndTime=end_time;

end