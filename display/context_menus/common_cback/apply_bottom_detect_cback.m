%% apply_bottom_detect_cback.m
%
% Apply bottom detection on selected area or region_cl
%
%% Help
%
% *USE*
%
% TODO
%
% *INPUT VARIABLES*
%
% * |select_plot|: TODO
% * |main_figure|: TODO
% * |ver|: TODO
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO
%
% *NEW FEATURES*
%
% * 2017-03-22: header and comments updated according to new format (Alex Schimel)
% * 2017-03-02: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function apply_bottom_detect_cback(~,~,select_plot,main_figure,ver)

update_algos(main_figure);
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);

switch class(select_plot)
    case 'region_cl'
        reg_obj=select_plot;
    otherwise
        idx_pings=round(nanmin(select_plot.XData)):round(nanmax(select_plot.XData));
        idx_r=round(nanmin(select_plot.YData)):round(nanmax(select_plot.YData));
        reg_obj=region_cl('Idx_r',idx_r,'Idx_pings',idx_pings);
end


switch ver
    case 'v2'
        alg_name='BottomDetectionV2';
    case 'v1'
        alg_name='BottomDetection';
end

show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');
old_bot=layer.Transceivers(idx_freq).Bottom;
layer.Transceivers(idx_freq).apply_algo(alg_name,'load_bar_comp',load_bar_comp,'reg_obj',reg_obj);
curr_disp.Bot_changed_flag=1; 
hide_status_bar(main_figure);
bot=layer.Transceivers(idx_freq).Bottom;
curr_disp.Bot_changed_flag=1;
setappdata(main_figure,'Curr_disp',curr_disp);
setappdata(main_figure,'Layer',layer);

add_undo_bottom_action(main_figure,layer.Transceivers(idx_freq),old_bot,bot);

setappdata(main_figure,'Layer',layer);
set_alpha_map(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');
display_bottom(main_figure);
order_stacks_fig(main_figure);

end