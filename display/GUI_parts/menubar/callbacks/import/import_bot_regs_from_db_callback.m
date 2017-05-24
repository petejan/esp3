%% import_bot_regs_from_db_callback.m
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
function import_bot_regs_from_db_callback(~,~,main_figure,bot,reg)

layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end
if bot>=0&&reg>=0
    war_str=('WARNING: This will replace currently defined Regions and Bottom?');
elseif bot>=0&&reg<0
    war_str=('WARNING: This will replace currently defined Bottom?');
elseif bot<0&&reg>=0
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

layer.load_bot_regs('bot_ver',bot,'reg_ver',reg);
disp('Bottom and regions imported');

display_bottom(main_figure);


display_regions(main_figure,'both');
curr_disp=getappdata(main_figure,'Curr_disp');
trans_obj=layer.get_trans(curr_disp.Freq);
curr_disp.Active_reg_ID=trans_obj.get_reg_first_Unique_ID();

set_alpha_map(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');
order_stacks_fig(main_figure);


end