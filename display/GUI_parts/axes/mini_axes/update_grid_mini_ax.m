function update_grid_mini_ax(main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
mini_axes_comp=getappdata(main_figure,'Mini_axes');

if ~isgraphics(mini_axes_comp.mini_ax.Parent,'figure')
    return;
end

[trans_obj,idx_freq]=layer.get_trans(curr_disp);
if isempty(trans_obj)
return;
end
xdata=get(mini_axes_comp.mini_echo,'XData');
ydata=get(mini_axes_comp.mini_echo,'YData');

[idx_r,idx_pings]=get_idx_r_n_pings(layer,curr_disp,mini_axes_comp.mini_echo);

switch curr_disp.Xaxes
    case 'seconds'
        xdata_grid=trans_obj.Time(idx_pings);
    case 'pings'
        xdata_grid=trans_obj.get_transceiver_pings(idx_pings);
    case 'meters'
        xdata_grid=trans_obj.GPSDataPing.Dist(idx_pings);
        if isempty(xdata)
            disp('NO GPS Data');
            curr_disp.Xaxes='pings';
            xdata_grid=trans_obj.get_transceiver_pings(idx_pings);
        end
    otherwise
        xdata_grid=trans_obj.get_transceiver_pings(idx_pings);      
end

ydata_grid=trans_obj.get_transceiver_range(idx_r);
 
switch curr_disp.Xaxes
    case 'seconds'
        dx=curr_disp.Grid_x/(24*60*60);
    otherwise
        dx=curr_disp.Grid_x;
end
idx_xticks=find((diff(rem(xdata_grid,dx))<0))+1;
idx_yticks=find((diff(rem(ydata_grid,curr_disp.Grid_y))<0))+1;

set(mini_axes_comp.mini_ax,'Xtick',xdata(idx_xticks),'Ytick',ydata(idx_yticks),'XAxisLocation','top','XGrid','on','YGrid','on','YDir','reverse');

end