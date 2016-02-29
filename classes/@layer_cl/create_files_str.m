function [path_xml,reg_file_str,bot_file_str]=create_files_str(layer_obj)

p = inputParser;
addRequired(p,'layer_obj',@(obj) isa(obj,'layer_cl'));

parse(p,layer_obj);

%[t_0,t_1]=layer_obj.get_time_bounds();
% 
% date_fmt='yyyymmddHHMMSS';
% str=[datestr(t_0,date_fmt) '_' datestr(t_1,date_fmt)];
% 
[path_xml,~,~]=fileparts(layer_obj.Filename{1});
path_xml=fullfile(path_xml,'bot_reg');
% reg_file_str=['r_' str '.xml'];
% bot_file_str=['b_' str '.xml'];
reg_file_str=cell(1,length(layer_obj.Filename));
bot_file_str=cell(1,length(layer_obj.Filename));

for i=1:length(layer_obj.Filename)
    [~,fileTemp,~]=fileparts(layer_obj.Filename{i});
    reg_file_str{i}=['r_' fileTemp '.xml'];
    bot_file_str{i}=['b_' fileTemp '.xml'];
end
