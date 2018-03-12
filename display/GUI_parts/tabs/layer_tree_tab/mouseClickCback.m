function mouseClickcback(hTree, eventData, main_figure,tree_hh)  %#ok hTree is unused
if eventData.isMetaDown  % right-click is like a Meta-button
    % Get the clicked node
    clickX = eventData.getX;
    clickY = eventData.getY;
    jtree = eventData.getSource;
    %treePath = jtree.getPathForLocation(clickX, clickY);
    nodes=getSelectedNodes(tree_hh);
    IDs={};
    for i=1:numel(nodes)
       usrdata=get(nodes(i),'userdata');
       IDs=union(IDs,usrdata.ids);
    end
    
    jmenu = setTreeContextMenu(main_figure,IDs);
    try
    % Display the (possibly-modified) context menu
    jmenu.show(jtree, clickX, clickY);
    jmenu.repaint;
    catch
    end
end
end

function jmenu = setTreeContextMenu(main_figure,IDs)

import javax.swing.*


menuLayItem1 = JMenuItem('Merge Selected layers');
menuLayItem2 = JMenuItem('Split Selected Layers (per survey data)');
menuLayItem3 = JMenuItem('Split Selected Layers (per files)');
str_delete='<HTML><center><FONT color="Red"><b>Delete selected layers</b></Font> ';
menuLayItem4 = JMenuItem(str_delete);

set(handle(menuLayItem1,'CallbackProperties'), 'ActionPerformedCallback',{@merge_selected_callback,main_figure,IDs});
set(handle(menuLayItem2,'CallbackProperties'), 'ActionPerformedCallback',{@split_selected_callback,main_figure,IDs,1});
set(handle(menuLayItem3,'CallbackProperties'), 'ActionPerformedCallback',{@split_selected_callback,main_figure,IDs,0});
set(handle(menuLayItem4,'CallbackProperties'), 'ActionPerformedCallback',{@delete_layers_callback,main_figure,IDs});

jmenu = JPopupMenu;
jmenu.add(menuLayItem1);
jmenu.add(menuLayItem2);
jmenu.add(menuLayItem3);
jmenu.add(menuLayItem4);

end 


function split_selected_callback(~,~,main_figure,IDs,id)
layers=getappdata(main_figure,'Layers');
layer=getappdata(main_figure,'Layer');
selected_layers=IDs;

if isempty(layer)
    return;
end

if isempty(selected_layers)
    return;
end

idx=nan(1,numel(selected_layers));
for i=1:length(selected_layers)
    [idx(i),~]=find_layer_idx(layers,selected_layers{i});
end

idx(isnan(idx))=[];

layers_to_split=layers(idx);

layers(idx)=[];

layers_sp=[];

for ilay=1:numel(layers_to_split)
    new_layers=layers_to_split(ilay).split_layer();
    new_layers.load_echo_logbook_db();
    layers_sp=[layers_sp new_layers];
end

if id>0
    layers_sp_sorted=layers_sp.sort_per_survey_data();
    
    layers_sp_out=[];
    
    for icell=1:length(layers_sp_sorted)
        layers_sp_out=[layers_sp_out shuffle_layers(layers_sp_sorted{icell},'multi_layer',-1)];
    end
else
    
    layers_sp_out=layers_sp;
end

%layers_sp_out=reorder_layers_time(layers_sp_out);
id_lay=layers_sp_out(end).Unique_ID;

layers=[layers layers_sp_out];
%layers=reorder_layers_time(layers);

[idx,~]=find_layer_idx(layers,id_lay);
layer=layers(idx);

setappdata(main_figure,'Layers',layers);
setappdata(main_figure,'Layer',layer);
clear_regions(main_figure,{},{});
loadEcho(main_figure);
end



function merge_selected_callback(src,evt,main_figure,IDs)
layers=getappdata(main_figure,'Layers');
layer=getappdata(main_figure,'Layer');
selected_layers=IDs;

if isempty(layer)
    return;
end

if isempty(selected_layers)
    return;
end

idx=nan(1,numel(selected_layers));
for i=1:length(selected_layers)
    [idx(i),~]=find_layer_idx(layers,selected_layers{i});
end

idx(isnan(idx))=[];
layers_to_shuffle=layers(idx);

layers(idx)=[];
new_lays=shuffle_layers(layers_to_shuffle,'multi_layer',-1);
layers_out=[layers new_lays];
%layers_out=reorder_layers_time(layers_out);

setappdata(main_figure,'Layers',layers_out);
setappdata(main_figure,'Layer',new_lays(1));
clear_regions(main_figure,{},{});
loadEcho(main_figure);
end