function shr_str=motion2shr(pitch,roll,heave,heading,time,roll_prec,pitch_prec,head_prec)
% $PASHR,hhmmss.sss,hhh.hh,T,rrr.rr,ppp.pp,xxx.xx,a.aaa,b.bbb,c.ccc,d,e*hh<CR><LF>
% 
% Field number:
%     hhmmss.sss - UTC time
%     hhh.hh - Heading in degrees
%     T - flag to indicate that the Heading is True Heading (i.e. to True North)
%     rrr.rr - Roll Angle in degrees
%     ppp.pp - Pitch Angle in degrees 
%     xxx.xx - Heave
%     a.aaa - Roll Angle Accuracy Estimate (Stdev) in degrees
%     b.bbb - Pitch Angle Accuracy Estimate (Stdev) in degrees
%     c.ccc - Heading Angle Accuracy Estimate (Stdev) in degrees
%     d - Aiding Status
%     e - IMU Status
%     hh - Checksum

timestr=datestr(time,'HHMMSS');
if isnan(heading)
    head_str='';
else
    head_str=num2str(heading,'%.3f');
end

if isnan(roll)
    roll_str='';
else
    roll_str=num2str(roll,'%.3f');
end
if isnan(pitch)
    pitch_str='';
else
    pitch_str=num2str(pitch,'%.3f');
end

if isnan(heave)
    heave_str='';
else
    heave_str=num2str(heave,'%.3f');
end

shr_str=sprintf('$PASHR,%s,%s,%c,%s,%s,%s,%.3f,%.3f,%.3f,1,1,',timestr,head_str,'T',roll_str,pitch_str,heave_str,roll_prec,pitch_prec,head_prec);
shr_str=addnmeachecksum(shr_str);
