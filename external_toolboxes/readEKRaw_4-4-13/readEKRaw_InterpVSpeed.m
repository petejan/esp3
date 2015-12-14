function data = readEKRaw_InterpVSpeed(data, varargin)
%readEKRaw_InterpVSpeed  Interpolate vessel speed data on a ping-by-ping basis
%   data = readEKRaw_InterpVSpeed(data, varargin) interpolates vessel speed values
%   on a ping-by-ping basis replacing the original vspeed data with the interpolated
%   values.
%
%   REQUIRED INPUT:
%               data:   The "data" structure output from readEKRaw
%
%   OPTIONAL PARAMETERS:
%          Method:   Set this parameter to the desired interpolation method.
%                    Valid methods are 'nearest', 'linear', 'spline', and 
%                    'cubic'.  For descriptions, see the MATLAB docs for
%                    interp1.
%                           Default: 'linear'
%
%       
%   OUTPUT:
%       Output is a modified version of the input data structure where the
%       vspeed field has been expanded to the same length as data.ping.time.
%
%       NOTE:  This function deletes the data.vspeed.time and data.vspeed.seg
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
if (~isfield(data, 'vspeed'))
    warning ('readEKRaw:ParameterError', ...
        'vspeed field does not exist in input data structure.');
    return
end

%  define defaults
method = 'linear';              %  default interpolation method is linear

%  process optional parameters
for n = 1:2:length(varargin)
    switch lower(varargin{n})
        case 'method'
            method = varargin{n + 1};
        otherwise
            warning('readEKRaw:ParameterError', ...
                ['Unknown property name: ' varargin{n}]);
    end
end

%  determine segment count
nsegStart = min(data.vspeed.seg(data.vspeed.seg > 0));
nsegEnd = max(data.vspeed.seg);

%  get total number of pings over all segments
nPings = length(data.pings(1).time);

%  create temporary vspeed array
vsTemp = zeros(nPings, 1, class(data.vspeed.speed));

%  loop thru segments, interpolating each
for n=nsegStart:nsegEnd
    %  switch based on the number of vspeed points
    nPingsInSeg = length(data.vspeed.time(data.vspeed.seg==n));
    switch nPingsInSeg
        case 0
            %  no vspeed data in file - do nothing
        case 1
            %  not enough fixes to interpolate - replicate
            vsTemp(data.pings(1).seg==n) = ...
                repmat(data.vspeed.speed(data.vspeed.seg==n), 1, nPingsInSeg);
        otherwise
            %  interpolate vspeed fixes
            vsTemp(data.pings(1).seg==n) = ...
                interp1(data.vspeed.time(data.vspeed.seg==n), ...
                data.vspeed.speed(data.vspeed.seg==n), ...
                data.pings(1).time(data.pings(1).seg==n), method);
    end
end

%  replace vspeed data
data.vspeed.speed = vsTemp;

%  remove time and seg fields from vspeed
data.vspeed = rmfield(data.vspeed, 'time');
data.vspeed = rmfield(data.vspeed, 'seg');


