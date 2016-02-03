function index_from_rawEK60(filename)
fid=fopen(filename);

if fid==-1
    return;
end
HEADER_LEN=12;

[nb_pings,nb_samples,channels,nb_nmea]=nb_datagramms_from_rawEK60(filename);

pos_pings=nan(1,nansum(nb_pings));
time_pings=nan(1,nansum(nb_pings));
pos_nmea=nan(1,nb_nmea);
time_nmea=nan(1,nb_nmea);
len_nmea=nan(1,nb_nmea);
chan_pings=nan(1,nansum(nb_pings));

i_nme0=0;
i_raw0=0;

while true
    len=fread(fid, 1, 'int32', 'l');
    if (feof(fid))
        break;
    end
    [dgType, dgTime] = readEKRaw_ReadDgHeader(fid, 0);
    switch dgType
        case 'CON0'
            fread(fid,len-HEADER_LEN+4,'uchar', 'l');
        case 'RAW0'
            i_raw0=i_raw0+1;
            pos_pings(i_raw0)=ftell(fid)-HEADER_LEN;
            time_pings(i_raw0)=dgTime;
            chan_pings(i_raw0)=int16(fread(fid,1,'int16','l'));
            fread(fid,len-(HEADER_LEN-4)-2,'uchar', 'l');
        case 'NME0'
            i_nme0=i_nme0+1;
            pos_nmea(i_nme0)=ftell(fid)-HEADER_LEN; 
            time_nmea(i_nme0)=dgTime;
            len_nmea(i_nme0)=len;
            fread(fid,len-HEADER_LEN+4,'uchar', 'l');
        case 'TAG0'
             fread(fid,len-HEADER_LEN+4,'uchar', 'l');
        case 'SVP0'
             fread(fid,len-HEADER_LEN+4,'uchar', 'l');
        otherwise
             fread(fid,len-HEADER_LEN+4,'uchar', 'l');
    end
end

fclose(fid);
save([filename(1:end-4) '_echoidx.mat'],'pos_pings','time_pings','chan_pings','pos_nmea','time_nmea','len_nmea','nb_samples','channels');
end
