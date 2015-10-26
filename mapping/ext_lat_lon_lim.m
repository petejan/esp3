function [LatLim_out,LonLim_out]=ext_lat_lon_lim(LatLim_in,LonLim_in,fext)

lon_box_w=diff(LonLim_in);
lat_box_w=diff(LatLim_in);

dlon=[-1 1]*lon_box_w*fext;
dlat=[-1 1]*lat_box_w*fext;

LonLim_out=[LonLim_in(1)+dlon(1) LonLim_in(2)+dlon(2)];
LatLim_out=[LatLim_in(1)+dlat(1) LatLim_in(2)+dlat(2)];

end