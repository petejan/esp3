function result = writeEKRaw(filename, header, data, varargin)
%writeEKRaw  Write an EK/ES60 raw data file
%   [varargout] = writeEKRaw(filename, header, data, varargin)
%       writes Simrad .raw files using the structures created by
%       readEKRaw as input.
%   
%   DISCLAIMERS:
%
%   This function will *not* create bit-perfect versions of your source data.
%   This function *should* create functionally equivalent files.  That is, the
%   numbers should be more or less the same but how the datagrams are ordered
%   in the raw file will be slightly different. If you require bit-perfect
%   copies, write your own function.
%
%   If you're manipulating the readEKRaw data structures it is your
%   responsibility to ensure that they are internally coherent. This function
%   does not perform any sanity checks on the data and can easily create bogus
%   data files. For example, if you change the number of samples in a ping,
%   you must also change the sample count. 
%
%   This function was created to be used with the readEKRaw data
%   structures. These structures typically contain data that has been
%   transformed, such as time which is transformed from the original
%   "NT Time" to MATLAB serial time. You should understand that there will
%   be some loss in precision due to rounding errors as these values
%   are transformed back to their raw types. Resultant .raw files will not be
%   bit for bit copies of the source .raw file though functionally the files
%   should be identical.  Using time as an example, typical differences are in
%   the range of 1.0e-5 seconds. If you are converting from power to Sv/Sp and
%   back, you should set the "Double" keyword of the Power2Sv and PowerSp
%   functions to minimize floating point rounding errors.
%
%   When writing cooked NMEA data, the UTC time inserted in the NMEA string
%   is the datagram time, not the UTC time from the original NMEA string
%   used to derive the cooked data. Further, the millisecond values are
%   *truncated* to hundredths of a second. For data collection systems with
%   properly syncronized clocks this should not be an issue but if the data
%   collection PC's clock is not syncronized to UTC the resulting NMEA data
%   time stamps may differ significantly from the original raw NMEA data.
%
%   NOTE THAT ANNOTATION DATAGRAMS (TAG0) ARE NOT CURRENTLY SUPPORTED. YOU
%   CAN EASILY ADD IT. SO IF YOU NEED IT, DO IT, THEN SEND ME THE CODE.
%
%   REQUIRED INPUT:
%          filename:    A string containing the path to the file to write or
%                       append data to.
%            header:    A readEKRaw "header" structure containing the file header
%                       information. See the readEKRaw file for information
%                       on the form of this structure.
%              data:    A readEKRaw "data" structure containing the raw data
%                       to write to file. See the readEKRaw file for information
%                       on the form of this structure.
%
%   OPTIONAL PARAMETERS:
%
%            Append:    Set this parameter to True to append data to an existing
%                       raw file. Note that it is your responsibility to
%                       ensure that the file is logically consistent and
%                       the resulting file will be "compatible" with whatever
%                       application you read it with.
%                           Default: false
%
%       Frequencies:    A scalar or vector of frequency values (in Hz) to
%                       write.  Set this to limit writing data to specific
%                       frequencies.
%                           Default: -1  (write all frequencies)
%
%        PadSamples:    Set this parameter to True to pad power and angle data
%                       for data where the sample range does not start at 1.
%                       For example, if the input structure only contains samples
%                       100-150, 99 -999 values would be padded "above" these
%                       samples to place the data at the original range
%                       from the transducer.
%                           Default: true
%
%         PingRange:    A 2 element vector in the form [start end] or a 3 element
%                       vector in the form [start stride end] defining the
%                       ping range to write to the file. To write to the end
%                       of the data , set end to Inf. You can set PingRange,
%                       or TimeRange.  Not both.
%                           Default: [1 1 Inf] - write entire data set
%
%         TimeRange:    A 2 element vector in the form [start end] defining the
%                       time range to write to the file.  Time values are in
%                       MATLAB serial time.  To write to the end of the data set, set
%                       end to Inf.  You can set PingRange, or TimeRange. Not both.
%                           Default: [0 Inf] - write entire file
%
%   COOKED NMEA OPTIONS:
%
%       The "cooked" NMEA data such as vessel log, GPS, and vessel speed can be written
%       to the raw file. Typically you will want to store the raw NMEA data when using
%       readEKRaw to minimize the differences between the source and destnation files.
%       In cases where you are manipulating this data you can set the keywords below to
%       write this cooked data to the .raw file.
%
%       It is important to note that the resulting NMEA strings will be different from
%       the  original NMEA data because some fields in the NMEA strings are simply dropped
%       when the .raw file is read.  These differences are noted below. No checksums are
%       generated for the cooked NMEA data.
%
%               GPS:    Set this parameter to true to write the GPS data as GPGLL NMEA
%                       strings. Note that the "Universal Time Coordinated" field will
%                       contain the time as recorded by the PC running the data collection
%                       software, not the UTC time as originally reported by the GPS system.
%                           Default: false
%
%         VesselLog:    Set this parameter to true to write the vlog data as SDVLW NMEA
%                       strings. Note that the "Distance since Reset" field will always
%                       be the same as the "Total cumulative distance".
%                           Default: false
%                
%       VesselSpeed:    Set this parameter to true to write the vspeed data as GPVTG NMEA
%                       strings. Note that the "Track Degrees (True)" and "Track Degrees
%                       (Magnetic)" fields will always be 0.
%                           Default: false
%
%
%   OUTPUT: Output is a structure containing a single field 'totalbytes'
%           which contains the total number of bytes written to the raw file.
%           This will be expanded in the future to contain more information.
%
%
%   REQUIRES: None.
%
%
%   Rick Towler
%   National Oceanic and Atmospheric Administration
%   Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%   This code is based on code by Lars Nonboe Andersen, Simrad

