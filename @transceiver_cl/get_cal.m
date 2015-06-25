
function cal=get_cal(Transceiver)

if strcmp(Transceiver.Mode,'CW')
    Np=Transceiver.Params.PulseLength(1);
    [~,idx_params]=nanmin(abs(Np-Transceiver.Config.PulseLength));
    gain=Transceiver.Config.Gain(idx_params);
    Sa_corr=Transceiver.Config.SaCorrection(idx_params);
    cal=struct('Gain',gain,'SaCorr',Sa_corr);
else
    
end
end