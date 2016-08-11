function load_reg_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');

if isempty(layer)
return;
end
    
app_path=getappdata(main_figure,'App_path');


if layer.ID_num==0
    return;
end

layer.CVS_BottomRegions(app_path.cvs_root,'BotCVS',0,'RegCVS',1);

setappdata(main_figure,'Layer',layer);


display_regions(main_figure);
set_alpha_map(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');
update_regions_tab(main_figure,1);
order_stacks_fig(main_figure);
end
