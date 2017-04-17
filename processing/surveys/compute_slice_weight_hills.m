function [weight,r_dist,area]=compute_slice_weight_hills(lat_s,long_s,lat_e,long_e,lat0,long0,R)

nb_slices=length(lat_s);
start_r=nan(1,nb_slices);

end_r=nan(1,nb_slices);

weight=nan(1,nb_slices);

for i=1:length(lat_e)
    start_r(i)=m_lldist([long0 long_s(i)],[lat0 lat_s(i)])*1e3;
    
    end_r(i)=m_lldist([long0 long_e(i)],[lat0 lat_e(i)])*1e3;
    
end

idx_sign=(sign(end_r)==sign(start_r));
weight(~idx_sign)=(end_r(~idx_sign).^2+start_r(~idx_sign).^2)./(2*R^2);
weight(idx_sign)=(end_r(idx_sign).^2+start_r(idx_sign).^2)./(2*R^2);
r_dist=start_r.*sign(end_r-start_r)+(start_r-end_r)/2;

% hfig=figure();
% 
% ax=axes(hfig);
% grid(ax,'on');
% plot(ax,r_dist,weight);

weight(abs(r_dist)>R)=0;
area=2*pi*R^2;

end