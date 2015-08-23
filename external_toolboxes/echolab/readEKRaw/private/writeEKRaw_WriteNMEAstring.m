function dgLen = writeEKRaw_WriteNMEAstring(fid, time, nmeaString, pad)
%writeEKRaw_WriteNMEAstring  write a NMEA string to an open Simrad .raw file
%   outBytes = writeEKRaw_WriteNMEAstring(fid, nmeaString) writes a NMEA
%       formatted string to a Simrad .raw file and returns the number of
%       bytes written.
%
%   REQUIRED INPUT:
%       nmeaString:     The NMEA string to write (do not include <cr><lf>)
%              fid:     The handle to the .raw file
%
%   OPTIONAL PARAMETERS:    None
%       
%   OUTPUT:
%       A scalar containing the number of bytes written to disk
%
%   REQUIRES:   None
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov
%

%-

global HEADER_LEN

%  the NMEA strings seem to be terminated with 2 or 4 nulls.
%  Not really sure what the logic is, so we'll throw a couple
%  of nulls on for good measure.
if pad; nmeaString = [uint8(nmeaString) 0 0]; end

%  calculate the length
dgLen = HEADER_LEN + length(nmeaString);
            
%  write the datagram length
fwrite(fid, dgLen, 'int32','l');

%  write the datagram header
writeEKRaw_WriteDgHeader(fid, 'NME0', time);

%  write the NMEA string
fwrite(fid, nmeaString, 'char', 'l');

%  write the datagram length again
fwrite(fid, dgLen, 'int32','l');