%-

%  declare globals
global MATLAB_NT_TIME_OFFSET HEADER_LEN CONF_HEADER_LEN XCVR_HEADER_LEN


%  define constants
HEADER_LEN = 12;                %  Bytes in datagram header
CONF_HEADER_LEN = 516;          %  Bytes in CON0 general configuration data
XCVR_HEADER_LEN = 320;          %  Bytes in CON0 per transceiver configuration data
SAMPLEDATA_FIXED_LEN = 72;      %  Fixed bytes in sample datagram

%  define the global MATLAB to NT time offset which is the number of 100
%  nano-second intervals from MATLAB's serial time reference point of
%  Jan 1 0000 00:00:00 to NT time's reference point of Jan 1 1601 00:00:00
MATLAB_NT_TIME_OFFSET = datenum(1601, 1, 1, 0, 0, 0) * 864000000000;


%  define default parameters
result = 0;
writeFreqs = -1;                %  Write all frequencies by default
append = false;                 %  By default write a new rawfile with header.
pingRange = [1 1 Inf];          %  Do not limit by ping and read all pings by default
timeRange = [0 Inf];            %  Do not limit by time by default
progressCallback = [];          %  No progress callback function defined
progressGranularity = 2;        %  Minimum percent change in progress before callback is called
subsetMode = 0;                 %  Specifies if/how a subset of the data is written (0-none, 1-ping, 2-time)
totalBytes = uint32(0);         %  Total number of bytes written

padSamples = true;              %  By default, pad sample data that doesn't start at the first sample
doGPS = false;
doVSPEED = false;
doVLOG = false;


%  check that at least the config and ping fields are present
if (~isfield(data, 'pings'))
    warning ('readEKRaw:ParameterError', ['The pings field is required but does ' ...
             'not exist in the data structure. Read the documentation.']);
    return
end
if (~isfield(data, 'config'))
    warning ('readEKRaw:ParameterError', ['The config field is required but does ' ...
             'not exist in the data structure. Read the documentation.']);
    return
end

%  check if the power field exists
if (data.pings(1).mode(1) ~= 2) && (~isfield(data.pings(1), 'power'))
    warning ('readEKRaw:ParameterError', ['Power field does not exist in data ' ...
             'structure. You must convert Sv/sv/Sp/sp to power before writing']);
    return
