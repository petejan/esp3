%% find_bt_cback.m
%
% Find Bad Transmits on selected area or region_cl
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
% * 2017-13-09: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function find_bt_cback(~,~,select_plot,main_figure)

update_algos(main_figure);
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
trans_obj=layer.get_trans(curr_disp.Freq);

switch class(select_plot)
    case 'region_cl'
        reg_obj=select_plot;
    otherwise
        idx_pings=round(nanmin(select_plot.XData)):round(nanmax(select_plot.XData));
        idx_r=round(nanmin(select_plot.YData)):round(nanmax(select_plot.YData));
        reg_obj=region_cl('Idx_r',idx_r,'Idx_pings',idx_pings);
end



show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');
old_bot=trans_obj.Bottom;
trans_obj.apply_algo('BadPingsV2','load_bar_comp',load_bar_comp,'reg_obj',reg_obj,'replace_bot',0);
curr_disp.Bot_changed_flag=1; 
hide_status_bar(main_figure);
bot=trans_obj.Bottom;
curr_disp.Bot_changed_flag=1;
setappdata(main_figure,'Curr_disp',curr_disp);
setappdata(main_figure,'Layer',layer);

add_undo_bottom_action(main_figure,trans_obj,old_bot,bot);

display_bottom(main_figure);
set_alpha_map(main_figure);
update_mini_ax(main_figure,0);

end






