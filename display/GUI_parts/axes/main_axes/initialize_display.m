function initialize_display(main_figure)


opt_panel=uitabgroup(main_figure,'Position',[0 .7 0.5 .3],'tag','option_tab_panel');
algo_panel=uitabgroup(main_figure,'Position',[0.5 .7 0.5 .3],'tag','algo_tab_panel');

load_display_tab(main_figure,opt_panel);
display_tab_comp=getappdata(main_figure,'Display_tab');
load_mini_axes(main_figure,display_tab_comp.display_tab,[0.05 0.1 0.75 0.45]);
load_regions_tab(main_figure,opt_panel);
load_lines_tab(main_figure,opt_panel);
load_calibration_tab(main_figure,opt_panel);
load_processing_tab(main_figure,opt_panel);
load_bottom_tab(main_figure,algo_panel);
load_bad_pings_tab(main_figure,algo_panel);
load_denoise_tab(main_figure,algo_panel);
load_school_detect_tab(main_figure,algo_panel);
load_single_target_tab(main_figure,algo_panel);
load_track_target_tab(main_figure,algo_panel);
load_axis_panel(main_figure);
load_info_panel(main_figure);

set(main_figure,'Visible','on');
end



