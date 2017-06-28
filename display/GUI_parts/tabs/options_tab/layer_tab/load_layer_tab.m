%% load_layer_tab.m
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
% * |tab_panel|: TODO: write description and info on variable
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
% * 2017-03-28: header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
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
    'CellSelectionCallback',{@goto_layer_cback,main_figure},...
    'BusyAction','cancel');

set(layer_tab_comp.layer_tab,'SizeChangedFcn',{@resize_table,main_figure});
set(layer_tab_comp.table,'KeyPressFcn',{@keypresstable,main_figure});

jtable = findjobj(layer_tab_comp.table);

policy = javax.swing.ScrollPaneConstants.HORIZONTAL_SCROLLBAR_NEVER;
jtable.setHorizontalScrollBarPolicy(policy)

pos_t = getpixelposition(layer_tab_comp.table);

set(layer_tab_comp.table,'ColumnWidth',{pos_t(3), 0});

rc_menu = uicontextmenu(ancestor(tab_panel,'figure'));
layer_tab_comp.table.UIContextMenu =rc_menu;

uiproc=uimenu(rc_menu,'Label','Processing');
uimenu(uiproc,'Label','Plot Pitch and Roll against bad pings','Callback',{@pitch_roll_analysis_callback,layer_tab_comp.table,main_figure});
uimap=uimenu(rc_menu,'Label','Mapping');
uimenu(uimap,'Label','Plot tracks from selected layers','Callback',{@plot_tracks_callback,layer_tab_comp.table,main_figure});

str_delete='<HTML><center><FONT color="Red"><b>Delete selected layers</b></Font> ';
lay_menu=uimenu(rc_menu,'Label','Layer Management');
uimenu(lay_menu,'Label','Merge Selected Layers','Callback',{@merge_selected_callback,layer_tab_comp.table,main_figure});
uimenu(lay_menu,'Label','Split Selected Layers (per survey data)','Callback',{@split_selected_callback,layer_tab_comp.table,main_figure,1});
uimenu(lay_menu,'Label','Split Selected Layers (per files)','Callback',{@split_selected_callback,layer_tab_comp.table,main_figure,0});
uimenu(lay_menu,'Label','Write GPS Data and Depth to database','Callback',{@write_gps_and_depth_to_db_callback,layer_tab_comp.table,main_figure});
uimenu(lay_menu,'Label',str_delete,'Callback',{@delete_layers_callback,layer_tab_comp.table,main_figure});

selected_layers=[];

setappdata(layer_tab_comp.table,'SelectedLayers',selected_layers);
setappdata(main_figure,'Layer_tab',layer_tab_comp);
update_layer_tab(main_figure);
end

function plot_tracks_callback(src,~,table,main_figure)
layers=getappdata(main_figure,'Layers');
selected_layers=getappdata(table,'SelectedLayers');

idx=nan(1,numel(selected_layers));
for i=1:length(selected_layers)   
    [idx(i),~]=find_layer_idx(layers,selected_layers(i));  
end

if isempty(idx)
    return;
end

map_input=map_input_cl.map_input_cl_from_obj(layers(idx),'SliceSize',0);

if nansum(isnan(map_input.LatLim))>=1
    return;
end

map_input.display_map_input_cl('main_figure',main_figure,'oneMap',1);

end

function delete_layers_callback(src,~,table,main_figure)
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
        setappdata(main_figure,'Layers',layers);
        setappdata(main_figure,'Layer',layer);
        loadEcho(main_figure);
        
        return;
    end
    
    [idx,~]=find_layer_idx(layers,selected_layers(i));
    
    layers=layers.delete_layers(selected_layers(i));
    layer=layers(nanmin(idx,length(layers)));
    
end
setappdata(main_figure,'Layers',layers);
setappdata(main_figure,'Layer',layer);
loadEcho(main_figure);
end

function merge_selected_callback(src,~,table,main_figure)
layers=getappdata(main_figure,'Layers');
layer=getappdata(main_figure,'Layer');
selected_layers=getappdata(table,'SelectedLayers');

if isempty(layer)
    return;
end

if isempty(selected_layers)
    return;
end

idx=nan(1,numel(selected_layers));
for i=1:length(selected_layers)

    [idx(i),~]=find_layer_idx(layers,selected_layers(i));
end

idx(isnan(idx))=[];

layers_to_shuffle=layers(idx);

layers(idx)=[];

layers_out=[layers shuffle_layers(layers_to_shuffle,'multi_layer',-1)];

setappdata(main_figure,'Layers',layers_out);
setappdata(main_figure,'Layer',layers_out(1));
loadEcho(main_figure);
end


function write_gps_and_depth_to_db_callback(src,~,table,main_figure)
layers=getappdata(main_figure,'Layers');
layer=getappdata(main_figure,'Layer');
selected_layers=getappdata(table,'SelectedLayers');
load_bar_comp=getappdata(main_figure,'Loading_bar');   
if isempty(layer)
    return;
end

if isempty(selected_layers)
    return;
end

idx=nan(1,numel(selected_layers));
for i=1:length(selected_layers)
    [idx(i),~]=find_layer_idx(layers,selected_layers(i));
end

idx(isnan(idx))=[];

layers_to_export=layers(idx);
show_status_bar(main_figure);
load_bar_comp.status_bar.setText('Updating Database with GPS Data');
layers_to_export.add_gps_data_to_db();
load_bar_comp.status_bar.setText('Done');
hide_status_bar(main_figure);


end

function split_selected_callback(src,~,table,main_figure,id)
layers=getappdata(main_figure,'Layers');
layer=getappdata(main_figure,'Layer');
selected_layers=getappdata(table,'SelectedLayers');

if isempty(layer)
    return;
end

if isempty(selected_layers)
    return;
end

idx=nan(1,numel(selected_layers));
for i=1:length(selected_layers)
    [idx(i),~]=find_layer_idx(layers,selected_layers(i));
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

layers_sp_out=reorder_layers_time(layers_sp_out);
id_lay=layers_sp_out(end).ID_num;

layers=[layers layers_sp_out];
layers=reorder_layers_time(layers);

[idx,~]=find_layer_idx(layers,id_lay);
layer=layers(idx);

setappdata(main_figure,'Layers',layers);
setappdata(main_figure,'Layer',layer);
loadEcho(main_figure);
end



function keypresstable(src,evt,main_figure)

switch evt.Key
    case 'delete'   
        delete_layers_callback(src,[],src,main_figure)
end

end

function goto_layer_cback(src,evt,main_figure)

layers=getappdata(main_figure,'Layers');
layer=getappdata(main_figure,'Layer');
up_display=0;

if ~isempty(evt.Indices)
    if size(evt.Indices,1)==1
        fig=ancestor(src,'figure');
        modifier = get(fig,'CurrentModifier');
        control = ismember({'shift' 'control'},modifier);
        if ~any(control)           
            if ~(layer.ID_num==src.Data{evt.Indices(1),2})
                [idx,~]=find_layer_idx(layers,src.Data{evt.Indices(1),2});
                layer=layers(idx);
                up_display=1;
            end
        end
        
    end
    selected_layers=unique([src.Data{evt.Indices(:,1),2}]);
else
    selected_layers=[];
end

setappdata(src,'SelectedLayers',selected_layers);
if up_display>0
    setappdata(main_figure,'Layers',layers);
    setappdata(main_figure,'Layer',layer);
    check_saved_bot_reg(main_figure);
    loadEcho(main_figure);
end

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