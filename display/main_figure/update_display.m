function update_display(main_figure,new)

set(main_figure,'WindowButtonMotionFcn','');
opt_panel=getappdata(main_figure,'option_tab_panel');
layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end

if new==1  
    init_grid_val(main_figure);
    update_bottom_tab(main_figure);
    update_bottom_tab_v2(main_figure);
    update_bad_pings_tab(main_figure);
    update_denoise_tab(main_figure);
    update_school_detect_tab(main_figure);
    update_single_target_tab(main_figure);
    update_track_target_tab(main_figure);
    update_processing_tab(main_figure);
    update_display_tab(main_figure);
    update_regions_tab(main_figure,1);
    update_lines_tab(main_figure);
    load_calibration_tab(main_figure,opt_panel);
    load_info_panel(main_figure);
    load_region_fig(main_figure,1,[]);
    update_layer_tab(main_figure);
end

update_axis_panel(main_figure,new);

try
    update_mini_ax(main_figure,new);
catch
    display_tab_comp=getappdata(main_figure,'Display_tab');
    load_mini_axes(main_figure,display_tab_comp.display_tab,[0 0 0.85 0.55]);
    update_mini_ax(main_figure,new);
end

set_axes_position(main_figure);
update_cmap(main_figure);
reverse_y_axis(main_figure);

display_bottom(main_figure);
display_tracks(main_figure);
display_file_lines(main_figure);
display_regions(main_figure,'both');
display_lines(main_figure);
display_survdata_lines(main_figure);

set_alpha_map(main_figure);
hide_status_bar(main_figure);
order_axes(main_figure);
order_stacks_fig(main_figure);
order_stacks_fig(main_figure);
reset_disp_info(main_figure);
curr_disp = getappdata(main_figure,'Curr_disp');
curr_disp.UIupdate=0;
%setappdata(main_figure,'Curr_disp',curr_disp);

end