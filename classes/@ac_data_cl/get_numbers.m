function numbers=get_numbers(ac_data_obj,varargin)

numbers=ac_data_obj.Number(1):ac_data_obj.Number(2);

if nargin>=2
    idx=varargin{1};
    idx(idx>length(numbers))=[];
    numbers=numbers(idx);
end
    

end