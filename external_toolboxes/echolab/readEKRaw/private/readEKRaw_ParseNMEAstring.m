function nmea = readEKRaw_ParseNMEAstring(nmeaString, rData)
%readEKRaw_ParseNMEAstring  parse NMEA string and return data in structure
%   nmea = readEKRaw_ParseNMEAstring(nmeaString, rData) parses the given  
%       NMEA string and returns a structure containing the data.
%
%   REQUIRED INPUT:
%       nmeaString:     A comma delimited NMEA 0183 string.
%            rData:     The readEKRaw parameter structure.
%
%   OPTIONAL PARAMETERS:    None
%       
%   OUTPUT:
%       Structure containing the fields which constitute the NMEA string passed
%       to the function.  More info on NMEA string formats can be found here:
%       http://www.nmea.de/nmea0183datensaetze.html
%
%   REQUIRES:   None
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov
%

%-

try

    %  extract the NMEA datagram type
    idx = regexp(nmeaString, ',');
	
    type = upper(nmeaString(2:idx(1) - 1));
    nmeadata = nmeaString(idx(1) + 1:end);
    %  remove checksum - add trailing comma for output lacking last field
    idx = regexp(nmeadata, '*');
    if (isempty(idx));
        nmeadata = [nmeadata ','];
    else
        nmeadata = [nmeadata(1:idx - 1) ',']; 
    end
    %  fill any empty fields (strread can't handle them)
    nmeadata = strrep(nmeadata, ',,', ',0');

    %  process datagram by type - only process datagrams we're interested in
    nmea = struct('type', 'NONE', 'string', '');

    switch type(3:end)

        case 'GGA'
            if (rData.gps && strcmpi(type, rData.gpsSource))
                %  parse the rest of the nmea text
                format = '%2d %2d %f %2d %f %c %3d %f %c %d %d %f %f %c %f %c %f %d';
                [out{1:18}] = strread(nmeadata, format, 1, 'delimiter', ',');

                %  define GPS GPGGA datagram
                nmea = struct('type', type, ...
                              'time', [out{1} out{2} out{3}], ...
                              'lat', out{4} + out{5} / 60, ...          
                              'lat_hem', out{6}, ...
                              'lon', out{7} + out{8} / 60, ...
                              'lon_hem', out{9}, ...
                              'fix', out{10}, ...
                              'nsat', out{11}, ...
                              'precision', out{12}, ...
                              'msl_alt', out{13}, ...
                              'msl_unit', out{14}, ...
                              'geoidal_alt', out{15}, ...
                              'geoidal_unit', out{16}, ...
                              'dif_age', out{17}, ...
                              'dif_sta', out{18} ...
                              );
            end

        case 'GLL'
            if (rData.gps && strcmpi(type, rData.gpsSource))
                %  parse the rest of the nmea text
                format = '%2d %f %c %3d %f %c %2d %2d %f %c';
                [out{1:10}] = strread(nmeadata, format, 1, 'delimiter', ',');

                %  convert status to GGA fix
                fix = strcmpi('A', out{10});

                %  define GPS geographic position datagram
                nmea = struct('type', type, ...
                              'lat', out{1} + out{2} / 60, ...          
                              'lat_hem', out{3}, ...
                              'lon', out{4} + out{5} / 60, ...
                              'lon_hem', out{6}, ...
                              'time', [out{7} out{8} out{9}], ...
                              'fix', fix ...
                              );
            end

        case 'VTG'
            if (rData.vSpeed)
                %  parse the rest of the nmea text
                format = '%f %c %f %c %f %c %f %c';
                [out{1:8}] = strread(nmeadata, format, 1, 'delimiter', ',');

                %  define Course Over Ground datagram
                nmea = struct('type', type, ...
                              'true_cov', out{1}, ...
                              'tcov_label', out{2}, ...
                              'mag_cov', out{3}, ...
                              'mcov_label', out{4}, ...
                              'sog_knts', out{5}, ...
                              'sogn_unit', out{6}, ...
                              'sog_kph', out{7},...
                              'sogk_unit', out{8} ...
                              );
            end

        case 'VLW'
            if (rData.vlog)
                %  parse the rest of the nmea text
                format = '%f %c %f %c';
                [out{1:4}] = strread(nmeadata, format, 1, 'delimiter', ',');

                %  define Distance Traveled through Water datagram
                nmea = struct('type', type, ...
                              'total_cum_dist', out{1}, ...
                              'tcd_unit', out{2}, ...
                              'dist_since_reset', out{3}, ...
                              'dsr_unit', out{4} ...
                      );
            end

        otherwise
            %  unknown datagram type
            nmea = struct('type', type, 'string', nmeadata);

    end
    
catch
    
    %  malformed NMEA string
    nmea = struct('type', 'XXXXX', 'string', nmeaString);
    
end