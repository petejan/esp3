function delete_regions_from_uid(main_figure,uid)


layer=getappdata(main_figure,'Layer');
if isempty(layer)||isempty(uid)
    return;
end
curr_disp=getappdata(main_figure,'Curr_disp');

if~iscell(uid)
    uid={uid};
end

[trans_obj,~]=layer.get_trans(curr_disp);
if ~isempty(uid)
    
    old_regs=trans_obj.Regions;
    
    idx=find_regions_Unique_ID(trans_obj,uid{1});
    
    for i=1:numel(uid)
        trans_obj.rm_region_id(uid{i});
        layer.rm_curves_per_ID(uid{i});
    end
    
    add_undo_region_action(main_figure,trans_obj,old_regs,trans_obj.Regions);
    
    display_regions(main_figure,'both');
    
    update_multi_freq_disp_tab(main_figure,'sv_f');
    update_multi_freq_disp_tab(main_figure,'ts_f');
    
    if ~isempty(trans_obj.Regions)
       curr_disp.Active_reg_ID=trans_obj.Regions(nanmax(idx-1,1)).Unique_ID;
    else
        curr_disp.Active_reg_ID=trans_obj.get_reg_first_Unique_ID();
    end
        
    order_stacks_fig(main_figure);
end

end