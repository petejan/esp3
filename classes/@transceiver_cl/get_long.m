function long = get_long(trans_obj,varargin)

long=trans_obj.GPSDataPing.Long;

if nargin>=2
    idx=varargin{1};
    long=long(idx);
end


end