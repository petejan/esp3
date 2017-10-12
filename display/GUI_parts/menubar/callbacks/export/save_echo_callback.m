function save_echo_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end

[path_tmp,~,~]=fileparts(layer.Filename{1});
layers_Str=list_layers(layer,'nb_char',80);

[fileN, path_tmp] = uiputfile('*.png',...
    'Save echogram',...
    fullfile(path_tmp,[layers_Str{1} '.png']));

if isequal(path_tmp,0)
    return;
else
save_echo(main_figure,path_tmp,fileN);



end