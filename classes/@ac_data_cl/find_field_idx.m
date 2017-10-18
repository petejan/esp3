function [idx,found]=find_field_idx(data,field)

idx=find(strcmp(data.Fieldname,lower(deblank(field))),1);

if isempty(idx)
    idx=1;
    found=0;
else
    found=1;
end

end