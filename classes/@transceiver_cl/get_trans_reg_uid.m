function reg_uid=get_trans_reg_uid(trans_obj)
reg_uid={};
if~isempty(trans_obj.Regions)
    reg_uid={trans_obj.Regions(:).Unique_ID};
end

end
