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
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);
list_reg = trans_obj.regions_to_str();
axes_panel_comp=getappdata(main_figure,'Axes_panel');
ah=axes_panel_comp.main_axes;
clear_lines(ah);

if ~isempty(list_reg)
    
    if isempty(ID)
        ID=curr_disp.Active_reg_ID;
    end
    
    old_regs=trans_obj.Regions;
    trans_obj.rm_region_id(ID);
    
    setappdata(main_figure,'Layer',layer);
    display_regions(main_figure,'both');
    
    add_undo_region_action(main_figure,trans_obj,old_regs,trans_obj.Regions);

    
    curr_disp.Active_reg_ID=trans_obj.get_reg_first_Unique_ID();
    order_stacks_fig(main_figure);
    curr_disp.Reg_changed_flag=1;
    
else
    return
end


end