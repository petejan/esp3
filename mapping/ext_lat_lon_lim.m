function [LatLim_out,LongLim_out]=ext_lat_lon_lim(LatLim_in,LongLim_in,fext)

lon_box_w=diff(LongLim_in);
lat_box_w=diff(LatLim_in);
box_w=nanmax([lon_box_w,lat_box_w]);

dlon=[-1 1]*nanmax(box_w,5*1e-4)*fext;
dlat=[-1 1]*nanmax(box_w,5* 1e-4)*fext;


LongLim_out=[LongLim_in(1)+dlon(1) LongLim_in(2)+dlon(2)];
LatLim_out=[LatLim_in(1)+dlat(1) LatLim_in(2)+dlat(2)];

end