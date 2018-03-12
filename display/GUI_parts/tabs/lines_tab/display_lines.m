function display_lines(main_figure)

layer=getappdata(main_figure,'Layer');
lines_tab_comp=getappdata(main_figure,'Lines_tab');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);

curr_time=trans_obj.Time;
curr_pings=trans_obj.get_transceiver_pings();

curr_range=trans_obj.get_transceiver_range();
curr_dist=trans_obj.GPSDataPing.Dist;

main_axes=axes_panel_comp.main_axes;

u=findobj(main_axes,'tag','lines');

delete(u);

list_line = layer.list_lines();

if isempty(layer.Lines)
    return;
end

active_line_idx=get(lines_tab_comp.tog_line,'value');

if curr_disp.DispLines>0
    vis='on';
else
    vis='off';
end

for i=1:length(list_line)
    active_line=layer.Lines(i);
    
    if nansum(curr_dist)>0&&active_line.Dist_diff~=0
        dist_corr=curr_dist-active_line.Dist_diff;
        time_corr=resample_data_v2(curr_time,curr_dist,dist_corr);
        time_corr(isnan(time_corr))=curr_time(isnan(time_corr))+nanmean(time_corr(:)-curr_time(:));       
        
    else
        time_corr=curr_time;
    end
    
    y_line=resample_data_v2(active_line.Range,active_line.Time,time_corr);
    y_line=y_line./nanmean(diff(curr_range));
    
    if isempty(y_line)
        warning('Line time does not match the current layer.');
        continue;
    end
    
    x_line=curr_pings;
    
    if i==active_line_idx
        color=[0 0.5 0];
    else
        color='r';
    end
    plot(main_axes,x_line,y_line,'color',color,'linewidth',2,'tag','lines','visible',vis);
    text(main_axes,nanmean(x_line(:)),nanmean(y_line(:)),active_line.Tag,'visible',vis,'FontAngle','italic','Fontsize',10,'tag','lines','color',color)
end

end

