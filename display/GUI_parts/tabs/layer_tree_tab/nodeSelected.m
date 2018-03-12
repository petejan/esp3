
function nodeSelected(src,evt, main_figure)
selNode=src.getSelectedNodes;
%layer_tree_tab_comp=getappdata(main_figure,'Layer_tree_tab');
layers=getappdata(main_figure,'Layers');
layer=getappdata(main_figure,'Layer');
%fig=ancestor(layer_tree_tab_comp.layer_tree_tab,'figure');
%
% modifier = get(fig,'CurrentModifier');
% control = ismember({'shift' 'control'},modifier);
if numel(selNode)>1
    return;
end
if ~isempty(selNode)
    selNode=selNode(1);
    userdata=selNode.handle.Userdata;
    if isempty(userdata)
        return;
    end
    switch userdata.level
        case 'layer'
            if strcmp(layer.Unique_ID,userdata.ids)
                return;
            end          
            [idx,~]=find_layer_idx(layers,userdata.ids);
            setappdata(main_figure,'Layers',layers);
            setappdata(main_figure,'Layer',layers(idx));
            check_saved_bot_reg(main_figure);
            loadEcho(main_figure);
    end
end
end