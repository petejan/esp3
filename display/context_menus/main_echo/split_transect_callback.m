function split_transect_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans=layer.Transceivers(idx_freq);

ax_main=axes_panel_comp.main_axes;


x_lim=double(get(ax_main,'xlim'));

cp = ax_main.CurrentPoint;
x=cp(1,1);
% y=cp(1,2);

x=nanmax(x,x_lim(1));
x=nanmin(x,x_lim(2));

% y=nanmax(y,y_lim(1));
% y=nanmin(y,y_lim(2));

xdata=trans.Data.get_numbers();


[~,idx_ping]=nanmin(abs(xdata-x));

t_n=trans.Data.Time(idx_ping);
surv=cell(1,2);
idx_split=0;
idx_start=0;
idx_end=length(layer.SurveyData);
surv_to_split=[];
surv_temp=[];

if isempty(layer.SurveyData)
    surv{1}=survey_data_cl();
    surv{2}=survey_data_cl();
    start_time=trans.Data.Time(1);
    end_time=trans.Data.Time(end);
else
    
    dt_before=nan(1,length(layer.SurveyData));
    dt_after=nan(1,length(layer.SurveyData));
    
    if length(layer.SurveyData)>=1
        for is=1:length(layer.SurveyData)
            surv_temp=layer.get_survey_data('Idx',is);
            if ~isempty(surv_temp)
                dt_before(is)=t_n-surv_temp.StartTime;
                dt_after(is)=surv_temp.EndTime-t_n;
                if t_n>=surv_temp.StartTime&&t_n<=surv_temp.EndTime
                    surv_to_split=surv_temp;
                    idx_split=is;
                end
            end
        end
    end
    
    if idx_split>1
        idx_start=idx_split-1;
    end
    
    if idx_split<length(layer.SurveyData)
        idx_end=idx_split+1;
    end
    
    if ~isempty(surv_to_split)
        surv{1}=surv_to_split;
        surv{2}=surv_to_split;
        start_time=surv_to_split.StartTime;
        end_time=surv_to_split.EndTime;
    else
        
        surv{1}=survey_data_cl();
        surv{2}=survey_data_cl();
        
        dt_before(dt_before<0)=nan;
        dt_after(dt_after<0)=nan;
        
        if isempty(find(~isnan(dt_before),1))
            idx_start=0;
            start_time=trans.Data.Time(1);
        else
            [~,idx_start]=nanmin(dt_before);
            surv_temp=layer.get_survey_data('Idx',idx_start);
            start_time=surv_temp.EndTime;
        end
        
        if isempty(find(~isnan(dt_after),1))
            idx_end=length(layer.SurveyData);
            end_time=trans.Data.Time(end);
        else
            [~,idx_end]=nanmin(dt_after);
            surv_temp=layer.get_survey_data('Idx',idx_end);
            end_time=surv_temp.StartTime;
        end
    end
    
end

if idx_split>0
    fprintf('Splitting %s at %s\n',surv_to_split.print_survey_data(),datestr(t_n));
    surv_temp=surv_to_split;
else
    surv_temp=surv{1};
    fprintf('Splitting Transect %s ===at %s\n',datestr(t_n));
end


surv{1}.StartTime(1)=start_time;
surv{1}.EndTime=t_n;
surv{2}.StartTime=t_n;
surv{2}.EndTime=end_time;



[surv{1}.Voyage,surv{1}.SurveyName,surv{1}.Snapshot,surv{1}.Stratum,surv{1}.Transect,cancel]=fill_survey_data_dlbox(surv_temp,'Title','Enter Data For First Part');
if cancel>0
    return;
end
[surv{2}.Voyage,surv{2}.SurveyName,surv{2}.Snapshot,surv{2}.Stratum,surv{2}.Transect,cancel]=fill_survey_data_dlbox(surv_temp,'Title','Enter Data For Second Part');
if cancel>0
    return;
end

new_surveydata=layer.SurveyData;
if idx_split>0
    new_surveydata(idx_split)=[];
end

new_surveydata{length(layer.SurveyData)+1}=surv{1};
new_surveydata{length(layer.SurveyData)+2}=surv{2};

layer.set_survey_data(new_surveydata);


layer.update_echo_logbook_file();

setappdata(main_figure,'Layer',layer);
load_cursor_tool(main_figure);
display_survdata_lines(main_figure);

end