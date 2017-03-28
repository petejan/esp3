function update_reglist_tab(main_figure,reg_uniqueID,new)
layer=getappdata(main_figure,'Layer');
reglist_tab_comp=getappdata(main_figure,'Reglist_tab');
if isempty(layer)||isempty(reglist_tab_comp)
    return;
end
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);

regions=trans_obj.Regions;
if ~isempty(reg_uniqueID)&&new==0
    if reg_uniqueID>=0
        region_mod=regions(trans_obj.list_regions_Unique_ID(reg_uniqueID));
        reg_table_data=update_reg_data_table(region_mod,reglist_tab_comp.table.Data);
        set(reglist_tab_comp.table,'Data',reg_table_data);
    else
        idx_mod=find([reglist_tab_comp.table.Data{:,10}]==abs(reg_uniqueID));
        if ~isempty(idx_mod)
            reglist_tab_comp.table.Data(idx_mod,:)=[];
        end
    end
else
    region_mod=regions;
    reg_table_data=update_reg_data_table(region_mod,[]);
    set(reglist_tab_comp.table,'Data',reg_table_data);
end

end