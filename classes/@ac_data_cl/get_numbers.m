function numbers=get_numbers(ac_data_obj,varargin)

numbers=(1:ac_data_obj.Nb_pings);

if nargin>=2
    idx=varargin{1};
    idx(idx>length(numbers))=[];
    numbers=numbers(idx);
end
    

end