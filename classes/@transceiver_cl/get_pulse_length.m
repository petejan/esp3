function [T,Np]=get_pulse_length(Trans_obj)

Np=double(round(Trans_obj.Params.PulseLength(1)/Trans_obj.Params.SampleInterval(1)));
T=double(Np*(Trans_obj.Params.SampleInterval(1)));

end