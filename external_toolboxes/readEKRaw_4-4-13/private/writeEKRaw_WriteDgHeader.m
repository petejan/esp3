function writeEKRaw_WriteDgHeader(fid, dgType, dgTime)
%writeEKRaw_WriteDgHeader  Write EK/ES DG datagram header
%   writeEKRaw_WriteDgHeader(fid, dgType, dgTime) write the datagram type
%   and time to the file id.  
%
%   REQUIRED INPUT:
%              fid:     file handle id
%           dgType:     String containing datagram Type name
%           dgTime:     Datagram time stamp in MATLAB serial time
%
%   OPTIONAL PARAMETERS:    None
%       
%   OUTPUT:     None
%
%   REQUIRES:   None
%
%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%  declare the global MATLAB to NT time offset which is the number of 100
%  nano-second intervals from MATLAB's serial time reference point of
%  Jan 1 0000 00:00:00 to NT time's reference point of Jan 1 1601 00:00:00
global MATLAB_NT_TIME_OFFSET

%  write the datagram type
fwrite(fid,dgType(1:4),'char', 'l');

%  convert MATLAB serial time to NT time
%  due to limitations in the DATENUM fuction, some precision is lost
%  in the conversion. The error is around 1.0e-5 seconds.
ntTime = uint64((dgTime * 864000000000) - MATLAB_NT_TIME_OFFSET);
highdatetime = bitshift(ntTime, -32);
lowdatetime = bitand(ntTime, 2^32 - 1);

%  write datagram time 
fwrite(fid, lowdatetime, 'uint32', 'l');
fwrite(fid, highdatetime, 'uint32', 'l');


