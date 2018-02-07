function lat = get_lat(trans_obj,varargin)

lat=trans_obj.GPSDataPing.Lat;

if nargin>=2
    idx=varargin{1};
    lat=lat(idx);
end


end