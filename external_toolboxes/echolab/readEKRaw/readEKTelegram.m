function [header, data, varargout] = readEKTelegram(filename, varargin)
%readEKTelegram  Read EK500 and EK60 telegram files
%   [header, data] = readEKTelegram(filename, varargin) returns two arrays
%   containing the telegram file header data and a structure containing the
%   telegram data.
%
%   REQUIRED INPUT:
%          filename:    A string containing the path to the file to read
%
%
%   OPTIONAL PARAMETERS:
%            
%
%   OUTPUT: Output is two structures containing the telegram data.  All times are in
%           MATLAB serial time.
%
%           header: A structure containing file header information in the form:
%
%                                         surveyname: [1x128 char]
%                                       transectname: [1x128 char]
%                                        soundername: [1x128 char]
%                                              spare: [1x128 char]
%                                   transceivercount: 0
%
%
%             data: Assuming M transceivers, N pings and Q samples, data is a
%                   structure in the form:
%
%                     config: 1xM structure array containing the transceiver
%                             specific configuration data in the form:
%
%                                          channelid: [1x128 char]
%                                           beamtype: 0
%                                          frequency: 0
%                                               gain: 0
%                                equivalentbeamangle: 0
%                                 beamwidthalongship: 0
%                               beamwidthathwartship: 0
%                          anglesensitivityalongship: 0
%                        anglesensitivityathwartship: 0
%                              anglesoffsetalongship: 0
%                             angleoffsetathwartship: 0
%                                               posx: 0
%                                               posy: 0
%                                               posz: 0
%                                               dirx: 0
%                                               diry: 0
%                                               dirz: 0
%                                   pulselengthtable: [5x1 double]
%                                             spare2: ''
%                                          gaintable: [5x1 double]
%                                             spare3: ''
%                                  sacorrectiontable: [5x1 double]
%                                             spare4: ''
%
%                      pings: 1xM structure array containing the ping specific
%                             data.  Some fields are optional (determined by
%                             parameters passed to the reader).  The structure
%                             is in the form:
%
%                                             number: [1xN uint32]
%                                               time: [1xN double]
%                                    transducerdepth: [1xN single] or [1x1 single]
%                                          frequency: [1xN single] or [1x1 single]
%                                      transmitpower: [1xN single] or [1x1 single]
%                                        pulselength: [1xN single] or [1x1 single]
%                                          bandwidth: [1xN single] or [1x1 single]
%                                     sampleinterval: [1xN single] or [1x1 single]
%                                      soundvelocity: [1xN single] or [1x1 single]
%                              absorptioncoefficient: [1xN single] or [1x1 single]
%                                              heave: [1xN single] optional
%                                              pitch: [1xN single] optional
%                                               roll: [1xN single] optional
%                                        temperature: [1xN single] optional
%                                  trawlopeningvalid: [1xN int16]  optional
%                               trawlupperdepthvalid: [1xN int16]  optional
%                                    trawlupperdepth: [1xN single] optional
%                                       trawlopening: [1xN single] optional
%                                             offset: [1xN int32] or [1x1 single]
%                                              count: [1xN int32]
%                                              power: [QxN single] optional
%                                          alongship: [QxN single] optional
%                                        athwartship: [QxN single] optional
%                                        samplerange: [1 1]
%                                                seg: [1xN int16]  optional
%
%                        gps: 1x1 structure containing GPS data.  Assuming W gps
%                             fixes, the structure is in the form:
%
%                                               time: [Wx1 double]
%                                                lat: [Wx1 double]
%                                                lon: [Wx1 double]
%                                                seg: [Wx1 int16]  optional
%
%                       NMEA: 1x1 structure containing raw NMEA data.
%                             Assuming P NMEA datagrams the structure is in
%                             the form:
%
%                                               time: [Px1 double]
%                                             string: {Px1 char}
%
%                             If the UserNMEA parameter is defined additional
%                             fields will be present in the NMEA structure named
%                             after the talker/sentence IDs contained in
%                             UserNMEA.
%
%                       vlog: 1x1 structure containing vessel log data. Assuming
%                             R vessel log records the structure is in the form:
%
%                                               time: [Rx1 double]
%                                               vlog: [Rx1 single]
%                                                seg: [Rx1 int16]  optional
%
%                     vspeed: 1x1 structure containing vessel speed data. Assuming
%                             S vessel speed records the structure is in the form:
%
%                                               time: [Sx1 double]
%                                             vspeed: [Sx1 single]
%                                                seg: [Sx1 int16]  optional
%
%                annotations: 1x1 structure containing annotation (TAG0) data.
%                             Assuming  T annotaions the structure is in the
%                             form:
%
%                                               time: [Tx1 double]
%                                               text: {Tx1 char}
%                       conf: 1x1 structure containing ME70 configuration 
%                             (CON1) data. The structure is in the form:
%
%                                               time: [Tx1 double]
%                                               text: {Tx1 char}
%
%                             The CON1 XML string is non-conformant in that the
%                             values for each node are stored within the opening
%                             tag as "value" instead of between the opening and
%                             closing tag.  As a result, most XML parsers cannot
%                             parse the string correctly.  Until a custom parser
%                             is written, the XML text will be returned.
%
%
%            rstat: 1x1 structure containing parameters used by the
%                   reader when reading multiple continuous files.
%                   The structure is in the form:
%
%                                    pingnum: [1xN uint32]  last ping number
%                                   segState: [2x1 uint16]  segment ending values
%                                   inRegion: [1x1 bool]    last ping was in/out of ROI
%                                        lat: [1x1 double]  last lat fix
%                                        lon: [1x1 double]  last lon fix
%                                     dgTime: [1x1 double]  time of last GPS fix
%                                       fpos: [1x1 int32]   ending file pointer location
%
%               NOTE: The GPS fix contained in the rstat structure will be
%                     used as the initial GPS fix for the file being read if
%                     it within MAXRSTATGPSM meters of the first fix read
%                     by readEKRaw. When used as recommended on CONTINUOUS
%                     files, this should never be an issue, but if
%                     accidently used on two non-contiguous files this provides
%                     a sanity check and the lat/lon from rstat will not be
%                     used. MAXRSTATGPSM is not exposed as a keyword and as
%                     of this writing is set as a constant at the top of the
%                     readEKRaw code at 500m.
%
%   REQUIRES:
%               vdist.m  (older non-vectorized version is faster in this application)
%               inpoly.m
%
%               These functions are included in the readEKRaw package.
%

