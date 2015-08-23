dfunction data = readEKRaw_ConvertPower(data, calParms, mode, args)
%readEKRaw_ConvertPower  Convert raw power to Sv and/or TS
%   data = readEKRaw_ConvertPower(data, calParms, mode, args) converts power
%   data contained in the readEKRaw data structure to Sp or TS based on the mode
%   argument.
%   
%   This function is usually called thru one of the wrapper functions
%   readEKRaw_Power2Sv or readEKRaw_Power2Sp but in special cases where both Sv
%   and Sp data are required it can be called directly.  When calling directly
%   the optional parameters must be passed as a cell array thru the "args"
%   parameter.  See MATLAB help on varargin for details.
%
%   REQUIRED INPUT:
%                data:   The "data" structure output from readEKRaw
%            calParms:   The calibration parameters data structure
%                mode:   Set to 1 to return Sv, 2 to return TS, 3 - both
%                args:   Cell array containing optional parameter names and
%                        values.
%
%   OPTIONAL PARAMETERS:
%           KeepPower:   By default, the power field is replaced by the Sv field.
%                        Set this value to true to keep the power field.
%                            Default: false
%
%              Linear:   Set this parameter to true to return data in linear
%                        units (sv or sp).
%                            Default: false
%
% tvgCorrectionFactor:   Set this parameter to true to apply TVG correction. Set 
%                        it to false to not apply TVG correction.
%                            Default: true
%       
%   OUTPUT:
%       Output is a modified version of the input data structure where the power
%       field has been changed to Sv, Sp, or both.
%
%   REQUIRES:   None
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%-

%  check if the power field exists
if (~isfield(data.pings(1), 'power'))
    warning ('readEKRaw:ParameterError', ...
        'Power field does not exist in data structure.');
    return
end

%  supporess log of zero error - store previous state
warnState = warning('off', 'MATLAB:log:logOfZero');
warning('off', 'MATLAB:divideByZero');

%  set defaults
tvgCorrectionFactor = 2.0;          %  default is to apply TVG correction with offset of 2
rPower = false;                     %  default is to delete power from struct
rLinear = false;                    %  default is to return Sp or Sv

%  process optional parameters
for n = 1:2:length(args)
    switch lower(args{n})
        case 'keeppower'
            rPower = (0 < args{n + 1});
        case 'tvgcorrection'
            if (0 < args{n + 1})
                tvgCorrectionFactor = 2.0;
            else
                tvgCorrectionFactor = 0.0;
            end
        case 'linear'
            rLinear = (0 < args{n + 1});
        otherwise
            warning('readEKRaw:ParameterError', ...
                ['Unknown property name: ' args{n}]);
    end
end

%  set output type based on mode value
switch mode
    case 1
        rSv = true;
        rSp = false;
    case 2
        rSv = false;
        rSp = true;
    case 3
        rSv = true;
        rSp = true;
    otherwise
        error('Unknown mode');
end

%  determine the number of transceivers
nXcvrs = size(data.pings,2);

%  loop thru transceiver data
for n=1:nXcvrs

    %  extract calibration parameters for this xcvr
    f = calParms(n).frequency;
    c = calParms(n).soundvelocity;
    t = calParms(n).sampleinterval;
    alpha = calParms(n).absorptioncoefficient;
    G = calParms(n).gain;
    phi = calParms(n).equivalentbeamangle;
    pt = calParms(n).transmitpower;
    tau = calParms(n).pulselength;

    %  calculate sample thickness
    dR = c * t / 2;

    %  calculate wavelength
    lambda =  c / f;

    %  calculate gains
    if (rSv); CSv = 10 * log10((pt * (10^(G/10))^2 * lambda^2 * ...
            c * tau * 10^(phi/10)) /  (32 * pi^2)); end
    if (rSp); CSp = 10 * log10((pt * (10^(G/10))^2 * lambda^2) / ...
            (16 * pi^2)); end

    %  calculate Sa Correction
    idx = find(calParms(n).pulselengthtable == tau);
    if (~isempty(idx))
        Sac = 2 * calParms(n).sacorrectiontable(idx);
    else
        warning('readEKRaw:ParameterError', ...
            'Sa correction table empty - Sa correction not applied.');
        Sac = 0;
    end

    %  determine number of samples in array
    pSize = size(data.pings(n).power);
    
    %  create range vector (in m)
    data.pings(n).range = double((0:pSize(1) - 1) + ...
        double(data.pings(n).samplerange(1)) - 1)' * dR;

    %  apply TVG Range correction - 
    rangeCorrected = data.pings(n).range - (tvgCorrectionFactor * dR);
    rangeCorrected(rangeCorrected < 0) = 0;
    
    if (rSv)
        %  calculate Sv TVG vector - ignore imag components of TVG
        TVG = real(20 * log10(rangeCorrected));
        TVG(TVG < 0) = 0;

        if (rLinear)
            %  calculate sv
            data.pings(n).sv = 10.^((data.pings(n).power + ...
                repmat(TVG, 1, pSize(2)) + (2 * alpha * ...
                repmat(rangeCorrected, 1, pSize(2))) - CSv - Sac) / 10);
            
        else
            %  calculate Sv
            data.pings(n).Sv = data.pings(n).power + ...
                repmat(TVG, 1, pSize(2)) + (2 * alpha * ...
                repmat(rangeCorrected, 1, pSize(2))) - CSv - Sac;
        end
    end
    
    if (rSp)
    	%  calculate TS TVG vector - ignore imag components of TVG
        TVG = real(40 * log10(rangeCorrected));
        TVG(TVG < 0) = 0;
        
        if (rLinear)
            %  calculate sp
            data.pings(n).sp = 10.^((data.pings(n).power + ...
                repmat(TVG, 1, pSize(2)) +  (2 * alpha * ...
                repmat(rangeCorrected, 1, pSize(2))) - CSp) / 10);
        else
            %  calculate Sp
            data.pings(n).Sp = data.pings(n).power + ...
                repmat(TVG, 1, pSize(2)) +  (2 * alpha * ...
                repmat(rangeCorrected, 1, pSize(2))) - CSp;
        end
    end
end

%  remove power field
if (rPower == 0); data.pings = rmfield(data.pings, 'power'); end

%  restore warning state
warning(warnState);

