function [header, frequencies] = readEKRaw_ReadHeader(fid)
%readEKRaw_ReadHeader  Read EK/ES raw data file header
%   [header, frequencies] = readEKRaw_ReadHeader(fid) returns a structure 
%       containing file header and transceiver configuration data.
%
%   REQUIRED INPUT:
%               fid:    file handle id
%
%   OPTIONAL PARAMETERS:    None
%       
%   OUTPUT:
%       Output is a data structure containing the header and transceiver
%       configuration data.
%
%   REQUIRES:   None
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%-

%  read configuration datagram (file header)
fread(fid, 1, 'int32', 'l');
[dgType, dgTime] = readEKRaw_ReadDgHeader(fid, 0);

configheader = readEKRaw_ReadConfigHeader(fid);
configheader.time = dgTime;

%  extract individual xcvr configurations and store list of frequencies
frequencies = zeros(1, configheader.transceivercount);
for i = 1:configheader.transceivercount
    configXcvr(i) = readEKRaw_ReadTransceiverConfig(fid);
    frequencies(i) = configXcvr(i).frequency;
end

%  create the configuration structure - store header and xcvr configs
header = struct('header',configheader,'transceiver',configXcvr);

fread(fid, 1, 'int32', 'l');