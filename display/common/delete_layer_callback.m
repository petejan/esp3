
function delete_layer_callback(~,~,main_figure)
    layers=getappdata(main_figure,'Layers');
    layer=getappdata(main_figure,'Layer');
    %cursor_mode_tool_comp=getappdata(main_figure,'Cursor_mode_tool'); 
    if length(layers)==1
        warning('You cannot delete the last layer standing');
        return;
    end
    

    [idx,~]=find_layer_idx(layers,layer.ID_num);
%     cursor_mode_tool_comp.jCombo.removeItemAt(idx-1);
%     cursor_mode_tool_comp.jCombo.addItem(layers_Str);
    
    layers=layers.delete_layers(layer.ID_num);
    layer=layers(nanmin(idx,length(layers)));
   
    setappdata(main_figure,'Layers',layers);
    setappdata(main_figure,'Layer',layer);
    
    update_display(main_figure,1);
end