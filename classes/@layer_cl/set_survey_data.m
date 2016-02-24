function set_survey_data(layer_obj,surv_data_cell)

if ~iscell(surv_data_cell)
    surv_data_cell={surv_data_cell};
end

str_surv_data_cell=cell(1,length(surv_data_cell));

for ic=1:length(str_surv_data_cell)
    if ~isempty(surv_data_cell{ic})
        %str_surv_data_cell{ic}=[surv_data_cell{ic}.print_survey_data() datestr(surv_data_cell{ic}.StartTime) datestr(surv_data_cell{ic}.EndTime)];
        str_surv_data_cell{ic}=surv_data_cell{ic}.print_survey_data();
    else
        str_surv_data_cell{ic}='';
    end
end

[~,idx_unique,idx_rep]=unique(str_surv_data_cell);

surv_data_cell_out=cell(1,length(idx_unique));

for i_cell=1:length(surv_data_cell_out)
    if ~isempty(surv_data_cell{idx_unique(i_cell)})
        surv_data_cell_out{i_cell}=surv_data_cell{idx_unique(i_cell)};
        
        surv_data_tot=surv_data_cell((idx_rep==i_cell));
%         if~iscell(surv_data_tot)
%             surv_data_tot={surv_data_tot};
%         end
        
        start_time=nan;
        end_time=nan;
        for icell2=1:length(surv_data_tot)
            if~isempty(surv_data_tot{icell2})
                start_time=nanmin(start_time,surv_data_tot{icell2}.StartTime);
                end_time=nanmax(end_time,surv_data_tot{icell2}.EndTime);
            end
            
        end
        
        if start_time==0
            surv_data_cell_out{i_cell}.StartTime=layer_obj.Transceivers(1).Data.Time(1);
        else
            surv_data_cell_out{i_cell}.StartTime=start_time;
        end
        
        if end_time==1
            surv_data_cell_out{i_cell}.EndTime=layer_obj.Transceivers(1).Data.Time(end);
        else
            surv_data_cell_out{i_cell}.EndTime=end_time;
        end
    end
end
surv_data_cell_out{1}
layer_obj.SurveyData=surv_data_cell_out;

end