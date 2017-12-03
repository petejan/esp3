
function IDs_out=add_region(trans_obj,regions,varargin)

p = inputParser;

addRequired(p,'trans_obj',@(trans_obj) isa(trans_obj,'transceiver_cl'));
addRequired(p,'regions',@(obj) isa(obj,'region_cl')||isempty(obj));
addParameter(p,'Tag','',@(x) ischar(x)||iscell(x));
addParameter(p,'IDs',[],@(x) isnumeric(x)||isempty(x));
addParameter(p,'Split',0,@(x) isnumeric(x)||islogical(x));
addParameter(p,'Merge',1,@(x) isnumeric(x)||islogical(x));
addParameter(p,'Origin','',@ischar);
addParameter(p,'Ping_offset',0,@isnumeric);


parse(p,trans_obj,regions,varargin{:});

IDs=p.Results.IDs;
Tag=p.Results.Tag;
Origin=p.Results.Origin;
Split=p.Results.Split;
Ping_offset=p.Results.Ping_offset;
IDs_out={};

for i=1:length(regions)
    regions(i).Idx_pings=regions(i).Idx_pings-Ping_offset;
    if ~isempty(regions(i).Poly)
        regions(i).Poly.Vertices(:,1)=regions(i).Poly.Vertices(:,1)-Ping_offset;
    end

    regions(i)=trans_obj.validate_region(regions(i));

       
    if numel(regions(i).Idx_pings)<2||numel(regions(i).Idx_r)<2
        continue;
    end

    regs_id=trans_obj.get_region_from_Unique_ID(regions(i).Unique_ID);
    
    if isempty(regs_id)||p.Results.Merge==0
        reg_curr=regions(i);
    else
        reg_tmp=[regions(i) regs_id];
                reg_curr=reg_tmp.concatenate_regions();
    end

    reg_curr.Unique_ID=regions(i).Unique_ID;
    trans_obj.rm_region_id(regions(i).Unique_ID);

    if ~strcmpi(Tag,'')
        if ~iscell(Tag)
            reg_curr.Tag=Tag;
        else
            if length(Tag)>=i
                reg_curr.Tag=Tag{i};
            else
                reg_curr.Tag=Tag{length(Tag)};
            end
        end 
    end
    
    if ~isempty(IDs)&&length(IDs)==length(regions)
        reg_curr.ID=IDs(i);
    end
    
    if ~strcmpi(Origin,'')
        if ~iscell(Origin)
            reg_curr.Origin=Origin;
        else
            if length(Origin)>=i
                reg_curr.Origin=Origin{i};
            else
                reg_curr.Origin=Origin{length(Origin)};
            end
        end
    end
    %Split=1
    if Split>0
        splitted_reg=reg_curr.split_region(trans_obj.Data.FileId,0);
        trans_obj.Regions=[trans_obj.Regions splitted_reg];
        IDs_out=union(IDs_out,{splitted_reg(:).Unique_ID});
    else
        trans_obj.Regions=[trans_obj.Regions reg_curr];
        IDs_out=union(IDs_out,reg_curr.Unique_ID);
    end
end
end
