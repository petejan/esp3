function data=readRaw0(data,idx_data,i_ping,PingRange,SampleRange,fid)

fread(fid,2,'uchar', 'l');
mode_low = fread(fid,1,'int8', 'l');
mode_high = fread(fid,1,'int8', 'l');

data.pings(idx_data).number(i_ping) = i_ping+PingRange(1)-1;
data.pings(idx_data).mode(i_ping) = 256 * mode_high + mode_low;
data.pings(idx_data).transducerdepth(i_ping) = fread(fid,1,'float32', 'l');
data.pings(idx_data).frequency(i_ping) = fread(fid,1,'float32', 'l');
data.pings(idx_data).transmitpower(i_ping) = fread(fid,1,'float32', 'l');
data.pings(idx_data).pulselength(i_ping) = fread(fid,1,'float32', 'l');
data.pings(idx_data).bandwidth(i_ping) = fread(fid,1,'float32', 'l');
data.pings(idx_data).sampleinterval(i_ping) = fread(fid,1,'float32', 'l');
data.pings(idx_data).soundvelocity(i_ping) = fread(fid,1,'float32', 'l');
data.pings(idx_data).absorptioncoefficient(i_ping) = fread(fid,1,'float32', 'l');
% data.pings(idx_data).heave(i_ping) = fread(fid,1,'float32', 'l');
% data.pings(idx_data).roll(i_ping) = fread(fid,1,'float32', 'l');
% data.pings(idx_data).pitch(i_ping) = fread(fid,1,'float32', 'l');
% data.pings(idx_data).temperature(i_ping) = fread(fid,1,'float32', 'l');
% data.pings(idx_data).trawlupperdepthvalid(i_ping) = fread(fid,1,'int16', 'l');
% data.pings(idx_data).trawlopeningvalid(i_ping) = fread(fid,1,'int16', 'l');
% data.pings(idx_data).trawlupperdepth(i_ping) = fread(fid,1,'float32', 'l');
% data.pings(idx_data).trawlopening(i_ping) = fread(fid,1,'float32', 'l');
fread(fid,28,'uint8','l');
data.pings(idx_data).offset(i_ping) = fread(fid,1,'int32', 'l');
data.pings(idx_data).count(i_ping) = fread(fid,1,'int32', 'l');

if data.pings(idx_data).count(i_ping) > 0
    len_load=min(SampleRange(2),data.pings(idx_data).count(i_ping))-SampleRange(1)+1;
    len_tot=data.pings(idx_data).count(i_ping)-SampleRange(1)+1;
    if data.pings(idx_data).mode(i_ping) ~= 2
        %  power * 10 * log10(2) / 256
        if SampleRange(1)>1
            fread(fid,SampleRange(1)-1,'int16', 'l');
        end
        data.pings(idx_data).power(SampleRange(1):len_load,i_ping)=(fread(fid,len_load,'int16', 'l') * 0.011758984205624);
        if len_tot>len_load
            fread(fid,len_tot-len_load,'int16', 'l');
        end
    end
    if data.pings(idx_data).mode(i_ping) > 1
         if SampleRange(1)>1
            fread(fid,2*(SampleRange(1)-1),'int16', 'l');
         end
        angle=fread(fid,[2 len_load],'int8', 'l');
        data.pings(idx_data).athwartship_e(SampleRange(1):len_load,i_ping)=angle(1,:);
        data.pings(idx_data).alongship_e(SampleRange(1):len_load,i_ping)=angle(2,:);
      
    end
        data.pings(idx_data).samplerange=[SampleRange(1) len_load];
end

end