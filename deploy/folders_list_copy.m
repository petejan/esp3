function folders=folders_list_copy(path)


folders{1}=fullfile(path, 'icons');
folders{2}=fullfile(path, 'private');

folders(cellfun(@isempty, folders))=[];

end