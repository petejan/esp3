
function change_layer_callback(~,~,main_figure,id)
layers=getappdata(main_figure,'Layers');
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

[idx,~]=find_layer_idx(layers,layer.ID_num);

switch id
    case 'next'
        if idx<length(layers)
            layer=layers(idx+1);
        else
            return;
        end
    case 'prev'
        if idx>1
            layer=layers(idx-1);
        else
            return;
            
        end
end


setappdata(main_figure,'Layers',layers);
setappdata(main_figure,'Layer',layer);

update_display(main_figure,1);
end