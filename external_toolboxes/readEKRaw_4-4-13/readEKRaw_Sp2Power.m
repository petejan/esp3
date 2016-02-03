function data = readEKRaw_Sp2Power(data, calParms, varargin)
%readEKRaw_Sp2Power  Convert Sp/sp to power
%   data = readEKRaw_Sp2Power(data, calParms, varargin) converts Sp/sp data
%       contained in the readEKRaw data structure to power.
%
%   power is calculated as follows:
%
%       recvPower = Sp - 40 * log10(Range) - (2 *  alpha * Range) + (10 * ...
%           log10((xmitPower * (10^(gain/10))^2 * lambda^2) / (16 * pi^2)))
%
%   REQUIRED INPUT:
%               data:   The "data" structure output from readEKRaw
%                       containing the Sp or sp fields.
%           calParms:   The calibration parameters data structure
%
%   OPTIONAL PARAMETERS:
%             KeepSp:   By default, the Sp/sp field is replaced by the power field.
%                       Set this value to true to keep the Sp/sp field.
%                            Default: false
%
%       tvgCorrection:  Set this parameter to true if you applied TVG correction.
%                       when you converted power to Sp/sp. IT IS ADVISED NOT TO
%                       CHANGE THIS UNLESS YOU KNOW WHAT YOU ARE DOING.
%                            Default: false
%       
%   OUTPUT:
%       Output is a modified version of the input data structure that includes a
%       new field "power".
%
%   REQUIRES:   None
%
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%-

%  check if the Sp or sp fields exist
if (sum(strcmp(fieldnames(data.pings(1)), 'Sp')) > 0)
    % we have the Sv field
    rLinear = false;
elseif (sum(strcmp(fieldnames(data.pings(1)), 'sp')) > 0)
    %  we have the sv field - set the linear keyword
    rLinear = true;
else
    %  we're missing both the Sv or sv fields
    warning ('readEKRaw:ParameterError', ...
        'Sp/sp field does not exist in data structure. Unable to convert to power.');
    return
end

rSource = false;             %  by default do not keep the Sv/sv field
tvgCorrectionFactor = 0.0;   %  default is to NOT apply TVG correction for Sp

%  process optional parameters
for n = 1:2:length(varargin)
    switch lower(varargin{n})
        case 'keepsp'
            rSource = (0 < varargin{n + 1});
        case 'tvgcorrection'
            if (0 < varargin{n + 1})
                tvgCorrectionFactor = 2.0;
            else
                tvgCorrectionFactor = 0.0;
            end
        otherwise
            warning('readEKRaw:ParameterError', ...
                ['Unknown property name: ' varargin{n}]);
    end
end

%  call convertPower with mode set to 4
data = readEKRaw_ConvertPower(data, calParms, 4, tvgCorrectionFactor, rLinear, ...
    rSource, false);
