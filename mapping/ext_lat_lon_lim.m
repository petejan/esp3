function [LatLim_out,LongLim_out]=ext_lat_lon_lim(LatLim_in,LongLim_in,fext)

 y_dist=nanmax(m_lldist([LongLim_in(1) LongLim_in(1)],LatLim_in),m_lldist([LongLim_in(2) LongLim_in(2)],LatLim_in));
 x_dist=nanmax(m_lldist(LongLim_in,[LatLim_in(1) LatLim_in(1)]),m_lldist(LongLim_in,[LatLim_in(2) LatLim_in(2)]));
 
factor=y_dist/x_dist;

[x_lim,y_lim]=m_ll2xy(LongLim_in,LatLim_in);


dx_ori=diff(x_lim);
dy_ori=diff(y_lim);

if factor>1
    dx=dx_ori*factor;
    dy=dy_ori;
else
    dy=dy_ori/factor;
    dx=dx_ori;
end
 
dx_ori=[-1 1]*dx_ori;
dy_ori=[-1 1]*dy_ori;

dx=[-1 1]*nanmax(dx,5*1e-4)*(1+fext)-dx_ori;
dy=[-1 1]*nanmax(dy,5* 1e-4)*(1+fext)-dy_ori;

% if abs(nanmean(LatLim_in))<90
%     dx=dx/cosd(nanmean(abs(LatLim_in)));
% end

x_lim=[x_lim(1)+dx(1) x_lim(2)+dx(2)];
y_lim=[y_lim(1)+dy(1) y_lim(2)+dy(2)];

[LongLim_out,LatLim_out]=m_xy2ll(x_lim,y_lim);



end