%% load_layer_tab.m
%
% _This section contains a very short description of the function, for the
% user to know this is part of ESP3 and what it is. Example below to
% replace. Delete these lines._
%
% Template of ESP3 function header.
%
%% Help
%
% *USE*
%
% _This section contains a more detailed description of what the function
% does and how to use it, for the interested user to have an overall
% understanding of its function. Example below to replace. Delete these
% lines._
%
% This is a text file containing the basic comment template to add at the
% start of any new ESP3 function to serve as function help.
%
% *INPUT VARIABLES*
%
% _This section contains bullet points of input variables with types and
% description. Example below to replace. Delete these lines._
%
% 'output_variable_1' (required). Valid Options:
%
% * char: description
% * cell: description
%
% 'output_variable_2' (optional). Valid Options:
%
% * 1xN numeric array: description
%
% 'output_variable_3' (parameter). Valid Options:
%
% * struct: description
%
% *OUTPUT VARIABLES*
%
% _This section contains bullet points of output variables. Example below
% to replace. Delete these lines._
%
% * 'output_variable_1': type and description
% * 'output_variable_2': type and description
%
% *RESEARCH NOTES*
%
% _This section describes what features are temporary, needed future
% developments and paper references. Example below to replace. Delete these lines._
%
% * research point 1
% * research point 2
%
% *NEW FEATURES*
%
% _This section contains dates and descriptions of major updates. Example
% below to replace. Delete these lines._
%
% * YYYY-MM-DD: second version. Describes the update.
% * YYYY-MM-DD: first version.
%
% *EXAMPLE*
%
% _This section contains examples of valid function calls. Note that
% example lines start with 3 white spaces so that the publish function
% shows them correctly as matlab code. Example below to replace. Delete
% these lines._
%
%   example_use_1; % comment on what this does.
%   example_use_2: % comment on what this line does.
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% _This last section contains at least author name and affiliation. Delete
% these lines._
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function

function load_layer_tab(main_figure,tab_panel)

switch tab_panel.Type
    case 'uitabgroup'
        layer_tab_comp.layer_tab=uitab(tab_panel,'Title','Layers');
        tab_menu = uicontextmenu(ancestor(tab_panel,'figure'));
        layer_tab_comp.layer_tab.UIContextMenu=tab_menu;
        uimenu(tab_menu,'Label','Undock Layer List','Callback',{@undock_layer_tab_callback,main_figure,'out_figure'});
    case 'figure'
        layer_tab_comp.layer_tab=tab_panel;
end

layer_tab_comp.table= uitable('Parent',layer_tab_comp.layer_tab,...
    'Data', [],...
    'ColumnName', {'Layers' 'ID'},...
    'ColumnFormat', {'char' 'numeric'},...
    'ColumnEditable',[false false],...
    'Units','Normalized',...
    'Position',[0.01 0 0.98 1],...
    'RowName',[],...
    'CellSelectionCallback',{@goto_layer_cback,main_figure} );

set(layer_tab_comp.layer_tab,'SizeChangedFcn',{@resize_table,main_figure});
    

jtable = findjobj(layer_tab_comp.table);

policy = javax.swing.ScrollPaneConstants.HORIZONTAL_SCROLLBAR_NEVER;
jtable.setHorizontalScrollBarPolicy(policy)

pos_t = getpixelposition(layer_tab_comp.table);

set(layer_tab_comp.table,'ColumnWidth',{pos_t(3), 0});

rc_menu = uicontextmenu(ancestor(tab_panel,'figure'));
layer_tab_comp.table.UIContextMenu =rc_menu;
uimenu(rc_menu,'Label','Delete selected layer(s)','Callback',{@delete_layers_callback,layer_tab_comp.table,main_figure});
selected_layers=[];

setappdata(layer_tab_comp.table,'SelectedLayers',selected_layers);
setappdata(main_figure,'Layer_tab',layer_tab_comp);
update_layer_tab(main_figure);
end
function delete_layers_callback(~,~,table,main_figure)
    layers=getappdata(main_figure,'Layers');
    layer=getappdata(main_figure,'Layer');
    selected_layers=getappdata(table,'SelectedLayers');
    
    if isempty(layer)
        return;
    end
    
    if isempty(selected_layers)
        return;
    end
    
    for i=1:length(selected_layers)
        check_saved_bot_reg(main_figure);
        if length(layers)==1
            warning('You cannot delete the last layer standing');
            return;
        end
        
        [idx,~]=find_layer_idx(layers,selected_layers(i));
        
        layers=layers.delete_layers(layer.ID_num);
        layer=layers(nanmin(idx,length(layers)));
       
    end
    setappdata(main_figure,'Layers',layers);
    setappdata(main_figure,'Layer',layer);
    loadEcho(main_figure);
end

function goto_layer_cback(src,evt,main_figure)

layers=getappdata(main_figure,'Layers');
layer=getappdata(main_figure,'Layer');


if ~isempty(evt.Indices)
    if size(evt.Indices,1)==1
        fig=ancestor(src,'figure');
        modifier = get(fig,'CurrentModifier');
        control = ismember({'shift' 'control'},modifier);
        if ~any(control)
            
            if layer.ID_num==src.Data{evt.Indices(1),2}
                return;
            end
            
            [idx,~]=find_layer_idx(layers,src.Data{evt.Indices(1),2});
            layer=layers(idx);
            setappdata(main_figure,'Layers',layers);
            setappdata(main_figure,'Layer',layer);
            check_saved_bot_reg(main_figure);
            loadEcho(main_figure);
            
        end
        
    end  
    selected_layers=[src.Data{evt.Indices(:,1),2}]; 
else
    selected_layers=[];
end

setappdata(src,'SelectedLayers',selected_layers);

end

function resize_table(src,~,main_figure)
layer_tab_comp=getappdata(main_figure,'Layer_tab');
if isempty(layer_tab_comp)
    return;
end
table=layer_tab_comp.table;

if~isempty(table)&&isvalid(table)
    column_width=table.ColumnWidth;
    pos_f=getpixelposition(layer_tab_comp.layer_tab);
    width_t_old=nansum([column_width{:}]);
    width_t_new=pos_f(3);
    new_width=cellfun(@(x) x/width_t_old*width_t_new,column_width,'un',0);
    set(table,'ColumnWidth',new_width);
end

end