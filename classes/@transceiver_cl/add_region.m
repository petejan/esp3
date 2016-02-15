
function add_region(trans_obj,regions,varargin)


p = inputParser;

addRequired(p,'trans_obj',@(trans_obj) isa(trans_obj,'transceiver_cl'));
addRequired(p,'regions',@(obj) isa(obj,'region_cl')||isempty(obj));
addParameter(p,'Tag','',@(x) ischar(x)||iscell(x));
addParameter(p,'Origin','',@ischar);
addParameter(p,'ID',[],@isnumeric);

parse(p,trans_obj,regions,varargin{:});

Tag=p.Results.Tag;
Origin=p.Results.Origin;

for i=1:length(regions)
    trans_obj.rm_region_id(regions(i).Unique_ID);
    regions(i).Unique_ID=regions(i).Unique_ID;
    if isempty(p.Results.ID)
        regions(i).ID=trans_obj.new_id();
    else
       regions(i).ID=p.Results.ID;
    end
        
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

    trans_obj.Regions=[trans_obj.Regions regions(i)];
end
end
