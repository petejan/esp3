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
set_alpha_map(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');
update_regions_tab(main_figure,1);
order_stacks_fig(main_figure);
update_reglist_tab(main_figure,[],0);


end