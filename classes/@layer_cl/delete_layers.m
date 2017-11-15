
function layers=delete_layers(layers,Unique_ID)

if~iscell(Unique_ID)
   Unique_ID={Unique_ID}; 
end

if isempty(Unique_ID)
    idx=1:length(layers);
else
    idx=[];
    for id=1:length(Unique_ID)
    [idx_temp,found]=find_layer_idx(layers,Unique_ID{id});
    if found==0
        warning('Cannot find layer to be deleted');
        continue;
    end
    idx=union(idx,idx_temp);
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