%% update_layer_tab.m
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
function update_layer_tab(main_figure)
layer_tab_comp=getappdata(main_figure,'Layer_tab');
layers=getappdata(main_figure,'Layers');
layer=getappdata(main_figure,'Layer');

nb_layer=length(layers);
data=cell(nb_layer,2);


layers_Str_comp=list_layers(layers);
data(:,1)=layers_Str_comp;
data(:,2)=num2cell([layers(:).ID_num]);

% [~,idx_sort]=sort([data{:,2}]);
% data=data(idx_sort,:);
[idx,~]=find_layer_idx(layers,layer.ID_num);

data(idx,1)=strcat('<html><b>',data(idx,1),'</b></html>');

layer_tab_comp.table.Data=data;

setappdata(main_figure,'Layer_tab',layer_tab_comp);
end