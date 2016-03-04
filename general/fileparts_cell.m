function [path_cell,filename_cell]=fileparts_cell(files_cell)

path_cell=cell(1,length(files_cell));
filename_cell=cell(1,length(files_cell));


for il=1:length(files_cell)
    [path_cell{il},tmp_1,tmp_2]=fileparts(files_cell{il});
    filename_cell{il}=[tmp_1 tmp_2];
end


end