%   Rick Towler
%   National Oceanic and Atmospheric Administration
%   Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%   This code is based on code by Lars Nonboe Andersen, Simrad; Rueben Patel, IMR,
%   and much input from Nils Olav "give me one more feature" Handegard, IMR.

%-

%  define constants
HEADER_LEN = 12;                %  Bytes in datagram header
CHUNK_SIZE = 2500;              %  size in array elements of allocation "chunks"
MAXRSTATGPSM = 500;             %  max distance (m) between rstat GPS fix and first read GPS fix

%  define default parameters
returnFreqs = -1;               %  Return all frequencies by default
timeOffset = 0;                 %  Assume logging PC time and timezone set correctly
fileDateFormat = '%4d%2d%2d*'   %  Default file date format YYYYMMDD-TTTTTT




rData.angle = true;             %  Return alon and athw electrical angles by default
rData.annotations = false;      %  Do not return annotations by default
rData.continue = false;         %  default is non-continuation mode
rData.gps = true;               %  Return GPS data (even if none available)
rData.gpsOnly = false;          %  Return all data, not just GPS
rData.gpsType = 'double';       %  Return GPS as double
rData.gpsSource = 'GPGGA';      %  Use GGA datagrams as GPS data source
rData.heave = false;            %  Do not return heave by default
rData.pitch = false;            %  Do not return pitch by default
rData.power = true;             %  Return power by default
rData.rawNMEA = false;          %  Do not return raw NMEA data
rData.roll = false;             %  Do not return roll by default
rData.skinny = uint32(0);       %  Return all ping-by-ping param data by default
rData.trawl = false;            %  Do not return trawl data by default
rData.temp = false;             %  Do not return temperature by default
rData.uNMEA = false;            %  Do not return user defined NMEA data
rData.vlog = false;             %  Do not return vessel log data
rData.vlogType = 'single';      %  Return vessel log as single
rData.vlwSource = 'SD';         %  Use the SD talker ID for VLW datagrams
rData.vSpeed = false;           %  Do not return vessel speed data
rData.vSpeedType = 'single';    %  Return vessel speed as single
rData.vtgSource = 'GP';         %  Use the GP talker ID for VTG datagrams
pingRange = [1 1 Inf];          %  Do not limit by ping and read all pings by default
timeRange = [0 Inf];            %  Do not limit by time by default

geoRegion = -1;                 %  Geographic region is undefined by default
geoConn = -1;                   %  No explicit polygon connectivity provided
rData.doGeo = false;            %  Don't limit data by geographic region (ROI)
isInRegion = true;              %  All points are in the ROI by default
rparms = -1;                    %  By default the reader parameters are unset.
maxSegGap = -1;                 %  By default, do not test for spatial gaps in data
progressCallback = [];          %  No progress callback function defined
progressGranularity = 2;        %  Minimum percent change in progress before callback is called
userNMEA = {};                  %  By default the user defined NMEA array is undefined
maxBadBytes = 5000;             %  Keep reading 5000 bytes past a bad datagram for a good one

