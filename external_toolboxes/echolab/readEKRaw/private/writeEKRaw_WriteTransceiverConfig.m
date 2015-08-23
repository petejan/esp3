function writeEKRaw_WriteTransceiverConfig(fid, configXcvr)
%writeEKRaw_WriteTransceiverConfig  Write EK/ES transceiver configuration data to file.
%   writeEKRaw_WriteTransceiverConfig(fid, configXcvr) writes the per
%   transceiver configuration data to file.
%
%   The EK60 raw data format limits the channelid to 128 bytes, spare2 and
%   spare3 to 8 bytes, and spare4 to 52 bytes. Fields containing more than
%   this will be truncated. Fields are expanded as necessary.
%
%   REQUIRED INPUT:
%               fid:    file handle id
%        configXcvr:     a data structure containing the transceiver configuration
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

%  expand channel ID to 128 bytes if needed
fieldLen = length(configXcvr.channelid);
if (fieldLen < 128); configXcvr.channelid = [configXcvr.channelid ...
        char(zeros(1,128-fieldLen))]; end
fwrite(fid,configXcvr.channelid(1:128),'char', 'l');
fwrite(fid,configXcvr.beamtype,'int32', 'l');
fwrite(fid,configXcvr.frequency,'float32', 'l');
fwrite(fid,configXcvr.gain,'float32', 'l');
fwrite(fid,configXcvr.equivalentbeamangle,'float32', 'l');
fwrite(fid,configXcvr.beamwidthalongship,'float32', 'l');
fwrite(fid,configXcvr.beamwidthathwartship,'float32', 'l');
fwrite(fid,configXcvr.anglesensitivityalongship,'float32', 'l');
fwrite(fid,configXcvr.anglesensitivityathwartship,'float32', 'l');
fwrite(fid,configXcvr.anglesoffsetalongship,'float32', 'l');
fwrite(fid,configXcvr.angleoffsetathwartship,'float32', 'l');
fwrite(fid,configXcvr.posx,'float32', 'l');
fwrite(fid,configXcvr.posy,'float32', 'l');
fwrite(fid,configXcvr.posz,'float32', 'l');
fwrite(fid,configXcvr.dirx,'float32', 'l');
fwrite(fid,configXcvr.diry,'float32', 'l');
fwrite(fid,configXcvr.dirz,'float32', 'l');
fwrite(fid,configXcvr.pulselengthtable(1:5),'float32', 'l');
%  expand spare2 to 8 bytes if needed
fieldLen = length(configXcvr.spare2);
if (fieldLen < 8); configXcvr.spare2 = [configXcvr.spare2 ...
        char(zeros(1, 8 - fieldLen))]; end
fwrite(fid,configXcvr.spare2(1:8),'char', 'l');
fwrite(fid,configXcvr.gaintable(1:5),'float32', 'l');
%  expand spare3 to 8 bytes if needed
fieldLen = length(configXcvr.spare3);
if (fieldLen < 8); configXcvr.spare3 = [configXcvr.spare3 ...
        char(zeros(1, 8 - fieldLen))]; end
fwrite(fid,configXcvr.spare3(1:8),'char', 'l');
fwrite(fid,configXcvr.sacorrectiontable(1:5),'float32', 'l');
%  expand spare4 to 52 bytes if needed
fieldLen = length(configXcvr.spare4);
if (fieldLen < 52); configXcvr.spare4 = [configXcvr.spare4 ...
        char(zeros(1, 52 - fieldLen))]; end
fwrite(fid,configXcvr.spare4(1:52),'char', 'l');