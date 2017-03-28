%% listenFreq.m
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
function listenFreq(~,~,main_figure)

opt_panel=getappdata(main_figure,'option_tab_panel');

update_bottom_tab(main_figure);
update_bottom_tab_v2(main_figure);
update_bad_pings_tab(main_figure);
update_denoise_tab(main_figure);
update_school_detect_tab(main_figure);
update_single_target_tab(main_figure);
update_track_target_tab(main_figure);
update_processing_tab(main_figure);
update_display_tab(main_figure);
update_regions_tab(main_figure,[]);
load_calibration_tab(main_figure,opt_panel);
load_info_panel(main_figure);
update_reglist_tab(main_figure,[],1);
update_axis_panel(main_figure,0);
update_mini_ax(main_figure,1);

display_bottom(main_figure);
display_tracks(main_figure);
display_regions(main_figure,'both');
set_alpha_map(main_figure);
order_axes(main_figure);
order_stacks_fig(main_figure);
display_info_ButtonMotionFcn([],[],main_figure,1);
end