%  process property name/value pairs
for n = 1:2:length(varargin)
    switch lower(varargin{n})
        case {'frequency' 'frequencies'}
            %  limit data returned to these frequencies (in Hz)
            returnFreqs = sort(varargin{n + 1});
        case 'timeoffset'
            %  set logging PC timezone offset
            timeOffset = varargin{n + 1};
        case 'geoconn'
            %  set geographic region polygon connectivity
            grSize = size(varargin{n + 1});
            if (grSize(1) > 2) && (grSize(2) ==2)
                geoConn = varargin{n + 1};
            else
                if (varargin{n + 1} == -1)
                    geoConn = varargin{n + 1};
                else
                    warning('readEKTelegram:ParameterError', ['GeoConn - Incorrect ' ...
                        'array size.  Must be a Nx2 array of vertex ids pairs where N > 2.']);
                end
            end
        case 'georegion'
            %  set geographic region
            grSize = size(varargin{n + 1});
            if (grSize(1) > 2) && (grSize(2) ==2)
                geoRegion = varargin{n + 1};
                rData.doGeo = true;
                rData.gps = true;
            else
                if (varargin{n + 1} == -1)
                    geoRegion = varargin{n + 1};
                    rData.doGeo = false;
                else
                    warning('readEKTelegram:ParameterError', ['GeoRegion - Incorrect ' ...
                        'array size.  Must be a Nx2 array of Lat,Lon pairs where N > 2.']);
                end
            end
        case 'readerstate'
            rparms = varargin{n + 1};
        case 'pingrange'
            %  set starting and ending pings to load
            switch length(varargin{n + 1})
                case 2
                    pingRange = ones(1,3);
                    pingRange(1) = varargin{n + 1}(1);
                    pingRange(3) = varargin{n + 1}(2);
                case 3
                    pingRange = varargin{n + 1};
                otherwise
                    warning('readEKTelegram:ParameterError', ['PingRange - Incorrect ' ...
                        'number of arguments. PingRange must be a 2 or 3 ' ...
                        'element vector [pingStart pingEnd] or [pingStart ' ...
                        'pingStride pingEnd]']);
            end
            % adjust chunk size if nPings is small
            nPings = pingRange(3) - pingRange(1) + 1;
            if (nPings < CHUNK_SIZE); CHUNK_SIZE = nPings; end
        case 'timerange'
            %  set starting and ending times to load
            if (length(varargin{n + 1}) == 2)
                timeRange = varargin{n + 1};
                if (timeRange(2) < 0); timeRange(2) = Inf; end
                if (timeRange(2) < timeRange(1))
                    error('TimeRange - timeStart is greater than timeEnd');
                end
            else
                warning('readEKTelegram:ParameterError', ['TimeRange - Incorrect ' ...
                    'number of arguments. TimeRange must be a 2 element vector ' ...
                    '[timeStart timeEnd]']);
            end

        case 'heave'
            rData.heave = (0 < varargin{n + 1});
        case 'continue'
            rData.continue = (0 < varargin{n + 1});
        case 'roll'
            rData.roll = (0 < varargin{n + 1});
        case 'pitch'
            rData.pitch = (0 < varargin{n + 1});
        case 'trawl'
            rData.trawl = (0 < varargin{n + 1});
        case {'temperature' 'temp'}
            rData.temp = (0 < varargin{n + 1});
        case 'power'
            rData.power = (0 < varargin{n + 1});
        case 'angles'
            rData.angle = (0 < varargin{n + 1});
        case 'annotations'
            rData.annotations = (0 < varargin{n + 1});
        case 'rawnmea'
            rData.rawNMEA = (0 < varargin{n + 1});
        case 'gps'
            rData.gps = (0 < varargin{n + 1});
            if (varargin{n + 1} > 1); rData.gpsType = 'double'; else ...
                    rData.gpsType = 'single'; end
        case 'gpsonly'
            rData.gpsOnly = (0 < varargin{n + 1});
        case 'gpssource'
            rData.gpsSource = varargin{n + 1};
        case 'maxseggap'
            maxSegGap = varargin{n + 1};
        case 'maxbadbytes'
            maxBadBytes = varargin{n + 1};
        case 'usernmea'
            if iscell(varargin{n + 1})
                userNMEA = varargin{n + 1};
                rData.uNMEA = true;
            else
                warning('readEKTelegram:ParameterError', ['UserNMEA argument must be' ...
                ' a cell array']);
            end
        case 'vessellog'
            rData.vlog = (0 < varargin{n + 1});
            if (varargin{n + 1} > 1); rData.vlogType = 'double'; else ...
                    rData.vlogType = 'single'; end
        case 'vtgsource'
            rData.vtgSource = varargin{n + 1};
        case 'vlwsource'
            rData.vlwSource = varargin{n + 1};
        case 'vesselspeed'
            rData.vSpeed = (0 < varargin{n + 1});
            if (varargin{n + 1} > 1); rData.vSpeedType = 'double'; else ...
                    rData.vSpeedType = 'single'; end
        case 'progresscallback'
            if (isa(varargin{n + 1}, 'function_handle')); ...
                progressCallback = varargin{n + 1}; end
        case 'progressgranularity'
                progressGranularity = varargin{n + 1};
        otherwise
            warning('readEKTelegram:ParameterError', ['Unknown property name: ' ...
                varargin{n}]);
    end
end


%  determine the telegram file type
[pathstr, name, ext] = fileparts(filename);
fType = lower(ext(2:4));
if fType(1) == 'd'; fType = 'dg'; end;
switch fType
    case 'ek5'
        %
    case 'dg'
        %
    otherwise
        header = -1; data = -1; varargout = {-1};
        warning('readEKTelegram:IOError', 'Unsupported file type: %s',ext);
        return;
end

%  open the file
fid = fopen(filename, 'r');
if (fid == -1)
    header = -1; data = -1; varargout = {-1};
    warning('readEKTelegram:IOError', 'Could not open file: %s%s',name,ext);
    return;
end

%  extract the starting year, month, and day from the file name
fDate = sscanf(name, fileDateFormat);

%  allocate array bookkeeping variables
nGPS = uint32(1);
nNMEA = uint32(1);
nVlog = uint32(1);
nVSpeed = uint32(1);
nTAG = uint32(1);
arraySize = zeros(1, 2, 'uint32');
arraySize(:,1) = CHUNK_SIZE;
arraySize(:,2) = 0;
nPings = repmat(uint32(1), 1, 1);
nuNMEA = [length(userNMEA) ones(1, length(userNMEA))];


%  define reader state variables
if isstruct(rparms)
    %  define state variables using provided parameters
    gpsSeg.in = rparms.segState(1);
    gpsSeg.out = rparms.segState(2);
    gpsSeg.inRegion = rparms.inRegion;
    isInRegion = rparms.inRegion;
    pingCounter = rparms.pingnum;
    
    %  insert previous GPS fix
    data.gps.time(nGPS) = rparms.dgTime;
    data.gps.lat(nGPS) = rparms.lat;
    data.gps.lon(nGPS) = rparms.lon;
    if (gpsSeg.inRegion)
        data.gps.seg(nGPS) = gpsSeg.in;
    else
        data.gps.seg(nGPS) = gpsSeg.out;
    end
    nGPS = nGPS + 1;
else
    %  define state variables using defaults
    gpsSeg.in = int16(0);
    gpsSeg.out = int16(0);
    gpsSeg.inRegion = true;
    pingCounter = repmat(uint32(0), 1, transceivercount);
end

%  if continuing - pick up where we left off
if (rData.continue) && (isstruct(rparms))
    fseek(fid, rparms.fpos, 'bof');
end

