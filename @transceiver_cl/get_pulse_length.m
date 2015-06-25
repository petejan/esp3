function [T,Np]=get_pulse_length(Trans_obj)

Np=round(Trans_obj.Params.PulseLength(1)/Trans_obj.Params.SampleInterval(1));
T=Np*(Trans_obj.Params.SampleInterval(1));

end