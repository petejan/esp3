function [t_0,t_1]=get_time_bounds(layer_obj)

p = inputParser;
addRequired(p,'layer_obj',@(obj) isa(obj,'layer_cl'));

parse(p,layer_obj);

t_0=nan;
t_1=nan;

for i=1:length(layer_obj.Frequencies)
    t_0=nanmin([t_0 layer_obj.Transceivers(i).Time]);
    t_1=nanmax([t_1 layer_obj.Transceivers(i).Time]);
end

end