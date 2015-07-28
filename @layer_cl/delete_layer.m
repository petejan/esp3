
function layers=delete_layer(layers,ID_num)

[idx,found]=find_layer_idx(layers,ID_num);
if found==0
    warning('Cannot find layer to be deleted');
    return;
end

for kk=1:length(layers(idx).Transceivers)
    for uu=1:length(layers(idx).Transceivers(kk).Data.SubData)       
        if isa(layers(idx).Transceivers(kk).Data.SubData(uu).Memap,'memmapfile')
            if exist(layers(idx).Transceivers(kk).Data.SubData(uu).Memap.Filename,'file')>0
                layers(idx).Transceivers(kk).Data.SubData(uu).Memap.Writable=false;
                %clear layers(idx).Transceivers(kk).Data.SubData(uu).Memap.Data
                delete(layers(idx).Transceivers(kk).Data.SubData(uu).Memap.Filename);
            end
        end
    end
end

layers(idx)=[];


end