function [gps_data,attitude_data]=read_n_file(filename,start_time,end_time)

filename(end-7)='n';

fid=fopen(filename,'r');

if fid == -1
    warning(['Unable to open file ' sprintf('d%07d',filenumber)]);
    gps_data=[];
    return;
end

%'4 LAT: 43 18.2600 S    LONG: 174 7.4600 E HDG: 164 SOG: 7.3 HDT: Depth: No HPR';
formatSpec='%f LAT: %f %f %c    LONG: %f %f %c HDG: %f SOG: %f HDT: %f Depth: %f ';

i=0;
while (true)
    if (feof(fid))
        break;
    end
    i=i+1;
    tline=strtrim(fgetl(fid));
       
%     l_old=length(tline);
%     tline = strrep(tline, ' ', ',');
%     l_new=0;
%     while l_new<l_old
%         l_old=length(tline);
%         tline = strrep(tline, ',,', ',');
%         l_new=length(tline);
%     end
    
    out = textscan(tline,formatSpec);
    switch out{4}
        case 'S'
            lat(out{1}+1)=-(double(out{2}) + out{3} / 60);
        otherwise
            lat(out{1}+1)=(double(out{2}) + out{3} / 60);
    end
    
    switch out{7}
        case 'E'
            lon(out{1}+1)=(double(out{5}) + out{6} / 60);
        otherwise
            lon(out{1}+1)=-(double(out{5}) + out{6} / 60);
    end
    sog(out{1}+1)=out{9};
    heading(out{1}+1)=out{8};    
end
fclose(fid);
time=linspace(start_time,end_time,length(lat));

gps_data=gps_data_cl('Lat',lat,'Long',lon,'Time',time,'NMEA','Esp2');
attitude_data=attitude_nav_cl('Heading',heading,'Time',time);



end