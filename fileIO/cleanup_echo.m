function cleanup_echo(main_figure)
hfigs=getappdata(main_figure,'ExternalFigures');
delete(hfigs);
close_figures_callback([],[],main_figure);

layers=getappdata(main_figure,'Layers');

try
    i=length(layers);
    while i>=1
        str_cell=list_layers(layers(i),'nb_char',80);
        try
            
            fprintf('Deleting temp files from %s\n',str_cell{1});
            layers=layers.delete_layers(layers(i).ID_num);
        catch
            fprintf('Could not clean files from %s\n',str_cell{1});
        end
        
        i=i-1;
    end
    
    dndobj=getappdata(main_figure,'Dndobj');
    delete(dndobj);
    
    appdata = get(main_figure,'ApplicationData');
    fns = fieldnames(appdata);
    for ii = 1:numel(fns)
        rmappdata(main_figure,fns{ii});
    end
catch
    
end

% dnd_control=findobj(main_figure,'class','dndcontrol');
%
% delete(dnd_control);

delete(main_figure);