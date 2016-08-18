function update_grid(main_figure)

layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

[idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);

xdata=get(axes_panel_comp.main_echo,'XData')
ydata=get(axes_panel_comp.main_echo,'YData');

[idx_r,idx_pings]=get_idx_r_n_pings(layer,curr_disp,axes_panel_comp.main_echo);

switch curr_disp.Xaxes
    case 'Time'
        xdata_grid=layer.Transceivers(idx_freq).Data.Time(idx_pings);
    case 'Number'
        xdata_grid=layer.Transceivers(idx_freq).Data.get_numbers(idx_pings);
    case 'Distance'
        xdata_grid=layer.Transceivers(idx_freq).GPSDataPing.Dist(idx_pings);
        if isempty(xdata)
            disp('NO GPS Data');
            curr_disp.Xaxes='Number';
            xdata_grid=layer.Transceivers(idx_freq).Data.get_numbers(idx_pings);
        end
    otherwise
        xdata_grid=layer.Transceivers(idx_freq).Data.get_numbers(idx_pings);      
end

ydata_grid=layer.Transceivers(idx_freq).Data.get_range(idx_r);
 
switch curr_disp.Xaxes
    case 'Time'
        dx=curr_disp.Grid_x/(24*60*60);
    otherwise
        dx=curr_disp.Grid_x;
end

idx_xticks=find((diff(rem(xdata_grid,dx))<0))+1;
idx_yticks=find((diff(rem(ydata_grid,curr_disp.Grid_y))<0))+1;


set(axes_panel_comp.main_axes,'Xtick',xdata(idx_xticks),'Ytick',ydata(idx_yticks),'XAxisLocation','top','XGrid','on','YGrid','on','YDir','reverse');
xlabel_out=format_label(xdata_grid(idx_xticks),curr_disp.Xaxes);
ylabel_out=format_label(ydata_grid(idx_yticks),'distance');
set(axes_panel_comp.main_axes,'XtickLabel',xlabel_out,'YtickLabel',ylabel_out,'XTickLabelRotation',90,'box','on','visible','on');

xticks=get(axes_panel_comp.main_axes,'XTick');
yticks=get(axes_panel_comp.main_axes,'YTick');

xticks_label=get(axes_panel_comp.main_axes,'XtickLabel');
yticks_label=get(axes_panel_comp.main_axes,'YtickLabel');

set(axes_panel_comp.vaxes,'YTick',yticks);
set(axes_panel_comp.haxes,'XTick',xticks);
xticks
set(axes_panel_comp.vaxes,'YtickLabel',yticks_label);
set(axes_panel_comp.haxes,'XtickLabel',xticks_label,'XTickLabelRotation',90,'box','on');
order_axes(main_figure);

end