function [header,config,data]=data_from_index(fileN,pos_pings,timer_pings,chan_pings,pos_nmea,time_nmea,len_nmea,nb_samples,channels)
HEADER_LEN=12;
fid=fopen(fileN,'r');
nb_transceivers=length(channels);

[tmp, frequencies] = readEKRaw_ReadHeader(fid);

header=tmp.header;
config=tmp.transceiver;

for i=1:nb_transceivers
    nb_pings_channel=nansum(channels(i)==chan_pings);  
    data.ping(i).mode = nan(1,nb_pings_channel);
    data.ping(i).transducerdepth = nan(1,nb_pings_channel);
    data.ping(i).frequency = nan(1,nb_pings_channel);
    data.ping(i).transmitpower = nan(1,nb_pings_channel);
    data.ping(i).pulselength = nan(1,nb_pings_channel);
    data.ping(i).bandwidth = nan(1,nb_pings_channel);
    data.ping(i).sampleinterval = nan(1,nb_pings_channel);
    data.ping(i).soundvelocity = nan(1,nb_pings_channel);
    data.ping(i).absorptioncoefficient = nan(1,nb_pings_channel);
    data.ping(i).heave = nan(1,nb_pings_channel);
    data.ping(i).roll = nan(1,nb_pings_channel);
    data.ping(i).pitch = nan(1,nb_pings_channel);
    data.ping(i).temperature = nan(1,nb_pings_channel);
    data.ping(i).trawlupperdepthvalid = nan(1,nb_pings_channel);
    data.ping(i).trawlopeningvalid = nan(1,nb_pings_channel);
    data.ping(i).trawlupperdepth = nan(1,nb_pings_channel);
    data.ping(i).trawlopening = nan(1,nb_pings_channel);
    data.ping(i).offset = nan(1,nb_pings_channel);
    data.ping(i).count = nan(1,nb_pings_channel);
    data.ping(i).power=nan(nb_samples(i),nb_pings_channel);
    data.ping(i).alongship=nan(nb_samples(i),nb_pings_channel);
    data.ping(i).athwartship=nan(nb_samples(i),nb_pings_channel);
    data.pings(i).time= nan(1,nb_pings_channel);
    
end
data.NMEA.time= time_nmea;
data.NMEA.string= cell(1,length(pos_nmea));

for ij=1:length(pos_nmea)
    fseek(fid,pos_nmea(ij)+HEADER_LEN,'bof');
    data.NMEA.string{ij}=fread(fid,len_nmea(ij)-HEADER_LEN,'uchar', 'l');
end

ping_chan=zeros(1,nb_transceivers);

for ii=1:length(pos_pings)
    
    fseek(fid,pos_pings(ii),'bof');
    fread(fid,HEADER_LEN,'uchar', 'l');
    channel = fread(fid,1,'int16', 'l');
    idx_data=find(channel==channels);
    ping_chan(idx_data)=ping_chan(idx_data)+1;
    
    mode_low = fread(fid,1,'int8', 'l');
    mode_high = fread(fid,1,'int8', 'l');
    data.ping(idx_data).mode(ping_chan(idx_data)) = 256 * mode_high + mode_low;
    data.ping(idx_data).transducerdepth(ping_chan(idx_data)) = fread(fid,1,'float32', 'l');
    data.ping(idx_data).frequency(ping_chan(idx_data)) = fread(fid,1,'float32', 'l');
    data.ping(idx_data).transmitpower(ping_chan(idx_data)) = fread(fid,1,'float32', 'l');
    data.ping(idx_data).pulselength(ping_chan(idx_data)) = fread(fid,1,'float32', 'l');
    data.ping(idx_data).bandwidth(ping_chan(idx_data)) = fread(fid,1,'float32', 'l');
    data.ping(idx_data).sampleinterval(ping_chan(idx_data)) = fread(fid,1,'float32', 'l');
    data.ping(idx_data).soundvelocity(ping_chan(idx_data)) = fread(fid,1,'float32', 'l');
    data.ping(idx_data).absorptioncoefficient(ping_chan(idx_data)) = fread(fid,1,'float32', 'l');
    data.ping(idx_data).heave(ping_chan(idx_data)) = fread(fid,1,'float32', 'l');
    data.ping(idx_data).roll(ping_chan(idx_data)) = fread(fid,1,'float32', 'l');
    data.ping(idx_data).pitch(ping_chan(idx_data)) = fread(fid,1,'float32', 'l');
    data.ping(idx_data).temperature(ping_chan(idx_data)) = fread(fid,1,'float32', 'l');
    data.ping(idx_data).trawlupperdepthvalid(ping_chan(idx_data)) = fread(fid,1,'int16', 'l');
    data.ping(idx_data).trawlopeningvalid(ping_chan(idx_data)) = fread(fid,1,'int16', 'l');
    data.ping(idx_data).trawlupperdepth(ping_chan(idx_data)) = fread(fid,1,'float32', 'l');
    data.ping(idx_data).trawlopening(ping_chan(idx_data)) = fread(fid,1,'float32', 'l');
    data.ping(idx_data).offset(ping_chan(idx_data)) = fread(fid,1,'int32', 'l');
    data.ping(idx_data).count(ping_chan(idx_data)) = fread(fid,1,'int32', 'l');
    if data.ping(idx_data).count(ping_chan(idx_data)) > 0
        if data.ping(idx_data).mode(ping_chan(idx_data)) ~= 2
            power = double(fread(fid,data.ping(idx_data).count(ping_chan(idx_data)),'int16', 'l'));
            %  power * 10 * log10(2) / 256
            data.ping(idx_data).power(1:data.ping(idx_data).count(ping_chan(idx_data)),ping_chan(idx_data)) = (power * 0.011758984205624);
        end
        if data.ping(idx_data).mode(ping_chan(idx_data)) > 1
            angle = fread(fid,[2 data.ping(idx_data).count(ping_chan(idx_data))],'int8', 'l');
            data.ping(idx_data).athwartship(1:data.ping(idx_data).count(ping_chan(idx_data)),ping_chan(idx_data)) = double(angle(1,:)');
            data.ping(idx_data).alongship(1:data.ping(idx_data).count(ping_chan(idx_data)),ping_chan(idx_data)) = double(angle(2,:)');
        end
    end
end

fclose(fid);
end