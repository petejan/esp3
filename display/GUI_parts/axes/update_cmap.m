function update_cmap(main_figure)

axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
mini_axes_comp=getappdata(main_figure,'Mini_axes');
single_target_tab_comp=getappdata(main_figure,'Single_target_tab');

[cmap,col_ax,col_lab,col_grid,col_bot,col_txt]=init_cmap(curr_disp.Cmap);


set(axes_panel_comp.vaxes,'YColor',col_lab);
set(axes_panel_comp.haxes,'XColor',col_lab);
set(axes_panel_comp.main_axes,'Color',col_ax,'GridColor',col_grid);
set(axes_panel_comp.bottom_plot,'Color',col_bot);
set(mini_axes_comp.mini_ax,'Color',col_ax,'GridColor',col_grid);
set(mini_axes_comp.bottom_plot,'Color',col_bot);


display_regions(main_figure,'both');
txt_obj=[findobj(axes_panel_comp.main_axes,'Type','Text','-not','Tag','lines');
findobj(mini_axes_comp.mini_ax,'Type','Text','-not','Tag','lines')];
set(txt_obj,'Color',col_txt);

colormap(mini_axes_comp.mini_ax,cmap);
colormap(axes_panel_comp.main_axes,cmap);
colormap(single_target_tab_comp.ax_pos,cmap);

end