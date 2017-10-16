function mask=mask_from_regions(trans_obj,varargin)

nb_samples=trans_obj.Data.Nb_samples;
nb_pings=trans_obj.Data.Nb_pings;

mask=zeros(nb_samples,nb_pings);

idx_bad=trans_obj.find_regions_type('Data');
idx_good=trans_obj.find_regions_type('Bad Data');

if ~isempty(varargin)
    idx_bad=intersect(idx_bad,varargin{1});
    idx_good=intersect(idx_good,varargin{1});
end

for i=idx_bad
    curr_reg=trans_obj.Regions(i);
    mask_temp=curr_reg.create_mask();
    idx_r_curr=curr_reg.Idx_r;
    idx_pings_curr=curr_reg.Idx_pings;
    mask(idx_r_curr,idx_pings_curr)= mask_temp;
end

for i=idx_good
    curr_reg=trans_obj.Regions(i);
    mask_temp=curr_reg.create_mask();
    idx_r_curr=curr_reg.Idx_r;
    idx_pings_curr=curr_reg.Idx_pings;
    mask(idx_r_curr,idx_pings_curr)= double(mask(idx_r_curr,idx_pings_curr)>0&mask_temp==0);
end

end