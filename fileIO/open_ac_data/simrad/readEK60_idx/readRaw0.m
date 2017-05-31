function data=readRaw0(data,idx_data,i_ping,PingRange,SampleRange,fid)

temp=fread(fid,4,'int8', 'l');

data.pings(idx_data).number(i_ping) = i_ping+PingRange(1)-1;
data.pings(idx_data).mode(i_ping) = 256 * temp(3) + temp(4);

temp=fread(fid,8,'float32', 'l');
data.pings(idx_data).transducerdepth(i_ping) = temp(1);
data.pings(idx_data).frequency(i_ping) = temp(2);
data.pings(idx_data).transmitpower(i_ping) = temp(3);
data.pings(idx_data).pulselength(i_ping) = temp(4);
data.pings(idx_data).bandwidth(i_ping) = temp(5);
data.pings(idx_data).sampleinterval(i_ping) = temp(6);
data.pings(idx_data).soundvelocity(i_ping) = temp(7);
data.pings(idx_data).absorptioncoefficient(i_ping) = temp(8);

fread(fid,7,'int32','l');
temp=fread(fid,2,'int32', 'l');
data.pings(idx_data).offset(i_ping) = temp(1);
data.pings(idx_data).count(i_ping) = temp(2);

if data.pings(idx_data).count(i_ping) > 0
    len_load=min(SampleRange(2),data.pings(idx_data).count(i_ping))-SampleRange(1)+1;
    len_tot=data.pings(idx_data).count(i_ping)-SampleRange(1)+1;
    if data.pings(idx_data).mode(i_ping) ~= 2
        %  power * 10 * log10(2) / 256
        if SampleRange(1)>1
            fread(fid,SampleRange(1)-1,'int16', 'l');
        end
        data_ping=fread(fid,len_load,'int16', 'l');
        len_load=numel(data_ping);
        data.pings(idx_data).power(SampleRange(1):len_load,i_ping)=(0.011758984205624*data_ping);
        
        if len_tot>len_load
            fread(fid,len_tot-len_load,'int16', 'l');
        end
    end
    
    if data.pings(idx_data).mode(i_ping) > 1
         if SampleRange(1)>1
            fread(fid,2*(SampleRange(1)-1),'int16', 'l');
         end
        angle=fread(fid,[2 len_load],'int8', 'l');
        len_load=size(angle,2);
        if len_load>0
            data.pings(idx_data).AcrossPhi(SampleRange(1):len_load,i_ping)=angle(1,:);
            data.pings(idx_data).AlongPhi(SampleRange(1):len_load,i_ping)=angle(2,:);
        end
    end
        data.pings(idx_data).samplerange=[SampleRange(1) len_load];
end

end