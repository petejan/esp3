%% initialize_display.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |main_figure|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-28: header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function initialize_display(main_figure)

opt_panel=uitabgroup(main_figure,'Position',[0 2/3 0.5 1/3]);
algo_panel=uitabgroup(main_figure,'Position',[0.5 2/3 0.5 1/3]);
curr_disp=getappdata(main_figure,'Curr_disp');

echo_tab_panel=uitabgroup(main_figure,'Units','Normalized','Position',[0 0.05 1 2/3-0.05]);
axes_panel=uitab(echo_tab_panel,'BackgroundColor',[1 1 1],'tag','axes_panel','Title',sprintf('%.0fkHz',curr_disp.Freq/1e3));

setappdata(main_figure,'echo_tab_panel',echo_tab_panel);
setappdata(main_figure,'option_tab_panel',opt_panel);
setappdata(main_figure,'algo_tab_panel',algo_panel);

create_menu(main_figure);

%fixed Tab in option panel
load_cursor_tool(main_figure);
load_display_tab(main_figure,opt_panel);
load_regions_tab(main_figure,opt_panel);
load_lines_tab(main_figure,opt_panel);
load_calibration_tab(main_figure,opt_panel);
load_processing_tab(main_figure,opt_panel);

%Undockable tabs
%load_layer_tab(main_figure,opt_panel);
%load_reglist_tab(main_figure,opt_panel);
load_map_tab(main_figure,opt_panel);
load_multi_freq_disp_tab(main_figure,opt_panel,'sv_f');
load_multi_freq_disp_tab(main_figure,opt_panel,'ts_f');
display_tab_comp=getappdata(main_figure,'Display_tab');

load_bottom_tab(main_figure,algo_panel);
load_bottom_tab_v2(main_figure,algo_panel);
load_bad_pings_tab(main_figure,algo_panel);
load_denoise_tab(main_figure,algo_panel);
load_school_detect_tab(main_figure,algo_panel);
load_single_target_tab(main_figure,algo_panel);
load_track_target_tab(main_figure,algo_panel);
load_axis_panel(main_figure,axes_panel);
load_multi_freq_tab(main_figure,algo_panel)
load_mini_axes(main_figure,display_tab_comp.display_tab,[0 0 0.85 0.60]);

format_color_gui(main_figure,curr_disp.Font);
obj_enable=findobj(main_figure,'Enable','on','-not','Type','uimenu');
set(obj_enable,'Enable','off');
centerfig(main_figure);
set(main_figure,'Visible','on');
drawnow;
load_loading_bar(main_figure);
load_info_panel(main_figure);



end






