function samples=get_samples(ac_data_obj,varargin)

range=get_range(ac_data_obj);
 
samples=(1:length(range))';

if nargin>=2
    idx=varargin{1};
    idx(idx>length(samples))=[];
    samples=samples(idx);
end
    

end