end

%  check if the electrical angle fields exists
if (data.pings(1).mode(1) > 1) && (~isfield(data.pings(1), 'alongship_e'))
    warning ('readEKRaw:ParameterError', ['Electrical angle fields do not exist in data ' ...
             'structure. You must convert physical angles to electrical angles before writing.']);
    return
end

%  extract some basic information from our data structure
nChannels = length(data.config);
frequencies = zeros(1, nChannels);
pingTimeRange = zeros(2, nChannels);
pingNumRange = zeros(2, nChannels);
for i = 1:nChannels   
    frequencies(i) = data.config(i).frequency;
    pingTimeRange(1,i) = data.pings(i).time(1);
    pingTimeRange(2,i) = data.pings(i).time(end);
    pingNumRange(1,i) = data.pings(i).number(1);
    pingNumRange(2,i) = data.pings(i).number(end);
end

%  process property name/value pairs
for n = 1:2:length(varargin)
    switch lower(varargin{n})
        case {'frequency' 'frequencies'}
            %  write specific frequncies to file (in Hz)
            writeFreqs = sort(varargin{n + 1});
        case 'pingrange'
            %  set starting and ending pings to write
            switch length(varargin{n + 1})
                case 2
                    pingRange = ones(1,3);
                    pingRange(1) = varargin{n + 1}(1);
                    pingRange(3) = varargin{n + 1}(2);
                case 3
                    pingRange = varargin{n + 1};
                otherwise
                    warning('writeEKRaw:ParameterError', ['PingRange - Incorrect ' ...
                        'number of arguments. PingRange must be a 2 or 3 ' ...
                        'element vector [pingStart pingEnd] or [pingStart ' ...
                        'pingStride pingEnd]']);
            end
            if (pingRange(3) < pingRange(1))
                error('PingRange - pingStart is greater than pingEnd');
            end
            %  check that pingrange is at least partially within data
            if (pingRange(3) < minPingNum) || (pingRange(1) > maxPingNum)
               error('PingRange specified is outside the range of pings in the data.');
            end
            %  set rangeMode for ping based range specification
            subsetMode = 1;
        case 'timerange'
            %  set starting and ending times to write
            if (length(varargin{n + 1}) == 2)
                timeRange = varargin{n + 1};
                if (timeRange(2) < 0); timeRange(2) = Inf; end
                if (timeRange(2) < timeRange(1))
                    error('TimeRange - timeStart is greater than timeEnd');
                end
            else
                warning('writeEKRaw:ParameterError', ['TimeRange - Incorrect ' ...
                    'number of arguments. TimeRange must be a 2 element vector ' ...
                    '[timeStart timeEnd]']);
            end
            %  set rangeMode for time based range specification
            subsetMode = 2;
        case 'gps'
            doGPS = (0 < varargin{n + 1});
        case 'vessellog'
            doVLOG = (0 < varargin{n + 1});
        case 'vesselspeed'
            doVSPEED = (0 < varargin{n + 1});
        case 'progresscallback'
            if (isa(varargin{n + 1}, 'function_handle')); ...
                progressCallback = varargin{n + 1}; end
        case 'progressgranularity'
            progressGranularity = varargin{n + 1};
        case 'append'
            append = (0 < varargin{n + 1});

        otherwise
            warning('writeEKRaw:ParameterError', ['Unknown property name: ' ...
                varargin{n}]);
    end
end


