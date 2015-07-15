
function delete_layer(~,~,main_figure)
    layers=getappdata(main_figure,'Layers');
    layer=getappdata(main_figure,'Layer');
    
    if length(layers)==1
        warning('You cannot delete the last layer standing');
        return;
    end
    
    [idx,~]=find_layer_idx(layers,layer.ID_num);
    
    for kk=1:length(layers(idx).Transceivers)
        if exist(layers(idx).Transceivers(kk).MatfileName,'file')>0
            delete(layers(idx).Transceivers(kk).MatfileName);
        end
    end
    
    layers(idx)=[];
    layer=layers(nanmin(idx,length(layer)));
    
    setappdata(main_figure,'Layers',layers);
    setappdata(main_figure,'Layer',layer);
    
    update_display(main_figure,1);
end