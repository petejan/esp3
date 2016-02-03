function [header, data, varargout] = readEKBot(filename, calParms, varargin)
%readEKBot  Read EK60 .bot bottom detection data file
%   [header, data, rstat] = readEKBot(filename, calParms, varargin) 
%       returns structures containing the .bot file header data and depth a data
%       contained in the specified .bot file.  Optionally returns a "readerState"
%       structure.
%
%   [header, data, rstat] = readEKBot(filename, calParms, rawData, varargin)
%       returns structures containing the .bot file header data and depth data
%       contained in the specified .bot file.  Optionally returns a "readerState"
%       structure.  Providing the rawData structure as the third argument provides
%       additional data that is used in processing the .bot file data (see
%       below).
%
%
%   A NOTE REGARDING MULTIPLEXED DATA:
%
%   When reading data collected from systems where one or more transceivers
%   are multiplexed (multiple transducers connected to a single transceiver)
%   the range/depth data for the multiplexed channels is replicated for
%   off-duty pings. This follows how the data is written to the .bot file.
%   It is your responsibility to extract the correct bottom detections for
%   your multiplexed channels.
%
%
%   REQUIRED INPUT:
%          filename:    A string containing the path to the file to read
%
%          calParms:    The calibration parameters data structure
%
%   OPTIONAL ARGUMENTS:
%
%           rawData:    Optionally pass an instance of a readEKRaw rawData 
%                       structure as the third argument.  Including this argument
%                       has multiple effects.  First, the bottom data is returned
%                       for the corresponding rawData pings only.  Secondly, the
%                       sound speed value used in calculating the range adjustment
%                       will be taken from the raw data.  Lastly, the
%                       function will return data for only the frequencies
%                       stored in the rawData structure.
%
%                       Do not pass this argument if *all* of the transceivers in
%                       your data files were multiplexed. At least one transceiver
%                       must not be multiplexed. This is a limitation of this
%                       function which you are welcome to fix.
%
%   OPTIONAL PARAMETERS:
%          Continue:    Set this parameter to True to start reading the file
%                       from the point specified in the ReaderState structure
%                       (see ReaderState below).  When used in conjunction with
%                       the TimeRange parameter this allows one to read .out
%                       files in chunks corresponding to specific raw files.
%                       Note that setting this parameter without setting
%                       the ReaderState parameter has no effect.
%                           Default: False
%
%       Frequencies:    A scalar or vector of frequency values (in Hz) to
%                       return.  Set this to limit reading data to specific
%                       frequencies.
%                           Default: -1  (return all frequencies)
%
%       ReaderState:    Set this parameter to an instance of the "rstat"
%                       structure (defined below) to enable continuity of
%                       certain parameters between calls to readEKOut.  This
%                       allows ping numbers to remain meaningful when multiple
%                       files are read.  This parameter is also is required when
%                       reading files in chunks using the 'Continue' parameter.
%                           Default: Undefined
%
%       ReturnDepth:    Set this parameter to True to return sounder detected
%                       bottom data as depth values.
%                           Default: False
%
%       ReturnRange:    Set this parameter to True to return sounder detected
%                       bottom data as range values.
%                           Default: True
%
%        SoundSpeed:    Set this parameter to a scalar value specifiying the
%                       sound speed used *when the file was recorded*.  This
%                       parameter must be set (or the rawData structure must be
%                       passed) if the sound speed specified in calParms is
%                       different than the sound speed that was used when
%                       recoding data.  This value will be used to adjust the
%                       range value given the recorded sound speed and the
%                       "processing" sound speed.  If this value is not
%                       specified and if the rawData structure is not passed no
%                       sound speed adjustments will be applied.
%
%                       NOTE:  If sound speed was changed in the middle of a
%                       file, you must pass a "non-skinny" rawData structure so
%                       that the recorded sound speed is avilable on a ping by
%                       ping basis.
%                           Default: Undefined
%
%        TimeOffset:    Set this parameter to a scalar value denoting the time
%                       offset, in hours, to be applied to the data to
%                       compensate for a misconfigured data collection PC.
%                           Default: 0
%
%       The timeOffset parameter is helpful in syncing pings with GPS fixes.
%       While most protocols call for collecting data with the PC's clock set to
%       GMT, a common mistake is to set the clock to GMT without adjusting the
%       time zone to GMT as well.  The Simrad EK60 software automatically
%       applies the time zone offset to the PC's local clock before storing ping
%       times so this misconfiguration results in ping times that are incorrect.
%       The timeOffset parameter will allow you to adjust for this mistake.
%
%         TimeRange:    A 2 element vector in the form [start end] defining the
%                       time range to read from the file.  Time values are in
%                       MATLAB serial time.  To read to the end of the file, set
%                       end to Inf.
%                           Default: [0 Inf] - read entire file
%
%   OUTPUT:
%           header: A structure containing file header information in the form:
%
%                        surveyname: [1x128 char]
%                      transectname: [1x128 char]
%                       soundername: [1x128 char]
%                             spare: [1x128 char]
%                   transceivercount: 0
%
%             data: Assuming M transceivers and N pings, data is a structure
%                   in the form:
%
%                     config: a 1xM structure containing the transceiver
%                             specific configuration data.
%                      pings: A structure containing the ping specific
%                             data. The structure is in the form:
%
%                           number: [1xN uint32]
%                             time: [1xN double]
%                      bottomdepth: [MxN single]
%
%            rstat: 1x1 structure containing parameters used by the
%                   reader when reading multiple continuous files.
%                   The structure is in the form:
%
%                          pingnum: [1xN uint32]  last ping number
%                             fpos: [1x1 int32]   ending file pointer location
%
%
%   REQUIRES:   None
%

