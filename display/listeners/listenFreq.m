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
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
[idx_freq,~]=layer.find_freq_idx(curr_disp.Freq);

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

load_calibration_tab(main_figure,opt_panel);
load_info_panel(main_figure);
update_reglist_tab(main_figure,[],1);

range=layer.Transceivers(idx_freq).get_transceiver_range();
[~,y_lim_min]=nanmin(abs(range-curr_disp.R_disp(1)));
[~,y_lim_max]=nanmin(abs(range-curr_disp.R_disp(2)));

if curr_disp.R_disp(2)==Inf
    y_lim_max=numel(range);
end
clear_regions(main_figure,[]);
set(axes_panel_comp.main_axes,'ylim',[y_lim_min y_lim_max]);
update_mini_ax(main_figure,1);
curr_disp.Active_reg_ID=layer.Transceivers(idx_freq).get_reg_first_Unique_ID();

display_bottom(main_figure);
display_tracks(main_figure);
set_alpha_map(main_figure);
order_stacks_fig(main_figure);
display_info_ButtonMotionFcn([],[],main_figure,1);
end

