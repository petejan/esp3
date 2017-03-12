
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
            idx_curr=idx+1;
        else
            return;
        end
    case 'prev'
        if idx>1
            idx_curr=idx-1;
        else
            return;
            
        end
end
layers_Str_comp=list_layers(layers);
[path_lay,~]=layer.get_path_files();

cursor_mode_tool_comp=getappdata(main_figure,'Cursor_mode_tool');

set(cursor_mode_tool_comp.jCombo, 'SelectedIndex', idx_curr-1);
set(cursor_mode_tool_comp.jCombo,'ToolTipText',[path_lay{1} layers_Str_comp{idx_curr}]);


setappdata(main_figure,'Layers',layers);
setappdata(main_figure,'Layer',layer);
check_saved_bot_reg(main_figure);

loadEcho(main_figure);

end