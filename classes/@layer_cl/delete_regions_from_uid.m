function delete_regions_from_uid(layer,curr_disp,uid)

if~iscell(uid)
    uid={uid};
end

[trans_obj,~]=layer.get_trans(curr_disp);
if ~isempty(uid)
    idx=find_regions_Unique_ID(trans_obj,uid{1});
    if isempty(idx)
        return;
    end
    
    for i=1:numel(uid)
        trans_obj.rm_region_id(uid{i});
        layer.rm_curves_per_ID(uid{i});
    end
    
end