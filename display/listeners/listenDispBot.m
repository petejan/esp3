function listenDispBot(src,listdata,main_figure)
main_menu=getappdata(main_figure,'main_menu');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
set(main_menu.disp_bottom,'checked',listdata.AffectedObject.DispBottom);
if isfield(axes_panel_comp,'bottom_plot')
    if isvalid(axes_panel_comp.bottom_plot)
        set(axes_panel_comp.bottom_plot,'visible',listdata.AffectedObject.DispBottom);
    end
end
end