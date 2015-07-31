function obj=resample_gps_data(gps_obj,time)

if ~isempty(gps_obj.Lat)
    if nansum(size(gps_obj.Time)==size(time))<2
        time=time';
    end
    [lat,~]=resample_data(gps_obj.Lat,gps_obj.Time,time);
    [long,time_gps]=resample_data(gps_obj.Long,gps_obj.Time,time);
    
    nmea=gps_obj.NMEA;
    
    if nansum((size(time_gps)==size(time)))<2
        time=time';
    end
    
    if nanmean(time_gps-time)<=100*nanmean(diff(time))
        obj=gps_data_cl('Lat',lat,'Long',long,'Time',time_gps,'NMEA',nmea);
    else
        obj=gps_data_cl();
    end
else
    obj=gps_data_cl();
end

end