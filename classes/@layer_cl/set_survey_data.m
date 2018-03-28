function set_survey_data(layer_obj,surv_data_cell)

if ~iscell(surv_data_cell)
    surv_data_cell={surv_data_cell};
end

surv_data_cell(cellfun(@isempty,surv_data_cell))=[];

if isempty(surv_data_cell)
    layer_obj.SurveyData=surv_data_cell;
    return;
end

if ~isempty(layer_obj.Transceivers)
    dt=nanmean(diff(layer_obj.Transceivers(1).Time));
else
    dt=1/(24*60*60);
end



start_time=nan(1,length(surv_data_cell));

for ic=1:length(start_time)
    if ~isempty(surv_data_cell{ic})
        start_time(ic)=surv_data_cell{ic}.StartTime;
    else
        start_time(ic)=0;
    end
end
[~,idx_sort]=sort(start_time);

surv_data_cell=surv_data_cell(idx_sort);


str_surv_data_cell=cell(1,length(surv_data_cell));
for ic=1:length(str_surv_data_cell)
    if ~isempty(surv_data_cell{ic})
        str_surv_data_cell{ic}=surv_data_cell{ic}.print_survey_data();
        start_time(ic)=surv_data_cell{ic}.StartTime;
    else
        str_surv_data_cell{ic}='';
    end
end

% [~,idx_unique,idx_rep]=unique(str_surv_data_cell);
%

for i_cell=1:length(surv_data_cell)
    if ~isempty(surv_data_cell{i_cell})

        idx_same=find(strcmp(str_surv_data_cell{i_cell},str_surv_data_cell));
        
        idx_same(idx_same==i_cell)=[];

        
        for isame=1:length(idx_same)
            
            if (surv_data_cell{idx_same(isame)}.StartTime<=surv_data_cell{i_cell}.EndTime+dt*10)&&(surv_data_cell{idx_same(isame)}.StartTime>=surv_data_cell{i_cell}.EndTime)
                surv_data_cell{i_cell}.EndTime=surv_data_cell{idx_same(isame)}.EndTime;
                surv_data_cell{idx_same(isame)}=[];
                str_surv_data_cell{idx_same(isame)}=[];
                continue;
            end
            
            if (surv_data_cell{idx_same(isame)}.EndTime>=surv_data_cell{i_cell}.StartTime-dt*10)&&surv_data_cell{idx_same(isame)}.EndTime<=surv_data_cell{i_cell}.StartTime
                surv_data_cell{i_cell}.StartTime=surv_data_cell{idx_same(isame)}.StartTime;
                surv_data_cell{idx_same(isame)}=[];
                str_surv_data_cell{idx_same(isame)}=[];
                continue;
            end
            
            
        end
        
        start_time=surv_data_cell{i_cell}.StartTime;
        end_time=surv_data_cell{i_cell}.EndTime;
        
        if isempty(end_time)
            end_time=1;
        end
        
        if isempty(start_time)
            start_time=0;
        end
        
        if start_time==0&&~isempty(layer_obj.Transceivers)
            surv_data_cell{i_cell}.StartTime=layer_obj.Transceivers(1).Time(1);
        else
            surv_data_cell{i_cell}.StartTime=start_time;
        end
        
        if end_time==1&&~isempty(layer_obj.Transceivers)
            surv_data_cell{i_cell}.EndTime=layer_obj.Transceivers(1).Time(end);
        else
            surv_data_cell{i_cell}.EndTime=end_time;
        end
    end
end
surv_data_cell(cellfun(@isempty,surv_data_cell))=[];

start_time=nan(1,length(surv_data_cell));

for ic=1:length(start_time)
    if ~isempty(surv_data_cell{ic})
        start_time(ic)=surv_data_cell{ic}.StartTime;
    end
end
[~,idx_sort]=sort(start_time);

surv_data_cell=surv_data_cell(idx_sort);

layer_obj.SurveyData=surv_data_cell;

end