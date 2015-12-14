function[data, varargout] = readEKRaw_InterpVLog(data, varargin)
%readEKRaw_InterpVL  Interpolate vessel log data on a ping-by-ping basis
%   data = readEKRaw_InterpVL(data, varargin) interpolates VL values on a
%   ping-by-ping basis replacing the original VL data with the interpolated
%   data.
%
%   NOTE:  By default, this function will delete pings whose associated VL data
%          is NaN after interpolation.  Set the KeepAll parameter to disable
%          this behavior.
%
%   REQUIRED INPUT:
%               data:   The "data" structure output from readEKRaw
%
%   OPTIONAL PARAMETERS:
%         BotData:   Set this parameter to an instance of the readEKRaw sounder
%                    detected bottom data structure to to remove bottom detections
%                    associated with pings that were removed during interpolation.
%                    You must also set an output argument to return the altered
%                    bottom data. This is a convienient method to keep the pings
%                    and bottom detection data structures the same length when
%                    interpolating VL.
%                           Default: []
%
%         KeepAll:   Set this parameter to true to avoid deleting pings whose
%                    associated VL datum lies outside the interval spanned by VL
%                    data (and if using the recommended linear interpolation is
%                    equal to NaN).
%                           Default: false
%
%          Method:   Set this parameter to the desired interpolation method.
%                    Valid methods are 'nearest', 'linear', 'spline', and 
%                    'cubic'.  For descriptions, see the MATLAB docs for
%                    interp1.
%                           Default: 'linear'
%
%   OUTPUT:
%       Output is a modified version of the input data structure where the vlog
%       field has been expanded to the same length as data.ping.time.
%
%       Optionally, this function will output a modified bottom detection structure
%       where the number, time, and bottomdepth fields have been trimmed to match
%       the "pings" data structure.
%
%       NOTE:  This function deletes the data.vlog.time and data.vlog.seg
%              fields since without modification they are meaningless after
%              interpolation and if modified they would simply be a copy of
%              data.ping.time and data.ping.seg.
%
%   REQUIRES:   None
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%-

%  check if the gps fields exists
if (~isfield(data, 'vlog'))
    warning ('readEKRaw:ParameterError', ...
        'vlog field does not exist in input data structure.');
    return
end

%  define defaults
method = 'linear';              %  default interpolation method is linear
keepAll = false;                %  default is to delete pings where VL==NaN or VL==0
botData = [];

%  process optional parameters
for n = 1:2:length(varargin)
    switch lower(varargin{n})
        case 'botdata'
            botData = varargin{n + 1};
        case 'method'
            method = varargin{n + 1};
        case 'keepall'
            keepAll = 0 < varargin{n + 1};
        otherwise
            warning('readEKRaw:ParameterError', ...
                ['Unknown property name: ' varargin{n}]);
    end
end

%  determine segment count
nsegStart = min(data.vlog.seg(data.vlog.seg > 0));
nsegEnd = max(data.vlog.seg);

%  get total number of pings over all segments
nPings = length(data.pings(1).time);

%  create temporary vspeed array
vlTemp = zeros(nPings, 1, class(data.vlog.vlog));


%  loop thru segments, interpolating each
for n=nsegStart:nsegEnd
    %  switch based on the number of vlog points
    nPingsInSeg = length(data.vlog.time(data.vlog.seg==n));
    switch nPingsInSeg
        case 0
            %  no vlog data in file - do nothing
        case 1
            %  not enough fixes to interpolate - replicate
            vlTemp(data.pings(1).seg==n) = ...
                repmat(data.vlog.vlog(data.vlog.seg==n), 1, nPingsInSeg);
        otherwise
            %  interpolate VL fixes
            vlTemp(data.pings(1).seg==n) = ...
                interp1(data.vlog.time(data.vlog.seg==n), ...
                data.vlog.vlog(data.vlog.seg==n), ...
                data.pings(1).time(data.pings(1).seg==n), method);
    end
end

%  replace vlog data
data.vlog.vlog = vlTemp;

if (~keepAll)
    % remove interpolated VL values outside of valid GPS interval
    vlNaN = isnan(data.vlog.vlog);
    data.vlog.vlog(vlNaN) = [];
    vlZeros = data.vlog.vlog == 0;
    data.vlog.vlog(vlZeros) = [];

    %  remove pings outside of valid GPS interval
    pNaNIDX = find(vlNaN == 1);
    pZeroIDX = find(vlZeros == 1);
    nFreqs = length(data.pings);
    for n=1:nFreqs
        data.pings(n) = readEKRaw_DeletePing(data.pings(n), pNaNIDX);
        data.pings(n) = readEKRaw_DeletePing(data.pings(n), pZeroIDX);
        if ~isempty(botData)
            botData.pings(n) = readEKRaw_DeleteBot(botData.pings(n), pNaNIDX);
            botData.pings(n) = readEKRaw_DeleteBot(botData.pings(n), pZeroIDX);
        end
    end
end

if ~isempty(botData); varargout = {botData}; end

%  remove time and seg fields from vlog
data.vlog = rmfield(data.vlog, 'time');
data.vlog = rmfield(data.vlog, 'seg');
