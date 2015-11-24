
function [gps_data,attitude_full]=nmea_to_attitude_gps(NMEA_string_cell,NMEA_time,idx_NMEA)
curr_gps=0;
curr_dist=0;
curr_att=0;
curr_heading=0;

for iiii=idx_NMEA(:)'
    %for iiii=1:length(NMEA_string_cell)
    curr_message=NMEA_string_cell{iiii};
    curr_message(isspace(curr_message))=' ';
    [nmea,nmea_type]=parseNMEA(curr_message);
    try
        switch nmea_type
            case 'gps'
                
                %Because gps messages can sometimes be corrupted
                %with spurious characters it is possible to parse
                %the NMEA message and still end up with invalid
                %lat/long values. The tests below are to ignore
                %such values
                
                if ~isempty(nmea.lat) && isreal(nmea.lat)       ...
                        && ~isempty(nmea.lon) && isreal(nmea.lon)       ...
                        && (nmea.lat_hem == 'S' || nmea.lat_hem == 'N') ...
                        && (nmea.lon_hem == 'E' || nmea.lon_hem == 'W')
                    if curr_gps==0
                        gps.type=nmea.type;
                    end
                    if strcmp(nmea.type,gps.type)
                        curr_gps=curr_gps+1;
                        
                        gps.time(curr_gps) = NMEA_time(iiii);
                        %  set lat/lon signs and store values
                        if (nmea.lat_hem == 'S');
                            gps.lat(curr_gps) = -nmea.lat;
                        else
                            gps.lat(curr_gps) = nmea.lat;
                        end
                        if (nmea.lon_hem == 'W');
                            gps.lon(curr_gps) = -nmea.lon;
                        else
                            gps.lon(curr_gps) = nmea.lon;
                        end
                        
                    end
                end
                %             case 'speed'
                %                 vspeed.time(curr_speed) = dgTime;
                %                 vspeed.speed(curr_speed) = nmea.sog_knts;
                %                 curr_speed = curr_speed + 1;
            case 'dist'
                if ~isempty(nmea.total_cum_dist)
                    curr_dist=curr_dist+1;
                    dist.time(curr_dist) = NMEA_time(iiii);
                    dist.vlog(curr_dist) = nmea.total_cum_dist;
                    
                end
            case 'attitude'
                if  ~isempty(nmea.heading) && ~isempty(nmea.pitch) && ~isempty(nmea.roll) && ~isempty(nmea.heave)
                    curr_att=curr_att+1;
                    attitude.time(curr_att) = NMEA_time(iiii);
                    attitude.heading(curr_att) = nmea.heading;
                    attitude.pitch(curr_att) = nmea.pitch;
                    attitude.roll(curr_att) = nmea.roll;
                    attitude.heave(curr_att) = nmea.heave;
                    
                end
            case 'heading'
                if ~isempty(nmea.heading)
                    curr_heading=curr_heading+1;
                    heading.time(curr_heading) = NMEA_time(iiii);
                    heading.heading(curr_heading) = nmea.heading;
                    
                end
        end
    catch
        fprintf('Invalid NMEA message: %s\n',curr_message);
    end
end

if curr_gps>0
    gps_data=gps_data_cl('Lat',gps.lat,'Long',gps.lon,'Time',gps.time,'NMEA',gps.type);
else
    gps_data=gps_data_cl();
end

if curr_att>0
    attitude_full=attitude_nav_cl('Heading',attitude.heading,'Pitch',attitude.pitch,'Roll',attitude.roll,'Heave',attitude.heave,'Time',attitude.time);
elseif curr_heading>0
    attitude_full=attitude_nav_cl('Heading',heading.heading,'Time',heading.time);
else
    attitude_full=attitude_nav_cl();
end
