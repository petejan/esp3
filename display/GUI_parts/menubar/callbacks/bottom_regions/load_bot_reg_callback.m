%% load_bot_reg_callback.m
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
function load_bot_reg_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');

if isempty(layer)
return;
end
    
app_path=getappdata(main_figure,'App_path');

if layer.ID_num==0
    return;
end

layer.CVS_BottomRegions(app_path.cvs_root)

setappdata(main_figure,'Layer',layer);

display_bottom(main_figure);
update_regions_tab(main_figure,1);
update_reglist_tab(main_figure,[],0);
display_regions(main_figure,'both');
set_alpha_map(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');
order_stacks_fig(main_figure);

end
