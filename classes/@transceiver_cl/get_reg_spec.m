function reg=get_reg_spec(trans_obj,idx_reg)

reg=struct('name','','id','','startDepth',0,'finishDepth',inf,'startSlice',0,'finishSlice',inf,'spec','');

for iuu=1:length(idx_reg)
    reg(iuu).name = ['Region ' num2str(trans_obj.Regions(idx_reg(iuu)).ID)];
    reg(iuu).id=trans_obj.Regions(idx_reg(iuu)).Unique_ID;
    reg(iuu).startDepth=0;
    reg(iuu).finishDepth=inf;
    reg(iuu).startSlice=0;
    reg(iuu).finishSlice=inf;
    reg(iuu).spec='';
end

end