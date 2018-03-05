function [lat_str,lon_str]=print_pos_str(lat,lon)

    if lon>180||lon<0
        
        e0w='W';
        if lon>180
           lon=abs(lon-360); 
        end
    else
        e0w='E';
    end
    
    if lat>0
        n0s='N';
    else
        n0s='S';
        lat=abs(lat);
    end
    lat_deg=floor(abs(lat));
    lon_deg=floor(abs(lon));
    lat_min=(abs(lat)-abs(lat_deg))*60;
    
    lon_min=(abs(lon)-abs(lon_deg))*60;
    
    lat_str=sprintf('%.0f %c %.2f %s',lat_deg,char(hex2dec('00BA')),lat_min,n0s);
    lon_str=sprintf('%.0f %c %.2f %s',lon_deg,char(hex2dec('00BA')),lon_min,e0w);
