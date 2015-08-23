function calParms = readEKRaw_GetCalParms(header, data, varargin)
% readEKRaw_GetCalParms - Extracts calibration params from readEKRaw structure
%   calParms = readEKRaw_GetCalParms(header, data) Extracts calibration
%       parameters from the readEKRaw output structures and returns them in a
%       structure suitable for input into other readEKRaw functions.
%
%   REQUIRED INPUT:
%        header:    The "header" structure returned by readEKRaw.
%          data:    The "data" structure returned by readEKRaw.
%
%   OPTIONAL PARAMETERS:
%
%    PingNumber:    A scalar specifying the ping to extract ping specfic
%                   parameters from.
%                       Default: 1
%       
%   OUTPUT:
%       Structure containing the relevant calibration parameters.
%
%   REQUIRES:   None
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov
%

%-

pingNo = 1;             % default is the first ping in the dataset

for n = 1:2:length(varargin)
    switch lower(varargin{n})
        case {'ping' 'pingnumber'}
            %  specify which ping to extract ping specific params from
            nPings = data.pings(1).number(end);
            if (varargin{n + 1} <= nPings)
                pingNo = varargin{n + 1};
            else
                warning('readEKRaw:ParameterError', ...
                    'PingNumber exceeds number of actual pings - Ignored');
            end
        otherwise
            warning('readEKRaw:ParameterError', ...
                ['Unknown property name: ' varargin{n}]);
    end
end

%  determine the number of transceivers in the xcvr struct
nXcvrs = length(data.config);

%  create the calibration parameters structure
calParms = repmat(struct('soundername', '', 'frequency', 0, ...
    'soundvelocity', 0, 'sampleinterval', 0, 'absorptioncoefficient', 0, ...
    'gain', 0, 'equivalentbeamangle', 0, 'pulselengthtable', 0, ...
    'gaintable', 0, 'sacorrectiontable', 0, 'transmitpower', 0, ...
    'pulselength', 0, 'anglesensitivityalongship', 0, ...
    'anglesensitivityathwartship', 0, 'anglesoffsetalongship', 0, ...
    'angleoffsetathwartship', 0, 'transducerdepth', 0), 1, nXcvrs);

%  loop thru available transceivers and extract calibration parameters
for n=1:nXcvrs
    calParms(n).soundername = header.soundername;
    calParms(n).frequency = data.config(n).frequency;
    calParms(n).soundvelocity = data.pings(n).soundvelocity(pingNo);
    calParms(n).sampleinterval = data.pings(n).sampleinterval(pingNo);
    calParms(n).absorptioncoefficient = data.pings(n).absorptioncoefficient(pingNo);
    calParms(n).gain = data.config(n).gain;
    calParms(n).equivalentbeamangle = data.config(n).equivalentbeamangle;
    calParms(n).pulselengthtable = data.config(n).pulselengthtable;
    calParms(n).gaintable  = data.config(n).gaintable;
    calParms(n).sacorrectiontable = data.config(n).sacorrectiontable;
    calParms(n).transmitpower = data.pings(n).transmitpower(pingNo);
    calParms(n).pulselength = data.pings(n).pulselength(pingNo);
    calParms(n).anglesensitivityalongship = data.config(n).anglesensitivityalongship;
    calParms(n).anglesensitivityathwartship = data.config(n).anglesensitivityathwartship;
    calParms(n).anglesoffsetalongship = data.config(n).anglesoffsetalongship;
    calParms(n).angleoffsetathwartship = data.config(n).angleoffsetathwartship;
    calParms(n).transducerdepth = data.pings(n).transducerdepth(pingNo);
end
