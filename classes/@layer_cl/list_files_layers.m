function [filenames,layer_IDs]=list_files_layers(layers)

filenames={};
layer_IDs=[];
for il=1:length(layers)
    filenames=[filenames layers(il).Filenames];
    layer_IDs=[layer_IDs repmat(layers(il).UniqueID,1,length(layers(il).Filenames))];
end


end