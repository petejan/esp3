function [timestamp,depth,tag]=read_evl(filename)

fid = fopen(filename);
fgetl(fid);
line = fgetl(fid);
num_pings = sscanf(line, '%d');

timestamp=nan(1,num_pings);
depth=nan(1,num_pings);
tag=nan(1,num_pings);

for i = 1:num_pings
    if feof(fid)
        break;
    end
    line = fgetl(fid);
    temp=textscan(line, '%s %s %f %d');
    time=char(temp{2});
    date=char(temp{1});
    timestamp(i)=datenum([date time(1:end-3)], 'yyyymmddHHMMSS');
    ms=str2double(time(end-2:end))/1e3;
    timestamp(i)=timestamp(i)+ms/(24*60*60);
    %timestamp(i) = datenum(datetime([date time],'InputFormat','yyyyMMddHHmmSSSSSS'));
    %date_temp(i)=temp{1};
    %time_temp(i)=str2double(temp{2});
    depth(i) = temp{3};
    tag(i)=temp{4};
end

fclose(fid);
[timestamp,I] = sort(timestamp);
idx_rem=diff(timestamp)==0;
depth=depth(I);
tag=tag(I);
timestamp(idx_rem)=[];
depth(idx_rem)=[];
tag(idx_rem)=[];

end