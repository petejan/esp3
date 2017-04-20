function numbers=get_numbers(ac_data_obj,varargin)

time=ac_data_obj.Time;
 
numbers=(1:length(time));

if nargin>=2
    idx=varargin{1};
    idx(idx>length(numbers))=[];
    numbers=numbers(idx);
end
    

end