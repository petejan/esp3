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
region_tab_comp=getappdata(main_figure,'Region_tab');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);
list_reg = trans_obj.regions_to_str();
axes_panel_comp=getappdata(main_figure,'Axes_panel');
ah=axes_panel_comp.main_axes;
clear_lines(ah);

if ~isempty(list_reg)
    
    if isempty(ID)
        idx_reg=nanmin(get(region_tab_comp.tog_reg,'value'),length(trans_obj.Regions));
        active_reg=trans_obj.Regions(idx_reg);
        ID=active_reg.Unique_ID;
    end
    idx= layer.Transceivers(idx_freq).find_regions_Unique_ID(ID);
    layer.Transceivers(idx_freq).rm_region_id(ID);
    

    setappdata(main_figure,'Layer',layer);
    update_regions_tab(main_figure,nanmax(idx-1,1));
    
    display_regions(main_figure,'both');
    order_stacks_fig(main_figure);
    update_reglist_tab(main_figure,[],0);
else
    return
end


end