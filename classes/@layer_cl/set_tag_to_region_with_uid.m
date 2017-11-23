function idx_mod=set_tag_to_region_with_uid(layer_obj,uid,tag)
idx_mod=[];
for it=1:numel(layer_obj.Transceivers)
    trans_obj=layer_obj.Transceivers(it);
    [idx_reg,found]=trans_obj.find_reg_idx(uid);
    if found>0
        trans_obj.Regions(idx_reg).Tag=tag;
        idx_mod=union(idx_mod,it);
    end
    
end

end