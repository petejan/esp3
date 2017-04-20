function samples=get_samples(ac_data_obj,varargin)

samples=(1:ac_data_obj.Nb_samples)';

if nargin>=2
    idx=varargin{1};
    idx(idx>length(samples))=[];
    samples=samples(idx);
end
    

end