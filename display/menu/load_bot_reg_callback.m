function load_bot_reg_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');

if layer.ID_num==0
    return;
end

    layer.CVS_BottomRegions()
   
    setappdata(main_figure,'Layer',layer);
    update_display(main_figure,0);
end
