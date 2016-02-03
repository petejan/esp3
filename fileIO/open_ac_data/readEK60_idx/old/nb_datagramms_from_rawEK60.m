function [nb_pings,nb_samples,channels,nb_nmea]=nb_datagramms_from_rawEK60(filename)
fid=fopen(filename);
if fid==-1
    return;
end

HEADER_LEN=12;

fread(fid, 1, 'int32', 'l');
dgType = char(fread(fid,4,'uchar', 'l')');

if ~strcmp(dgType,'CON0')
    nb_pings=-1;
    nb_samples=-1;
    channels=-1;
    nb_nmea=-1;
    return;
end
fread(fid,2,'uint32', 'l');
char(fread(fid,512,'uchar', 'l')');
nb_transceivers = fread(fid,1,'int32', 'l');

channels=nan(1,nb_transceivers);
nb_pings=zeros(1,nb_transceivers);
nb_samples=zeros(1,nb_transceivers);
i_chan=1;
i_raw0=0;
nb_nmea=0;
nb_dg=0;
fseek(fid, 0, -1);
while true
    len=fread(fid, 1, 'int32', 'l');
    if (feof(fid))
        break;
    end
    dgType = char(fread(fid,4,'uchar', 'l')');
    switch dgType
        case 'RAW0'
            fread(fid,HEADER_LEN-4,'uchar', 'l');
            i_raw0=i_raw0+1;
            chan_temp=int16(fread(fid,1,'int16','l'));
            
            if nansum(chan_temp==channels)==0
                channels(i_chan)=chan_temp;
                i_chan=i_chan+1;
            end
            fseek(fid,66,0);
            nb_pings(chan_temp==channels)=nb_pings(chan_temp==channels)+1;
            nb_samples(chan_temp==channels) = nanmax(fread(fid,1,'int32', 'l'),nb_samples(chan_temp==channels));
            fread(fid,len-2-(HEADER_LEN-4)-66-4,'uchar', 'l');
        case 'NME0'
            fread(fid,len,'uchar', 'l');
            nb_nmea=nb_nmea+1;
        otherwise
            fread(fid,len,'uchar', 'l');
    end
end

fclose(fid);

end
