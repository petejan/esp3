
function layers=delete_layers(layers,ID_num)

if isempty(ID_num)
    idx=1:length(layers);
else
    [idx,found]=find_layer_idx(layers,ID_num);
    if found==0
        warning('Cannot find layer to be deleted');
        return;
    end
end

for i=idx
    layers(idx(i)).delete();
end


layers(idx)=[];


end