function data = readEKRaw_AllocateData(xcvrCount, xcvrConfig, ...
    aSize, rData, sampleRange, nSamples, userNMEA)
%readEKRaw_AllocateData  Allocate data structure for storing raw data
%   data = readEKRaw_AllocateData(len) pre-allocates the main data structure for
%       storing raw data.
%
%   REQUIRED INPUT:
%   xcvrCount:    the number of transceivers to allocate for
%  xcvrConfig:    the transducer configuration structure
%       aSize:    the initial column length allocation
%       rData:    the return data structure
%    nSamples:    array containing the initial row length allocations
%
%   OPTIONAL PARAMETERS:    None
%       
%   OUTPUT:
%       Output *the* data structure
%
%   REQUIRES:   None
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%-

%  set parameter array size based on "skinny/fat" mode
if (rData.skinny > 0); bSize = 1; else bSize = aSize; end

%  allocate transceiver based data arrays
for n=1:xcvrCount
    data.config(n) = xcvrConfig(n);
    data.pings(n).number = zeros(1, aSize, 'uint32');
    data.pings(n).time = zeros(1, aSize, 'double');
    data.pings(n).mode = zeros(1, bSize, 'int8');
    data.pings(n).transducerdepth = zeros(1, bSize, 'single');
    data.pings(n).frequency = zeros(1, bSize, 'single');
    data.pings(n).transmitpower = zeros(1, bSize, 'single');
    data.pings(n).pulselength = zeros(1, bSize, 'single');
    data.pings(n).bandwidth = zeros(1, bSize, 'single');
    data.pings(n).sampleinterval = zeros(1, bSize, 'single');
    data.pings(n).soundvelocity = zeros(1, bSize, 'single');
    data.pings(n).absorptioncoefficient = zeros(1, bSize, 'single');
    if (rData.heave); data.pings(n).heave = zeros(1, aSize, 'single'); end
    if (rData.roll); data.pings(n).roll = zeros(1, aSize, 'single'); end
    if (rData.pitch); data.pings(n).pitch = zeros(1, aSize, 'single'); end
    if (rData.temp); data.pings(n).temperature = zeros(1, aSize, 'single'); end
    if (rData.trawl)
        data.pings(n).trawlopeningvalid = zeros(1, aSize, 'int16');
        data.pings(n).trawlupperdepthvalid = zeros(1, aSize, 'int16');
        data.pings(n).trawlupperdepth = zeros(1, aSize, 'single');
        data.pings(n).trawlopening = zeros(1, aSize, 'single');
    end
    data.pings(n).offset = zeros(1, bSize, 'int32');
    data.pings(n).count = zeros(1, aSize, 'int32');
    if (rData.power); data.pings(n).power = zeros(nSamples(n), aSize, 'single') - 999; end
    if (rData.angle)
        data.pings(n).alongship_e = zeros(nSamples(n), aSize, 'int8');
        data.pings(n).athwartship_e = zeros(nSamples(n), aSize, 'int8');
    end
    data.pings(n).samplerange = [sampleRange(1) nSamples(n)];
     if (rData.gps); data.pings(n).seg = zeros(1, aSize, 'int16'); end
end

%  allocate GPS data arrays
if (rData.gps > 0)
    data.gps = struct('time', zeros(aSize, 1, 'double'), ...
                      'lat', zeros(aSize, 1, rData.gpsType), ...
                      'lon', zeros(aSize, 1, rData.gpsType), ...
                      'seg', zeros(aSize, 1, 'int16'), ...
                      'len', uint32(aSize));
end

%  allocate raw NMEA data array
if (rData.rawNMEA > 0)
    data.NMEA = struct('time', zeros(aSize, 1, 'double'));
    data.NMEA.string = cell(aSize, 1);
    data.NMEA.len = uint32(aSize);
end

%  allocate user defined NMEA data arrays
if (rData.uNMEA > 0)
    for n=1:length(userNMEA)
        data.NMEA.(userNMEA{n}) = struct('time', zeros(aSize, 1, 'double'));
        data.NMEA.(userNMEA{n}).string = cell(aSize, 1);
        data.NMEA.(userNMEA{n}).len = uint32(aSize);
    end
end

%  allocate vessel log data arrays
if (rData.vlog)
    data.vlog = struct('time', zeros(aSize, 1, 'double'), ...
                       'vlog', zeros(aSize, 1, rData.vlogType), ...
                       'len', uint32(aSize));
    if (rData.gps); data.vlog.seg = zeros(aSize, 1, 'int16'); end
end

%  allocate vessel speed data arrays
if (rData.vSpeed)
    data.vspeed = struct('time', zeros(aSize, 1, 'double'), ...
                         'speed', zeros(aSize, 1, rData.vSpeedType), ...
                         'len', uint32(aSize));
    if (rData.gps); data.vspeed.seg = zeros(aSize, 1, 'int16'); end
end

%  allocate annotation data arrays
if (rData.annotations)
    data.annotations = struct('time', zeros(aSize, 1, 'double'), ...
                              'len', uint32(aSize));
    data.annotations.text = cell(aSize,1);
end