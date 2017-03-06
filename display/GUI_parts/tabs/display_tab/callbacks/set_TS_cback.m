
function set_TS_cback(~,~,main_figure)
% set_TS_cback(~,~,main_figure)
%
% DESCRIPTION
%
% Callback to change TS for biomass visualisation
%
% USE
%%
% PROCESSING SUMMARY
%
% - [Bullet point list summary of the steps in the processing.]
% - [DELETE THESE LINES IF UNUSED]
%
% INPUT VARIABLES
%
% - ESP3 figure
%
%
% RESEARCH NOTES
%
% [Describes what features are temporary or needed future developments.]
% [Also use for paper references.]
% [DELETE THESE LINES IF UNUSED]
%
% NEW FEATURES
%
% YYYY-MM-DD: [second version. Describes the update. DELETE THIS LINE IF UNUSED]
% 2017-03-06: first version.
%
% EXAMPLE
%
% % example 1:
% [This section contains examples of valid function calls.]
%
% % example 2:
% [DELETE THESE LINES IF UNUSED]
%
%%%
% Yoann Ladroit NIWA
%%%

layer=getappdata(main_figure,'Layer');
display_tab_comp=getappdata(main_figure,'Display_tab');
TS=str2double(get(display_tab_comp.TS,'string'));
if isnan(TS)
    set(display_tab_comp.TS,'string',-50)
end

if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');


[idx_freq,found]=find_freq_idx(layer,curr_disp.Freq);
if found==0
    return;
end
trans_obj=layer.Transceivers(idx_freq);
[~,found]=trans_obj.Data.find_field_idx('fishdensity');

if found==0
    return;
end

sv=trans_obj.Data.get_datamat('sv');

data_mat=10.^(sv-TS)/10;
trans_obj.Data.replace_sub_data('fishdensity',data_mat);
curr_disp.setField('fishdensity');
setappdata(main_figure,'Curr_disp',curr_disp);



