function [T,Np]=get_pulse_length(Trans_obj)
%%%%%%TODO%%%%Make it so you can change pulse length while acquiring data
Np=double(round(Trans_obj.Params.PulseLength(1)./Trans_obj.Params.SampleInterval(1)));
T=double(Trans_obj.Params.PulseLength(1));
% Np=double(round(Trans_obj.Params.PulseLength./Trans_obj.Params.SampleInterval));
% T=double(Trans_obj.Params.PulseLength);
end