
function cal=get_cal(Transceiver)
if strcmp(Transceiver.Mode,'CW')
    Np=Transceiver.Params.PulseLength(1);
    [~,idx_params]=nanmin(abs(Np-Transceiver.Config.PulseLength));
    G0=Transceiver.Config.Gain(idx_params);
    SACORRECT=Transceiver.Config.SaCorrection(idx_params);
    cal=struct('G0',G0,'SACORRECT',SACORRECT);   
else
   cal=[]; 
end
end