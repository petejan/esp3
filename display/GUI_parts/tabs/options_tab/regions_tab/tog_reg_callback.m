function tog_reg_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
region_tab_comp=getappdata(main_figure,'Region_tab');
curr_disp=getappdata(main_figure,'Curr_disp');

idx_freq=find_freq_idx(layer,curr_disp.Freq);

active_reg=get(region_tab_comp.tog_reg,'value');
list_name=get(region_tab_comp.tog_reg,'string');
list_name_reg = layer.Transceivers(idx_freq).regions_to_str();

active_reg=nanmin(active_reg,length(list_name_reg));

if isempty(list_name_reg)
    list_name{1}='--';
    active_reg=1;
end

switch list_name{active_reg}
    case '--'
        return;
    otherwise
        reg_curr=layer.Transceivers(idx_freq).Regions(active_reg);
end

set(region_tab_comp.tog_reg,'string',list_name_reg);

shape_types=get(region_tab_comp.shape_type,'string');
shape_type_idx=find(strcmp(reg_curr.Shape,shape_types));
set(region_tab_comp.shape_type,'value',shape_type_idx);

data_types=get(region_tab_comp.data_type,'string');
data_type_idx=find(strcmp(reg_curr.Type,data_types));
set(region_tab_comp.data_type,'value',data_type_idx);

refs=get(region_tab_comp.tog_ref,'string');
ref_idx=find(strcmp(reg_curr.Reference,refs));
set(region_tab_comp.tog_ref,'value',ref_idx);

w_units=get(region_tab_comp.cell_w_unit,'string');
w_unit_idx=find(strcmp(reg_curr.Cell_w_unit,w_units));
set(region_tab_comp.cell_w_unit,'value',w_unit_idx);

h_units=get(region_tab_comp.cell_h_unit,'string');
h_unit_idx=find(strcmp(reg_curr.Cell_h_unit,h_units));
set(region_tab_comp.cell_h_unit,'value',h_unit_idx);

set(region_tab_comp.tag,'string',reg_curr.Tag);
set(region_tab_comp.id,'string',num2str(reg_curr.ID,'%.0f'));

cell_w=reg_curr.Cell_w;
set(region_tab_comp.cell_w,'string',cell_w);

cell_h=reg_curr.Cell_h;
set(region_tab_comp.cell_h,'string',cell_h);
setappdata(main_figure,'Region_tab',region_tab_comp);

activate_region_callback([],[],reg_curr,main_figure);
end

