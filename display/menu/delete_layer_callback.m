
function delete_layer_callback(~,~,main_figure)
    layers=getappdata(main_figure,'Layers');
    layer=getappdata(main_figure,'Layer');
    
    if length(layers)==1
        warning('You cannot delete the last layer standing');
        return;
    end
    
    [idx,~]=find_layer_idx(layers,layer.ID_num);
    
    layers=layers.delete_layer(layer.ID_num);
    layer=layers(nanmin(idx,length(layers)));
   
    setappdata(main_figure,'Layers',layers);
    setappdata(main_figure,'Layer',layer);
    
    update_display(main_figure,1);
end