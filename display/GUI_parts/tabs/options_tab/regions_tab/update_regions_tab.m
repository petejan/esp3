function update_regions_tab(main_figure)
region_tab_comp=getappdata(main_figure,'Region_tab');
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);

if ~isempty(trans_obj.GPSDataPing)
    dist=trans_obj.GPSDataPing.Dist;
else
    dist=0;
end


if ~isempty(dist)
    w_units= {'pings','meters'};
else
    w_units= {'pings'};
end

set(region_tab_comp.cell_w_unit,'string',w_units);

%idx_reg=trans_obj.find_regions_Unique_ID(curr_disp.Active_reg_ID);

% if ~isempty(idx_reg)
%     reg_curr=trans_obj.Regions(idx_reg);
% 
%     data_types=get(region_tab_comp.data_type,'string');
%     data_type_idx=find(strcmp(reg_curr.Type,data_types));
%     set(region_tab_comp.data_type,'value',data_type_idx);
%     
%     refs=get(region_tab_comp.tog_ref,'string');
%     ref_idx=find(strcmp(reg_curr.Reference,refs));
%     set(region_tab_comp.tog_ref,'value',ref_idx);
%     
%     w_unit_idx=find(strcmp(reg_curr.Cell_w_unit,w_units));
%     set(region_tab_comp.cell_w_unit,'value',w_unit_idx);
%     
%     h_units=get(region_tab_comp.cell_h_unit,'string');
%     h_unit_idx=find(strcmp(reg_curr.Cell_h_unit,h_units));
%     set(region_tab_comp.cell_h_unit,'value',h_unit_idx);
%     
%     set(region_tab_comp.tag,'string',reg_curr.Tag);
%     set(region_tab_comp.id,'string',num2str(reg_curr.ID,'%.0f'));
%     
%     cell_w=reg_curr.Cell_w;
%     set(region_tab_comp.cell_w,'string',cell_w);
%     
%     cell_h=reg_curr.Cell_h;
%     set(region_tab_comp.cell_h,'string',cell_h);
%     setappdata(main_figure,'Region_tab',region_tab_comp);
% end
%set(findall(region_tab_comp.region_tab, '-property', 'Enable'), 'Enable', 'on');

setappdata(main_figure,'Region_tab',region_tab_comp);

end