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
if ~isdeployed
    disp('update_layer_tab');
end
layer_tab_comp=getappdata(main_figure,'Layer_tab');
layers=getappdata(main_figure,'Layers');
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

nb_layer=length(layers);
data_new=cell(nb_layer,2);


% data_old=layer_tab_comp.table.Data;
try
    jScroll = findjobj(layer_tab_comp.table, 'class','UIScrollPane');
    
    jView = jScroll.getViewport();
    pos=jView.getViewPosition;
    
    layers_Str_comp=list_layers(layers);
    data_new(:,1)=layers_Str_comp;
    data_new(:,2)=num2cell([layers(:).ID_num]);
    [idx,~]=find_layer_idx(layers,layer.ID_num);
    
    if isempty(idx)
        return;
    end
    
    % if~isempty(data_old)
    %  [~,b,c]=intersect([data_new{:,2}],[data_old{:,2}]);
    % else
    %    b=[];
    %    c=[];
    % end
    % if all(b==c)&&~isempty(b)&&size(data_new)
    %     idx_mod=find(~strcmp(data_new(:,1),data_old(:,1)));
    %     for i=1:idx_mod
    %         layer_tab_comp.table.Data{i,1}=data_new{i,1};
    %     end
    %
    % else
    layer_tab_comp.table.Data=data_new;
    % end
    layer_tab_comp.table.Data{idx,1}=strcat('<html><FONT color="Red"><b>',data_new{idx,1},'</b></html>');
    
    drawnow;  pause(0.02);
    
    jView.setViewPosition(pos)
    
    jScroll.repaint();    % workaround for any visual glitches
catch
    if ~isdeployed()
        disp('Error while updating layer_tab');
    end
end
setappdata(main_figure,'Layer_tab',layer_tab_comp);
end