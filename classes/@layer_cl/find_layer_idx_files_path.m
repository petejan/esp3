function [idx,found]=find_layer_idx_files_path(layers,pathtofile,files)

if iscell(pathtofile)
    pathtofile=pathtofile{1};
end


files_lay=cell(1,length(layers));
path_lay=cell(1,length(layers));

for i=1:length(layers)
    if isvalid(layers(i))
        [path_lay_temp,files_lay{i}]=layers(i).get_path_files();
        path_lay{i}=path_lay_temp{1};
    end
end

idx_path=find(cellfun(@(x) strcmp(x,pathtofile),path_lay));

if strcmp(pathtofile(end),'\')
    idx_path_2=find(cellfun(@(x) strcmp(x,pathtofile(1:end-1)),path_lay));
    idx_path=union(idx_path,idx_path_2);
end
idx_files=find(cellfun(@(x) nansum(strcmp(x,files)==0)==0,files_lay));

idx=intersect(idx_path,idx_files);

if isempty(idx)
    idx=1;
    found=0;
else
    found=1;
end

end