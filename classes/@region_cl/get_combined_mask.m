function [mask_common,idx_r,idx_pings,type]=get_combined_mask(region_1,region_2,method)


idx_pings=nanmin([region_1.Idx_pings(1) region_2.Idx_pings(1)]):nanmax([region_1.Idx_pings(end) region_2.Idx_pings(end)]);
idx_r=(nanmin([region_1.Idx_r(1) region_2.Idx_r(1)]):nanmax([region_1.Idx_r(end) region_2.Idx_r(end)]))';

mask_common_1_tot=zeros(length(idx_r),length(idx_pings));
mask_common_2_tot=zeros(length(idx_r),length(idx_pings));

[~,~,idx_pings_old_1]=intersect(region_1.Idx_pings,idx_pings);
[~,~,idx_r_old_1]=intersect(region_1.Idx_r,idx_r);
[~,~,idx_pings_old_2]=intersect(region_2.Idx_pings,idx_pings);
[~,~,idx_r_old_2]=intersect(region_2.Idx_r,idx_r);



switch region_1.Shape
    case 'Polygon'
        mask_common_1=region_1.get_mask();
    otherwise
        mask_common_1=ones(length(region_1.Idx_r),length(region_1.Idx_pings));
end

switch region_2.Shape
    case 'Polygon'
        mask_common_2=region_2.get_mask;
    otherwise
        mask_common_2=ones(length(region_2.Idx_r),length(region_2.Idx_pings));
end


mask_common_1_tot(idx_r_old_1,idx_pings_old_1)=mask_common_1;
mask_common_2_tot(idx_r_old_2,idx_pings_old_2)=mask_common_2;

switch region_1.Type
    case 'Data'
        switch region_2.Type
            case 'Bad Data'
                mask_common_2_tot=~mask_common_2_tot;
                method='intersect';
        end
        type=region_1.Type;
    case 'Bad Data'
        switch region_2.Type
            case 'Data'
                mask_common_1_tot=~mask_common_1_tot;
                method='intersect';
                type=region_2.Type;
            case 'Bad Data'
                type=region_1.Type;
        end
       
end

switch method
    case 'intersect'
        mask_common=mask_common_1_tot&mask_common_2_tot;
    case 'union'
        mask_common=mask_common_1_tot|mask_common_2_tot;
end





