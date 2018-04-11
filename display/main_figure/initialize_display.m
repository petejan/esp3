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

pan_height=270;
pix_pos=getpixelposition(main_figure);
opt_panel=uitabgroup(main_figure,'Units','pixels','Position',[0 pix_pos(4)-pan_height 0.5*pix_pos(3) pan_height]);
algo_panel=uitabgroup(main_figure,'Units','pixels','Position',[0.5*pix_pos(3) pix_pos(4)-pan_height 0.5*pix_pos(3) pan_height]);
echo_tab_panel=uitabgroup(main_figure,'Units','pixels','Position',[0 0.05*pix_pos(4) pix_pos(3) pix_pos(4)-pan_height-0.05*pix_pos(4)]);

curr_disp=getappdata(main_figure,'Curr_disp');
setappdata(main_figure,'echo_tab_panel',echo_tab_panel);
setappdata(main_figure,'option_tab_panel',opt_panel);
setappdata(main_figure,'algo_tab_panel',algo_panel);



create_menu(main_figure);
load_esp3_panel(main_figure,echo_tab_panel);
load_file_panel(main_figure,echo_tab_panel);


%fixed Tab in option panel
load_cursor_tool(main_figure);
load_display_tab(main_figure,opt_panel);
load_lines_tab(main_figure,opt_panel);
load_calibration_tab(main_figure,opt_panel);
load_processing_tab(main_figure,opt_panel);

%Undockable tabs
load_tree_layer_tab(main_figure,opt_panel);
load_reglist_tab(main_figure,opt_panel);
load_map_tab(main_figure,opt_panel);
load_st_tracks_tab(main_figure,opt_panel);
load_multi_freq_disp_tab(main_figure,opt_panel,'sv_f');
load_multi_freq_disp_tab(main_figure,opt_panel,'ts_f');

load_bottom_tab(main_figure,algo_panel);
load_bad_pings_tab(main_figure,algo_panel);
load_denoise_tab(main_figure,algo_panel);
load_school_detect_tab(main_figure,algo_panel);
load_single_target_tab(main_figure,algo_panel);
load_track_target_tab(main_figure,algo_panel);
load_multi_freq_tab(main_figure,algo_panel);


format_color_gui(main_figure,curr_disp.Font);
display_tab_comp=getappdata(main_figure,'Display_tab');
opt_panel.SelectedTab=display_tab_comp.display_tab;
esp3_tab_comp=getappdata(main_figure,'esp3_tab');
echo_tab_panel.SelectedTab=esp3_tab_comp.esp3_tab;
obj_enable=findobj(main_figure,'Enable','on','-not','Type','uimenu');
set(obj_enable,'Enable','off');
centerfig(main_figure);
set(main_figure,'Visible','on');
drawnow;

load_loading_bar(main_figure);
load_info_panel(main_figure);


end






