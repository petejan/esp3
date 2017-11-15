function [idx,found]=find_layer_idx(layers,ID)

layer_id={layers(:).Unique_ID};

idx=find(strcmpi(layer_id,ID),1);
if isempty(idx)
    idx=1;
    found=0;
else
    found=1;
end

end