%  define the writer state - a 11 x n array containing data used to both
%  determine the order data is written to disk and what to write.
%
%    n is equal to the number of data channels plus and ancillary data 
%    such as GPS, VLOG, etc.
%
%    writerState(1,:)    the "channel" where #'s < 1000 are channel data whose
%                       value indexes into the ping structure and 1000=NMEA,
%                       1001=GPS, 1002=VLOG, 1003=VSPEED
%    writerState(2,:)    the time of the next datum for this data type
%    writerState(3,:)    the index at this time
%    writerState(4,:)    the maximum index for this data type
%    writerState(5,:)    the number of bytes written of this type
%    writerState(6,:)    true if this channel is "skinny" (only for ping data)
%    writerState(7,:)    true if this channel has heave data (only for ping data)
%    writerState(8,:)    true if this channel has pitch data (only for ping data)
%    writerState(9,:)    true if this channel has roll data (only for ping data)
%    writerState(10,:)   true if this channel has temp data (only for ping data)
%    writerState(11,:)   true if this channel has trawl data (only for ping data)
writerState = zeros(11, nChannels);
writerState(1,:) = 1:nChannels;

%  eliminate frequencies we are not writing
if (writeFreqs(1) > 0)
    [val, idx] = setdiff(frequencies, writeFreqs);
    pingTimeRange(:, idx) = [];
    pingNumRange(:, idx) = [];
    frequencies(:, idx) = [];
    nChannels = length(frequencies);
    writerState(:, idx) = [];
    
    %  emit a warning if we don't have any acoustic data to write
    if (nChannels == 0)
         warning('writeEKRaw:ParameterError', ['No channel data exists or none of the ' ...
                 'specified frequencies exist in the data. No channel data will be written!']);
    end

end

%  determine the time range that the ping data spans
if (nChannels > 0)
    minPingTime = min(pingTimeRange(1,:));
    maxPingTime = max(pingTimeRange(2,:));
else
    minPingTime = Inf;
    maxPingTime = -Inf;
end


%  get time range of NMEA data and populate writerState array
if (isfield(data, 'NMEA') && isfield(data.NMEA, 'time'))
    minNMEAtime = min(data.NMEA.time);
    maxNMEAtime = max(data.NMEA.time);
    writerState(:, end + 1) = zeros(11,1);
    writerState(1, end) = 1000;
    writerState(4, end) = length(data.NMEA.time);
else
    minNMEAtime = Inf;
    maxNMEAtime = -Inf;
end

%  get time range of GPS data and populate writerState array
if (isfield(data, 'gps') && isfield(data.gps, 'time')) && doGPS
    minGPStime = min(data.gps.time);
    maxGPStime = max(data.gps.time);
    writerState(:, end + 1) = zeros(11,1);
    writerState(1, end) = 1001;
    writerState(4, end) = length(data.gps.time);
else
    minGPStime = Inf;
    maxGPStime = -Inf;
end

%  get time range of vessel log data and populate writerState array
if (isfield(data, 'vlog') && isfield(data.vlog, 'time')) && doVLOG
    minVLOGtime = min(data.vlog.time);
    maxVLOGtime = max(data.vlog.time);
    writerState(:, end + 1) = zeros(11,1);
    writerState(1, end) = 1002;
    writerState(4, end) = length(data.vlog.time);
else
    minVLOGtime = Inf;
    maxVLOGtime = -Inf;
end

%  get time range of vessel speed data and populate writerState array
if (isfield(data, 'vspeed') && isfield(data.vspeed, 'time')) && doVSPEED
    minVPEEDtime = min(data.vspeed.time);
    maxVPEEDtime = max(data.vspeed.time);
    writerState(:, end + 1) = zeros(11,1);
    writerState(1, end) = 1003;
    writerState(4, end) = length(data.vspeed.time);
else
    minVPEEDtime = Inf;
    maxVPEEDtime = -Inf;
end

%  determine the overall time range
minDataTime = min([minPingTime minNMEAtime minGPStime minVLOGtime minVPEEDtime]);
maxDataTime = max([maxPingTime maxNMEAtime maxGPStime maxVLOGtime maxVPEEDtime]);


