function reg=get_reg_spec(trans_obj,idx_reg)

reg=struct('name','','id',[],'unique_id',[],'startDepth',nan,'finishDepth',nan,'startSlice',nan,'finishSlice',nan,'spec','');

for iuu=1:length(idx_reg)
    reg(iuu).name = ['Region' num2str(trans_obj.Regions(idx_reg(iuu)).ID)];
    reg(iuu).unique_id=trans_obj.Regions(idx_reg(iuu)).Unique_ID;
    reg(iuu).id=trans_obj.Regions(idx_reg(iuu)).ID;
    reg(iuu).startDepth=nan;
    reg(iuu).finishDepth=nan;
    reg(iuu).startSlice=nan;
    reg(iuu).finishSlice=nan;
    reg(iuu).spec='';
end

end