%   Rick Towler
%   National Oceanic and Atmospheric Administration
%   Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%-

%  define constants
HEADER_LEN = 12;               %  Length in bytes of datagram header
CHUNK_SIZE = 500;              %  size in array elements of allocation "chunks"

%  define default parameters
adjustRange = uint8(0);         %  Default is not to adjust range for sound speed change
returnFreqs = -1;               %  Return all frequencies by default
returnRange = true;             %  Return data as depth by default
rparms = -1;                    %  Reader State parameters unset
rData.continue = false;         %  Default is to not continue
soundSpeed = -1;                %  Default sound dpeed is "undefined"
timeOffset = 0;                 %  Assume logging PC time and timezone set correctly
timeRange = [0 Inf];            %  Do not limit by time by default
useRaw = false;                 %  By default don't use rawData structure

%  check if rawData structure was passed
nVarArgs = length(varargin);
vaStart = 1; rawData = []; useRaw = false;
if (mod(nVarArgs,2) ~= 0)
    %  rawData structure passed
    rawData = varargin{1};
    vaStart = 2;
    useRaw = true;
end

%  process property name/value pairs
for n = vaStart:2:nVarArgs
    switch lower(varargin{n})
        case 'continue'
            rData.continue = (0 < varargin{n + 1});
        case {'frequency' 'frequencies'}
            %  limit data returned to these frequencies (in Hz)
            returnFreqs = sort(varargin{n + 1});
        case 'readerstate'
            rparms = varargin{n + 1};
        case 'returndepth'
            returnRange = ~(varargin{n + 1} > 0);
        case 'returnrange'
            returnRange = (varargin{n + 1} > 0);
        case 'soundspeed'
            soundSpeed = varargin{n + 1};
            if (soundSpeed > 0); adjustRange = uint8(3); end
        case 'timeoffset'
            %  set logging PC timezone offset
            timeOffset = varargin{n + 1};
        case 'timerange'
            %  set starting and ending times to load
            if (length(varargin{n + 1}) == 2)
                timeRange = varargin{n + 1};
                if (timeRange(2) < 0); timeRange(2) = Inf; end
                if (timeRange(2) < timeRange(1))
                    error('TimeRange - timeStart is greater than timeEnd');
                end
            else
                warning('readEKRaw:ParameterError', ['TimeRange - Incorrect ' ...
                    'number of arguments. TimeRange must be a 2 element vector ' ...
                    '[timeStart timeEnd]']);
            end
        otherwise
            warning('readEKRaw:ParameterError', ...
                ['Unknown property name: ' varargin{n}]);
    end
