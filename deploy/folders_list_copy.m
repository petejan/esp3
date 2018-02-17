function folders=folders_list_copy(path)


folders{1}=fullfile(path, 'icons');
folders{2}=fullfile(path, 'private');
folders{3}=fullfile(path, 'config');
folders{3}=fullfile(path, 'java');
folders{4}=fullfile(path, 'example_data');
folders{5}=fullfile(path, 'html');
folders(cellfun(@isempty, folders))=[];

end