function display_lines(main_figure)

layer=getappdata(main_figure,'Layer');
lines_tab_comp=getappdata(main_figure,'Lines_tab');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);

curr_time=layer.Transceivers(idx_freq).Data.Time;
curr_dist=layer.Transceivers(idx_freq).GPSDataPing.Dist;

main_axes=axes_panel_comp.main_axes;
main_echo=axes_panel_comp.main_echo;

u=findobj(main_axes,'tag','lines');

delete(u);
x=double(get(main_echo,'xdata'));
%y=double(get(main_echo,'ydata'));


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
    
    dist_corr=curr_dist-active_line.Dist_diff; 
    time_corr=resample_data_v2(curr_time,curr_dist,dist_corr);
    time_corr(isnan(time_corr))=curr_time(isnan(time_corr))+nanmean(time_corr(:)-curr_time(:));
    y_line=resample_data_v2(active_line.Range,active_line.Time,time_corr);
    
    
    [~,idx_pings]=get_idx_r_n_pings(layer,curr_disp,main_echo);
    if isempty(y_line)
        warning('Line time does not match the current layer.');
        
        continue;
    end
    
    y_line=y_line(idx_pings);
    x_line=x;
      
    if i==active_line_idx
        color='r';
    else
        color='g';
    end
    plot(main_axes,x_line,y_line,color,'linewidth',2,'tag','lines','visible',vis);
    text(nanmean(x_line(:)),nanmean(y_line(:)),active_line.Tag,'visible',vis,'FontAngle','italic','Fontsize',10,'tag','lines')
end

end

