function data = readEKRaw_Power2Sv(data, calParms, varargin)
%readEKRaw_Power2Sv  Convert raw power to Sv
%   data = readEKRaw_Power2Sv(data, calParms, varargin) converts power data
%       contained in the readEKRaw data structure to Sv.
%
%   Sv is calculated as follows:
%
%       Sv = recvPower + 20 log10(Range) + (2 *  alpha * Range) - (10 * ...
%           log10((xmitPower * (10^(gain/10))^2 * lambda^2 * ...
%            c * tau * 10^(psi/10)) / (32 * pi^2)) - (2 * SaCorrection)
%
%   REQUIRED INPUT:
%               data:   The "data" structure output from readEKRaw
%                       containing the power field.
%           calParms:   The calibration parameters data structure
%
%   OPTIONAL PARAMETERS:
%           KeepPower:  By default, the power field is replaced by the Sv field.
%                       Set this value to true to keep the power field.
%                            Default: false
%
%              Linear:  Set this parameter to true to return data in linear
%                       units (sv).
%                            Default: false
%
%              Double:  Set this parameter to true to return Sv/sv as double
%                       precision.
%                           Default: false
%
%       tvgCorrection:  Set this parameter to true to apply TVG correction. Set 
%                       it to false to not apply TVG correction. For specialized
%                       applications you can explicitly specify the IT IS ADVISED
%                       NOT TO CHANGE THIS UNLESS YOU KNOW WHAT YOU ARE DOING.
%                            Default: true
%       
%   OUTPUT:
%       Output is a modified version of the input data structure that includes a
%       new field Sv (dB re 1 m^-1) if the Linear parameter is set to false or
%       sv (m^-1) if Linear is true.
%
%   REQUIRES:   None
%
%   NOTE:  The output of this function varies slightly from the values returned
%          from Echoview in that Echoview drops the first sample so
%          when compared to Echoview this function returns nEVSamples + 1.
%          Excluding this first sample, there will be differences in data values
%          up to +-0.02 dB in the first ~7 samples and less than +-0.0001 dB
%          in subsequent samples. Also note that Echoview numbers samples
%          starting at 0 so for example sample 94 in Echoview is sample 96 in
%          the readEKRaw data structure.
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%-

%  check if the power field exists
if (~isfield(data.pings(1), 'power'))
    warning ('readEKRaw:ParameterError', ...
        'Power field does not exist in data structure. Unable to convert to Sv/sv.');
    return
end

rDouble = false;                %  default is to return data as single
rSource = false;                %  default is to not keep the power field
rLinear = false;                %  default is to return log data
tvgCorrectionFactor = 2.0;      %  default is to apply TVG correction with offset of 2 for Sv

%  process optional parameters
for n = 1:2:length(varargin)
    switch lower(varargin{n})
        case 'keeppower'
            rSource = (0 < varargin{n + 1});
        case 'double'
            rDouble = (0 < varargin{n + 1});
        case 'tvgcorrection'
            if isa(varargin{n + 1}, 'logical')
                if (varargin{n + 1} == false)
                    %  set TVG correction factor to 0
                    tvgCorrectionFactor = 0.0;
                end
            else
                %  user specified a custom TVG correction factor
                tvgCorrectionFactor = varargin{n + 1};
            end
        case 'linear'
            rLinear = (0 < varargin{n + 1});
        otherwise
            warning('readEKRaw:ParameterError', ...
                ['Unknown property name: ' varargin{n}]);
    end
end

%  call convertPower with mode set to 1
data = readEKRaw_ConvertPower(data, calParms, 1, tvgCorrectionFactor, rLinear, ...
    rSource, rDouble);

