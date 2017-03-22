%% change_layer_callback.m
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
% * |id|: TODO
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

layer=layers(idx_curr);

setappdata(main_figure,'Layers',layers);
setappdata(main_figure,'Layer',layer);
check_saved_bot_reg(main_figure);

loadEcho(main_figure);

end