function bytesOut = writeEKRaw_WriteHeader(fid, header, rawData)
%writeEKRaw_WriteHeader  Write EK/ES raw data file header
%   writeEKRaw_WriteHeader(fid, header, data) writes a structure 
%       containing file header and transceiver configuration data.
%
%   REQUIRED INPUT:
%               fid:    file handle id
%            header:    the raw file header structure retured from readEKRaw
%           rawData:    the raw data structure returned from readEKRaw
%
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

%-

%  declare globals (defined in writeEKRaw)
global HEADER_LEN CONF_HEADER_LEN XCVR_HEADER_LEN;

%  determine length of the CON0 datagram
dgLen = HEADER_LEN + CONF_HEADER_LEN + (header.transceivercount * XCVR_HEADER_LEN);
bytesOut = dgLen + 8;

%  write the configuration datagram (file header)
fwrite(fid, dgLen, 'int32', 'l');
writeEKRaw_WriteDgHeader(fid, 'CON0', header.time);
writeEKRaw_WriteConfigHeader(fid, header);

%  write the individual xcvr configurations
for i = 1:header.transceivercount
    writeEKRaw_WriteTransceiverConfig(fid, rawData.config(i));
end

fwrite(fid, dgLen, 'int32', 'l');