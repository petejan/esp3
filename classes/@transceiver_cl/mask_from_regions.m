function mask=mask_from_regions(trans_obj)

nb_samples=diff(trans_obj.Data.Samples)+1;
nb_pings=diff(trans_obj.Data.Number)+1;

mask=zeros(nb_samples,nb_pings);

idx=list_regions_type(trans_obj,'Data');

for i=idx
    curr_reg=trans_obj.Regions(i);
    mask_temp=curr_reg.create_mask();
    idx_r_curr=curr_reg.Idx_r;
    idx_pings_curr=curr_reg.Idx_pings;
    mask(idx_r_curr,idx_pings_curr)= mask_temp;
end

idx=list_regions_type(trans_obj,'Bad Data');
for i=idx
    curr_reg=trans_obj.Regions(i);
    mask_temp=curr_reg.create_mask();
    idx_r_curr=curr_reg.Idx_r;
    idx_pings_curr=curr_reg.Idx_pings;
    mask(idx_r_curr,idx_pings_curr)= double(mask(idx_r_curr,idx_pings_curr)>0&mask_temp==0);
end

end