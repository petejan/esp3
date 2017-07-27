function rmc_str=latlong2rmc(lat,lon,timestamp,speed_knots,heading)
% $GPRMC,123519,A,4807.038,N,01131.000,E,022.4,084.4,230394,003.1,W*6A
% 
% Where:
%      RMC          Recommended Minimum sentence C
%      123519       Fix taken at 12:35:19 UTC
%      A            Status A=active or V=Void.
%      4807.038,N   Latitude 48 deg 07.038' N
%      01131.000,E  Longitude 11 deg 31.000' E
%      022.4        Speed over the ground in knots
%      084.4        Track angle in degrees True
%      230394       Date - 23rd of March 1994
%      003.1,W      Magnetic Variation
%      *6A          The checksum data, always begins with *


time=datestr(timestamp,'HHMMSS');
date=datestr(timestamp,'ddmmyyyy');
lat_deg=floor(abs(lat));
lon_deg=floor(abs(lon));

lat_min=(abs(lat)-lat_deg)*100/60;
lon_min=(abs(lon)-lon_deg)*100/60;

if sign(lat)>=0
    nos='N';
else
    nos='S';
end

if sign(lon)>=0
    eow='E';
else
    eow='W';
end


rmc_str=sprintf('$GPRMC,%s,A,%02d%02.3f,%c,%03d%02.3f,%c,%03.1f,%03.1f,%s,,',time,lat_deg,lat_min,nos,lon_deg,lon_min,eow,speed_knots,heading,date);
rmc_str=addnmeachecksum(rmc_str);
