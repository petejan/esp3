function loadEcho(main_figure)
% loadEcho(main_figure)
%
% DESCRIPTION
%
% [This section containg a very short description of the function, for the user to know this is part of ESP3 and what it is]
% Template of ESP3 function header.
% [REPLACE THESE LINES WITH ACTUAL CONTENT OR DELETE IF UNUSED]
%
% USE
%
% [This section contains a more detailed description of what the function does and how to use it, for the interested user to have an overall understanding of its function] 
% This is a text file containing the basic comment template to add at the
% start of any new ESP3 function to serve as function help. 
% [REPLACE THESE LINES WITH ACTUAL CONTENT OR DELETE IF UNUSED]
%
% PROCESSING SUMMARY
%
% [This section contains bullet point list of major processing steps, for the very interested user to have a clear understanding of the function works before reading its details]
% - Function does this first
% - Then it does this
% [REPLACE THESE LINES WITH ACTUAL CONTENT OR DELETE IF UNUSED]
%
% INPUT VARIABLES
%
% - main_figure (required): ESP3 main figure
%
% RESEARCH NOTES
%
% NEW FEATURES
%
% 2017-03-13: comments and header by alex.
%
%%%
% Yoann Ladroit, NIWA.
%%%

if isempty(main_figure)
    return;
end

remove_interactions(main_figure);
rm_listeners(main_figure);

layer  = getappdata(main_figure,'Layer');
layers = getappdata(main_figure,'Layers');

if isempty(layers)
    return;
end

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

setappdata(main_figure,'Curr_disp',curr_disp);
reset_mode([],[],main_figure);
update_display(main_figure,flag);


init_listeners(main_figure);
set(main_figure,'WindowButtonMotionFcn',{@display_info_ButtonMotionFcn,main_figure,0});






end