%  determine the start and end times based on if/how we're subsetting
switch subsetMode
    case 0
        %  write the entire data structure
        currentTime = minDataTime;
        endTime = maxDataTime;
    case 1
        %  find the current(start) time based on ping number
        chanIdx = find((pingNumRange(1,:) <= pingRange(1)) & ...
                   (pingNumRange(2,:) >= pingRange(1)), 1, 'first');
        pingIdx = find(data.pings(chanIdx).number == pingRange(1), 1, 'first');
        currentTime = data.pings(chanIdx).time(pingIdx);
        
        %  find the end time based on ping number
        chanIdx = find((pingNumRange(1,:) <= pingRange(3)) & ...
                   (pingNumRange(2,:) >= pingRange(3)), 1, 'first');
        pingIdx = find(data.pings(chanIdx).number == pingRange(3), 1, 'first');
        endTime = data.pings(chanIdx).time(pingIdx);
        
    case 2
        %  start and end times are explicitly set
        currentTime = timeRange(1);
        endTime = timeRange(2);
end
startTime = currentTime;
cbLast = -1; 


%  populate the writerState array with initial values
for i=1:size(writerState,2)
    chan =  writerState(1,i);
    switch true
        case (chan < 1000)
            %  this is ping data - find the closest ping time
            chanIdx = find(data.pings(chan).time >= currentTime, 1, 'first');
            if ~isempty(chanIdx)
                writerState(3,i) = chanIdx;
                writerState(2,i) = data.pings(chan).time(chanIdx);
                writerState(4,i) = pingNumRange(2,i);
                writerState(6,i) = (length(data.pings(chan).frequency) == 1);
                writerState(7,i) = isfield(data.pings(chan), 'heave');
                writerState(8,i) = isfield(data.pings(chan), 'pitch');
                writerState(9,i) = isfield(data.pings(chan), 'roll');
                writerState(10,i) = isfield(data.pings(chan), 'temperature');
                writerState(11,i) = isfield(data.pings(chan), 'trawlopeningvalid');
            else
                % there is no ping time greater than current time
                writerState(2,i) = Inf;
            end
        case (chan == 1000)
            %  this is raw NMEA data
            chanIdx = find(data.NMEA.time >= currentTime, 1, 'first');
            if ~isempty(chanIdx)
                writerState(3,i) = chanIdx;
                writerState(2,i) = data.NMEA.time(chanIdx);
            else
                % there is no NMEA time greater than current time
                writerState(2,i) = Inf;
            end
        case (chan == 1001)
            %  this is GPS data
            chanIdx = find(data.gps.time >= currentTime, 1, 'first');
            if ~isempty(chanIdx)
                writerState(3,i) = chanIdx;
                writerState(2,i) = data.gps.time(chanIdx);
            else
                % there is no GPS time greater than current time
                writerState(2,i) = Inf;
            end
        case (chan == 1002)
            %  this is VLOG data
            chanIdx = find(data.vlog.time >= currentTime, 1, 'first');
            if ~isempty(chanIdx)
                writerState(3,i) = chanIdx;
                writerState(2,i) = datavlog.time(chanIdx);
            else
                % there is no VLOG time greater than current time
                writerState(2,i) = Inf;
            end
        case (chan == 1003)
            %  this is VSPEED data
            chanIdx = find(data.vspeed.time >= currentTime, 1, 'first');
            if ~isempty(chanIdx)
                writerState(3,i) = chanIdx;
                writerState(2,i) = data.vspeed.time(chanIdx);
            else
                % there is no VSPEED time greater than current time
                writerState(2,i) = Inf;
            end
    end
end


%  open the file and write the header
if (append)
    %  open an existing file and append data
    [val, name, ext] = fileparts(filename);
    fid = fopen(filename, 'a');
    if (fid == -1)
        varargout = {-1};
        warning('writeEKRaw:IOError', 'Could not open raw file: %s%s',name,ext);
        return;
    end