%  progress callback - determine divisor
if (~isempty(progressCallback))
    wbLast = -1;
    switch true
        case (pingRange(3) ~= Inf)
            wbMode = 1;
            wbMax = (pingRange(3) - pingRange(1)) / pingRange(2);
        case (timeRange(2) ~= Inf)
            wbMode = 2;
            wbMax = timeRange(2) - timeRange(1);
        otherwise
            wbMode = 0;
            cp = ftell(fid);
            fseek(fid, 0 , 'eof');
            wbMax = ftell(fid);
            fseek(fid, cp, 'bof');
    end
end


%  read file, processing individual datagrams
while (true)
    
    %  check if we're at the end of the file
    len = fread(fid, 1, 'int32', 'l');
    if (feof(fid))
        break;
    end

    %  read datagram header
    [dgType, dgTime] = readEKRaw_ReadDgHeader(fid, timeOffset);
    
    %  if reading subsets - check if we're done
    if (dgTime > timeRange(2))
        %  move file pointer back to beginning of this datagram
        fseek(fid, -(HEADER_LEN + 4), 0);
        break;
    end
    
    %  call progress callback
    if (~isempty(progressCallback))
        %  calculate current position
        switch wbMode
            case 0
                wbCur = ftell(fid);
            case 1
                wbCur = pingCounter(1) - pingRange(1);
            case 2
                wbCur = dgTime - timeRange(1);
        end
        %  calculate normalized progress value
        wbProg = wbCur / wbMax;
        
        %  clamp...
        if (wbProg > 1); wbProg = 1; end
        if (wbProg < 0); wbProg = 0; end
        
        %  are we calling back this iteration?
        wbThis = round(wbProg * 100);
        if (mod(wbThis, progressGranularity) == 0) && (wbThis ~= wbLast)
            % call the progress callback
            progressCallback(wbProg);
            wbLast = wbThis;
        end
    end
    
    %  process datagrams by type
    switch (dgType)

        case 'NME0'
            % Process NMEA datagram

            %  read datagram
            text = char(fread(fid, len - HEADER_LEN, 'char', 'l')');
            
            %  store the raw NMEA text
            if (rData.rawNMEA)
                %  check len of arrays - extend if required
                if (nNMEA > data.NMEA.len)
                    data.NMEA.time = [data.NMEA.time; zeros(CHUNK_SIZE, ...
                        1, 'double')];
                    data.NMEA.string = [data.NMEA.string; cell(CHUNK_SIZE,1)];
                    data.NMEA.len = data.NMEA.len + CHUNK_SIZE;
                end
                
                %  assign raw NMEA data
                data.NMEA.time(nNMEA) = dgTime;
                data.NMEA.string(nNMEA) = {text};
                nNMEA = nNMEA + 1;
            end

            if rData.gps || rData.vlog || rData.vSpeed || rData.uNMEA
            
                %  parse datagram
                nmea = readEKRaw_ParseNMEAstring(text, rData);
                
                %  extract datagrams of interest, process and store
                switch true
                    
                    %  GPS Fix data
                    case rData.gps && strcmp(nmea.type, rData.gpsSource)

                        %  check that GPS data has valid fix - drop if not
                        if (nmea.fix == 0)
                            fread(fid, 1, 'int32', 'l');
                            continue;
                        end

                        %  check len of arrays - extend if required
                        if (nGPS > data.gps.len)
                            data.gps.time = [data.gps.time; zeros(CHUNK_SIZE, ...
                                1, 'double')];
                            data.gps.lat = [data.gps.lat; zeros(CHUNK_SIZE, ...
                                1, rData.gpsType)];
                            data.gps.lon = [data.gps.lon; zeros(CHUNK_SIZE, ...
                                1, rData.gpsType)];
                            data.gps.seg = [data.gps.seg; zeros(CHUNK_SIZE, ...
                                1, 'int16')];
                            data.gps.len = data.gps.len + CHUNK_SIZE;
                        end
                        
                        %  set time
                        data.gps.time(nGPS) = dgTime;
                        
                        %  set lat/lon signs and store values
                        if (nmea.lat_hem == 'S'); 
                            data.gps.lat(nGPS) = -nmea.lat;
                        else
                            data.gps.lat(nGPS) = nmea.lat;
                        end
                        if (nmea.lon_hem == 'W'); 
                            data.gps.lon(nGPS) = -nmea.lon;
                        else
                            data.gps.lon(nGPS) = nmea.lon;
                        end

                        %  are we limiting data by geographic region?
                        if (rData.doGeo)
                            %  yes - test if fix is in ROI
                            if (geoConn(1) < 0)
                                %  no connectivity provided
                                [isInRegion, bnd] = inpoly([data.gps.lat(nGPS), ...
                                    data.gps.lon(nGPS)], geoRegion);
                            else
                                %  explicit connectivity provided
                                [isInRegion, bnd] = inpoly([data.gps.lat(nGPS), ...
                                    data.gps.lon(nGPS)], geoRegion, geoConn);
                            end
                        else
                            %  no - always "in"
                            isInRegion = true;
                        end

                        %  set prior GPS fix
                        if (nGPS == 1)
                            %  no priors in data.gps
                            if (isstruct(rparms))
                                %  check if the rparms fix is close
                                %  this is a sanity check on the rstat GPS fix
                                dist = vdist(data.gps.lat(nGPS), data.gps.lon(nGPS), ...
                                    rparms.lat, rparms.lon);
                                if dist < MAXRSTATGPSM
                                    % pick up last fix from rparms struct
                                    lastLat = rparms.lat;
                                    lastLon = rparms.lon;
                                else
                                    %  too far apart - replicate first fix
                                    lastLat = data.gps.lat(nGPS);
                                    lastLon = data.gps.lon(nGPS);
                                end
                            else
                                %  no rparms - just replicate first fix
                                lastLat = data.gps.lat(nGPS);
                                lastLon = data.gps.lon(nGPS);
                                
                                %  set initial segment value
                                if (isInRegion)
                                    %  only need to set in state...
                                    gpsSeg.in = 1;
                                end
                            end
                        else
                            %  priors read - assign
                            lastLat = data.gps.lat(nGPS-1);
                            lastLon = data.gps.lon(nGPS-1);
                        end
                        
                        %  check if vessel moved and calculate delta
                        if  (maxSegGap > 0) && ((data.gps.lat(nGPS) - lastLat ~= 0) || ...
                            (data.gps.lon(nGPS) - lastLon ~= 0))

                            %  moved - calculate distance between fixes (in m)
                            dist = vdist(data.gps.lat(nGPS), data.gps.lon(nGPS), ...
                                lastLat, lastLon);
                        else
                            %  no movement
                            dist = 0;
                        end
                        
                        %  determine segment value
                        if (maxSegGap > 0) && (dist > maxSegGap)
                            %  distance exceeds threshold - increment segment
                            if (gpsSeg.inRegion)
                                %  in ROI - increment "in" counter
                                gpsSeg.in = gpsSeg.in + int16(1);
                                data.gps.seg(nGPS) = gpsSeg.in;
                            else
                                %  out of ROI - increment "out" counter
                                gpsSeg.out = gpsSeg.out - int16(1);
                                data.gps.seg(nGPS) = gpsSeg.out;
                            end
                        elseif (rData.doGeo)
                            if (isInRegion)
                                %  in ROI
                                if (~gpsSeg.inRegion)
                                    %  transitioned - increment in counter
                                    gpsSeg.inRegion = true;
                                    gpsSeg.in = gpsSeg.in + int16(1);
                                end
                                data.gps.seg(nGPS) = gpsSeg.in;
                            else
                                %  out of ROI
                                if (gpsSeg.inRegion)
                                    %  transitioned - decrement out counter
                                    gpsSeg.inRegion = false;
                                    gpsSeg.out = gpsSeg.out - int16(1);
                                end
                                data.gps.seg(nGPS) = gpsSeg.out;
                            end
                        else
                            %  not using ROI's or segGap - always in one segment
                            data.gps.seg(nGPS) = gpsSeg.in;
                        end
                        %  increment GPS counter
                        nGPS = nGPS + 1;

                        
                    %  store vessel log data    
                    case rData.vlog && strcmp([rData.vlwSource 'VLW'], nmea.type) && isInRegion

                        %  check len of arrays - extend if required
                        if (nVlog > data.vlog.len)
                            data.vlog.time = [data.vlog.time; zeros(CHUNK_SIZE, 1, 'double')];
                            data.vlog.vlog = [data.vlog.vlog; zeros(CHUNK_SIZE, 1, rData.vlogType)];
                            if (rData.gps)
                                data.vlog.seg = [data.vlog.seg; zeros(CHUNK_SIZE, 1, 'int16')];
                            end
                            data.vlog.len = data.vlog.len + CHUNK_SIZE;
                        end
                        
                        data.vlog.time(nVlog) = dgTime;
                        data.vlog.vlog(nVlog) = nmea.total_cum_dist;
                        if (rData.gps); data.vlog.seg(nVlog) = gpsSeg.in; end
                        nVlog = nVlog + 1;


                    %  store vessel speed data
                    case rData.vSpeed && strcmp([rData.vtgSource 'VTG'], nmea.type) && isInRegion

                        %  check len of arrays - extend if required
                        if (nVSpeed > data.vspeed.len)
                            data.vspeed.time = [data.vspeed.time; zeros(CHUNK_SIZE, 1, 'double')];
                            data.vspeed.speed = [data.vspeed.speed; zeros(CHUNK_SIZE, 1, rData.vSpeedType)];
                            if (rData.gps)
                                data.vspeed.seg = [data.vspeed.seg; zeros(CHUNK_SIZE, 1, 'int16')];
                            end
                            data.vspeed.len = data.vspeed.len + CHUNK_SIZE;
                        end
                        
                        data.vspeed.time(nVSpeed) = dgTime;
                        data.vspeed.speed(nVSpeed) = nmea.sog_knts;
                        data.vspeed.seg(nVSpeed) = gpsSeg.in;
                        nVSpeed = nVSpeed + 1;

                end
                
                %  store user defined NMEA strings
                if rData.uNMEA
                    thisNMEA = strcmpi(nmea.type, userNMEA);
                    nuIDX = [false thisNMEA];
                    if sum(thisNMEA) > 0
                        %  check len of arrays - extend if required
                        if (nuNMEA(nuIDX) > data.NMEA.(userNMEA{thisNMEA}).len)
                            data.NMEA.(userNMEA{thisNMEA}).time = ...
                                [data.NMEA.(userNMEA{thisNMEA}).time; zeros(CHUNK_SIZE, 1, 'double')];
                            data.NMEA.(userNMEA{thisNMEA}).string = ...
                                [data.NMEA.(userNMEA{thisNMEA}).string; cell(CHUNK_SIZE, 1)];
                            data.NMEA.(userNMEA{thisNMEA}).len = ...
                                data.NMEA.(userNMEA{thisNMEA}).len + CHUNK_SIZE;
                        end

                        data.NMEA.(userNMEA{thisNMEA}).time(nuNMEA(nuIDX)) = dgTime;
                        data.NMEA.(userNMEA{thisNMEA}).string(nuNMEA(nuIDX)) = {text};
                        nuNMEA(nuIDX) = nuNMEA(nuIDX) + 1;
                    end
                end
                
            end
            lastType = dgType;

        case 'TAG0'
            %  Process annotation datagram
            text = char(fread(fid, len - HEADER_LEN, 'char', 'l')');
            
            if (rData.annotations)
                %  check len of arrays - extend if required
                if (nTAG > data.annotations.len)
                    data.annotations.time = [data.annotations.time; zeros(CHUNK_SIZE, 1, 'double')];
                    data.annotations.text = [data.annotations.text; cell(CHUNK_SIZE, 1)];
                    data.annotations.len = data.annotations.len + CHUNK_SIZE;
                end

                data.annotations.time(nTAG) = dgTime;
                data.annotations.text(nTAG) = {text};
                nTAG = nTAG + 1;
            end
            lastType = dgType;

        case 'RAW0'
            %  Process sample datagram
            if (CIDs(1) > 0)
                sampledata = readEKRaw_ReadSampledata(fid, sampledata);
                idx = find(CIDs == sampledata.channel);
            else
                idx = [];
                fread(fid, len - HEADER_LEN, 'char', 'l');
            end
            
            %  check if we're storing this frequency...
            if (~isempty(idx)) 
                
                %  increment total ping counter
                pingCounter(idx) = pingCounter(idx) + 1;
                
                %  if reading subsets - check if we're done
                if (pingCounter(idx) > pingRange(3))
                    %  move file pointer back to beginning of this datagram
                    fseek(fid, -(len + 4), 0);
                    %  tick back ping counter
                    pingCounter(idx) = pingCounter(idx) - 1;
                    break;
                end
                
                %  check if we're storing this ping...
                if (pingCounter(idx) >= pingRange(1)) && (dgTime >= timeRange(1)) &&...
                    (isInRegion) && (~mod(pingCounter(idx), pingRange(2)))
                
                    %  check length of arrays - extend if required
                    if (nPings(idx) > arraySize(idx,1))
                        arraySize(idx,1) = arraySize(idx,1) + CHUNK_SIZE;
                        data.pings(idx).number(1, nPings(idx):arraySize(idx,1)) = 0;
                        data.pings(idx).time(1, nPings(idx):arraySize(idx,1)) = 0;
                        if (~rData.skinny)
                            data.pings(idx).transducerdepth(1, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).frequency(1, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).transmitpower(1, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).pulselength(1, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).bandwidth(1, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).sampleinterval(1, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).soundvelocity(1, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).absorptioncoefficient(1, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).offset(1, nPings(idx):arraySize(idx,1)) = 0;
                        end
                        if (rData.heave); data.pings(idx).heave(1, nPings(idx):arraySize(idx,1)) = 0; end
                        if (rData.roll); data.pings(idx).roll(1, nPings(idx):arraySize(idx,1)) = 0; end
                        if (rData.pitch); data.pings(idx).pitch(1, nPings(idx):arraySize(idx,1)) = 0; end
                        if (rData.temp); data.pings(idx).temperature(1, nPings(idx):arraySize(idx,1)) = 0; end
                        if (rData.trawl)
                            data.pings(idx).trawlopeningvalid(1, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).trawlupperdepthvalid(1, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).trawlupperdepth(1, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).trawlopening(1, nPings(idx):arraySize(idx,1)) = 0;
                        end
                        data.pings(idx).count(1, nPings(idx):arraySize(idx,1)) = 0;
                        if (rData.power); data.pings(idx).power(:, nPings(idx):arraySize(idx,1)) = -999; end
                        if (rData.angle)
                            data.pings(idx).alongship(:, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).athwartship(:, nPings(idx):arraySize(idx,1)) = 0;
                        end
                        if (rData.gps); data.pings(idx).seg(1, nPings(idx):arraySize(idx,1)) = 0; end
                    end
                    
                    %  copy this pings data into output arrays
                    data.pings(idx).number(nPings(idx)) = pingCounter(idx);
                    data.pings(idx).time(nPings(idx)) = dgTime;

                    if (rData.skinny > 0)
                        if (rData.skinny == nPings(idx))
                            %  operating in "skinny" mode and this is the ping we
                            %  want to read our parameters from.
                            data.pings(idx).transducerdepth(1) = ...
                                sampledata.transducerdepth;
                            data.pings(idx).frequency(1) = ...
                                sampledata.frequency;
                            data.pings(idx).transmitpower(1) = ...
                                sampledata.transmitpower;
                            data.pings(idx).pulselength(1) = ...
                                sampledata.pulselength;
                            data.pings(idx).bandwidth(1) = ...
                                sampledata.bandwidth;
                            data.pings(idx).sampleinterval(1) = ...
                                sampledata.sampleinterval;
                            data.pings(idx).soundvelocity(1) = ...
                                sampledata.soundvelocity;
                            data.pings(idx).absorptioncoefficient(1) = ...
                                sampledata.absorptioncoefficient;
                            data.pings(idx).offset(1) = ...
                                sampledata.offset;
                        end
                    else
                        %  operating in "fat" mode.  Store all parameters.
                        data.pings(idx).transducerdepth(nPings(idx)) = ...
                            sampledata.transducerdepth;
                        data.pings(idx).frequency(nPings(idx)) = ...
                            sampledata.frequency;
                        data.pings(idx).transmitpower(nPings(idx)) = ...
                            sampledata.transmitpower;
                        data.pings(idx).pulselength(nPings(idx)) = ...
                            sampledata.pulselength;
                        data.pings(idx).bandwidth(nPings(idx)) = ...
                            sampledata.bandwidth;
                        data.pings(idx).sampleinterval(nPings(idx)) = ...
                            sampledata.sampleinterval;
                        data.pings(idx).soundvelocity(nPings(idx)) = ...
                            sampledata.soundvelocity;
                        data.pings(idx).absorptioncoefficient(nPings(idx)) = ...
                            sampledata.absorptioncoefficient;
                        data.pings(idx).offset(nPings(idx)) = ...
                            sampledata.offset;
                    end
                    if (rData.heave); data.pings(idx).heave(nPings(idx)) = ...
                        sampledata.heave; end
                    if (rData.roll); data.pings(idx).roll(nPings(idx)) = ...
                        sampledata.roll; end
                    if (rData.pitch); data.pings(idx).pitch(nPings(idx)) = ...
                        sampledata.pitch; end
                    if (rData.temp); data.pings(idx).temperature(nPings(idx)) = ...
                        sampledata.temperature; end
                    if (rData.trawl)
                        data.pings(idx).trawlopeningvalid(nPings(idx)) = ...
                            sampledata.trawlopeningvalid;
                        data.pings(idx).trawlupperdepthvalid(nPings(idx)) = ...
                            sampledata.trawlupperdepthvalid;
                        data.pings(idx).trawlupperdepth(nPings(idx)) = ...
                            sampledata.trawlupperdepth;
                        data.pings(idx).trawlopening(nPings(idx)) = ...
                            sampledata.trawlopening;
                    end
                    
                    %  handle "subsettable" data
                    if (sampleRange(1) <= sampledata.count)
                        %  determine ending sample index
                        if (sampleRange(2) > sampledata.count)
                            endIdx = sampledata.count;
                            %  cap number of data samples stored to maxSampleRange
                            if endIdx > maxSampleRange; endIdx = maxSampleRange; end
                        else
                            endIdx = sampleRange(2);
                        end
                        %  store actual sample count value
                        count = (endIdx - sampleRange(1)) + 1;
                        data.pings(idx).count(nPings(idx)) = count;

                        %  check depth of arrays - extend if required
                        if (arraySize(idx,2) < count)
                            nSampAdd = count - uint16(arraySize(idx,2));
                            if (rData.power)
                                data.pings(idx).power(end + 1:end + nSampAdd,:) = -999;
                            end
                            if (rData.angle)
                                data.pings(idx).alongship(end + 1:end + nSampAdd,:) = 0;
                                data.pings(idx).athwartship(end + 1:end + nSampAdd,:) = 0;
                            end
                            arraySize(idx,2) = count;
                        end
                        
                        if (rData.power)
                            %  store power
                            data.pings(idx).power(1:count, nPings(idx)) = ...
                                sampledata.power(sampleRange(1):endIdx);
                        end
                        if (rData.angle)
                            %  store angles
                            data.pings(idx).alongship(1:count, nPings(idx)) = ...
                                sampledata.alongship(sampleRange(1):endIdx);
                            data.pings(idx).athwartship(1:count, nPings(idx)) = ...
                                sampledata.athwartship(sampleRange(1):endIdx);
                        end
                        %  store GPS line segment value
                        if (rData.gps)
                            data.pings(idx).seg(nPings(idx)) = gpsSeg.in;
                        end
                            
                    end

                    %  increment stored ping counter
                    nPings(idx) = nPings(idx) + 1;
                end
            end
            lastIDX = idx;
            lastType = dgType;

        case 'CON1'
            %  Read ME70 CON datagram
            conText = char(fread(fid, len - HEADER_LEN, 'char', 'l')');
            
            %  At some point this will return a data structure containing
            %  the parameters defined in the CON1 datagram but currently
            %  only the text contained in the datagram is returned.
            %
            %  The CON1 XML string is non-conformant in that the values for
            %  each node are stored within the opening tag as "value"
            %  instead of between the opening and closing tag.
            %
            %  Most XML packages do not parse this correctly.  The
            %  following code does parse the string, but the resulting
            %  structure is awkward to navigate.  (requires xml_io_tools
            %  from the MATLAB code contrib site.
            %
            %  A custom parser needs to be written to return a sane
            %  structure containing the CON1 data.
            
            %  create DOM node
             conText = conText(regexp(conText, '?>\r\n<', 'end'):end - 2);
%             conText = ['<?xml version="1.0" encoding="ISO-8859-1"?>' conText];
%             conText = java.lang.String(conText);
%             stream = java.io.StringBufferInputStream(conText);
%             factory = javaMethod('newInstance','javax.xml.parsers.DocumentBuilderFactory');
%             builder = factory.newDocumentBuilder;
%             conText = builder.parse(stream);
            
            %  process DOM node
%            [tree, RootName] = xml_read(conText);
            
            %  return configuration data as a char array
            data.conf.time = dgTime;
            data.conf.text = conText;
            lastType = dgType;
            
        case 'SVP0'
            %  Read Sound Velocity Profile datagram
            svpText = char(fread(fid, len - HEADER_LEN, 'char', 'l')');
            
            % this datagram is not handled at this time.
            % Bjarte Berntsen (Kongsberg) has provided the format and I
            % will incorporate this at some point in the future.
            
            lastType = dgType;
            
        % Process unknown datagrams
        otherwise
            if (maxBadBytes > 0)
                %  Display warning - try to find next datagram
                warning('readEKRaw:Datagram', ['Invalid datagram at offset ' num2str(ftell(fid)) ...
                    '(d) - Searching for next datagram...']);

                %  rewind to last good dgram header
                fseek(fid, -(lastLen + 8), 0);

                ok = false;
                nBytes = 0;
                while (~ok)
                    try
                        %  read 4 bytes and look for known datagram
                        dgType = char(fread(fid,4,'char', 'l')');
                    catch
                        warning('readEKRaw:Datagram', 'Unable to locate next valid datagram.');
                        break;
                    end
                    nBytes = nBytes + 4;
                    if (strcmp(dgType, 'CON1') || strcmp(dgType, 'RAW0') || ...
                            strcmp(dgType ,'TAG0') || strcmp(dgType ,'NME0') || ...
                            strcmp(dgType, 'SVP0'))
                        %  if found w/in last datagram, last datagram is malformed
                        if (nBytes < (lastLen - 8)) && (strcmp(lastType, 'RAW0'))
                            %  only need to drop bad RAW0 datagrams
                            nPings(lastIDX) = nPings(lastIDX) - 1;
                        end
                        %  rewind to beginning of datagram
                        fseek(fid, -12, 0);
                        ok = true;
                    else
                        %  rewind 3 bytes
                        fseek(fid, -3, 0);
                        nBytes = nBytes - 3;
                        %  check if we're giving up
                        if (nBytes > maxBadBytes); 
                            warning('readEKRaw:Datagram', ['Unable to locate valid datagram.' ...
                                ' Giving up.']);
                            break;
                        end
                    end
                end
                if (~ok); break; end
            else
                warning('readEKRaw:Datagram', ['Invalid datagram at offset ' num2str(ftell(fid)) ...
                    '(d) - Aborting...']);
                break;
            end
            
    end
    
    %  datagram length is repeated...
    lastLen = fread(fid, 1, 'int32', 'l');
    
end

%  set the readerState return parameters
if (nargout == 3)
    rp.fpos = ftell(fid);
    rp.pingnum = pingCounter;
    if (rData.gps) && (nGPS > 1)
        rp.segState = [gpsSeg.in, gpsSeg.out];
        rp.inRegion = gpsSeg.inRegion;
        rp.lat = data.gps.lat(nGPS-1);
        rp.lon = data.gps.lon(nGPS-1);
        rp.dgTime = dgTime;
    else
        rp.segState = [0, 0];
        rp.inRegion = true;
        rp.lat = -1;
        rp.lon = -1;
    end
    varargout = {rp};
end

%  close file.
fclose(fid);

%  trim GPS/vlog/vspeed/annotation arrays
if (rData.gps)
    data.gps.time = data.gps.time(1:nGPS-1);
    data.gps.lat = data.gps.lat(1:nGPS-1);
    data.gps.lon = data.gps.lon(1:nGPS-1);
    data.gps.seg = data.gps.seg(1:nGPS-1);
    data.gps = rmfield(data.gps, 'len');
end
if (rData.vlog)
    data.vlog.time = data.vlog.time(1:nVlog-1);
    data.vlog.vlog = data.vlog.vlog(1:nVlog-1);
    if (rData.gps); data.vlog.seg = data.vlog.seg(1:nVlog-1); end
    data.vlog = rmfield(data.vlog, 'len');
end
if (rData.vSpeed)
    data.vspeed.time = data.vspeed.time(1:nVSpeed-1);
    data.vspeed.speed = data.vspeed.speed(1:nVSpeed-1);
    if (rData.gps); data.vspeed.seg = data.vspeed.seg(1:nVSpeed-1); end
    data.vspeed = rmfield(data.vspeed, 'len');
end
if (rData.annotations)
    data.annotations.time = data.annotations.time(1:nTAG-1);
    data.annotations.text = data.annotations.text(1:nTAG-1);
    data.annotations = rmfield(data.annotations, 'len');
end
if (rData.rawNMEA)
    data.NMEA.time = data.NMEA.time(1:nNMEA-1);
    data.NMEA.string = data.NMEA.string(1:nNMEA-1);
    data.NMEA = rmfield(data.NMEA, 'len');
end
if (rData.uNMEA)
    for n=1:nuNMEA(1)
        data.NMEA.(userNMEA{n}).time = data.NMEA.(userNMEA{n}).time(1:nuNMEA(n+1)-1);
        data.NMEA.(userNMEA{n}).string = data.NMEA.(userNMEA{n}).string(1:nuNMEA(n+1)-1);
        data.NMEA.(userNMEA{n}) = rmfield(data.NMEA.(userNMEA{n}), 'len');
    end
end

%  for each transducer...
for idx=1:transceivercount
   
    if (nPings(idx) <= arraySize(idx,1))
        %  Trim output data arrays
        data.pings(idx).number(nPings(idx):end) = [];
        data.pings(idx).time(nPings(idx):end) = [];
        if (~rData.skinny)
            data.pings(idx).transducerdepth(nPings(idx):end) = [];
            data.pings(idx).frequency(nPings(idx):end) = [];
            data.pings(idx).transmitpower(nPings(idx):end) = [];
            data.pings(idx).pulselength(nPings(idx):end) = [];
            data.pings(idx).bandwidth(nPings(idx):end) = [];
            data.pings(idx).sampleinterval(nPings(idx):end) = [];
            data.pings(idx).soundvelocity(nPings(idx):end) = [];
            data.pings(idx).absorptioncoefficient(nPings(idx):end) = [];
            data.pings(idx).offset(nPings(idx):end) = [];
        end
        if (rData.heave); data.pings(idx).heave(nPings(idx):end) = []; end
        if (rData.roll); data.pings(idx).roll(nPings(idx):end) = []; end
        if (rData.pitch); data.pings(idx).pitch(nPings(idx):end) = []; end
        if (rData.temp); data.pings(idx).temperature(nPings(idx):end) = []; end
        if (rData.trawl)
            data.pings(idx).trawlopeningvalid(nPings(idx):end) = [];
            data.pings(idx).trawlupperdepthvalid(nPings(idx):end) = [];
            data.pings(idx).trawlupperdepth(nPings(idx):end) = [];
            data.pings(idx).trawlopening(nPings(idx):end) = [];
        end
        if (rData.gps); data.pings(idx).seg(nPings(idx):end) = []; end
        data.pings(idx).count(nPings(idx):end) = [];
        if (rData.power)
            data.pings(idx).power(:, nPings(idx):end) = [];
        end
        if (rData.angle)
            data.pings(idx).alongship(:, nPings(idx):end) = [];
            data.pings(idx).athwartship(:, nPings(idx):end) = [];
        end
    end
end
