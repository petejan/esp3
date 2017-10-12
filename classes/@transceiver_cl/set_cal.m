
function set_cal(trans_obj,cal)

if strcmp(trans_obj.Mode,'CW')
   [pulse_length,~]=trans_obj.get_pulse_length(1);
    
    
    [~,idx_params]=nanmin(abs(pulse_length-trans_obj.Config.PulseLength));
    trans_obj.Config.Gain(idx_params)=cal.G0;
    
    trans_obj.Config.SaCorrection(idx_params)=cal.SACORRECT;
else
    
end
end