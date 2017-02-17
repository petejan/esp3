function [path_to_files,line_file]=create_line_xml_fname(data_filename)
[path_to_files,~,~]=fileparts(data_filename);
path_to_files=fullfile(path_to_files,'lines');
[~,fileTemp,~]=fileparts(data_filename);
line_file=['l_' fileTemp '.xml'];
end