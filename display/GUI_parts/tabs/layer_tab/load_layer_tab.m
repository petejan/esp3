%% load_layer_tab.m
%
% TODO
%
%% Help
%
% *USE*
%
% TODO
%
% *INPUT VARIABLES*
%
% * |main_figure|: TODO
% * |tab_panel|: TODO
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: complete header and in-code commenting
%
% *NEW FEATURES*
%
% * 2017-03-22: header and comments (Alex Schimel)
% * 2017-03-21: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function load_layer_tab(main_figure,tab_panel)

layer_tab_comp.layer_tab=uitab(tab_panel,'Title','Layers');

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

rc_menu = uicontextmenu(main_figure);
    layer_tab_comp.table.UIContextMenu =rc_menu;
    uimenu(rc_menu,'Label','Delete selected layer(s)','Callback',{@delete_layers_callback,layer_tab_comp.table,main_figure});
selected_layers=[];

setappdata(layer_tab_comp.table,'SelectedLayers',selected_layers);
setappdata(main_figure,'Layer_tab',layer_tab_comp);
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
        setappdata(main_figure,'Layers',layers);
        setappdata(main_figure,'Layer',layer);
        loadEcho(main_figure);
    end

end

function goto_layer_cback(src,evt,main_figure)

layers=getappdata(main_figure,'Layers');
layer=getappdata(main_figure,'Layer');


if ~isempty(evt.Indices)
    if size(evt.Indices,1)==1
        % fig=ancestor(src,'figure');
        % switch fig.SelectionType
        %     case 'open'
        modifier = get(main_figure,'CurrentModifier');
        control = ismember({'shift' 'control'},modifier);
        if ~any(control)
            if layer.ID_num==src.Data{evt.Indices(1),2}
                return;
            end
            [idx,~]=find_layer_idx(layers,src.Data{evt.Indices(1),2});
            layer=layers(idx);
            
            
        end
    end
    setappdata(main_figure,'Layers',layers);
            setappdata(main_figure,'Layer',layer);
            check_saved_bot_reg(main_figure);
            loadEcho(main_figure);
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

if~isempty(table)
    column_width=table.ColumnWidth;
    pos_f=getpixelposition(layer_tab_comp.layer_tab);
    width_t_old=nansum([column_width{:}]);
    width_t_new=pos_f(3);
    new_width=cellfun(@(x) x/width_t_old*width_t_new,column_width,'un',0);
    set(table,'ColumnWidth',new_width);
end

end