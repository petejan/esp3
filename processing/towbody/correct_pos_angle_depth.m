function [new_lat,new_long,hfig]=correct_pos_angle_depth(old_lat,old_long,angle_deg,depth_m,proj)


distance=depth_m/tand(angle_deg);

n=nanmin(numel(old_lat)-1,10);
heading=heading_from_lat_long(old_lat(1:n:end),old_long(1:n:end));

heading=mode(round(heading));

[x_ship,y_ship,Zone]=deg2utm(old_lat,old_long);

Y_new=y_ship-distance*sind(heading);%E
X_new=x_ship-distance*cosd(heading);%N

[new_lat,new_long] = utm2degx(X_new,Y_new,num2str(Zone));

LongLim=[nanmin(union(old_long,new_long)) nanmax(union(old_long,new_long))];

LatLim=[nanmin(union(old_lat,new_lat)) nanmax(union(old_lat,new_lat))];

[LatLim,LongLim]=ext_lat_lon_lim(LatLim,LongLim,0.3);


hfig=new_echo_figure([],'Name','Corrected Navigation');
ax=axes(hfig,'Nextplot','add');
m_proj(proj,'long',LongLim,'lat',LatLim);
m_plot(ax,old_long(1),old_lat(1),'Marker','o','Markersize',10,'Color',[0 0.5 0],'tag','start');
m_plot(ax,old_long,old_lat,'Color','k','tag','Nav');
m_plot(ax,new_long(1),new_lat(1),'Marker','o','Markersize',10,'Color',[0 0.5 0],'tag','start');
m_plot(ax,new_long,new_lat,'Color','r','tag','Nav');
m_grid('box','fancy','tickdir','in','axes',ax);