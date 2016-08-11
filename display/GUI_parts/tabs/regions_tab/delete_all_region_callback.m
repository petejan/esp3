
function delete_all_region_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);
list_reg = trans_obj.regions_to_str();
axes_panel_comp=getappdata(main_figure,'Axes_panel');
ah=axes_panel_comp.main_axes;
clear_lines(ah);

if ~isempty(list_reg)
    layer.Transceivers(idx_freq).rm_regions();
    setappdata(main_figure,'Layer',layer);
    update_regions_tab(main_figure,[]);
    display_regions(main_figure);
else
    return
end


end