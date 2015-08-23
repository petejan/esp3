function data = readEKRaw_ConvertAngles(data, calParms, varargin)
%readEKRaw_ConvertAngles  Convert between electrical and physical angles
%   data = readEKRaw_ConvertAngles(data, calParms) converts electrical
%       angles to physical angles or physical to electrical using the
%       following equations:
%
%   physical = ((electrical_angle * 180 / 128) / sensitivity) - offset
%
%   electrical_angle = (((physical + offset) * sensitivity) * 128) / 180
%
%   IMPORTANT NOTE: As of 12/2009 the readEKRaw structure changed so that
%                   there is a distinction between electrical and physical
%                   angles. Electrical angles are now stored as "alongship_e"
%                   and "athwartship_e" and physical angles as "alongship"
%                   and "athwartship". This function assumes that if
%                   electrical angle data is present you want to convert to
%                   physical angles and that it physical angle data is
%                   present you're converting to electrical angles. If both
%                   fields exist in the structure you must specify which
%                   direction to convert.
%
%   REQUIRED INPUT:
%               data:   The "data" structure output from readEKRaw
%           calParms:   The calibration parameters data structure
%
%   OPTIONAL PARAMETERS:
%
%       The default behavior of this function is to check for the
%       'alongship_e' field in the input data structure and to assume that
%       if it is present that the intention is to convert the electrical
%       angles to physical.  If the 'alongship_e' field doesn't exist, the
%       function assumes that you want to convert physical to electrical.
%       If both fields exist, the function will convert electrical to
%       physical unless you explicitly state which conversion you want. Use
%       the following two keyword parameters to explicitly control the
%       conversion:
%             ToElec:   Set this keyword to true to convert from physical
%                       to electrical angles.
%
%             ToPhys:   Set this keyword to true to convert from electrical
%                       to physical angles.
%
%
%     KeepElecAngles:   By default, when converting to physical angles the
%                       electrical angle fields are replaced by the physical
%                       angle fields. Set this value to true to keep the
%                       electrical angle fields.
%                           Default: false
%
%     KeepPhysAngles:   By default, when converting to electrical angles the
%                       physical angle fields are replaced by the electrical
%                       angle fields. Set this value to true to keep the
%                       physical angle fields.
%                           Default: false
%   OUTPUT:
%       Output is a modified version of the input data structure where the angle
%       data has been converted to physical angles.  The data is converted "in
%       place" thus the electrical angle data is lost.
%
%   REQUIRES:   None
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%-

mode = -1;                          %  by default we check the structure to determine mode
rPhysAngles = false;                %  delete physical angles if converting to electrical
rElecAngles = false;                %  delete electrical angles if converting to physical

%  process optional parameters
for n = 1:2:length(varargin)
    switch lower(varargin{n})
        case 'keepelecangles'
            rElecAngles = (0 < varargin{n + 1});
        case 'keepphysangles'
            rPhysAngles = (0 < varargin{n + 1});
        case 'toelec'
            mode = 0;
        case 'tophys'
            mode = 1;
        otherwise
            warning('readEKRaw:ParameterError', ...
                ['Unknown property name: ' varargin{n}]);
    end
end

if (mode == -1)
    %  mode not explicitly specified - guess
    if (isfield(data.pings(1), 'alongship_e'))
        %  assume we're converting to physical
        mode = 1;
    else
        %  assume we're converting to electrical
        mode = 0;
    end
end
    
%  determine the number of transceivers
nXcvrs = size(data.pings,2);

%  loop thru transceiver data
for n=1:nXcvrs
    if (mode == 0)
        %  check if the alon and athw physical angle fields exists
        if (~isfield(data.pings(1), 'alongship'))
            warning ('readEKRaw:ParameterError', ...
                'Alongship and Athwartship physical angle fields do not exist in data structure.');
            return
        end
        
        %  convert physical angles to electrical angles
        data.pings(n).alongship_e = int8((((data.pings(n).alongship + ...
            calParms(n).anglesoffsetalongship) * ...
            calParms(n).anglesensitivityalongship) * 128.) / 180.);
        data.pings(n).athwartship_e = int8((((data.pings(n).athwartship + ...
            calParms(n).angleoffsetathwartship) * ...
            calParms(n).anglesensitivityathwartship) * 128.) / 180.);
    else
        %  check if the alon and athw electrical angle fields exists
        if (~isfield(data.pings(1), 'alongship_e'))
            warning ('readEKRaw:ParameterError', ...
                'Alongship and Athwartship electrical angle fields do not exist in data structure.');
            return
        end
        
        %  convert electrical angles to physical angles
        data.pings(n).alongship = ((single(data.pings(n).alongship_e) * ...
            1.40625) / calParms(n).anglesensitivityalongship) - ...
            calParms(n).anglesoffsetalongship;
        data.pings(n).athwartship = ((single(data.pings(n).athwartship_e) * ...
            1.40625) / calParms(n).anglesensitivityathwartship) - ...
            calParms(n).angleoffsetathwartship;
    end
end

%  remove electrical angle fields
if (~rElecAngles && mode == 1)
    data.pings = rmfield(data.pings, 'alongship_e');
    data.pings = rmfield(data.pings, 'athwartship_e');
end

%  remove physical angle fields
if (~rPhysAngles && mode == 0)
    data.pings = rmfield(data.pings, 'alongship');
    data.pings = rmfield(data.pings, 'athwartship');
end