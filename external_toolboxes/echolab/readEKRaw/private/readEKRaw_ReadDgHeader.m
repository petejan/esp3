function [dgType, dgTime] = readEKRaw_ReadDgHeader(fid, timeOffset)
%READEKRAW_READDGHEADER  Read EK/ES DG datagram header
%   dgheader = readEKRaw_ReadDgHeader(fid, timeOffset) returns the datagram type
%   and time. Time is returned in MATLAB serial time.
%
%   REQUIRED INPUT:
%               fid:    file handle id
%        timeOffset:    Offset, in hours, to add to the datagram timestamp.
%                       timeOffset can be used to syncronize pings with GPS time
%                       in datasets which were collected with a misconfigured
%                       PC clock.
%
%   OPTIONAL PARAMETERS:    None
%       
%   OUTPUT:
%       Output is two scalar variables - one containing the datagram type, the
%       other the datagram time converted to MATLAB serial time.
%
%   REQUIRES:   None
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%-

%  read datagram type
dgType = char(fread(fid,4,'char', 'l')');

%  read datagram time (NT Time - number of 100-nanosecond 
%  intervals since January 1, 1601)
lowdatetime = fread(fid,1,'uint32', 'l');
highdatetime = fread(fid,1,'uint32', 'l');

%  convert NT time to MATLAB serial time
ntSecs = (highdatetime * 2 ^ 32 + lowdatetime) / 10000000;
dgTime = datenum(1601, 1, 1, timeOffset, 0, ntSecs);
