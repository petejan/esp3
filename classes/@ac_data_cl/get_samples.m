function samples=get_samples(ac_data_obj,varargin)

samples=(ac_data_obj.Samples(1):ac_data_obj.Samples(2))';

if nargin>=2
    idx=varargin{1};
    idx(idx>length(samples))=[];
    samples=samples(idx);
end
    

end