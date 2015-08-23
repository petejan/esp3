function update_regions_tab(main_figure)
region_tab_comp=getappdata(main_figure,'Region_tab');
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
idx_freq=find_freq_idx(layer,curr_disp.Freq);


list_reg = list_regions(layer.Transceivers(idx_freq));

if isempty(list_reg)
    list_reg={'--'};
end

set(region_tab_comp.tog_reg,'string',list_reg);

if get(region_tab_comp.tog_reg,'value')>length(list_reg)
    set(region_tab_comp.tog_reg,'value',1)
end

tog_reg_callback([],[],main_figure)

setappdata(main_figure,'Region_tab',region_tab_comp);
end