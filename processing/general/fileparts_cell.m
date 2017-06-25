function [path_cell,filename_cell]=fileparts_cell(files_cell)

[path_cell,filename_cell_tmp,ext_cell]=cellfun(@fileparts,files_cell,'UniformOutput',0);

filename_cell=cellfun(@(x,y) [x y],filename_cell_tmp,ext_cell,'UniformOutput',0);

end