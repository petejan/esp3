function [path_lay,files_lay]=get_path_files(layer_obj)
[path_lay,files_lay,ext_lay]=cellfun(@fileparts,layer_obj.Filename,'UniformOutput',0);

for ic=1:length(files_lay)
    files_lay{ic}=deblank([files_lay{ic} ext_lay{ic}]);
end

end