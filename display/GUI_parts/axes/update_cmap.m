function update_cmap(main_figure)

axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
mini_axes_comp=getappdata(main_figure,'Mini_axes');
map_tab_comp=getappdata(main_figure,'Map_tab');

[cmap,col_ax,col_lab,col_grid,col_bot,col_txt]=init_cmap(curr_disp.Cmap);

set(axes_panel_comp.vaxes,'YColor',col_lab);
set(axes_panel_comp.haxes,'XColor',col_lab);
set(axes_panel_comp.main_axes,'Color',col_ax,'GridColor',col_grid,'MinorGridColor',col_grid);
set(axes_panel_comp.bottom_plot,'Color',col_bot);
set(mini_axes_comp.mini_ax,'Color',col_ax,'GridColor',col_grid,'MinorGridColor',col_grid);
set(mini_axes_comp.bottom_plot,'Color',col_bot);


display_regions(main_figure,'all');

txt_obj=[findobj(axes_panel_comp.main_axes,'Type','Text','-not','Tag','lines');
    findobj(mini_axes_comp.mini_ax,'Type','Text','-not','Tag','lines')];
set(txt_obj,'Color',col_txt);

colormap(mini_axes_comp.mini_ax,cmap);
colormap(axes_panel_comp.main_axes,cmap);
colormap(map_tab_comp.ax_pos,cmap);

if isappdata(main_figure,'Secondary_freq')&&curr_disp.DispSecFreqs>0
    secondary_freq=getappdata(main_figure,'Secondary_freq');
    set(secondary_freq.axes,'Color',col_ax,'GridColor',col_grid,'MinorGridColor',col_grid);
    for iax=1:numel(secondary_freq.axes)
        colormap(secondary_freq.axes(iax),cmap);
        set(secondary_freq.bottom_plots(iax),'color',col_bot);
    end
end
end