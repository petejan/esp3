function [dgType,ntSecs]=readEK60Header_v2(fid)

%  read datagram type
dgType = char(fread(fid,4,'uchar', 'l')');

%  read datagram time (NT Time - number of 100-nanosecond 
%  intervals since January 1, 1601)
lowdatetime = fread(fid,1,'uint32', 'l');
highdatetime = fread(fid,1,'uint32', 'l');

%  convert NT time to seconds
ntSecs = (highdatetime * 2 ^ 32 + lowdatetime) / 10000000;
end

