function init_grid_val(main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);

switch curr_disp.Xaxes
    case 'seconds'
        x_vec=trans_obj.Time*(24*60*60);
        curr_disp.Grid_x=60*10^(floor(log10(x_vec(end)-x_vec(1))/60));
    case 'meters'
        x_vec=trans_obj.GPSDataPing.Dist;
        curr_disp.Grid_x=10^(floor(log10(x_vec(end)-x_vec(1))))/10;
    case 'pings'
        x_vec=trans_obj.get_transceiver_pings();
        curr_disp.Grid_x=10^(floor(log10(x_vec(end)-x_vec(1))))/10;
end

range=trans_obj.get_transceiver_range();
curr_disp.Grid_y=10^(floor(log10(range(end)-range(1))))/5;

end