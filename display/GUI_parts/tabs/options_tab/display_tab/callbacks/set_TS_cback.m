%% set_TS_cback.m
%
% Callback to change TS for biomass visualisation
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
% * 2017-03-06: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function set_TS_cback(~,~,main_figure)


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


[trans_obj,idx_freq]=layer.get_trans(curr_disp);
if isempty(trans_obj)
    return;
end

[~,found]=trans_obj.Data.find_field_idx('fishdensity');

if found==0
    return;
end

sv=trans_obj.Data.get_datamat('sv');

data_mat=10.^(sv-TS)/10;
trans_obj.Data.replace_sub_data('fishdensity',data_mat);
curr_disp.setField('fishdensity');
setappdata(main_figure,'Curr_disp',curr_disp);



