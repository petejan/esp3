function configtransducer = readEKRaw_ReadTransducerConfig(fid)
%readEKRaw_ReadTransducerConfig  Read EK/ES transceiver configuration data
%   configtransducer = readEKRaw_ReadTransducerConfig(fid) returns a
%       structure containing the transceiver configuration from a EK/ES raw
%       data file.
%
%   REQUIRED INPUT:
%               fid:    file handle id
%
%   OPTIONAL PARAMETERS:    None
%       
%   OUTPUT:
%       Output is a data structure containing the transceiver configuration
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

configtransducer.channelid = char(fread(fid,128,'char')');
configtransducer.beamtype = fread(fid,1,'int32');
configtransducer.frequency = fread(fid,1,'float32');
configtransducer.gain = fread(fid,1,'float32');
configtransducer.equivalentbeamangle = fread(fid,1,'float32');
configtransducer.beamwidthalongship = fread(fid,1,'float32');
configtransducer.beamwidthathwartship = fread(fid,1,'float32');
configtransducer.anglesensitivityalongship = fread(fid,1,'float32');
configtransducer.anglesensitivityathwartship = fread(fid,1,'float32');
configtransducer.anglesoffsetalongship = fread(fid,1,'float32');
configtransducer.angleoffsetathwartship = fread(fid,1,'float32');
configtransducer.posx = fread(fid,1,'float32');
configtransducer.posy = fread(fid,1,'float32');
configtransducer.posz = fread(fid,1,'float32');
configtransducer.dirx = fread(fid,1,'float32');
configtransducer.diry = fread(fid,1,'float32');
configtransducer.dirz = fread(fid,1,'float32');
configtransducer.pulselengthtable = fread(fid,5,'float32');
configtransducer.spare2 = char(fread(fid,8,'char')');
configtransducer.gaintable = fread(fid,5,'float32');
configtransducer.spare3 = char(fread(fid,8,'char')');
configtransducer.sacorrectiontable = fread(fid,5,'float32');
configtransducer.spare4 = char(fread(fid,52,'char')');
