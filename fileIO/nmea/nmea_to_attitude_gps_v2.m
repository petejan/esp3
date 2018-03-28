
function [gps_data,attitude_full]=nmea_to_attitude_gps_v2(NMEA_string_cell,NMEA_time,idx_NMEA)
curr_gps=0;
curr_dist=0;
curr_att=0;
curr_heading=0;
[nmea,nmea_type]=cellfun(@parseNMEA,NMEA_string_cell(idx_NMEA),'UniformOutput',0);

NMEA_time=NMEA_time(idx_NMEA);

idx_gps=strcmp(nmea_type,'gps');
nmea_gps=nmea(idx_gps);
time_nmea_gps=NMEA_time(idx_gps);

try
    seconds_computer=time_nmea_gps*(24*60*60)-floor(time_nmea_gps)*24*60*60;
    seconds_gps=nan(1,numel(nmea_gps));
    for i=1:numel(nmea_gps)
        if ~isempty(nmea_gps{i}.time)
            if numel(nmea_gps{i}.time)==3
                seconds_gps(i)=nansum(double(nmea_gps{i}.time).*[60*60 60 1]);
            end
        end
    end
    
    time_diff=nanmean(seconds_gps-seconds_computer);
    
    if time_diff>1
        fprintf('Computer time is %s in advance on GPS time\n',datestr(time_diff/(24*60*60),'HH:MM:SS'));
    elseif time_diff<-1
        fprintf('Computer time is %s behind GPS time\n',datestr(time_diff/(24*60*60),'HH:MM:SS'));
    end
catch 
    disp('Could not compare GPS to computer time');
end

for iiii=1:length(idx_NMEA)

    try
        switch nmea_type{iiii}
            case 'gps'
                
                %Because gps messages can sometimes be corrupted
                %with spurious characters it is possible to parse
                %the NMEA message and still end up with invalid
                %lat/long values. The tests below are to ignore
                %such values
                
                if ~isempty(nmea{iiii}.lat) && isreal(nmea{iiii}.lat)       ...
                        && ~isempty(nmea{iiii}.lon) && isreal(nmea{iiii}.lon)       ...
                        && (nmea{iiii}.lat_hem == 'S' || nmea{iiii}.lat_hem == 'N') ...
                        && (nmea{iiii}.lon_hem == 'E' || nmea{iiii}.lon_hem == 'W')
                    
                    curr_gps=curr_gps+1;
                    gps.type{curr_gps}=nmea{iiii}.type;
                    gps.time(curr_gps) = NMEA_time(iiii);
                    %  set lat/lon signs and store values
                    if (nmea{iiii}.lat_hem == 'S')
                        gps.lat(curr_gps) = -nmea{iiii}.lat;
                    else
                        gps.lat(curr_gps) = nmea{iiii}.lat;
                    end
                    if (nmea{iiii}.lon_hem == 'W')
                        gps.lon(curr_gps) = -nmea{iiii}.lon;
                    else
                        gps.lon(curr_gps) = nmea{iiii}.lon;
                    end
                    
                    
                end
                %             case 'speed'
                %                 vspeed.time(curr_speed) = dgTime;
                %                 vspeed.speed(curr_speed) = nmea{iiii}.sog_knts;
                %                 curr_speed = curr_speed + 1;
            case 'dist'
                if ~isempty(nmea{iiii}.total_cum_dist)
                    curr_dist=curr_dist+1;
                    dist.time(curr_dist) = NMEA_time(iiii);
                    dist.vlog(curr_dist) = nmea{iiii}.total_cum_dist;
                    
                end
            case 'attitude'
                if  ~isempty(nmea{iiii}.heading) && ~isempty(nmea{iiii}.pitch) && ~isempty(nmea{iiii}.roll) && ~isempty(nmea{iiii}.heave)
                    curr_att=curr_att+1;
                    attitude.time(curr_att) = NMEA_time(iiii);
                    attitude.heading(curr_att) = nmea{iiii}.heading;
                    attitude.pitch(curr_att) = nmea{iiii}.pitch;
                    attitude.roll(curr_att) = nmea{iiii}.roll;
                    attitude.heave(curr_att) = nmea{iiii}.heave;
                    
                end
            case 'heading'
                if ~isempty(nmea{iiii}.heading)
                    curr_heading=curr_heading+1;
                    heading.time(curr_heading) = NMEA_time(iiii);
                    heading.heading(curr_heading) = nmea{iiii}.heading;
                    
                end
        end
    catch
        fprintf('Invalid NMEA message: %s\n',NMEA_string_cell{idx_NMEA(iiii)});
    end
end

if curr_gps>0&&isfield(gps,'lat')
    types=unique(gps.type);
    nb_type=cellfun(@(x) nansum(strcmp(x,gps.type)),types);
    [~,id_max]=nanmax(nb_type);
    id_keep=strcmp(types(id_max),gps.type);
    gps_data=gps_data_cl('Lat',gps.lat(id_keep),'Long',gps.lon(id_keep),'Time',gps.time(id_keep),'NMEA',gps.type{id_max});
else
    gps_data=gps_data_cl();
end

if curr_att>0
    attitude_full=attitude_nav_cl('Heading',attitude.heading,'Pitch',attitude.pitch,'Roll',attitude.roll,'Heave',attitude.heave,'Time',attitude.time);
elseif curr_heading>0
    attitude_full=attitude_nav_cl('Heading',heading.heading,'Time',heading.time);
else
    attitude_full=attitude_nav_cl.empty();
end
