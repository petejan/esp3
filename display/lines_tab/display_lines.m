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

u=get(main_axes,'children');

for ii=1:length(u)
    if strcmp(get(u(ii),'tag'),'lines')
        delete(u(ii));
    end
end


x=double(get(main_echo,'xdata'));
%y=double(get(main_echo,'ydata'));


list_line = layer.list_lines();

axes(main_axes)

active_line_idx=get(lines_tab_comp.tog_line,'value');
if curr_disp.DispReg>0
    vis='on';
else
    vis='off';
end

for i=1:length(list_line)
    active_line=layer.Lines(i);
    
    if active_line.Dist_diff>= 0
        [~,idx_t]=nanmin(abs((curr_dist-active_line.Dist_diff)));
        dt_trawl=curr_time(idx_t)-curr_time(1);
    else
        [~,idx_t]=nanmin(abs(curr_dist+active_line.Dist_diff));
         dt_trawl=-curr_time(idx_t)+curr_time(1);
    end
    
    
    
    [y_line,~,~]=resample_data(active_line.Range,active_line.Time+dt_trawl,curr_time);
    
    if isempty(y_line)
        continue;
    end

    x_line=x;    

      
    if i==active_line_idx
        color='r';
    else
        color='g';
    end
    plot(x_line,y_line,color,'linewidth',2,'tag','lines','visible',vis);
    %text(nanmean(x_line(:)),nanmean(y_line(:)),line_curr.Tag,'visible',vis,'FontAngle','italic','Fontsize',10,'tag','line')
end

end

