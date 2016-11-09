function [lat_s,lat_e,long_s,long_e]=start_end_lat_long_from_raw_file(filename)
fid=fopen(filename,'r','l');
lat_s=0;
lat_e=0;
long_s=0;
long_e=0;
HEADER_LEN=12;
if fid==-1
    return;
end

[path_f,fileN,~]=fileparts(filename);

fileIdx=fullfile(path_f,'echoanalysisfiles',[fileN '_echoidx.mat']);

if exist(fileIdx,'file')==2
    load(fileIdx);
else
    fprintf('File %s not indexed\n',fileN);
    fclose(fid);
    return;
end

idx_nme0=find(strcmp(idx_raw_obj.type_dg,'NME0'));

if isempty(idx_nme0)
    fclose(fid);
    return
end

i=1;
start_found=0;
while start_found==0&&i<=length(idx_nme0)
    pos=ftell(fid);
    fread(fid,idx_raw_obj.pos_dg(idx_nme0(i))-pos+HEADER_LEN,'uchar', 'l');
    str_temp=fread(fid,idx_raw_obj.len_dg(idx_nme0(i))-HEADER_LEN,'*char', 'l')';
    [gps_data,~]=nmea_to_attitude_gps({str_temp},idx_raw_obj.time_dg(idx_nme0(i)),1);
    if ~isempty(gps_data.Lat)
        start_found=1;
        lat_s=gps_data.Lat;
        long_s=gps_data.Long;
    else
        i=i+1;
    end
end

i=length(idx_nme0);
end_found=0;

while end_found==0&&i>01
    fseek(fid,idx_raw_obj.pos_dg(idx_nme0(i))+HEADER_LEN,'bof');
    str_temp=fread(fid,idx_raw_obj.len_dg(idx_nme0(i))-HEADER_LEN,'*char', 'l')';
    [gps_data,~]=nmea_to_attitude_gps({str_temp},idx_raw_obj.time_dg(idx_nme0(i)),1);
    if ~isempty(gps_data.Lat)
        end_found=1;
        lat_e=gps_data.Lat;
        long_e=gps_data.Long;
    else
        i=i-1;
    end
end

fclose(fid);


end
