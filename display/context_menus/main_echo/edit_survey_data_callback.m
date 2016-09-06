function edit_survey_data_callback(~,~,main_figure,rem)
layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans=layer.Transceivers(idx_freq);

ax_main=axes_panel_comp.main_axes;
x_lim=double(get(ax_main,'xlim'));

cp = ax_main.CurrentPoint;
x=cp(1,1);

x=nanmax(x,x_lim(1));
x=nanmin(x,x_lim(2));

xdata=trans.Data.get_numbers();

[~,idx_ping]=nanmin(abs(xdata-x));

t_n=trans.Data.Time(idx_ping);

surv=cell(1,1);
idx_modif=0;

surv_to_modif=[];

if isempty(layer.SurveyData)
    surv{1}=survey_data_cl();
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
                    surv_to_modif=surv_temp;
                    idx_modif=is;
                end
            end
        end
    end
    
    
    if ~isempty(surv_to_modif)
        surv{1}=surv_to_modif;
        start_time=surv_to_modif.StartTime;
        end_time=surv_to_modif.EndTime;
    else
        surv{1}=survey_data_cl();
        
        dt_before(dt_before<0)=nan;
        dt_after(dt_after<0)=nan;
        
        if ~any(~isnan(dt_before))
            start_time=trans.Data.Time(1);
        else
            [~,idx_start]=nanmin(dt_before);
            surv_temp=layer.get_survey_data('Idx',idx_start);
            start_time=surv_temp.EndTime;
        end
        
        if ~any(~isnan(dt_after));
            end_time=trans.Data.Time(end);
        else
            [~,idx_end]=nanmin(dt_after);
            surv_temp=layer.get_survey_data('Idx',idx_end);
            end_time=surv_temp.StartTime;
        end
    end
    
end


if idx_modif>0
    fprintf('Modifying Survey data for %s\n',surv_to_modif.print_survey_data());
    surv_temp=surv_to_modif;
else
    surv_temp=surv{1};
    fprintf('Modifying Survey Data\n');
end


if rem==0
    [surv{1}.Voyage,surv{1}.SurveyName,surv{1}.Snapshot,surv{1}.Stratum,surv{1}.Transect,cancel]=fill_survey_data_dlbox(surv_temp,'title','Enter New Survey Data');
    if cancel>0
        return;
    end
else
    surv{1}=survey_data_cl();
    surv{1}.Voyage=surv_temp.Voyage;
    surv{1}.SurveyName=surv_temp.SurveyName;
end

surv{1}.StartTime=start_time;
surv{1}.EndTime=end_time;

if idx_modif>0
    new_surveydata=layer.SurveyData;
    new_surveydata{idx_modif}=surv{1};
else
    new_surveydata=layer.SurveyData;
    new_surveydata{length(layer.SurveyData)+1}=surv{1};
    
end

layer.set_survey_data(new_surveydata);
layer.update_echo_logbook_file();
setappdata(main_figure,'Layer',layer);

load_cursor_tool(main_figure);
display_survdata_lines(main_figure)

end