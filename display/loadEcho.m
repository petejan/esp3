%% loadEcho.m
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
% * |main_figure|: Handle to main ESP3 window
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO
%
% *NEW FEATURES*
%
% * 2017-03-22: header and comments updated according to new format (Alex Schimel)
% * 2017-03-13: comments and header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function loadEcho(main_figure)

if isempty(main_figure)
    return;
end


layer  = getappdata(main_figure,'Layer');
layers = getappdata(main_figure,'Layers');

if isempty(layers)
    return;
end

remove_interactions(main_figure);
disable_listeners(main_figure);
uiundo(main_figure,'clear');

nb_layers = length(layers);
curr_disp = getappdata(main_figure,'Curr_disp');


[idx_freq,found_freq] = find_freq_idx(layer,curr_disp.Freq);
[~,found_field] = find_field_idx(layer.Transceivers(idx_freq).Data,curr_disp.Fieldname);

if found_freq == 0
    idx_freq = 1;
    %disp('Cannot Find Frequency...');
    curr_disp.Freq = layer.Frequencies(idx_freq);
end

if found_field == 0
    [~,found] = find_field_idx(layer.Transceivers(idx_freq).Data,'sv');
    if found == 0
        field = layer.Transceivers(idx_freq).Data.Fieldname{1};
    else
        field = 'sv';
    end
    curr_disp.setField(field);
end
setappdata(main_figure,'Curr_disp',curr_disp);
%old_nb=curr_disp.NbLayers;
if ~isempty(layer)
    if layer.ID_num==curr_disp.CurrLayerID && nb_layers==curr_disp.NbLayers
        flag = 0;
    else
        flag = 1;
        curr_disp.CurrLayerID = layer.ID_num;
        curr_disp.NbLayers    = nb_layers;
        %disp('New Layer')
    end
end
curr_disp.Bot_changed_flag = 0;
curr_disp.Reg_changed_flag = 0;
curr_disp.UIupdate=1;

curr_disp.Active_reg_ID=layer.Transceivers(idx_freq).get_reg_first_Unique_ID();

setappdata(main_figure,'Curr_disp',curr_disp);

update_display(main_figure,flag);
waitfor(curr_disp,'UIupdate',0)

enable_listeners(main_figure);

%curr_disp.CursorMode=curr_mode;
curr_disp.CursorMode='Normal';

enabled_obj=findobj(main_figure,'Enable','off');
set(enabled_obj,'Enable','on');

if ~isdeployed
    fprintf(1,'Currently %.0f active objects in ESP3\n\n',numel(findall(main_figure)));
end

end

