function [path_xml,reg_file_str,bot_file_str]=create_files_str(layer_obj)

p = inputParser;
addRequired(p,'layer_obj',@(obj) isa(obj,'layer_cl'));

parse(p,layer_obj);

reg_file_str=cell(1,length(layer_obj.Filename));
bot_file_str=cell(1,length(layer_obj.Filename));

for i=1:length(layer_obj.Filename)
    [path_xml,bot_file_str{i},reg_file_str{i}]=create_bot_reg_xml_fname(layer_obj.Filename{i});
end
    