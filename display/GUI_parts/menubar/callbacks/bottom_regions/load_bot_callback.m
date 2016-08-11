function load_bot_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');

if isempty(layer)
return;
end
    
app_path=getappdata(main_figure,'App_path');


if layer.ID_num==0
    return;
end

layer.CVS_BottomRegions(app_path.cvs_root,'BotCVS',1,'RegCVS',0);
setappdata(main_figure,'Layer',layer);
display_bottom(main_figure);
set_alpha_map(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');
order_stacks_fig(main_figure);
end
