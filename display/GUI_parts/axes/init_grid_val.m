function init_grid_val(main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
[idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);
switch curr_disp.Xaxes
    case 'Time'
        x_vec=layer.Transceivers(idx_freq).Data.Time*(24*60*60);
        curr_disp.Grid_x=60*10^(floor(log10(x_vec(end)-x_vec(1))/60));
    case 'Distance'
        x_vec=layer.Transceivers(idx_freq).GPSDataPing.Dist;
        curr_disp.Grid_x=10^(floor(log10(x_vec(end)-x_vec(1))))/10;
    case 'Number'
        x_vec=layer.Transceivers(idx_freq).Data.get_numbers();
        curr_disp.Grid_x=10^(floor(log10(x_vec(end)-x_vec(1))))/10;
end
curr_disp.Grid_y=10^(floor(log10(layer.Transceivers(idx_freq).Data.Range(2)-layer.Transceivers(idx_freq).Data.Range(1))))/5;

end