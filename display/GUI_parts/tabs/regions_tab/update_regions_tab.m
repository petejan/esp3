function update_regions_tab(main_figure)
region_tab_comp=getappdata(main_figure,'Region_tab');

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
idx_freq=find_freq_idx(layer,curr_disp.Freq);


list_reg = layer.Transceivers(idx_freq).regions_to_str();
dist=layer.Transceivers(idx_freq).GPSDataPing.Dist;

if isempty(list_reg)
    list_reg={'--'};
end

set(region_tab_comp.tog_reg,'string',list_reg);

if ~isempty(dist)
    units_w= {'pings','meters'};
else
    units_w= {'pings'};
end

set(region_tab_comp.cell_w_unit,'string',units_w);

if get(region_tab_comp.tog_reg,'value')>length(list_reg)
    set(region_tab_comp.tog_reg,'value',1)
end
set(findall(region_tab_comp.region_tab, '-property', 'Enable'), 'Enable', 'on');

setappdata(main_figure,'Region_tab',region_tab_comp);

end