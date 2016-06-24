function display_region_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');
region_tab_comp=getappdata(main_figure,'Region_tab');
hfigs=getappdata(main_figure,'ExternalFigures');


idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);

list_reg = trans_obj.regions_to_str();


if ~isempty(list_reg)
    active_reg=trans_obj.Regions(get(region_tab_comp.tog_reg,'value'));
    new_fig=active_reg.display_region(trans_obj);
else
    return;
end


hfigs=[hfigs new_fig];
setappdata(main_figure,'ExternalFigures',hfigs);


end