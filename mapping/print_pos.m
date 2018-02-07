function pos_string=print_pos(lat,long)


    if long>180||long<0
        
        e0w=[char(hex2dec('00BA')) 'W'];
        if long>180
           long=abs(long-360); 
        end
    else
        e0w=[char(hex2dec('00BA')) 'E'];
    end
    
    if lat>0
        n0s=[char(hex2dec('00BA')) 'N'];
    else
        n0s=[char(hex2dec('00BA')) 'S'];
        lat=abs(lat);
    end
    
    pos_string=sprintf('Lat:%.6f %s\n Long:%.6f %s',lat,n0s,long,e0w);
