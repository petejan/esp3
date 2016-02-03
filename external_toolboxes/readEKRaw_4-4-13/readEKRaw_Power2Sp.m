function data = readEKRaw_Power2Sp(data, calParms, varargin)
%readEKRaw_Power2Sp  Convert raw power to Sp
%   data = readEKRaw_Power2Sp(data, calParms, varargin) converts power data
%       contained in the readEKRaw data structure to Sp.
%
%   Sp is calculated as follows:
%
%       Sp = recvPower + 40 * log10(Range) + (2 *  alpha * Range) - (10 * ...
%           log10((xmitPower * (10^(gain/10))^2 * lambda^2) / (16 * pi^2)))
%
%
%   By default, TVG range correction is not applied to the data. This
%   results in output that is consistent with the Simrad "P" telegram and TS
%   data exported from Echoview version 4.3 and later (prior versions applied
%   the correction by default).
%
%   If you intend to perform single target detections you *must* apply the
%   TVG range correction at some point in your process. This can be done by
%   either setting the tvgCorrection keyword of this function or it can be
%   done as part of your single target detection routine.
%
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
%                       units (sp).
%                            Default: false
%
%              Double:  Set this parameter to true to return Sv/sv as type
%                       double precision.
%                           Default: false
%
%       tvgCorrection:   Set this parameter to true to apply TVG correction. Set 
%                        it to false to not apply TVG correction. IT IS ADVISED
%                        NOT TO CHANGE THIS UNLESS YOU KNOW WHAT YOU ARE DOING.
%                            Default: false
%       
%   OUTPUT:
%       Output is a modified version of the input data structure that includes a
%       new field Sp (dB re 1 m^2) if the Linear parameter is set to false or
%       sp (m^2) if Linear is true.
%
%   REQUIRES:   None
%
%   NOTE:  The output of this function varies slightly from the values returned
%          from Echoview in that Echoview drops the first sample so
%          when compared to Echoview this function returns nEVSamples + 1.
%          Excluding this first sample, there will be differences in data values
%          up to +-0.1 dB in the first ~7 samples and less than +-0.0001 dB
%          in subsequent samples.
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%-

%  check if the power field exists
if (~isfield(data.pings(1), 'power'))
    warning ('readEKRaw:ParameterError', ...
        'Power field does not exist in data structure. Unable to convert to Sp/sp.');
    return
end

rDouble = false;                %  default is to return data as single
rSource = false;                %  default is to not keep the power field
rLinear = false;                %  default is to return log data
tvgCorrectionFactor = 0.0;      %  default is to NOT apply TVG correction for Sp/sp

%  process optional parameters
for n = 1:2:length(varargin)
    switch lower(varargin{n})
        case 'keeppower'
            rSource = (0 < varargin{n + 1});
        case 'double'
            rDouble = (0 < varargin{n + 1});
        case 'tvgcorrection'
            if (0 < varargin{n + 1})
                tvgCorrectionFactor = 2.0;
            else
                tvgCorrectionFactor = 0.0;
            end
        case 'linear'
            rLinear = (0 < varargin{n + 1});
        otherwise
            warning('readEKRaw:ParameterError', ...
                ['Unknown property name: ' varargin{n}]);
    end
end

%  call convertPower with mode set to 3
data = readEKRaw_ConvertPower(data, calParms, 3, tvgCorrectionFactor, rLinear, ...
    rSource, rDouble);


