%% load_reg_callback.m
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
function load_reg_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');

if isempty(layer)
return;
end
    
app_path=getappdata(main_figure,'App_path');


layer.CVS_BottomRegions(app_path.cvs_root,'BotCVS',0,'RegCVS',1);

setappdata(main_figure,'Layer',layer);

display_regions(main_figure,'all');
curr_disp=getappdata(main_figure,'Curr_disp');

curr_disp.setActive_reg_ID({});

set_alpha_map(main_figure,'main_or_mini',union({'main','mini'},layer.ChannelID));
order_stacks_fig(main_figure);

end
