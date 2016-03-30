function folders=folders_list_copy(path)


folders{1}=fullfile(path, 'icons');


folders(cellfun(@isempty, folders))=[];

end