end

%  set up rawData specific vars
if (useRaw)
    %  set timeRange based on rawData time values
    timeRange = [rawData.pings(1).time(1) rawData.pings(1).time(end)];
    
    %  set the return frequencies and determine max number of pings
    nx = length(rawData.pings);
    returnFreqs = zeros(nx,1);
    arrayLen = zeros(nx,1);
    for n=1:nx
        returnFreqs(n) = rawData.pings(n).frequency(1);
        arrayLen(n) = length(rawData.pings(n).time);
    end
    [arrayLen, alIdx] = max(arrayLen);
    
    %  determine if we have a "skinny" or "fat" rawData structure
    if (length(rawData.pings(1).soundvelocity) == 1);
        adjustRange = uint8(1); else adjustRange = uint8(2); end

else
    arrayLen = CHUNK_SIZE;
end


%  open file for reading
fid = fopen(filename, 'r');
if (fid==-1)
    [pathstr, name, ext] = fileparts(filename);
    header = -1; data = -1; varargout = {-1};
    warning('readEKRaw:IOError', 'Could not open out file: %s%s',name,ext);
    return;
end

%  read configuration datagram (file header)
[config, frequencies] = readEKRaw_ReadHeader(fid);

%  create an index that returns all frequencies in the file
idx = 1:config.header.transceivercount;
cpIdx = 1:config.header.transceivercount;

if (returnFreqs(1) > 0)
    %  remove xcvrs we're not interested in
    [c, a, b] = setxor(returnFreqs, frequencies);
    config.transceiver(b) = [];
    idx(b) = [];
    cpIdx = 1:length(idx);
    %  update header data to reflect change
    config.header.transceivercount = config.header.transceivercount - ...
        length(c);
    header = config.header;
    %  return if none of the freqs specified exist in the file
    if (config.header.transceivercount == 0)
        warning('readEKRaw:IOError', ['The specified frequencies are not ' ...
            'in the file.']);
        fclose(fid);
        header = -1; data = -1; varargout = {-1};
        return;
    end
else
    header = config.header;
end


%  calculate sound speed correction factor if possible.  Otherwise extract
%  soundspeed values to use in ping-by-ping corrections.
switch adjustRange
    case 1
        %  a single sound speed value is taken from rawData
        %  it is assumed this value is constant throughout the file
        soundvelocity = zeros(1, config.header.transceivercount, 'single');
        for n=1:config.header.transceivercount
            soundvelocity(n) = rawData.pings(n).soundvelocity(1);
        end
        cf = [calParms(:).soundvelocity] ./ soundvelocity;
    case 2
        %  per ping sound speeds are taken from the rawData
        soundvelocity = zeros(arrayLen, config.header.transceivercount, 'single');
        for n=1:config.header.transceivercount
            %  check for multiplexed channels (length is 1/2 arrayLen)
            if (length(rawData.pings(n).soundvelocity) == arrayLen)
                %  non-multiplexed channel
                soundvelocity(:,n) = rawData.pings(n).soundvelocity;
            else
                %  this is a multiplexed (or broken) channel. Replicate sound
                %  velocity data (a bit wasteful but a quick fix)
                soundvelocity(1:2:end,n) = rawData.pings(n).soundvelocity;
                soundvelocity(2:2:end,n) = rawData.pings(n).soundvelocity;
            end
        end
        %  can't calculate cf right now - do it ping by ping below
    case 3
        %  recorded sound speed passed in as argument
        cf = [calParms(:).soundvelocity] / soundSpeed;
    otherwise
        %  nothing to do here since we're not ajusting the range....
