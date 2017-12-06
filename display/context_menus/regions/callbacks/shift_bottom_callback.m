%% shift_bottom_callback.m
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
% * |select_plot|: TODO: write description and info on variable
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
% * 2017-03-28: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function shift_bottom_callback(~,~,select_plot,main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');

[trans_obj,idx_freq]=layer.get_trans(curr_disp);
switch class(select_plot)
    case 'region_cl'
        reg_obj=trans_obj.get_region_from_Unique_ID(curr_disp.Active_reg_ID);
    otherwise
        idx_pings=round(nanmin(select_plot.XData)):round(nanmax(select_plot.XData));
        idx_r=round(nanmin(select_plot.YData)):round(nanmax(select_plot.YData));
        reg_obj=region_cl('Name','Select Area','Idx_r',idx_r,'Idx_pings',idx_pings,'Unique_ID','1');
end

answer=inputdlg('Enter Shifting value','Shift Bottom',1,{'0'});

if isempty(answer)||isnan(str2double(answer{1}))
    return;
end
old_bot=trans_obj.Bottom;
for i=1:numel(reg_obj)
    idx_pings=reg_obj(i).Idx_pings;
    
    trans_obj.shift_bottom(str2double(answer{1}),idx_pings);
end

curr_disp.Bot_changed_flag=1;

setappdata(main_figure,'Curr_disp',curr_disp);
setappdata(main_figure,'Layer',layer);


bot=trans_obj.Bottom;
curr_disp.Bot_changed_flag=1;
setappdata(main_figure,'Curr_disp',curr_disp);
setappdata(main_figure,'Layer',layer);

add_undo_bottom_action(main_figure,trans_obj,old_bot,bot);

set_alpha_map(main_figure);
display_bottom(main_figure);
order_stacks_fig(main_figure);

end