function [filenames,layer_IDs]=list_files_layers(layers)

filenames={};
layer_IDs=[];
for il=1:length(layers)
    filenames=[filenames layers(il).Filename];
    layer_IDs=[layer_IDs repmat(layers(il).ID_num,1,length(layers(il).Filename))];
end


end