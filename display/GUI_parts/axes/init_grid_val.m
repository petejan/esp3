function curr_disp=init_grid_val(main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,~]=layer.get_trans(curr_disp);

[dx,dy]=curr_disp.get_dx_dy();

if dx==0
    switch curr_disp.Xaxes_current
        case 'seconds'
            x_vec=trans_obj.Time*(24*60*60);
            dx=60*10^(floor(log10(x_vec(end)-x_vec(1))/60));
        case 'meters'
            x_vec=trans_obj.GPSDataPing.Dist;
            dx=10^(floor(log10(x_vec(end)-x_vec(1))))/10;           
        case 'pings'
            x_vec=trans_obj.get_transceiver_pings();
            dx=10^(floor(log10(x_vec(end)-x_vec(1))))/10;
    end
end

if dy==0
    range=trans_obj.get_transceiver_range();
    dy=10^(floor(log10(range(end)-range(1))))/5;
end

curr_disp.set_dx_dy(dx,dy,[]);

end