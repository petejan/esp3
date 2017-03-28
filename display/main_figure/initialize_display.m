function initialize_display(main_figure)

curr_disp=getappdata(main_figure,'Curr_disp');
opt_panel=uitabgroup(main_figure,'Position',[0 .7 0.5 .3]);
algo_panel=uitabgroup(main_figure,'Position',[0.5 .7 0.5 .3]);
setappdata(main_figure,'option_tab_panel',opt_panel);
setappdata(main_figure,'algo_tab_panel',algo_panel);



create_menu(main_figure);
load_cursor_tool(main_figure);
load_display_tab(main_figure,opt_panel);
display_tab_comp=getappdata(main_figure,'Display_tab');

load_mini_axes(main_figure,display_tab_comp.display_tab,[0 0 0.85 0.50]);
load_regions_tab(main_figure,opt_panel);
load_lines_tab(main_figure,opt_panel);
load_calibration_tab(main_figure,opt_panel);
load_processing_tab(main_figure,opt_panel);
load_layer_tab(main_figure,opt_panel);
load_reglist_tab(main_figure,opt_panel);
load_bottom_tab(main_figure,algo_panel);
load_bottom_tab_v2(main_figure,algo_panel);
load_bad_pings_tab(main_figure,algo_panel);
load_denoise_tab(main_figure,algo_panel);
load_school_detect_tab(main_figure,algo_panel);
load_single_target_tab(main_figure,algo_panel);
load_track_target_tab(main_figure,algo_panel);
load_axis_panel(main_figure);

format_color_gui(main_figure,curr_disp.Font);
obj_enable=findobj(main_figure,'Enable','on','-not','Type','uimenu');
set(obj_enable,'Enable','off');
set(main_figure,'Visible','on');
drawnow;
movegui(main_figure,'center');
load_loading_bar(main_figure);
load_info_panel(main_figure);


end






