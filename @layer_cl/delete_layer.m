
function layers=delete_layer(layers,ID_num)

[idx,found]=find_layer_idx(layers,ID_num);
if found==0
    warning('Cannot find layer to be deleted');
    return;
end

for kk=1:length(layers(idx).Transceivers)
    if exist(layers(idx).Transceivers(kk).MatfileName,'file')>0
        delete(layers(idx).Transceivers(kk).MatfileName);
    end
end

layers(idx)=[];


end