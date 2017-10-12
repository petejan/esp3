function sacorr=get_current_sacorr(trans_obj)
sacorrs=trans_obj.Config.SaCorrection;
pulse_lengths=trans_obj.Config.PulseLength;
pulse_length=trans_obj.get_pulse_length(1);
[~,idx_pulse]=nanmin(abs(pulse_lengths-pulse_length));
sacorr=sacorrs(idx_pulse);
end