else
    %  open a new file
    [val, name, ext] = fileparts(filename);
    fid = fopen(filename, 'w');
    if (fid == -1)
        varargout = {-1};
        warning('writeEKRaw:IOError', 'Could not open raw file: %s%s',name,ext);
        return;
    end
    %  write configuration datagram 'CON0'
    totalBytes = writeEKRaw_WriteHeader(fid, header, data);
    
    %  write the ME/MS70 CON1 datagram if applicable
    if isfield(data, 'conf')
        %  determine the datagram length and write it
        dgLen = HEADER_LEN + length(data.conf.text);
        fwrite(fid, dgLen, 'int32', 'l');
        %  write the CON1 datagram header
        writeEKRaw_WriteDgHeader(fid, 'CON1', data.conf.time);
        %  write the configuration text
        fwrite(fid, data.conf.text, 'char', 'l');
        %  write the length again
        fwrite(fid, dgLen, 'int32', 'l');
    end
end


%  write out data within the defined time span
while (currentTime <= endTime)

    %  find the next datum to write
    [val, chanIdx] = min(writerState(2,:) - currentTime);
    %  get the channle number (>1000 is NMEA type data)
    chan = writerState(1,chanIdx);
    
    switch true
        %  write ping data
        case (chan < 1000)
            %  construct the sampledata structure for this ping
            
            %  get the index into this channel's "parameter" fields
            if writerState(6,chanIdx); idx = 1; else idx = writerState(3,chanIdx);  end
            
            %  populate them...
            sampledata.channel = chan;
            sampledata.mode = data.pings(chan).mode(idx);
            sampledata.transducerdepth = data.pings(chan).transducerdepth(idx);
            sampledata.frequency = data.pings(chan).frequency(idx);
            sampledata.transmitpower = data.pings(chan).transmitpower(idx);
            sampledata.pulselength = data.pings(chan).pulselength(idx);
            sampledata.bandwidth = data.pings(chan).bandwidth(idx);
            sampledata.sampleinterval = data.pings(chan).sampleinterval(idx);
            sampledata.soundvelocity = data.pings(chan).soundvelocity(idx);
            sampledata.absorptioncoefficient = data.pings(chan).absorptioncoefficient(idx);
            sampledata.offset = data.pings(chan).offset(idx);
            
            %  populate the power and angle fields
            nSampsThisPing = data.pings(chan).count(writerState(3,chanIdx));
            if (data.pings(chan).samplerange(1) ~= 1 && padSamples)
                %  create the padding
                sampledata.count = nSampsThisPing + data.pings(chan).samplerange(1) - 1;
                padding = repmat(-999., data.pings(chan).samplerange(1) - 1, 1);
                if (sampledata.mode ~= 2)
                    %  pad the power data
                    sampledata.power = [padding ; ...
                        data.pings(chan).power(1:nSampsThisPing, writerState(3,chanIdx))];
                end
                if (sampledata.mode > 1)
                    %  pad the angle data
                    sampledata.alongship = [uint8(padding) ; ...
                        data.pings(chan).alongship_e(1:nSampsThisPing, ...
                        writerState(3,chanIdx))];
                    sampledata.athwartship = [uint8(padding) ; ...
                        data.pings(chan).athwartship_e(1:nSampsThisPing, ...
                        writerState(3,chanIdx))];
                end
            else
                %  do not pad
                sampledata.count = nSampsThisPing;
                if (sampledata.mode ~= 2)
                    sampledata.power = data.pings(chan).power(1:nSampsThisPing, ...
                        writerState(3,chanIdx));
                end
                if (sampledata.mode > 1)
                    sampledata.alongship = data.pings(chan).alongship_e(1:nSampsThisPing, ...
                        writerState(3,chanIdx));
                    sampledata.athwartship = data.pings(chan).athwartship_e(1:nSampsThisPing, ...
                        writerState(3,chanIdx));
                end
            end
            
            %  extract the ancillary ping data - have to include else clause
            %  since channel data may be mixed has/doesn't have ancillary ping data
            if writerState(7,chanIdx)
                sampledata.heave = data.pings(chan).heave(writerState(3,chanIdx));
            else
                sampledata.heave = 0;
            end
            if writerState(8,chanIdx)
                sampledata.pitch = data.pings(chan).pitch(writerState(3,chanIdx));
            else
                sampledata.pitch = 0;
            end
            if writerState(9,chanIdx)
                sampledata.roll = data.pings(chan).roll(writerState(3,chanIdx));
            else
                sampledata.roll = 0;
            end
            if writerState(10,chanIdx)
                sampledata.temperature = data.pings(chan).temperature(writerState(3,chanIdx));
            else
                sampledata.temperature = 0;
            end
            if writerState(11,chanIdx)
                sampledata.trawlupperdepthvalid = data.pings(chan).trawlupperdepthvalid(writerState(3,chanIdx));
                sampledata.trawlopeningvalid = data.pings(chan).trawlopeningvalid(writerState(3,chanIdx));
                sampledata.trawlupperdepth = data.pings(chan).trawlupperdepth(writerState(3,chanIdx));
                sampledata.trawlopening = data.pings(chan).trawlopening(writerState(3,chanIdx));
            else
                sampledata.trawlupperdepthvalid = 0;
                sampledata.trawlopeningvalid = 0;
                sampledata.trawlupperdepth = 0;
                sampledata.trawlopening = 0;
            end

            %  calculate the length of this datagram
            dgLen = HEADER_LEN + SAMPLEDATA_FIXED_LEN + (sampledata.count * 2);
            if (sampledata.mode > 1)
                %  add in the angle data
                dgLen = dgLen + (sampledata.count * 2);
            end
                
            %  write the datagram length
            fwrite(fid, dgLen, 'int32','l');

            %  write the datagram header
            writeEKRaw_WriteDgHeader(fid, 'RAW0', writerState(2,chanIdx));

            %  write the sample data to file
            writeEKRaw_WriteSampledata(fid, sampledata);
            
            %  write the datagram length again
            fwrite(fid, dgLen, 'int32','l');
            
            %  increment this channels index value
            writerState(3,chanIdx) = writerState(3,chanIdx) +  pingRange(2);
            %  check if we're still within the bounds of the data
            if (writerState(3,chanIdx) > writerState(4,chanIdx))
                %  we're out of bounds for this channel
                writerState(2,chanIdx) = Inf;
            else
                %  in bounds - set the ping time for this new index value
                writerState(2,chanIdx) = data.pings(chan).time(writerState(3,chanIdx));
            end
            
            
        %  write raw NMEA data
        case (chan == 1000)
            %  extract the NMEA string
            nmeaString = data.NMEA.string{writerState(3,chanIdx)};
            
            %  write the NMEA string
            dgLen = writeEKRaw_WriteNMEAstring(fid, ...
                data.NMEA.time(writerState(3,chanIdx)), nmeaString, false);
            
            %  increment this channels index value
            writerState(3,chanIdx) = writerState(3,chanIdx) + 1;
            %  check if we're still within the bounds of the data
            if (writerState(3,chanIdx) > writerState(4,chanIdx))
                %  we're out of bounds for this channel
                writerState(2,chanIdx) = Inf;
            else
                %  in bounds - set the ping time for this new index value
                writerState(2,chanIdx) = data.NMEA.time(writerState(3,chanIdx));
            end
            
        %  write GPS data (GPGLL style)
        case (type == 1001)
            %  determine hemispheres
            if (data.gps.lat(writerState(3,chanIdx)) > 0);
                latHem = 'N';
                lat = data.gps.lat(writerState(3,chanIdx));
            else
                latHem = 'S';
                lat = -data.gps.lat(writerState(3,chanIdx));
            end
            if (data.gps.lon(writerState(3,chanIdx)) > 0);
                lonHem = 'E';
                lon = data.gps.lon(writerState(3,chanIdx));
            else
                lonHem = 'W';
                lon = -data.gps.lon(writerState(3,chanIdx));
            end
            %  convert to dms
            latD = floor(lat);
            latMS = (lat - latD) * 60;
            lonD = floor(lon);
            lonMS = (lon - lonD) * 60;
            
            %  convert time - truncate to hundredths of a second
            utc = datestr(data.gps.time(writerState(3,chanIdx)), 'HHmmss.FFF');
            utc = utc(1:end-1);
            
            %  build the GPGLL NMEA string
            format = '$GPGLL,%2d%7.4f,%c,%3d%7.4f,%c,%s,A';
            nmeaString = sprintf(format, latD, latMS, latHem, lonD, lonMS, lonHem, utc);
            
            %  write the NMEA string
            dgLen = writeEKRaw_WriteNMEAstring(fid, ...
                data.gps.time(writerState(3,chanIdx)), nmeaString, true);
            
            %  increment this channels index value
            writerState(3,chanIdx) = writerState(3,chanIdx) + 1;
            %  check if we're still within the bounds of the data
            if (writerState(3,chanIdx) > writerState(4,chanIdx))
                %  we're out of bounds for this channel
                writerState(2,chanIdx) = Inf;
            else
                %  in bounds - set the ping time for this new index value
                writerState(2,chanIdx) = data.gps.time(writerState(3,chanIdx));
            end

                        
        %  write VLOG data
        case (type == 1002) 
            
            %  build the SDVLW NMEA string
            format = '$SDVLW,%0.3f,N,%0.3f,N';
            nmeaString = sprintf(format, data.vlog.vlog(writerState(3,chanIdx)), ...
                data.vlog.vlog(writerState(3,chanIdx)));
            
            %  write the NMEA string
            dgLen = writeEKRaw_WriteNMEAstring(fid, ...
                data.vlog.time(writerState(3,chanIdx)), nmeaString, true);
            
            %  increment this channels index value
            writerState(3,chanIdx) = writerState(3,chanIdx) + 1;
            %  check if we're still within the bounds of the data
            if (writerState(3,chanIdx) > writerState(4,chanIdx))
                %  we're out of bounds for this channel
                writerState(2,chanIdx) = Inf;
            else
                %  in bounds - set the ping time for this new index value
                writerState(2,chanIdx) = data.vlog.time(writerState(3,chanIdx));
            end
            
        %  write VSPEED data
        case (type == 1003)
            
            %  build the GPVTG NMEA string
            format = '$GPVTG,0.0,T,0.0,M,%0.3f,N,%0.3f,K';
            nmeaString = sprintf(format, data.vspeed.speed(writerState(3,chanIdx)), ...
                data.vspeed.speed(writerState(3,chanIdx)) * 1.852);
            
            %  write the NMEA string
            dgLen = writeEKRaw_WriteNMEAstring(fid, ...
                data.vspeed.time(writerState(3,chanIdx)), nmeaString, true);
            
            %  increment this channels index value
            writerState(3,chanIdx) = writerState(3,chanIdx) + 1;
            %  check if we're still within the bounds of the data
            if (writerState(3,chanIdx) > writerState(4,chanIdx))
                %  we're out of bounds for this channel
                writerState(2,chanIdx) = Inf;
            else
                %  in bounds - set the ping time for this new index value
                writerState(2,chanIdx) = data.vspeed.time(writerState(3,chanIdx));
            end

    end
    
    %  call the progress indicator callback...
    if (~isempty(progressCallback))
        %  calculate normalized progress value
        cbProg = (currentTime - startTime) / (endTime - startTime);

        %  clamp...
        if (cbProg > 1); cbProg = 1; end
        if (cbProg < 0); cbProg = 0; end

        %  are we calling back this iteration?
        cbThis = round(cbProg * 100);
        if (mod(cbThis, progressGranularity) == 0) && (cbThis ~= cbLast)
            % call the progress callback
            progressCallback(cbProg);
            cbLast = cbThis;
        end
    end
    
    %  increment the byte counters
    writerState(5,chanIdx) =  dgLen + 8;
    totalBytes = totalBytes + writerState(5,chanIdx);
    
    %  "increment" current time
    currentTime = min(writerState(2,:));
    
end

%  close  the file
fclose(fid);


%  construct the return structure
%
%  Currently this is simply the total number of bytes but this should be
%  expanded to include a fields for ping(1xN channels) and NMEA data that
%  include the total bytes and number of pings/NMEA datagrams written.
result = struct('totalbytes', totalBytes);

