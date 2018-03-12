%% delete_region_callback.m
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
% * |ID|: TODO: write description and info on variable
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
function delete_region_callback(~,~,main_figure,ID)

layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end
curr_disp=getappdata(main_figure,'Curr_disp');

axes_panel_comp=getappdata(main_figure,'Axes_panel');
ah=axes_panel_comp.main_axes;
clear_lines(ah);

if isempty(ID)
    ID=curr_disp.Active_reg_ID;
end

[trans_obj,~]=layer.get_trans(curr_disp);

old_regs=trans_obj.Regions;

layer.delete_regions_from_uid(curr_disp,ID);

add_undo_region_action(main_figure,trans_obj,old_regs,trans_obj.Regions);

display_regions(main_figure,'both');

update_multi_freq_disp_tab(main_figure,'sv_f',0);
update_multi_freq_disp_tab(main_figure,'ts_f',0);


curr_disp.setActive_reg_ID({});


order_stacks_fig(main_figure);
update_reglist_tab(main_figure,0);
end

