function [lat_centre,long_centre] = find_centre(gps_objs)
nb_trans=numel(gps_objs);

lat0=0;
long0=0;
for i=1:nb_trans
    nb_points=numel(gps_objs(i).Lat);
    idx_keep=nanmax(round(nb_points/4),1):nanmax(round(3*nb_points/4),1);
    lat0=lat0+median(gps_objs(i).Lat(idx_keep));
    long0=long0+nanmean(gps_objs(i).Long(idx_keep));
end

lat0=lat0/nb_trans;
long0=long0/nb_trans;


[xinit,yinit,zone_init]=deg2utm(lat0,long0);

x=cell(1,nb_trans);
y=cell(1,nb_trans);
zone=cell(1,nb_trans);
p=nan(2,nb_trans);


for i=1:nb_trans
    nb_points=numel(gps_objs(i).Lat);
    idx_keep=nanmax(round(nb_points/4),1):nanmax(round(3*nb_points/4),1);
    [x{i},y{i},zone{i}]=deg2utm(gps_objs(i).Lat,gps_objs(i).Long);
    %     x{i}=x{i}-xinit;
    %     y{i}=y{i}-yinit;
    p(:,i)=polyfit(x{i}(idx_keep),y{i}(idx_keep),1);
    
end

func_sum = @(xp) sum((-p(1,:)*xp(1)+xp(2)-p(2,:)).^2./(1+p(1,:).^2));

x_out=fminsearch(func_sum,[xinit,yinit]);


[lat_centre,long_centre]=utm2degx(x_out(1),x_out(2),zone_init);


hfig=figure();
ax=axes(hfig,'Nextplot','add');
grid(ax,'on');
for i=1:nb_trans
    plot(ax,gps_objs(i).Lat,gps_objs(i).Long)
end
plot(ax,lat0,long0,'x');
plot(ax,lat_centre,long_centre,'s');




end


