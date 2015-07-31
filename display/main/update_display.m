function update_display(main_figure,new)
set(main_figure,'WindowButtonMotionFcn','');
main_childs=get(main_figure,'children');
tags=get(main_childs,'Tag');
idx_opt=strcmp(tags,'option_tab_panel');
idx_algo=strcmp(tags,'algo_tab_panel');
layer=getappdata(main_figure,'Layer');
if layer.ID_num==0
    return;
end

if new==1
    load_display_tab(main_figure,main_childs(idx_opt));
    load_cursor_tool(main_figure);
    load_processing_tab(main_figure,main_childs(idx_opt));
    load_bottom_tab(main_figure,main_childs(idx_algo));
    load_bad_pings_tab(main_figure,main_childs(idx_algo));
    load_denoise_tab(main_figure,main_childs(idx_algo));
    load_school_detect_tab(main_figure,main_childs(idx_algo));
    load_single_target_tab(main_figure,main_childs(idx_algo));
    load_track_target_tab(main_figure,main_childs(idx_algo));
    load_regions_tab(main_figure,main_childs(idx_opt));
    load_calibration_tab(main_figure,main_childs(idx_opt));
    
else
    selected_opt_tab=get(main_childs(idx_opt),'SelectedTab');
    active_opt_tab=selected_opt_tab.Title;
    
    %     selected_algo_tab=get(main_childs(idx_algo),'SelectedTab');
    %     active_algo_tab=selected_algo_tab.Title;
    
    update_bottom_tab(main_figure)
    update_bad_pings_tab(main_figure)
    update_denoise_tab(main_figure);
    update_school_detect_tab(main_figure);
    update_single_target_tab(main_figure);
    update_track_target_tab(main_figure);
    update_processing_tab(main_figure);
    
    update_display_tab(main_figure);
    load_regions_tab(main_figure,main_childs(idx_opt));
    load_calibration_tab(main_figure,main_childs(idx_opt));
    
    opt_tabs=get(main_childs(idx_opt),'children');
    %algo_tab=get(main_childs(idx_opt),'children');
    
    for i=1:length(opt_tabs)
        if strcmp(active_opt_tab,opt_tabs(i).Title)
            set(main_childs(idx_opt),'SelectedTab',opt_tabs(i));
        end
    end
    
    %     for i=1:length(algo_tab)
    %         if strcmp(active_algo_tab,algo_tab(i).Title)
    %             set(main_childs(idx_algo),'SelectedTab',algo_tab(i));
    %         end
    %     end
    
end


curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);

load_info_panel(main_figure);
load_axis_panel(main_figure,new);
set(main_figure,'WindowButtonMotionFcn',{@display_info,main_figure,layer.Transceivers(idx_freq)});

% disp('Done!')

end