function mask_inter=get_mask_from_intersection(reg_1,regs_2)
switch reg_1.Shape
    case 'Polygon'
        mask_1=reg_1.MaskReg;
    otherwise
        mask_1=true(length(reg_1.Idx_r),length(reg_1.Idx_pings));
end
mask_inter=false(size(mask_1));

for iu=1:length(regs_2)
    if strcmpi(reg_1.Unique_ID,regs_2(iu).Unique_ID)
        continue;
    end
    idx_r_2=regs_2(iu).Idx_r;
    idx_pings_2=regs_2(iu).Idx_pings;
    [~,idx_r_from_1,idx_r_from_2]=intersect(reg_1.Idx_r,idx_r_2);
    [~,idx_pings_from_1,idx_pings_from_2]=intersect(reg_1.Idx_pings,idx_pings_2);
    
    switch regs_2(iu).Shape
        case 'Polygon'
            mask_2=regs_2(iu).get_mask();
            mask_temp=mask_1(idx_r_from_1,idx_pings_from_1)&mask_2(idx_r_from_2,idx_pings_from_2);
        otherwise
            mask_temp=true(length(idx_r_from_1),length(idx_pings_from_1));
    end
    mask_inter(idx_r_from_1,idx_pings_from_1)= mask_inter(idx_r_from_1,idx_pings_from_1)|mask_temp;
end



end