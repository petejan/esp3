function [idx_lays,found]=find_layer_idx_files_path(layers,filenames)

if~iscell(filenames)
    filenames={filenames};
end

[filenames_lays,layer_IDs]=layers.list_files_layers();

idx_lays=[];
for ifi=1:length(filenames)
    idx_f=find(strcmpi(filenames{ifi},filenames_lays));
    if isempty(idx_f)
        continue;
    end
    id_lays=unique(layer_IDs(idx_f));
    for i=1:length(id_lays)
        [idx_tmp,found_id]=layers.find_layer_idx(id_lays(i));
        if found_id==1
            idx_lays=[idx_tmp idx_lays];
        end
    end
    
end

idx_lays=unique(idx_lays);

if isempty(idx_lays)
    idx_lays=1;
    found=0;
else
    found=1;
end

end