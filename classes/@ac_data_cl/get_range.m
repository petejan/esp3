function range=get_range(ac_data_obj,varargin)

range=ac_data_obj.Range;

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