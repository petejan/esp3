function writeEKRaw_WriteSampledata(fid, sampledata)
% writeEKRaw_WriteSampledata  Write EK/ES RAW0 datagram to file
%   writeEKRaw_WriteSampledata(fid, sampledate) writes the sampledata
%       structure to disk as en EK RAW0 datagram.
%
%   REQUIRED INPUT:
%               fid:    file handle id of raw file
%        sampledata:    sampledata data structure
%
%   OPTIONAL PARAMETERS:    None
%       
%   OUTPUT: None
%
%   REQUIRES:   None
%
%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov
%
%   Based on code by Lars Nonboe Andersen, Simrad.

%-

fwrite(fid,sampledata.channel,'int16', 'l');
mode_high = floor(sampledata.mode / 256);
mode_low = sampledata.mode - (mode_high * 256);
fwrite(fid, mode_low,'int8', 'l');
fwrite(fid, mode_high,'int8', 'l');
fwrite(fid, sampledata.transducerdepth,'float32', 'l');
fwrite(fid, sampledata.frequency,'float32', 'l');
fwrite(fid, sampledata.transmitpower,'float32', 'l');
fwrite(fid, sampledata.pulselength,'float32', 'l');
fwrite(fid, sampledata.bandwidth,'float32', 'l');
fwrite(fid, sampledata.sampleinterval,'float32', 'l');
fwrite(fid, sampledata.soundvelocity,'float32', 'l');
fwrite(fid, sampledata.absorptioncoefficient,'float32', 'l');
fwrite(fid, sampledata.heave,'float32', 'l');
fwrite(fid, sampledata.roll,'float32', 'l'); 
fwrite(fid, sampledata.pitch,'float32', 'l'); 
fwrite(fid, sampledata.temperature, 'float32', 'l'); 
fwrite(fid, sampledata.trawlupperdepthvalid, 'int16', 'l');
fwrite(fid, sampledata.trawlopeningvalid, 'int16', 'l');
fwrite(fid, sampledata.trawlupperdepth, 'float32', 'l');
fwrite(fid, sampledata.trawlopening, 'float32', 'l');
fwrite(fid, sampledata.offset, 'int32', 'l');
fwrite(fid, sampledata.count, 'int32', 'l');
if (sampledata.mode ~= 2)
    fwrite(fid, (sampledata.power / 0.011758984205624), 'int16', 'l');
end
if (sampledata.mode > 1)
    fwrite(fid, [sampledata.athwartship' ; sampledata.alongship'], 'int8', 'l');
end
