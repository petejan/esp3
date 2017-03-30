%% remove_cvs_callback.m
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
function remove_cvs_callback(~,~,main_figure)

layers=getappdata(main_figure,'Layers');

choice = questdlg('WARNING: This will remove all CVS Regions?', ...
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
end

setappdata(main_figure,'Layers',layers);
display_bottom(main_figure);
update_regions_tab(main_figure,1);
update_reglist_tab(main_figure,[],0);
display_regions(main_figure,'both');
set_alpha_map(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');
order_stacks_fig(main_figure);


end