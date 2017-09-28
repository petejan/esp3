function [dgType,ntSecs]=readEK60Header_v2(fid)

%  read datagram type
dgType = char(fread(fid,4,'uchar', 'l')');

%  read datagram time (NT Time - number of 100-nanosecond 
%  intervals since January 1, 1601)
time_tot=fread(fid,2,'uint32', 'l');
%  convert NT time to seconds
ntSecs = (time_tot(2) * 2 ^ 32 + time_tot(1)) / 10000000;
end

