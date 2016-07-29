function listenFreq(~,~,main_figure)
main_childs=get(main_figure,'children');
tags=get(main_childs,'Tag');
idx_opt=strcmp(tags,'option_tab_panel');

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

update_axis_panel(main_figure,0);
update_mini_ax(main_figure);

display_bottom(main_figure);
display_tracks(main_figure);
display_regions(main_figure);
set_alpha_map(main_figure);
order_axes(main_figure);
order_stacks_fig(main_figure);
end

