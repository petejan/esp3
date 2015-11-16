function folders=folders_list(path)

folders{1}=fullfile(path,'external_toolboxes');
folders{2}=fullfile(path, 'acoustic');
folders{3}=fullfile(path, 'classes');
folders{4}=fullfile(path, 'algos');
folders{5}=fullfile(path, 'GUI_parts');
folders{6}=fullfile(path, 'esp2');
folders{7}=fullfile(path, 'export');
folders{8}=fullfile(path, 'fileIO');
folders{9}=fullfile(path, 'icons');
folders{10}=fullfile(path, 'general');
folders{11}=fullfile(path, 'mapping');
folders{12}=fullfile(path, 'signal_processing');

end