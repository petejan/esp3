function [path_xml,line_file_str]=create_files_line_str(layer_obj)

p = inputParser;
addRequired(p,'layer_obj',@(obj) isa(obj,'layer_cl'));

parse(p,layer_obj);

path_xml=cell(1,length(layer_obj.Filename));
line_file_str=cell(1,length(layer_obj.Filename));

for i=1:length(layer_obj.Filename)
    [path_xml{i},line_file_str{i}]=create_line_xml_fname(layer_obj.Filename{i});
end
    