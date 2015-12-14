function dgHeader = readEKTelegram_ReadDGHeader(fid, fType, fDate)
%readEKTelegram_ReadDGHeader  Read EK60/EK500 DG telegram header
%   dgHeader = readEKTelegram_ReadDGHeader(fid, type) returns a  structure
%       containing an DG/EK telegram header.
%
%   REQUIRED INPUT:
%               fid:    file handle id
%              type:    a string containing the DG file type.  Supported
%                       types are:
%
%                       'ek5': Sonardata Echolog 500 files
%                       'dg' : Simrad .dg files
%
%
%   OPTIONAL PARAMETERS:    None
%       
%   OUTPUT:
%       Output is a structure containing the telegram header data
%
%   REQUIRES:   None
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%-

dgHeader.size = fread(fid,1,'int16', 'l');
if strcmp(fType, 'dg')
    dgHeader.checksum = char(fread(fid,2,'char', 'l')');
end
dgHeader.type = char(fread(fid,2,'char', 'l')');
char(fread(fid,1,'char', 'l')');
dgTime = char(fread(fid,8,'char', 'l')');
char(fread(fid,1,'char', 'l')');
dgHeader.time = datenum(fDate(1), fDate(2), fDate(3), str2double(dgTime(1:2)), ...
    str2double(dgTime(3:4)), str2double(dgTime(5:6)) + (str2double(dgTime(7:8)) / 100));

