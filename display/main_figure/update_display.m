%% update_display.m
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
% * |new|: TODO: write description and info on variable
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
function update_display(main_figure,new)

if ~isdeployed
    disp('Update Display');
end

if ~isappdata(main_figure,'Axes_panel')
    echo_tab_panel=getappdata(main_figure,'echo_tab_panel');
    axes_panel=uitab(echo_tab_panel,'BackgroundColor',[1 1 1],'tag','axes_panel');
    load_axis_panel(main_figure,axes_panel);
    display_tab_comp=getappdata(main_figure,'Display_tab');
    load_mini_axes(main_figure,display_tab_comp.display_tab,[0 0 1 0.70]);
end

opt_panel=getappdata(main_figure,'option_tab_panel');
sel_tab=opt_panel.SelectedTab;
layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end


if new==1  
    update_bottom_tab(main_figure);
    update_bottom_tab_v2(main_figure);
    update_bad_pings_tab(main_figure);
    update_denoise_tab(main_figure);
    update_school_detect_tab(main_figure);
    update_single_target_tab(main_figure,1);
    update_track_target_tab(main_figure);
    update_processing_tab(main_figure);
    
    update_map_tab(main_figure);
    update_st_tracks_tab(main_figure);
    update_multi_freq_disp_tab(main_figure,'sv_f',0);
    update_multi_freq_disp_tab(main_figure,'ts_f',0);
    update_lines_tab(main_figure);
    update_calibration_tab(main_figure);
    update_tree_layer_tab(main_figure);
    update_reglist_tab(main_figure,1);
    clear_regions(main_figure,{},{});
    update_multi_freq_tab(main_figure);
    clean_echo_figures(main_figure,'Tag','attitude');
end

update_axis_panel(main_figure,new);

if new==1
    update_display_tab(main_figure);
    load_secondary_freq_win(main_figure);
    update_file_panel(main_figure);
    update_echo_int_tab(main_figure,new);
end

try
    update_mini_ax(main_figure,new);
catch
    display_tab_comp=getappdata(main_figure,'Display_tab');
    load_mini_axes(main_figure,display_tab_comp.display_tab,[0 0 1 0.70]);
    update_mini_ax(main_figure,new);
end
opt_panel.SelectedTab=sel_tab;
set_axes_position(main_figure);
update_cmap(main_figure);
reverse_y_axis(main_figure);

display_bottom(main_figure);
display_tracks(main_figure);
display_file_lines(main_figure);
%display_regions(main_figure,'both');%already in update_cmap
display_lines(main_figure);
display_survdata_lines(main_figure);

set_alpha_map(main_figure,'main_or_mini',union({'main','mini'},layer.ChannelID));
%hide_status_bar(main_figure);

order_stacks_fig(main_figure);
reset_disp_info(main_figure);
order_axes(main_figure); 
curr_disp = getappdata(main_figure,'Curr_disp');
curr_disp.UIupdate=0;

%setappdata(main_figure,'Curr_disp',curr_disp);

end