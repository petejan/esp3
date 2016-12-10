function gain=get_current_gain(trans_obj)

gains=trans_obj.Config.Gain;
pulse_lengths=trans_obj.Config.PulseLength;
pulse_length=trans_obj.get_pulse_length;
[~,idx_pulse]=nanmin(abs(pulse_lengths-pulse_length));
gain=gains(idx_pulse);

end