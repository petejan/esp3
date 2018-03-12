%% load_tree_layer_tree_tab.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |main_figure|: Handle to main ESP3 window
% * |parent_tab_group|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2018-03-08: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function load_tree_layer_tab(main_figure,parent_tab_group)
import javax.swing.*
import java.awt.*

switch parent_tab_group.Type
    case 'uitabgroup'
        layer_tree_tab_comp.layer_tree_tab=new_echo_tab(main_figure,parent_tab_group,'Title','Layer List','UiContextMenuName','laylist');
    case 'figure'
        layer_tree_tab_comp.layer_tree_tab=parent_tab_group;
end


iconpath = fullfile(whereisEcho(),'icons');

tree_h = com.mathworks.hg.peer.UITreePeer;
layer_tree_tab_comp.tree_h = javaObjectEDT(tree_h);
tree_hh = handle(tree_h,'CallbackProperties');


layer_tree_tab_comp.root_node = uitreenode('v0', [], 'Layers', fullfile(iconpath,'foldericon.gif'), false);
layer_tree_tab_comp.tree_h.setRoot(layer_tree_tab_comp.root_node);
treePane = layer_tree_tab_comp.tree_h.getScrollPane;
treePane.setMinimumSize(Dimension(50,50));

layer_tree_tab_comp.jTreeObj = treePane.getViewport.getComponent(0);
layer_tree_tab_comp.jTreeObj.setShowsRootHandles(true)
layer_tree_tab_comp.jTreeObj.getSelectionModel.setSelectionMode(javax.swing.tree.TreeSelectionModel.DISCONTIGUOUS_TREE_SELECTION);
treePanel = JPanel(BorderLayout);
treePanel.add(treePane, BorderLayout.CENTER);

layer_tree_tab_comp.tree_h.setMultipleSelectionEnabled(true);
layer_tree_tab_comp.tree_h.setSelectedNode(layer_tree_tab_comp.root_node);

% set(tree_hh, 'NodeExpandedCallback', {@nodeExpanded, tree_h});
set(tree_hh, 'NodeSelectedCallback', {@nodeSelected, main_figure});

handleTree = layer_tree_tab_comp.tree_h.getScrollPane;
jTreeObj = handleTree.getViewport.getComponent(0);
jTreeObjh = handle(jTreeObj,'CallbackProperties');
set(jTreeObjh, 'MousePressedCallback', {@mouseClickCback,main_figure,tree_hh});  % context (right-click) menu

% rightPanel = JPanel(BorderLayout);
% 
% hsplitPane = JSplitPane(JSplitPane.HORIZONTAL_SPLIT, treePanel, rightPanel);
% hsplitPane.setOneTouchExpandable(true);
% hsplitPane.setContinuousLayout(true);
% hsplitPane.setResizeWeight(0.6);

pos = getpixelposition(layer_tree_tab_comp.layer_tree_tab);
% 

% globalPanel = JPanel(BorderLayout);
% globalPanel.add(hsplitPane, BorderLayout.CENTER);
%[~, hcontainer] = javacomponent(lefglobalPanelt, [0,0,pos(3:4)], layer_tree_tab_comp.layer_tree_tab);
[~, hcontainer] = javacomponent(treePanel, [0,0,pos(3) pos(4)], layer_tree_tab_comp.layer_tree_tab);
set(hcontainer,'units','normalized');
drawnow;
% hsplitPaneLocation = 0.5;
% hsplitPane.setDividerLocation(hsplitPaneLocation);  


setappdata(main_figure,'Layer_tree_tab',layer_tree_tab_comp);
update_tree_layer_tab(main_figure);
end


% function write_gps_and_depth_to_db_callback(src,~,table,main_figure)
% layers=getappdata(main_figure,'Layers');
% layer=getappdata(main_figure,'Layer');
% selected_layers=getappdata(table,'SelectedLayers');
% load_bar_comp=getappdata(main_figure,'Loading_bar');
% if isempty(layer)
%     return;
% end
% 
% if isempty(selected_layers)
%     return;
% end
% 
% idx=nan(1,numel(selected_layers));
% for i=1:length(selected_layers)
%     [idx(i),~]=find_layer_idx(layers,selected_layers{i});
% end
% 
% idx(isnan(idx))=[];
% 
% layers_to_export=layers(idx);
% show_status_bar(main_figure);
% load_bar_comp.status_bar.setText('Updating Database with GPS Data');
% %layers_to_export.add_gps_data_to_db();
% layers_to_export.add_ping_data_to_db();
% load_bar_comp.status_bar.setText('Done');
% hide_status_bar(main_figure);
% 
% 
% end
% 
% 
% function keypresstable(src,evt,main_figure)
% 
% switch evt.Key
%     case 'delete'
%         delete_layers_callback(src,[],src,main_figure)
% end
% 
% end


