function [header,data]=data_from_raw_idx_cl(path_f,idx_raw_obj,varargin)

p = inputParser;
addRequired(p,'path_f',@(x) ischar(x));
addRequired(p,'idx_raw_obj',@(x) isa(x,'raw_idx_cl'));
addParameter(p,'PingRange',[1 inf],@isnumeric);
addParameter(p,'SampleRange',[1 inf],@isnumeric);
addParameter(p,'Frequencies',[],@isnumeric);
addParameter(p,'GPSOnly',0,@isnumeric);

parse(p,path_f,idx_raw_obj,varargin{:});
results=p.Results;

PingRange=results.PingRange;
SampleRange=results.SampleRange;
Frequencies=results.Frequencies;

HEADER_LEN=12;
fid=fopen(fullfile(path_f,idx_raw_obj.filename),'r');

if fid==-1
    warning('Cannot Open file %s',idx_raw_obj.filename);
    header=-1;
    data=-1;
    return;
end
    

[tmp, freq] = readEKRaw_ReadHeader(fid);
header=tmp.header;
if isempty(Frequencies)
    idx_freq=(1:length(freq))';
else
    [~,~,idx_freq] = intersect(Frequencies,freq);
end

if isempty(idx_freq)
    idx_freq=(1:length(freq))';
end


if p.Results.GPSOnly>0
    channels=[];
    nb_pings=0;
    nb_samples=0;
else
channels=unique(idx_raw_obj.chan_dg(~isnan(idx_raw_obj.chan_dg)));
channels=channels(idx_freq);
nb_pings=idx_raw_obj.get_nb_pings_per_channels();
nb_pings=nb_pings(idx_freq);
nb_pings=nanmin(nb_pings,PingRange(2));
nb_pings=nb_pings-PingRange(1)+1;
nb_pings(nb_pings<0)=0;

nb_samples=idx_raw_obj.get_nb_samples_per_channels();
nb_samples=nb_samples(idx_freq);
nb_samples=nanmin(nb_samples,SampleRange(2));
nb_samples=nb_samples-SampleRange(1)+1;
nb_samples(nb_samples<0)=0;
end

nb_nmea=idx_raw_obj.get_nb_nmea_dg();

data=init_dataEK60(nb_pings,nb_samples,nb_nmea);

data.config=tmp.transceiver(idx_freq);
header.transceivercount=length(idx_freq);

time_nmea=idx_raw_obj.get_time_dg('NME0');
data.NMEA.time= time_nmea;
data.NMEA.string= cell(1,nb_nmea);
i_ping=zeros(1,length(channels));
i_nmea=0;


for idg=1:length(idx_raw_obj.type_dg)
   pos=ftell(fid);
   
   switch  idx_raw_obj.type_dg{idg}
       case 'NME0'
          %fseek(fid,idx_raw_obj.pos_dg(idg),'bof');
          fread(fid,idx_raw_obj.pos_dg(idg)-pos+HEADER_LEN,'uchar', 'l');
          i_nmea=i_nmea+1;
          data.NMEA.string{i_nmea}=char(fread(fid,idx_raw_obj.len_dg(idg)-HEADER_LEN,'uchar', 'l')');
       case 'RAW0'
           if p.Results.GPSOnly>0
               continue;
           end
           chan=idx_raw_obj.chan_dg(idg);
           idx_chan=find(chan==channels);
           if isempty(idx_chan)
               continue;
           end
           %fseek(fid,idx_raw_obj.pos_dg(idg),'bof');
           fread(fid,idx_raw_obj.pos_dg(idg)-pos+HEADER_LEN,'uchar', 'l');
           i_ping(idx_chan)=i_ping(idx_chan)+1;
           if (i_ping(idx_chan)>=PingRange(1))&&(i_ping(idx_chan)<=PingRange(2))
               data.pings(idx_chan).time(i_ping(idx_chan)-PingRange(1)+1)=idx_raw_obj.time_dg(idg);

                data=readRaw0(data,idx_chan,i_ping(idx_chan)-PingRange(1)+1,PingRange,SampleRange,fid);

           end
   end
end


fclose(fid);
end