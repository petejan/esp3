function recompute_region_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
Transceiver=layer.Transceivers(idx_freq);
list_reg = list_regions(layer.Transceivers(idx_freq));
region_tab_comp=getappdata(main_figure,'Region_tab');

if ~isempty(list_reg)
    idx_reg=get(region_tab_comp.tog_reg,'value');
    if idx_reg>length(Transceiver.Regions)
        return;
    end
    active_reg=Transceiver.Regions(idx_reg);
else
    return
end


data_types=get(region_tab_comp.data_type,'string');
data_type_idx=get(region_tab_comp.data_type,'value');
data_type=data_types{data_type_idx};
active_reg.Type=data_type;

refs=get(region_tab_comp.tog_ref,'string');
ref_idx=get(region_tab_comp.tog_ref,'value');
ref=refs{ref_idx};
active_reg.Reference=ref;

w_units=get(region_tab_comp.cell_w_unit,'string');
w_unit_idx=get(region_tab_comp.cell_w_unit,'value');
w_unit=w_units{w_unit_idx};
active_reg.Cell_w_unit=w_unit;

h_units=get(region_tab_comp.cell_h_unit,'string');
h_unit_idx=get(region_tab_comp.cell_h_unit,'value');
h_unit=h_units{h_unit_idx};
active_reg.Cell_h_unit=h_unit;


idx_r=active_reg.Idx_r;
idx_pings=active_reg.Idx_pings;
      

active_reg.Cell_h=str2double(get(region_tab_comp.cell_h,'string'));
active_reg.Cell_w=str2double(get(region_tab_comp.cell_w,'string'));

layer.Transceivers(idx_freq).rm_region_name_id(active_reg.Name,active_reg.ID)
layer.Transceivers(idx_freq).add_region(active_reg);

list_reg = list_regions(layer.Transceivers(idx_freq));

if ~isempty(list_reg)
    set(region_tab_comp.tog_reg,'string',list_reg);
    set(region_tab_comp.tog_reg,'value',length(list_reg));
else
    set(region_tab_comp.tog_reg,'string',{'--'});
end
setappdata(main_figure,'Region_tab',region_tab_comp);
setappdata(main_figure,'Layer',layer);
load_axis_panel(main_figure,0)

end
