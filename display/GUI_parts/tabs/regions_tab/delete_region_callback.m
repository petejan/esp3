
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
    layer.Transceivers(idx_freq).rm_region_id(ID);
    
    list_reg = layer.Transceivers(idx_freq).regions_to_str();
    
    if ~isempty(list_reg)
        set(region_tab_comp.tog_reg,'value',1)
        set(region_tab_comp.tog_reg,'string',list_reg);
    else
        set(region_tab_comp.tog_reg,'value',1)
        set(region_tab_comp.tog_reg,'string',{'--'});
    end
    setappdata(main_figure,'Layer',layer);
    update_regions_tab(main_figure,1);
    display_regions(main_figure);
    order_stacks_fig(main_figure);
else
    return
end


end