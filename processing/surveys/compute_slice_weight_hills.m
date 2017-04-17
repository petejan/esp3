%% compute_slice_weight_hills.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |lat_s|: TODO: write description and info on variable
% * |long_s|: TODO: write description and info on variable
% * |lat_e|: TODO: write description and info on variable
% * |long_e|: TODO: write description and info on variable
% * |lat0|: TODO: write description and info on variable
% * |long0|: TODO: write description and info on variable
% * |R|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |weight|: TODO: write description and info on variable
% * |r_dist|: TODO: write description and info on variable
% * |area|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-04-15: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
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

hfig=figure();

ax=axes(hfig);
grid(ax,'on');
plot(ax,r_dist,weight);


area=2*pi*R^2;

end