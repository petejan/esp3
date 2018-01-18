%% import_bot_regs_from_xml_callback.m
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
% * |bot|: TODO: write description and info on variable
% * |reg|: TODO: write description and info on variable
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
function import_bot_regs_from_xml_callback(~,~,main_figure,bot,reg)

layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end
if ~isempty(bot)&&~isempty(reg)
    war_str=('WARNING: This will replace currently defined Regions and Bottom?');
elseif ~isempty(bot)&&isempty(reg)
    war_str=('WARNING: This will replace currently defined Bottom?');
elseif isempty(bot)&&~isempty(reg)
    war_str=('WARNING: This will replace currently defined Regions?');
else
    return;
end


choice = questdlg(war_str, ...
    'Load XML',...
    'Yes','No', ...
    'No');
% Handle response
switch choice
    case 'No'
        return;
end

[~,~,~]=layer.load_bot_regs('bot_ver',bot,'reg_ver',reg);

clear_regions(main_figure,{},{});
display_bottom(main_figure);

display_regions(main_figure,'all');
curr_disp=getappdata(main_figure,'Curr_disp');
curr_disp.setActive_reg_ID({});

set_alpha_map(main_figure,'main_or_mini',union({'main','mini'},layer.ChannelID));
order_stacks_fig(main_figure);

end