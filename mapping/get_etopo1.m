function [lat,lon,bathy]=get_etopo1(latlim,lonlim)
% ETOPO1_Bed_g_gmt4.grd
% Format:
%            classic
% Global Attributes:
%            Conventions = 'COARDS/CF-1.0'
%            title       = 'ETOPO1_Bed_g_gmt4.grd'
%            GMT_version = '4.4.0'
%            node_offset = 0
% Dimensions:
%            x = 21601
%            y = 10801
% Variables:
%     x
%            Size:       21601x1
%            Dimensions: x
%            Datatype:   double
%            Attributes:
%                        long_name    = 'Longitude'
%                        actual_range = [-180  180]
%                        units        = 'degrees_east'
%     y
%            Size:       10801x1
%            Dimensions: y
%            Datatype:   double
%            Attributes:
%                        long_name    = 'Latitude'
%                        actual_range = [-90           90]
%                        units        = 'degrees_north'
%     z
%            Size:       21601x10801
%            Dimensions: x,y
%            Datatype:   int32
%            Attributes:
%                        long_name    = 'z'
%                        _FillValue   = -2147483648
%                        actual_range = [-10898   8271]
etopo_file=fullfile(whereisEcho,'private','ETOPO1_Bed_g_gmt4.grd');

lon_etopo=ncread(etopo_file,'x');
lat_etopo=ncread(etopo_file,'y');

lonlim(lonlim>180)=lonlim(lonlim>180)-360;

if latlim(1)<=latlim(2)
    idx_lat=find(lat_etopo>=latlim(1)&lat_etopo<=latlim(2));
else
    idx_lat=union(find(lat_etopo>=latlim(1)&lat_etopo<=90),find(lat_etopo>=-90&lat_etopo<=latlim(2)));
end

if lonlim(1)<=lonlim(2)
    idx_lon=find(lon_etopo>=lonlim(1)&lon_etopo<=lonlim(2));
else
    idx_lon=union(find(lon_etopo>=lonlim(1)&lon_etopo<=180),find(lon_etopo>=-180&lon_etopo<=lonlim(2)));
end

if nansum(diff(idx_lat)>1)>0 
    id_lat_step=[1 find(diff(idx_lat)>1)+1 length(idx_lat)+1];
else
    id_lat_step=[1 length(idx_lat)+1];
end

if nansum(diff(idx_lon)>1)>0 
    id_lon_step=[1 find(diff(idx_lon)>1)+1 length(idx_lon)+1];
else
    id_lon_step=[1 length(idx_lon)+1];
end
lat=nan(size(idx_lat));
lon=nan(size(idx_lon));
bathy=nan(length(idx_lon),length(idx_lat));

for j=1:length(id_lat_step)-1
    lat(id_lat_step(j):id_lat_step(j+1)-1)=lat_etopo(idx_lat(id_lat_step(j):id_lat_step(j+1)-1));
end

for i=1:length(id_lon_step)-1
    lon(id_lon_step(i):id_lon_step(i+1)-1)=lon_etopo(idx_lon(id_lon_step(i):id_lon_step(i+1)-1));
end

for i=1:length(id_lon_step)-1
    for j=1:length(id_lat_step)-1
        bathy(id_lon_step(i):id_lon_step(i+1)-1,id_lat_step(j):id_lat_step(j+1)-1)=ncread(etopo_file,'z',...
            [idx_lon(id_lon_step(i)) idx_lat(id_lat_step(j))],[id_lon_step(i+1)-id_lon_step(i) id_lat_step(j+1)-id_lat_step(j)],[1 1]);
    end
end

if latlim(1)>=latlim(2)
    lat_temp=lat;
    lat_temp(lat_temp<0)=lat_temp(lat_temp<0)+180;
    [~,idx_order_lat]=sort(lat_temp);
    lat=lat(idx_order_lat);bathy=bathy(:,idx_order_lat);
end

if lonlim(1)>=lonlim(2)
    lon_temp=lon;
    lon_temp(lon_temp<0)=lon_temp(lon_temp<0)+360;
    [~,idx_order_lon]=sort(lon_temp);
    lon=lon(idx_order_lon);bathy=bathy(idx_order_lon,:);
end
lon(lon<0)=lon(lon<0)+360;
bathy=flipud(bathy');
end