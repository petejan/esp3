
function add_region(obj,regions,varargin)


p = inputParser;

addRequired(p,'obj',@(obj) isa(obj,'transceiver_cl'));
addRequired(p,'regions',@(obj) isa(obj,'region_cl')||isempty(obj));
addParameter(p,'Tag','',@(x) ischar(x)||iscell(x));
addParameter(p,'Origin','',@ischar);

parse(p,obj,regions,varargin{:});

Tag=p.Results.Tag;
Origin=p.Results.Origin;

for i=1:length(regions)
    obj.rm_region_id(regions(i).Unique_ID);
    regions(i).integrate_region(obj);
    regions(i).Unique_ID=regions(i).Unique_ID;
    regions(i).ID=regions(i).ID;
    if ~strcmpi(Tag,'')
        if ~iscell(Tag)
            regions(i).Tag=Tag;
        else
            if length(Tag)>=i
                regions(i).Tag=Tag{i};
            else
                regions(i).Tag=Tag{length(Tag)};
            end
        end 
    end
    
    if ~strcmpi(Origin,'')
        if ~iscell(Origin)
            regions(i).Origin=Origin;
        else
            if length(Origin)>=i
                regions(i).Origin=Origin{i};
            else
                regions(i).Origin=Origin{length(Origin)};
            end
        end
    end

    obj.Regions=[obj.Regions regions(i)];
end
end