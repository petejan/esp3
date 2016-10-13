function display_region_callback(~,~,reg_curr,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');
hfigs=getappdata(main_figure,'ExternalFigures');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);


if isempty(reg_curr)
    region_tab_comp=getappdata(main_figure,'Region_tab');
    list_reg = trans_obj.regions_to_str();
    if ~isempty(list_reg)
        reg_curr=trans_obj.Regions(get(region_tab_comp.tog_reg,'value'));
    else
        return;
    end
end


new_fig=reg_curr.display_region(trans_obj);

add_fig(main_figure,new_fig);
hfigs=[hfigs new_fig];
setappdata(main_figure,'ExternalFigures',hfigs);


end