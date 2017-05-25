
function IDs_out=add_region(trans_obj,regions,varargin)

p = inputParser;

addRequired(p,'trans_obj',@(trans_obj) isa(trans_obj,'transceiver_cl'));
addRequired(p,'regions',@(obj) isa(obj,'region_cl')||isempty(obj));
addParameter(p,'Tag','',@(x) ischar(x)||iscell(x));
addParameter(p,'IDs',[],@(x) isnumeric(x)||isempty(x));
addParameter(p,'Split',1,@(x) isnumeric(x)||islogical(x));
addParameter(p,'Origin','',@ischar);


parse(p,trans_obj,regions,varargin{:});

IDs=p.Results.IDs;
Tag=p.Results.Tag;
Origin=p.Results.Origin;
Split=p.Results.Split;
IDs_out=[];
for i=1:length(regions)
    trans_obj.rm_region_id(regions(i).Unique_ID);
    regions(i)=trans_obj.validate_region(regions(i));
    
    if numel(regions(i).Idx_pings)<2||numel(regions(i).Idx_r)<2
        continue;
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
    
    if ~isempty(IDs)&&length(IDs)==length(regions)
        regions(i).ID=IDs(i);
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

    if Split>0
        splitted_reg=regions(i).split_region(trans_obj.Data.FileId);
        trans_obj.Regions=[trans_obj.Regions splitted_reg];
        IDs_out=union(IDs_out,[splitted_reg(:).Unique_ID]);
    else
        trans_obj.Regions=[trans_obj.Regions regions(i)];
        IDs_out=union(IDs_out,regions(i).Unique_ID);
    end
end
end
