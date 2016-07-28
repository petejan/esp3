function order_stacks_fig(main_figure)
display_tab_comp=getappdata(main_figure,'Display_tab');
axes_panel_comp=getappdata(main_figure,'Axes_panel');

order_stack(display_tab_comp.mini_ax);
order_stack(axes_panel_comp.main_axes);

end