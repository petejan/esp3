function setBottom_from_evl(trans_obj,filename)

p = inputParser;

addRequired(p,'trans_obj',@(x) isa(x,'transceiver_cl'));
addRequired(p,'filename',@(x) ischar(x));

parse(p,trans_obj,filename);


timevec=trans_obj.Time;
range=trans_obj.get_transceiver_range();

obj=create_bottom_from_evl(filename,range,timevec);

trans_obj.Bottom=obj;

end