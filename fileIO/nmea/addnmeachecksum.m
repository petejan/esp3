
function NMEA_String = addnmeachecksum(NMEA_String)
checksum = 0;
if contains(NMEA_String,'*')
    NMEA_String = strtok(NMEA_String,'*');
end

NMEA_String_d = double(NMEA_String);   
for count = 2:length(NMEA_String)      
    checksum = bitxor(checksum,NMEA_String_d(count)); 
    checksum = uint16(checksum);       
end

checksum = double(checksum);
checksum = dec2hex(checksum);


if length(checksum) == 1
    checksum = strcat('0',checksum);
end

NMEA_String = strcat(NMEA_String, strcat('*',checksum));