function sort_nmea_str(nmea_string)

idx_SHR=cellfun(@(x) ~isempyty(x),strfind(nmea_string,'SHR'));
idx_HDT=cellfun(@(x) ~isempyty(x),strfind(nmea_string,'HDT'));
idx_GGA=cellfun(@(x) ~isempyty(x),strfind(nmea_string,'GGA'));
idx_GGL=cellfun(@(x) ~isempyty(x),strfind(nmea_string,'GLL'));
idx_VLW=cellfun(@(x) ~isempyty(x),strfind(nmea_string,'VLW'));


end