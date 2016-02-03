function data=readRaw0_v2(data,idx_data,i_ping,SampleRange,fid,len)
pos_init=ftell(fid);
 
fseek(fid,pos_init,-1);
everything=uint8(fread(fid,len,'uint8', 'l'));

% fseek(fid,pos_init,-1);
% everything_16=fread(fid,len,'int16', 'l');


%fread(fid,2,'uchar', 'l');1
mode_low = everything(3);
mode_high = everything(4);

data.pings(idx_data).number(i_ping) = i_ping;
data.pings(idx_data).mode(i_ping) = 256 * mode_high + mode_low;
data.pings(idx_data).transducerdepth(i_ping) = typecast(everything(5:8),'single');
data.pings(idx_data).frequency(i_ping) = typecast(everything(9:12),'single');
data.pings(idx_data).transmitpower(i_ping)= typecast(everything(13:16),'single');
data.pings(idx_data).pulselength(i_ping) = typecast(everything(17:20),'single');
data.pings(idx_data).bandwidth(i_ping) = typecast(everything(21:24),'single');
data.pings(idx_data).sampleinterval(i_ping) = typecast(everything(25:28),'single');
data.pings(idx_data).soundvelocity(i_ping) = typecast(everything(29:32),'single');
data.pings(idx_data).absorptioncoefficient(i_ping) = typecast(everything(33:36),'single');
% data.pings(idx_data).heave(i_ping) = fread(fid,1,'float32', 'l');37
% data.pings(idx_data).roll(i_ping) = fread(fid,1,'float32', 'l');41
% data.pings(idx_data).pitch(i_ping) = fread(fid,1,'float32', 'l');45
% data.pings(idx_data).temperature(i_ping) = fread(fid,1,'float32', 'l');49
% data.pings(idx_data).trawlupperdepthvalid(i_ping) = fread(fid,1,'int16',
% 'l');53
% data.pings(idx_data).trawlopeningvalid(i_ping) = fread(fid,1,'int16',
% 'l');55
% data.pings(idx_data).trawlupperdepth(i_ping) = fread(fid,1,'float32',
% 'l');57
% data.pings(idx_data).trawlopening(i_ping) = fread(fid,1,'float32',
% 'l');61
data.pings(idx_data).offset(i_ping) = typecast(everything(65:68),'int32');
data.pings(idx_data).count(i_ping) = typecast(everything(69:72),'int32');
pow_start=73+2*(SampleRange(1)-1);

if data.pings(idx_data).count(i_ping) > 0
    len_load=min(SampleRange(2),data.pings(idx_data).count(i_ping))-SampleRange(1)+1;
    len_tot=data.pings(idx_data).count(i_ping)-SampleRange(1)+1;
    if data.pings(idx_data).mode(i_ping) ~= 2
        %  power * 10 * log10(2) / 256
        data.pings(idx_data).power(:,i_ping)=(typecast(everything(pow_start:pow_start+2*len_load-1),'int16')) * 0.011758984205624;
    end
    angle_start=pow_start+2*len_tot;
    if data.pings(idx_data).mode(i_ping) > 1
        angle=typecast(everything(angle_start:angle_start+2*len_load-1),'int8');
        data.pings(idx_data).athwartship_e(:,i_ping)=angle(1:2:end);
        data.pings(idx_data).alongship_e(:,i_ping)=angle(2:2:end);
    end
    data.pings(idx_data).samplerange=[SampleRange(1) len_load];
end

end