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
    init_grid_val(main_figure);
    update_bottom_tab(main_figure)
    update_bad_pings_tab(main_figure)
    update_denoise_tab(main_figure);
    update_school_detect_tab(main_figure);
    update_single_target_tab(main_figure);
    update_track_target_tab(main_figure);
    update_processing_tab(main_figure);
    update_display_tab(main_figure);
    update_regions_tab(main_figure,1);
    update_lines_tab(main_figure);
    load_calibration_tab(main_figure,main_childs(idx_opt));
    load_info_panel(main_figure);
end

update_axis_panel(main_figure,new);
set_axes_position(main_figure);
update_cmap(main_figure);
reverse_y_axis(main_figure);

display_bottom(main_figure);
display_tracks(main_figure);
display_file_lines(main_figure);
display_regions(main_figure);
display_lines(main_figure);
display_survdata_lines(main_figure);

set_alpha_map(main_figure);
order_axes(main_figure);
order_stacks_fig(main_figure);
update_mini_ax(main_figure);
display_info_ButtonMotionFcn([],[],main_figure,1);
set(main_figure,'WindowButtonMotionFcn',{@display_info_ButtonMotionFcn,main_figure,0});


end