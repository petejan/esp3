
function delete_region_callback(~,~,main_figure,Unique_ID)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
region_tab_comp=getappdata(main_figure,'Region_tab');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
Transceiver=layer.Transceivers(idx_freq);
list_reg = list_regions(layer.Transceivers(idx_freq));
axes_panel_comp=getappdata(main_figure,'Axes_panel');
ah=axes_panel_comp.main_axes;
clear_lines(ah);

if ~isempty(list_reg)
    if isempty(Unique_ID)
        active_reg=Transceiver.Regions(get(region_tab_comp.tog_reg,'value'));
        Unique_ID=active_reg.Unique_ID;
    end
    layer.Transceivers(idx_freq).rm_region_id(Unique_ID);
    
    list_reg = list_regions(layer.Transceivers(idx_freq));
    
    if ~isempty(list_reg)
        set(region_tab_comp.tog_reg,'value',1)
        set(region_tab_comp.tog_reg,'string',list_reg);
    else
        set(region_tab_comp.tog_reg,'value',1)
        set(region_tab_comp.tog_reg,'string',{'--'});
    end
    setappdata(main_figure,'Layer',layer);
    display_regions(main_figure);
else
    return
end


end