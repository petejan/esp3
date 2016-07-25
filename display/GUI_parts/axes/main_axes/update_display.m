function update_display(main_figure,new)

set(main_figure,'WindowButtonMotionFcn','');
main_childs=get(main_figure,'children');
tags=get(main_childs,'Tag');

idx_opt=strcmp(tags,'option_tab_panel');
%idx_algo=strcmp(tags,'algo_tab_panel');
layer=getappdata(main_figure,'Layer');


if isempty(layer)
    return;
end

if new==1
    load_cursor_tool(main_figure);
    curr_disp=getappdata(main_figure,'Curr_disp');
    [idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);
    switch curr_disp.Xaxes
        case 'Time'
            x_vec=layer.Transceivers(idx_freq).Data.Time*(24*60*60);
        case 'Distance'
            x_vec=layer.Transceivers(idx_freq).GPSDataPing.Dist;
        case 'Number'
            x_vec=layer.Transceivers(idx_freq).Data.get_numbers();
    end
    
    curr_disp.Grid_y=10^(floor(log10(layer.Transceivers(idx_freq).Data.Range(2)-layer.Transceivers(idx_freq).Data.Range(1))))/5;
    curr_disp.Grid_x=10^(floor(log10(x_vec(end)-x_vec(1))))/10;
    
end
update_bottom_tab(main_figure)
update_bad_pings_tab(main_figure)
update_denoise_tab(main_figure);
update_school_detect_tab(main_figure);
update_single_target_tab(main_figure);
update_track_target_tab(main_figure);
update_processing_tab(main_figure);
update_display_tab(main_figure);
update_regions_tab(main_figure);

load_calibration_tab(main_figure,main_childs(idx_opt));

load_info_panel(main_figure);
update_axis_panel(main_figure,new);
update_mini_ax(main_figure);

change_grid_callback([],[],main_figure);
set(main_figure,'WindowButtonMotionFcn',{@display_info_ButtonMotionFcn,main_figure,0});


end