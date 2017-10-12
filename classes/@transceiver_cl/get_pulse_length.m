function [T,Np]=get_pulse_length(trans_obj,varargin)
%%%%%%TODO%%%%Make it so you can change pulse length while acquiring data
Np=double(round(trans_obj.Params.PulseLength./trans_obj.Params.SampleInterval));
T=double(trans_obj.Params.PulseLength);

if ~isempty(varargin)
    Np=Np(varargin{1});
    T=T(varargin{1});
end

end