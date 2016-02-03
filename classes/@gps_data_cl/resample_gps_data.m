function obj=resample_gps_data(gps_obj,time)

if ~isempty(gps_obj.Lat)
    if nansum(size(gps_obj.Time)==size(time))<2
        time=time';
    end
    [lat,~]=resample_data_v2(gps_obj.Lat,gps_obj.Time,time,'Type','Angle');
    [long,~]=resample_data_v2(gps_obj.Long,gps_obj.Time,time,'Type','Angle');
    nmea=gps_obj.NMEA;
    
    if nansum((size(long)==size(time)))<2
        time=time';
    end
    if nansum(isnan(lat))<length(lat)
        if nansum(~isnan(lat))==length(lat)
            obj=gps_data_cl('Lat',lat,'Long',long,'Time',time,'NMEA',nmea);
        else
            warning('Issue with navigation data... No position for every pings')
            obj=gps_data_cl('Lat',lat,'Long',long,'Time',time,'NMEA',nmea);
        end
    else
        warning('Issue with navigation data...')
        obj=gps_data_cl();
    end
else
    obj=gps_data_cl();
end

end