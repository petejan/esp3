function [header, data] = readEKRaw_SetCalParms(header, data, calParms)
% readEKRaw_SetCalParms - Sets calibration parameters in the readEKRaw structure
%   [header, data] = readEKRaw_SetCalParms(header, data, calParms) Sets 
%       the calibration parameters in the readEKRaw output structure to the
%       values specified in the calibration parameters structure. This
%       function is effectively the reverse of readEKRaw_GetCalParms
%
%   REQUIRED INPUT:
%        header:    The readEKRaw header structure to be changed.
%          data:    The readEKRaw data structure to be changed.
%       calParms:   The readEKRaw calibration parameters structure
%
%   OPTIONAL PARAMETERS:  None
% 
%   OUTPUT:
%       header:     readEKRaw header structure containing the modified 
%                   calibration parameters.
%         data:     readEKRaw data structure containing the modified 
%                   calibration parameters.
%
% 
%   REQUIRES:  None
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov
%


%  determine the number of transceivers in the xcvr struct
nXcvrs = length(data.config);

%  loop thru available transceivers and set calibration parameters
for n=1:nXcvrs
    header.soundername(1:size(calParms(n).soundername,2))  =  calParms(n).soundername;
    data.config(n).frequency = calParms(n).frequency;
    data.pings(n).soundvelocity(:) = calParms(n).soundvelocity ;
    data.pings(n).sampleinterval(:) = calParms(n).sampleinterval;
    data.pings(n).absorptioncoefficient(:) = calParms(n).absorptioncoefficient;
    data.config(n).gain = calParms(n).gain;
    data.config(n).equivalentbeamangle = calParms(n).equivalentbeamangle;
    data.config(n).beamwidthalongship = calParms(n).beamwidthalongship;
    data.config(n).beamwidthathwartship = calParms(n).beamwidthathwartship;
    data.config(n).pulselengthtable = calParms(n).pulselengthtable;
    data.config(n).gaintable = calParms(n).gaintable;
    data.config(n).sacorrectiontable = calParms(n).sacorrectiontable;
    data.pings(n).transmitpower(:) = calParms(n).transmitpower;
    data.pings(n).pulselength(:) = calParms(n).pulselength;
    data.config(n).anglesensitivityalongship = calParms(n).anglesensitivityalongship;
    data.config(n).anglesensitivityathwartship = calParms(n).anglesensitivityathwartship;
    data.config(n).anglesoffsetalongship = calParms(n).anglesoffsetalongship;
    data.config(n).angleoffsetathwartship = calParms(n).angleoffsetathwartship;
    data.pings(n).transducerdepth(:) = calParms(n).transducerdepth;
end