end

%  allocate transceiver based data arrays
for n=1:config.header.transceivercount
    data.config(n) = config.transceiver(n);
end
data.pings.number = zeros(1, arrayLen, 'uint32');
data.pings.time = zeros(1, arrayLen, 'double');
data.pings.bottomdepth = zeros(config.header.transceivercount, ...
    arrayLen, 'single');

%  allocate bookkeeping variables
arraySize = uint32(arrayLen);
nPings = uint32(1);
if isstruct(rparms)
    pingCounter = rparms.pingnum;
else
    pingCounter = uint32(0);
end

%  build xducerdepth array
if (returnRange)
    transducerdepth = zeros(config.header.transceivercount, 1);
    for n=1:config.header.transceivercount
        transducerdepth(n) = calParms(n).transducerdepth;
    end
end

%  if continuing - pick up where we left off
if (rData.continue) && (isstruct(rparms))
    fseek(fid, rparms.fpos, 'bof');
end


%  read entire file, processing individual datagrams
while (true)
    
    %  check if we're at the end of the file
    fread(fid, 1, 'int32', 'l');
    if (feof(fid))
        break;
    end

    %  read datagram header
    [dgType, dgTime] = readEKRaw_ReadDgHeader(fid, timeOffset);

    %  process datagrams by type
    switch dgType

        case 'BOT0'
            
            %  if reading subsets - check if we're done
            if (dgTime > timeRange(2))
                %  move file pointer back to beginning of this datagram
                fseek(fid, - (HEADER_LEN + 4), 0);
                break;
            end
            
            %  Read BOT datagram
            transceivercount = fread(fid, 1, 'int32', 'l');
            depth = fread(fid, transceivercount, 'float64', 'l');

            %  increment total ping counter
            pingCounter = pingCounter + 1;
            
            %  check if we're storing this ping...
            if (dgTime >= timeRange(1))
                
                %  check length of arrays - extend if required
                if (nPings > arraySize)
                    arraySize = arraySize + CHUNK_SIZE;
                    data.pings.number(1, nPings:arraySize) = 0;
                    data.pings.time(1, nPings:arraySize) = 0;
                    data.pings.bottomdepth(:, nPings:arraySize) = 0;
                end

                if (adjustRange > 0)
                    %  adjust range based on sound speed values
                    if (adjustRange == 2)
                        cf = [calParms(cpIdx).soundvelocity] ./ [soundvelocity(nPings,:)];
                    end
                    if (sum(cf)/length(idx) ~= 1); depth(idx) = depth(idx) .* cf'; end
                end
                
                if (returnRange)
                    %  convert depth to range - this is opposite of .out files
                    depth(idx) = depth(idx) - transducerdepth;
                end
                
                %  store data assuming there are transceivercount depths per datagram. 
                data.pings.number(nPings) = pingCounter;
                data.pings.time(nPings) = dgTime;
                data.pings.bottomdepth(:,nPings) = depth(idx);
                nPings = nPings + 1;
            end

        otherwise
            %  Skip unknown datagram - print warning message
            warning('readEKRaw:IOError', strcat('Unknown datagram ''', ...
                dgheader.datagramtype,''' in file'));

    end
    
    %  datagram length is repeated...
    fread(fid, 1, 'int32', 'l');
end

%  set the readerState return parameters
if (nargout == 3)
    rp.fpos = ftell(fid);
    rp.pingnum = pingCounter;
    varargout = {rp};
end

%  close file.
fclose(fid);

if (nPings < length(data.pings.number))
    %  trim bottom data arrays
    data.pings.number(nPings:end) = [];
    data.pings.time(nPings:end) = [];
    data.pings.bottomdepth(:,nPings:end) = [];
end
