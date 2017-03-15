function dist = get_dist(trans_obj,varargin)

dist=trans_obj.GPSDataPing.Dist;

if nargin>=2
    idx=varargin{1};
    dist=dist(idx);
end


end

