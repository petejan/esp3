function [path_xml,reg_file_str,bot_file_str,i_file_str]=create_files_str(layer_obj)

p = inputParser;
addRequired(p,'layer_obj',@(obj) isa(obj,'layer_cl'));

parse(p,layer_obj);

[t_0,t_1]=layer_obj.get_time_bounds();

date_fmt='yyyymmddHHMMSS';
str=[datestr(t_0,date_fmt) '_' datestr(t_1,date_fmt)];

path_xml=fullfile(layer_obj.PathToFile,'bot_reg');
reg_file_str=['r_' str '.xml'];
bot_file_str=['b_' str '.xml'];
i_file_str=['i_' str '.xml'];