%% compute_slice_weight_hills.m
%
% Compute weighting for integrated slices on a hill survey. TODO: add
% reference to paper
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |lat_s|: starting latitude of slice
% * |long_s|: starting longitude of slice
% * |lat_e|: ending latitude of slice
% * |long_e|: ending longitude of slice
% * |lat0|: hill center latitude
% * |long0|: hill center longitude
% * |R|: hill radius in meter
%
% *OUTPUT VARIABLES*
%
% * |weight|: resulting weight for each slice
% * |r_dist|: mean distance from center for each slice
% * |area|: total hill area
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
    start_r(i)=m_lldist([long0 long_s(i)],[lat0 lat_s(i)])*1e3;%distance of start of slice from center in m
    
    end_r(i)=m_lldist([long0 long_e(i)],[lat0 lat_e(i)])*1e3;%distance of end of slice from center in m
    
end

idx_sign=(sign(end_r)==sign(start_r));

weight(~idx_sign)=(end_r(~idx_sign).^2+start_r(~idx_sign).^2)./(2*R^2);
weight(idx_sign)=(end_r(idx_sign).^2+start_r(idx_sign).^2)./(2*R^2);

r_dist=start_r.*sign(end_r-start_r)+(start_r-end_r)/2;

weight(abs(r_dist)>R)=0;
area=pi*R^2;

end