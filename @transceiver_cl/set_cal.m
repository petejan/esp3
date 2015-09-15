
function set_cal(Transceiver,cal)

if strcmp(Transceiver.Mode,'CW')
    Np=Transceiver.Params.PulseLength(1);
    [~,idx_params]=nanmin(abs(Np-Transceiver.Config.PulseLength));
    Transceiver.Config.Gain(idx_params)=cal.G0;
    Transceiver.Config.SaCorrection(idx_params)=cal.SACORRECT;
else
    
end
end