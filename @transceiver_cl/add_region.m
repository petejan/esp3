
function add_region(obj,regions,varargin)


p = inputParser;

addRequired(p,'obj',@(obj) isa(obj,'transceiver_cl'));
addRequired(p,'regions',@(obj) isa(obj,'region_cl')||isempty(obj));
addParameter(p,'Tag','',@ischar);
addParameter(p,'Origin','',@ischar);

parse(p,obj,regions,varargin{:});

Tag=p.Results.Tag;
Origin=p.Results.Origin;

for i=1:length(regions)
    obj.rm_region_id(regions(i).Unique_ID);
    regions(i).integrate_region(obj);
    regions(i).Unique_ID=obj.new_unique_id();
    regions(i).ID=regions(i).ID;
    regions(i).Tag=Tag;
    regions(i).Origin=Origin;
    obj.Regions=[obj.Regions regions(i)];
end
end
