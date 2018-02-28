function [data,power,AlongPhi,AcrossPhi]=readRaw0_v2(data,idx_data,i_ping,fid)

temp=fread(fid,4,'int8', 'l');
data.pings(idx_data).datatype='11000000000';
data.pings(idx_data).number(i_ping) = i_ping;
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

temp=fread(fid,9,'int32', 'l');
data.pings(idx_data).offset(i_ping) = temp(8);
data.pings(idx_data).count(i_ping) = temp(9);

if data.pings(idx_data).count(i_ping) > 0
    len_load=data.pings(idx_data).count(i_ping);

    if data.pings(idx_data).mode(i_ping) ~= 2
        %  power * 10 * log10(2) / 256
        data_ping=fread(fid,len_load,'int16', 'l');
        len_load=numel(data_ping);
        power=(0.011758984205624*data_ping);
    end    
    if data.pings(idx_data).mode(i_ping) > 1
        angle=fread(fid,[2 len_load],'int8', 'l');
        len_load=size(angle,2);
        if len_load>0
            AcrossPhi=angle(1,:);
            AlongPhi=angle(2,:);
        end
    end
        data.pings(idx_data).samplerange=[1 len_load];
end

end