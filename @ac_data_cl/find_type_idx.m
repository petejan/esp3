function [idx,found]=find_type_idx(data,type)

idx=find(strcmp(data.Type,type),1);
if isempty(idx)
    idx=1;
    found=0;
else
    found=1;
end
end