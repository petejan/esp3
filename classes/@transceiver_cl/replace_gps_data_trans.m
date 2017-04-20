function gps_data_ping=replace_gps_data_trans(trans_obj,gps_data_obj)

    gps_data_ping=gps_data_obj.resample_gps_data(trans_obj.Time);
    
    trans_obj.GPSDataPing=gps_data_ping;

end