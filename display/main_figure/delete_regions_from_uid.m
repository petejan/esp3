function delete_regions_from_uid(main_figure,uid)


layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end
curr_disp=getappdata(main_figure,'Curr_disp');

if~iscell(uid)
    uid={uid};
end

[trans_obj,~]=layer.get_trans(curr_disp);
if ~isempty(uid)
    old_regs=trans_obj.Regions;
    
    for i=1:numel(uid)
        trans_obj.rm_region_id(uid{i});
        layer.rm_curves_per_ID(uid{i});
    end
    
    display_regions(main_figure,'both');
    
    add_undo_region_action(main_figure,trans_obj,old_regs,trans_obj.Regions);
    update_multi_freq_disp_tab(main_figure);
    order_stacks_fig(main_figure);
    curr_disp.Active_reg_ID=trans_obj.get_reg_first_Unique_ID();
end

end