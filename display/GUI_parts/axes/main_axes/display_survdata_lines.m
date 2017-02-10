function display_survdata_lines(main_figure)

axes_panel_comp=getappdata(main_figure,'Axes_panel');
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');

[idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);
ax=axes_panel_comp.main_axes;
xdata=layer.Transceivers(idx_freq).Data.get_numbers();
ydata=layer.Transceivers(idx_freq).get_transceiver_range();

u=findobj(ax,'Tag','surv_id');
delete(u);

Time=layer.Transceivers(idx_freq).Data.Time;
idx_start_time=[];
idx_end_time=[];

if length(layer.SurveyData)>=1
    idx_start_time=nan(1,length(layer.SurveyData));
    idx_end_time=nan(1,length(layer.SurveyData));
    for is=1:length(layer.SurveyData)
        surv_temp=layer.get_survey_data('Idx',is);
        if ~isempty(surv_temp)
            [~,idx_start_time(is)]=nanmin(abs(surv_temp.StartTime-Time));
            [~,idx_end_time(is)]=nanmin(abs(surv_temp.EndTime-Time));
        end
    end
end
dt=nanmean(diff(xdata));

for ifile=1:length(idx_start_time)
    if ~isempty(idx_start_time(ifile))
        plot(ax,xdata(idx_start_time(ifile)).*ones(size(ydata))+dt,ydata,'g','tag','surv_id');
    end
end

for ifile=1:length(idx_end_time)
    if ~isempty(idx_end_time(ifile))
        plot(ax,xdata(idx_end_time(ifile)).*ones(size(ydata))-dt,ydata,'r','tag','surv_id');
    end
end

end