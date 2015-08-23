function writeEKRaw_WriteConfigHeader(fid, configheader)
%writeEKRaw_WriteConfigHeader  Write EK/ES DG configuration header
%   writeEKRaw_WriteConfigHeader(fid, configheader) writes the data
%       contained in the readEKRaw configuration header to file.
%
%   The EK60 raw data format limits the surveyname, transectname,
%   soundername, and spare fields to 128 bytes. Fields containing more than
%   128 bytes will be truncated. Fields are expanded as necessary.
%
%   REQUIRED INPUT:
%               fid:    file handle id
%      configheader:    the configuration structure retured from readEKRaw
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
%
%   Based on code by Lars Nonboe Andersen, Simrad.

%-

%  expand surveyname to 128 bytes if needed
fieldLen = length(configheader.surveyname);
if (fieldLen < 128); configheader.surveyname = [configheader.surveyname ...
        char(zeros(1,128-fieldLen))]; end
fwrite(fid,configheader.surveyname(1:128),'char', 'l');
%  expand transectname to 128 bytes if needed
fieldLen = length(configheader.transectname);
if (fieldLen < 128); configheader.transectname = [configheader.transectname ...
        char(zeros(1,128-fieldLen))]; end
fwrite(fid,configheader.transectname(1:128),'char', 'l');
%  expand soundername to 128 bytes if needed
fieldLen = length(configheader.soundername);
if (fieldLen < 128); configheader.soundername = [configheader.soundername ...
        char(zeros(1,128-fieldLen))]; end
fwrite(fid,configheader.soundername(1:128),'char', 'l');
%  expand spare to 128 bytes if needed
fieldLen = length(configheader.spare);
if (fieldLen < 128); configheader.spare = [configheader.spare ...
        char(zeros(1,128-fieldLen))]; end
fwrite(fid,configheader.spare(1:128),'char', 'l');
fwrite(fid,configheader.transceivercount,'int32', 'l');

