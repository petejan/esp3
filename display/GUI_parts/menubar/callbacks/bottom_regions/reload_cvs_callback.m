%% reload_cvs_callback.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |main_figure|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-28: header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function reload_cvs_callback(~,~,main_figure)

layers=getappdata(main_figure,'Layers');
app_path=getappdata(main_figure,'App_path');
choice = questdlg('WARNING: This will replace all CVS Regions?', ...
    'Bottom/Region',...
    'Yes','No', ...
    'No');

switch choice
    case 'No'
        return;
end

for i=1:length(layers)
    for uui=1:length(layers(i).Frequencies)
        layers(i).Transceivers(uui).rm_region_origin('esp2');
    end
    layers(i).CVS_BottomRegions(app_path.cvs_root)
end

setappdata(main_figure,'Layers',layers);

curr_disp=getappdata(main_figure,'Curr_disp');
display_regions(main_figure,'all');
[trans_obj,~]=layer.get_trans(curr_disp);
curr_disp.Active_reg_ID=trans_obj.get_reg_first_Unique_ID();

display_bottom(main_figure);

set_alpha_map(main_figure,'main_or_mini',union({'main','mini'},layer.ChannelID));
order_stacks_fig(main_figure);




end