function data = readEKRaw_ConvertPower(data, calParms, mode, tvgCFac, ...
        rLinear, rSource, rDouble)
%readEKRaw_ConvertPower  Convert raw power to Sv or Sp and back
%   data = readEKRaw_ConvertPower(data, calParms, mode, args) converts power
%   data contained in the readEKRaw data structure to Sp or TS based on the mode
%   argument.
%
%   REQUIRED INPUT:
%                data:   The "data" structure output from readEKRaw
%            calParms:   The calibration parameters data structure
%                mode:   1 pow->Sv, 2 Sv->pow, 3 pow->Sp, 4 Sp->pow
%             tvgCFac:   The TVG range correction factor
%             rLinear:   Set to true to return data in linear units
%             rSource:   Set to true to *not* delete the conversion source field.
%             rDouble:   Return double precision values
%
%   OPTIONAL PARAMETERS:  None.
%       
%   OUTPUT:
%       Output is a modified version of the input data structure where the power
%       field has been changed to Sv/sv, or Sp/sp. If converting to power
%       the Sv/sv/Sp/sp field is changed to power.
%
%   REQUIRES:   None
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%-

%  supporess log of zero error - store previous state
warnState = warning('off', 'MATLAB:log:logOfZero');
warning('off', 'MATLAB:divideByZero');


%  determine the number of transceivers
nXcvrs = size(data.pings,2);

%  loop thru transceiver data
for n=1:nXcvrs

    %  extract calibration parameters for this xcvr
    f = double(calParms(n).frequency);
    c = double(calParms(n).soundvelocity);
    t = double(calParms(n).sampleinterval);
    alpha = double(calParms(n).absorptioncoefficient);
    G = double(calParms(n).gain);
    phi = double(calParms(n).equivalentbeamangle);
    pt = double(calParms(n).transmitpower);
    tau = double(calParms(n).pulselength);

    %  calculate sample thickness
    dR = c * t / 2;

    %  calculate wavelength
    lambda =  c / f;

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
    % Changed the assignment of pSize due to a strange bug in matlab where
    % pSize(2) came back as 65535 when data.pings(n).time > 65535
    %  pSize = [data.pings(n).samplerange(2)length(data.pings(n).time)];
    pSize(2) = length(data.pings(n).time);
    pSize(1) = data.pings(n).samplerange(2);


    %  create range vector (in m)
    data.pings(n).range = double((0:pSize(1) - 1) + ...
        double(data.pings(n).samplerange(1)) - 1)' * dR;

    %  apply TVG Range correction - 
    rangeCorrected = data.pings(n).range - (tvgCFac * dR);
    rangeCorrected(rangeCorrected < 0) = 0;
    
    if (mode <= 2)
        %  calculate Sv TVG vector - ignore imag components of TVG
        TVG = real(20 * log10(rangeCorrected));
        TVG(TVG < 0) = 0;
        
        %  calculate gains for Sv/sv output
        CSv = 10 * log10((pt * (10^(G/10))^2 * lambda^2 * ...
                c * tau * 10^(phi/10)) /  (32 * pi^2));

        if (rLinear)
            if (mode == 1)
                %  calculate sv from power
                data.pings(n).sv = 10.^((double(data.pings(n).power) + ...
                    repmat(TVG, 1, pSize(2)) + (2 * alpha * ...
                    repmat(rangeCorrected, 1, pSize(2))) - CSv - Sac) / 10);
                if ~rDouble; data.pings(n).sv = single(data.pings(n).sv); end;
            else
                %  calculate power from sv
                data.pings(n).power = (10. * log10(data.pings(n).sv)) - ...
                    repmat(TVG, 1, pSize(2)) - (2 * alpha * ...
                    repmat(rangeCorrected, 1, pSize(2))) + CSv + Sac;
            end
        else
            if (mode == 1)
                %  calculate Sv
                data.pings(n).Sv = double(data.pings(n).power) + ...
                    repmat(TVG, 1, pSize(2)) + (2 * alpha * ...
                    repmat(rangeCorrected, 1, pSize(2))) - CSv - Sac;
                if ~rDouble; data.pings(n).Sv = single(data.pings(n).Sv); end;
            else
                %  calculate power from Sv
                data.pings(n).power = data.pings(n).Sv - ...
                    repmat(TVG, 1, pSize(2)) - (2 * alpha * ...
                    repmat(rangeCorrected, 1, pSize(2))) + CSv + Sac;
            end
        end
    end
    
    if (mode >= 3)
    	%  calculate TS TVG vector - ignore imag components of TVG
        TVG = real(40 * log10(rangeCorrected));
        TVG(TVG < 0) = 0;
        
        %  calculate gains for Sp/sp output
        CSp = 10 * log10((pt * (10^(G/10))^2 * lambda^2) / (16 * pi^2));
        
        if (rLinear)
            if (mode == 3)
                %  calculate sp from power
                data.pings(n).sp = 10.^((double(data.pings(n).power) + ...
                    repmat(TVG, 1, pSize(2)) +  (2 * alpha * ...
                    repmat(rangeCorrected, 1, pSize(2))) - CSp) / 10);
                if ~rDouble; data.pings(n).sp = single(data.pings(n).sp); end;
            else
                %  calculate power from sp
                data.pings(n).power = (10. * log10(data.pings(n).sp)) - ...
                    repmat(TVG, 1, pSize(2)) -  (2 * alpha * ...
                    repmat(rangeCorrected, 1, pSize(2))) + CSp;
            end
        else
            if (mode == 3)
                %  calculate Sp from power
                data.pings(n).Sp = double(data.pings(n).power) + ...
                    repmat(TVG, 1, pSize(2)) +  (2 * alpha * ...
                    repmat(rangeCorrected, 1, pSize(2))) - CSp;
                if ~rDouble; data.pings(n).Sp = single(data.pings(n).Sp); end;
            else
                %  calculate power from Sp
                data.pings(n).power = data.pings(n).Sp - ...
                    repmat(TVG, 1, pSize(2)) -  (2 * alpha * ...
                    repmat(rangeCorrected, 1, pSize(2))) + CSp;
            end
        end
    end
end

%  remove source field (if applicable)
if (~rSource)
    switch true
        case (mode == 1) || (mode == 3)
            data.pings = rmfield(data.pings, 'power');
        case (mode == 2)
            if rLinear
                data.pings = rmfield(data.pings, 'sv');
            else
                data.pings = rmfield(data.pings, 'Sv');
            end
        case (mode == 4)
            if rLinear
                data.pings = rmfield(data.pings, 'sp');
            else
                data.pings = rmfield(data.pings, 'Sp');
            end
    end
end

%  restore warning state
warning(warnState);