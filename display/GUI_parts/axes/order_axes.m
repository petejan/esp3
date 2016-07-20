function order_axes(main_figure)
axes_panel_comp=getappdata(main_figure,'Axes_panel');
uistack(axes_panel_comp.main_axes,'bottom');
end