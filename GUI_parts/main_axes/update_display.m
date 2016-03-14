function update_display(main_figure,new)

set(main_figure,'WindowButtonMotionFcn','');
main_childs=get(main_figure,'children');
tags=get(main_childs,'Tag');

idx_opt=strcmp(tags,'option_tab_panel');
idx_algo=strcmp(tags,'algo_tab_panel');
layer=getappdata(main_figure,'Layer');


if isempty(layer)
    return;
end

if new==1
    load_cursor_tool(main_figure);
    load_display_tab(main_figure,main_childs(idx_opt)); 
    load_regions_tab(main_figure,main_childs(idx_opt));
    load_lines_tab(main_figure,main_childs(idx_opt));
    load_calibration_tab(main_figure,main_childs(idx_opt));
    load_processing_tab(main_figure,main_childs(idx_opt));   
    load_bottom_tab(main_figure,main_childs(idx_algo));
    load_bad_pings_tab(main_figure,main_childs(idx_algo));
    load_denoise_tab(main_figure,main_childs(idx_algo));
    load_school_detect_tab(main_figure,main_childs(idx_algo));
    load_single_target_tab(main_figure,main_childs(idx_algo));
    load_track_target_tab(main_figure,main_childs(idx_algo));
    
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
    
    curr_disp.Grid_y=(layer.Transceivers(idx_freq).Data.Range(2)-layer.Transceivers(idx_freq).Data.Range(1))/10;
    curr_disp.Grid_x=(x_vec(end)-x_vec(1))/15;
    
else
    selected_opt_tab=get(main_childs(idx_opt),'SelectedTab');
    active_opt_tab=selected_opt_tab.Title;
        
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
   
    opt_tabs=get(main_childs(idx_opt),'children');
    
    for i=1:length(opt_tabs)
        if strcmp(active_opt_tab,opt_tabs(i).Title)
            set(main_childs(idx_opt),'SelectedTab',opt_tabs(i));
        end
    end

    
end

load_info_panel(main_figure);
load_axis_panel(main_figure,new);
change_grid_callback([],[],main_figure);
set(main_figure,'WindowButtonMotionFcn',{@display_info_ButtonMotionFcn,main_figure,0});


end