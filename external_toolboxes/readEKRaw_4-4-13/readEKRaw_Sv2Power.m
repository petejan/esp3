function data = readEKRaw_Sv2Power(data, calParms, varargin)
%readEKRaw_Sv2Power  Convert Sv or sv to power
%   data = readEKRaw_Sv2Power(data, calParms, varargin) converts Sv or sv data
%       contained in the readEKRaw data structure to power.
%
%   power is calculated as follows:
%
%       recvPower = Sv - 20 log10(Range) - (2 *  alpha * Range) + (10 * ...
%           log10((xmitPower * (10^(gain/10))^2 * lambda^2 * ...
%            c * tau * 10^(psi/10)) / (32 * pi^2)) + (2 * SaCorrection)
%
%   REQUIRED INPUT:
%               data:   The "data" structure output from readEKRaw
%                       containing either the Sv or sv fields.
%           calParms:   The calibration parameters data structure
%
%   OPTIONAL PARAMETERS:
%             KeepSv:   By default, the Sv/sv field is replaced by the power field.
%                       Set this value to true to keep the Sv/sv field.
%                            Default: false
%
%       tvgCorrection:   Set this parameter to true if you applied TVG correction.
%                        when you converted power to Sv/sv. IT IS ADVISED NOT TO 
%                        CHANGE THIS UNLESS YOU KNOW WHAT YOU ARE DOING.
%                            Default: true
%       
%   OUTPUT:
%       Output is a modified version of the input data structure that includes a
%       new field "power". If the power field exists, 
%
%   REQUIRES:   None
%
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%-

%  check for either the Sv or sv fields
if (sum(strcmp(fieldnames(data.pings(1)), 'Sv')) > 0)
    % we have the Sv field
    rLinear = false;
elseif (sum(strcmp(fieldnames(data.pings(1)), 'sv')) > 0)
    %  we have the sv field - set the linear keyword
    rLinear = true;
else
    %  we're missing both the Sv or sv fields
    warning ('readEKRaw:ParameterError', ...
        'Sv/sv field does not exist in data structure. Unable to convert to power.');
    return
end

rSource = false;             %  by default do not keep the Sv/sv field
tvgCorrectionFactor = 2.0;   %  default is to apply TVG correction with offset of 2 for Sv

%  process optional parameters
for n = 1:2:length(varargin)
    switch lower(varargin{n})
        case 'keepsv'
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

%  call convertPower with mode set to 2
data = readEKRaw_ConvertPower(data, calParms, 2, tvgCorrectionFactor, rLinear, ...
    rSource, false);
