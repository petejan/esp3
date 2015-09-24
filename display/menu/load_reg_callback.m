function load_reg_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
app_path=getappdata(hObject,'App_path');


if layer.ID_num==0
    return;
end

    layer.CVS_BottomRegions(app_path.cvs_root,'BotCVS',0,'RegCVS',1);
   
    setappdata(main_figure,'Layer',layer);
    update_display(main_figure,0);
end
