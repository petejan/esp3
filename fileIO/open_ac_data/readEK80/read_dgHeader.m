function [dgType,dgTime]=read_dgHeader(fid,timeOffset)

dgType = char(fread(fid,4,'char', 'l')');
%  read datagram time (NT Time - number of 100-nanosecond
%  intervals since January 1, 1601)
lowdatetime = fread(fid,1,'uint32', 'l');
highdatetime = fread(fid,1,'uint32', 'l');
%  convert NT time to MATLAB serial time
ntSecs = (highdatetime * 2 ^ 32 + lowdatetime) / 10000000;
dgTime = datenum(1601, 1, 1, timeOffset, 0, ntSecs);

end