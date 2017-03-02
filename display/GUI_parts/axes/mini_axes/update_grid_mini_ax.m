function update_grid_mini_ax(main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
mini_axes_comp=getappdata(main_figure,'Mini_axes');

if ~isgraphics(mini_axes_comp.mini_ax.Parent,'figure')
    return;
end

[idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);

xdata=get(mini_axes_comp.mini_echo,'XData');
ydata=get(mini_axes_comp.mini_echo,'YData');

[idx_r,idx_pings]=get_idx_r_n_pings(layer,curr_disp,mini_axes_comp.mini_echo);

switch curr_disp.Xaxes
    case 'Time'
        xdata_grid=layer.Transceivers(idx_freq).Data.Time(idx_pings);
    case 'Number'
        xdata_grid=layer.Transceivers(idx_freq).get_transceiver_pings(idx_pings);
    case 'Distance'
        xdata_grid=layer.Transceivers(idx_freq).GPSDataPing.Dist(idx_pings);
        if isempty(xdata)
            disp('NO GPS Data');
            curr_disp.Xaxes='Number';
            xdata_grid=layer.Transceivers(idx_freq).get_transceiver_pings(idx_pings);
        end
    otherwise
        xdata_grid=layer.Transceivers(idx_freq).get_transceiver_pings(idx_pings);      
end

ydata_grid=layer.Transceivers(idx_freq).get_transceiver_range(idx_r);
 
switch curr_disp.Xaxes
    case 'Time'
        dx=curr_disp.Grid_x/(24*60*60);
    otherwise
        dx=curr_disp.Grid_x;
end
idx_xticks=find((diff(rem(xdata_grid,dx))<0))+1;
idx_yticks=find((diff(rem(ydata_grid,curr_disp.Grid_y))<0))+1;

set(mini_axes_comp.mini_ax,'Xtick',xdata(idx_xticks),'Ytick',ydata(idx_yticks),'XAxisLocation','top','XGrid','on','YGrid','on','YDir','reverse');

end