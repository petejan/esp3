function [LatLim_out,LongLim_out]=ext_lat_lon_lim(LatLim_in,LongLim_in,fext)

lon_box_w=diff(LongLim_in);
lat_box_w=diff(LatLim_in);

dlon=[-1 1]*lon_box_w*fext;
dlat=[-1 1]*lat_box_w*fext;

LongLim_out=[LongLim_in(1)+dlon(1) LongLim_in(2)+dlon(2)];
LatLim_out=[LatLim_in(1)+dlat(1) LatLim_in(2)+dlat(2)];

end