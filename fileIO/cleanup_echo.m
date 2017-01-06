function cleanup_echo(main_figure)
hfigs=getappdata(main_figure,'ExternalFigures');
delete(hfigs);
close_figures_callback([],[],main_figure);

layers=getappdata(main_figure,'Layers');

i=length(layers);
while i>=1
    try
        layers=layers.delete_layers(layers(i).ID_num);
    catch
        fprintf('Could not clean files from %s\n',list_layers(layers(i),'nb_char',80));
    end
    
    i=i-1;
end


appdata = get(main_figure,'ApplicationData');
fns = fieldnames(appdata);
for ii = 1:numel(fns)
    rmappdata(main_figure,fns{ii});
end


delete(main_figure);