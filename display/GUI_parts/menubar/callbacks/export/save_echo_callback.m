function save_echo_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end

[path_tmp,~,~]=fileparts(layer.Filename{1});
path_tmp = uigetdir(path_tmp,'Choose directory to save');

if isequal(path,0)
    return;
else
save_echo(main_figure,path_tmp);



end