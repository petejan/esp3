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
    
    [idx,~]=find_layer_idx(layers,layer.ID_num);
    
    layers=layers.delete_layers(layer.ID_num);
    layer=layers(nanmin(idx,length(layers)));
   
    setappdata(main_figure,'Layers',layers);
    setappdata(main_figure,'Layer',layer);
    check_saved_bot_reg(main_figure);
    loadEcho(main_figure);
end