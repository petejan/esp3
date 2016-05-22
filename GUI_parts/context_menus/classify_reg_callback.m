
function classify_reg_callback(~,~,reg_curr,main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');

hfigs=getappdata(main_figure,'ExternalFigures');
idx_freq=find_freq_idx(layer,curr_disp.Freq);

list_reg = layer.Transceivers(idx_freq).regions_to_str();


if  isempty(list_reg)
    return;
end

if isempty(reg_curr)
    region_tab_comp=getappdata(main_figure,'Region_tab');
    idx_reg=get(region_tab_comp.tog_reg,'value');  
else
   idx_reg=layer.Transceivers(idx_freq).list_regions_Unique_ID(reg_curr.Unique_ID);
end

new_fig=layer.apply_classification(idx_freq,idx_reg);


hfigs=[hfigs new_fig];
setappdata(main_figure,'ExternalFigures',hfigs);
setappdata(main_figure,'Layer',layer);
display_regions(main_figure);
update_display(main_figure,0)
end
