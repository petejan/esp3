function load_bot_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');

if layer.ID_num==0
    return;
end

    layer.CVS_BottomRegions('BotCVS',1,'RegCVS',0);
   
    setappdata(main_figure,'Layer',layer);
    update_display(main_figure,0);
end
