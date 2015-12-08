function listenDispBot(src,listdata,main_figure)
display_tab_comp=getappdata(main_figure,'Display_tab');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
set(display_tab_comp.disp_bottom,'value',strcmpi(listdata.AffectedObject.DispBottom,'on'));
if isfield(axes_panel_comp,'bottom_plot')
    if isvalid(axes_panel_comp.bottom_plot)
        set(axes_panel_comp.bottom_plot,'visible',listdata.AffectedObject.DispBottom);
    end
end
end