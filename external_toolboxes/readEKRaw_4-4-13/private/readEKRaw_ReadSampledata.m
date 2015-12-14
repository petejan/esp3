function sampledata = readEKRaw_ReadSampledata(fid, sampledata)
%readEKRaw_ReadSampledata  Read EK/ES RAW0 datagram
%   sampledata = readEKRaw_ReadSampledata(fid, sampledate) returns a structure
%       containing the data from a EK/ES RAW0 datagram.
%
%   REQUIRED INPUT:
%               fid:    file handle id of raw file
%        sampledata:    pre-allocated sampledata data structure
%
%   OPTIONAL PARAMETERS:    None
%       
%   OUTPUT:
%       Output is a data structure containing the RAW0 datagram data
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

sampledata.channel = fread(fid,1,'int16', 'l');
mode_low = fread(fid,1,'int8', 'l');
mode_high = fread(fid,1,'int8', 'l');
sampledata.mode = 256 * mode_high + mode_low;
sampledata.transducerdepth = fread(fid,1,'float32', 'l');
sampledata.frequency = fread(fid,1,'float32', 'l');
sampledata.transmitpower = fread(fid,1,'float32', 'l');
sampledata.pulselength = fread(fid,1,'float32', 'l');
sampledata.bandwidth = fread(fid,1,'float32', 'l');
sampledata.sampleinterval = fread(fid,1,'float32', 'l');
sampledata.soundvelocity = fread(fid,1,'float32', 'l');
sampledata.absorptioncoefficient = fread(fid,1,'float32', 'l');
sampledata.heave = fread(fid,1,'float32', 'l');
sampledata.roll = fread(fid,1,'float32', 'l');
sampledata.pitch = fread(fid,1,'float32', 'l');
sampledata.temperature = fread(fid,1,'float32', 'l');
sampledata.trawlupperdepthvalid = fread(fid,1,'int16', 'l');
sampledata.trawlopeningvalid = fread(fid,1,'int16', 'l');
sampledata.trawlupperdepth = fread(fid,1,'float32', 'l');
sampledata.trawlopening = fread(fid,1,'float32', 'l');
sampledata.offset = fread(fid,1,'int32', 'l');
sampledata.count = fread(fid,1,'int32', 'l');

sampledata.power = [];
sampledata.alongship = [];
sampledata.athwartship = [];
if (sampledata.count > 0)
    %  check length of arrays - grow if necessary
    if (length(sampledata.power) < sampledata.count)
        nSampAdd = sampledata.count - length(sampledata.power);
        sampledata.power(end + 1:end + nSampAdd) = -999;
        sampledata.alongship(end + 1:end + nSampAdd) = 0;
        sampledata.athwartship(end + 1:end + nSampAdd) = 0;
    end
    if (sampledata.mode ~= 2)
        power = fread(fid,sampledata.count,'int16', 'l');
        %  power * 10 * log10(2) / 256
        sampledata.power(1:sampledata.count) = (power * 0.011758984205624);
    end
    if (sampledata.mode > 1)
        angle = fread(fid,[2 sampledata.count],'int8', 'l');
        sampledata.athwartship(1:sampledata.count) = angle(1,:)';
        sampledata.alongship(1:sampledata.count) = angle(2,:)';
    end
end
