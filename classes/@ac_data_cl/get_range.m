function range=get_range(ac_data_obj,varargin)

samples=ac_data_obj.get_samples();
dR=(ac_data_obj.Range(2)-ac_data_obj.Range(1))/length(samples);

range=(samples-1)*dR;

if nargin>=2
    idx=varargin{1};
    if ~isnan(idx)
        idx(idx>length(range))=[];
        range=range(idx);
    else
        range=0;
    end
end

end