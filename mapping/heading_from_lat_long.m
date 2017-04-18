function heading=heading_from_lat_long(lat,long)

x = sind(diff(long)).* cos(lat(2:end));
 y = cosd(lat(1:end-1)).*sind(lat(2:end))-...
        sind(lat(1:end-1)).*cosd(lat(2:end)).*cosd(diff(long));
    
heading = atan2d(y,x);

end