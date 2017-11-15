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
function delete_layer_callback(~,~,main_figure)
    layers=getappdata(main_figure,'Layers');
    layer=getappdata(main_figure,'Layer');
    
    if isempty(layer)
        return;
    end
    
    check_saved_bot_reg(main_figure);
    if length(layers)==1
        warning('You cannot delete the last layer standing');
        return;
    end
    
    [idx,~]=find_layer_idx(layers,layer.Unique_ID);
    
    str_cell=list_layers(layers(idx),'nb_char',80);
    try
        fprintf('Deleting temp files from %s\n',str_cell{1});
        layers=layers.delete_layers(layer.Unique_ID);
    catch
        fprintf('Could not clean files from %s\n',str_cell{1});
    end

    layer=layers(nanmin(idx,length(layers)));
   
    setappdata(main_figure,'Layers',layers);
    setappdata(main_figure,'Layer',layer);

    loadEcho(main_figure);
end