
function layers=delete_layers(layers,ID_num)

if isempty(ID_num)
    idx=1:length(layers);
else
    idx=[];
    for id=1:length(ID_num)
    [idx_temp,found]=find_layer_idx(layers,ID_num(id));
    if found==0
        warning('Cannot find layer to be deleted');
        continue;
    end
    idx=[idx idx_temp];
    end
end

if isempty(idx)
    return;
end

for i=idx
    layers(i).rm_memaps();
end


layers(idx)=[];


end