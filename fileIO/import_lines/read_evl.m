function [timestamp,depth]=read_evl(filename)

fid = fopen(filename);
fgetl(fid);
line = fgetl(fid);
num_pings = sscanf(line, '%d');

timestamp=nan(1,num_pings);
depth=nan(1,num_pings);

for i = 1:num_pings
    line = fgetl(fid);
    date=line(1:8);
    time=line(10:19);
    temp=sscanf(line, '%*d %*d %f %d');
    timestamp(i) = datenum([date 'T' time], 'yyyymmddTHHMMSS');
    depth(i) = temp(1);
end
fclose(fid);

end