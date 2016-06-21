function datamat=get_subdatamat(data,idx_r,idx_ping,varargin)

p = inputParser;

addRequired(p,'data',@(x) isa(data,'ac_data_cl'));
addRequired(p,'idx_r',@isnumeric);
addRequired(p,'idx_ping',@isnumeric);
addParameter(p,'field','sv',@ischar);


parse(p,data,idx_r,idx_ping,varargin{:});

field=p.Results.field;

if isempty(idx_r)
    idx_r=data.get_samples();
end

if isempty(idx_ping)
    idx_ping=data.get_numbers();
end

[idx,found]=find_field_idx(data,(deblank(field)));

if found
    datamat=nan(length(idx_r),length(idx_ping));
    
    for icell=1:length(data.SubData(idx).Memap)
        idx_ping_cell=find(data.FileId==icell);
        [idx_ping_cell_red,idx_ping_temp,~]=intersect(idx_ping,idx_ping_cell);

        if ~isempty(idx_ping_temp)
            datamat(:,idx_ping_temp)=double(data.SubData(idx).Memap{icell}.Data.(lower(deblank(field)))(idx_r,idx_ping_cell_red-idx_ping_cell(1)+1));
        end
    end
else
    datamat=[];
end


end