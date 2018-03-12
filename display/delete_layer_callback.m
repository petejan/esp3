%% delete_layer_callback.m
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
function delete_layer_callback(~,~,main_figure,IDs)

layers=getappdata(main_figure,'Layers');

if isempty(layers)
    return;
end

if isempty(IDs)
    layer=getappdata(main_figure,'Layer');
    IDs=layer.Unique_ID;
    check_saved_bot_reg(main_figure);
end

if ~iscell(IDs)
    IDs={IDs};
end

for idi=1:numel(IDs)    
    [idx,~]=find_layer_idx(layers,IDs{idi});
    
    str_cell=list_layers(layers(idx),'nb_char',80);
    try
        fprintf('Deleting temp files from %s\n',str_cell{1});
        layers=layers.delete_layers(layer.Unique_ID);
    catch
        fprintf('Could not clean files from %s\n',str_cell{1});
    end
end

if ~isempty(layers)
    layer=layers(nanmin(idx,length(layers)));
    
    setappdata(main_figure,'Layers',layers);
    setappdata(main_figure,'Layer',layer);
    
    loadEcho(main_figure);
else
    obj_enable=findobj(main_figure,'Enable','on','-not',{'Type','uimenu','-or','Type','uitable'});
    set(obj_enable,'Enable','off');
    
    layer_obj=layer_cl.empty();
    setappdata(main_figure,'Layers',layers);
    setappdata(main_figure,'Layer',layer_obj);
    
    axes_panel_comp=getappdata(main_figure,'Axes_panel');
    delete(axes_panel_comp.axes_panel);
    rmappdata(main_figure,'Axes_panel');
    
    mini_axes_comp=getappdata(main_figure,'Mini_axes');
    delete(mini_axes_comp.mini_ax);
    rmappdata(main_figure,'Mini_axes');
    
    if isappdata(main_figure,'Secondary_freq')
        sec_freq=getappdata(main_figure,'Secondary_freq');
        delete(sec_freq.fig);
        rmappdata(main_figure,'Secondary_freq');
    end
    
    update_multi_freq_disp_tab(main_figure,'sv_f',1);
    update_multi_freq_disp_tab(main_figure,'ts_f',1);
    update_reglist_tab(main_figure,0);
    update_tree_layer_tab(main_figure);

end
end