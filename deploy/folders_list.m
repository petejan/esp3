function folders=folders_list(path)


folders{1}=fullfile(path,'external_toolboxes');
folders{2}=fullfile(path, 'processing');
folders{3}=fullfile(path, 'classes');
folders{4}=fullfile(path, 'algos');
folders{5}=fullfile(path, 'display');
folders{7}=fullfile(path, 'fileIO');
folders{8}=fullfile(path, 'mapping');



folders(cellfun(@isempty, folders))=[];

end