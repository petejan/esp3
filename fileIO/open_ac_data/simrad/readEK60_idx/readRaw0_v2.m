function [data,power,angle]=readRaw0_v2(data,idx_data,i_ping,fid)

data.pings(idx_data).number(i_ping) = i_ping;

temp=fread(fid,8,'float32', 'l');
data.pings(idx_data).transducerdepth(i_ping) = temp(1);
data.pings(idx_data).frequency(i_ping) = temp(2);
data.pings(idx_data).transmitpower(i_ping) = temp(3);
data.pings(idx_data).pulselength(i_ping) = temp(4);
data.pings(idx_data).bandwidth(i_ping) = temp(5);
data.pings(idx_data).sampleinterval(i_ping) = temp(6);
data.pings(idx_data).soundvelocity(i_ping) = temp(7);
data.pings(idx_data).absorptioncoefficient(i_ping) = temp(8);

temp=fread(fid,9,'int32', 'l');
power=[];
angle=[];

data.pings(idx_data).offset(i_ping) = temp(8);
data.pings(idx_data).count(i_ping) = temp(9);

if data.pings(idx_data).count(i_ping) > 0
    len_load=data.pings(idx_data).count(i_ping);
    
    if data.pings(idx_data).datatype(1)==dec2bin(1)
        %  power * 10 * log10(2) / 256
        power=0.011758984205624*fread(fid,len_load,'int16', 'l');
        len_load=numel(power);
    end
    
    if data.pings(idx_data).datatype(2)==dec2bin(1)
        angle=fread(fid,[2 len_load],'int8', 'l');
    end
    data.pings(idx_data).samplerange=[1 len_load];
end

end