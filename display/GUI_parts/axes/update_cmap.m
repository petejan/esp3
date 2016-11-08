function update_cmap(main_figure)

axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
mini_axes_comp=getappdata(main_figure,'Mini_axes');


switch lower(curr_disp.Cmap)
    case {'parula' 'jet' 'hsv' 'winter' 'autumn' 'spring' 'hot' 'cool'}
        cmap=colormap(curr_disp.Cmap);
        col_ax='w';
        col_lab='k';
        col_grid=[0 0 0];
        col_bot='k'; 
    case 'esp2'
        cmap=esp2_colormap();
        col_ax='k';
        col_lab=[0.8 0.8 0.8];
        col_grid=[1 1 1];
        col_bot='y';
    case 'ek500'
        cmap=ek500_colormap();
        col_ax='w';
        col_lab='k';
        col_grid=[0 0 0];
        col_bot='g'; % Simrad sounders use a green bottom line
end


set(axes_panel_comp.vaxes,'YColor',col_lab);
set(axes_panel_comp.haxes,'XColor',col_lab);
set(axes_panel_comp.main_axes,'Color',col_ax,'GridColor',col_grid);
set(axes_panel_comp.bottom_plot,'Color',col_bot);
set(mini_axes_comp.mini_ax,'Color',col_ax,'GridColor',col_grid);
set(mini_axes_comp.bottom_plot,'Color',col_bot);
tog_reg_callback([],[],main_figure)

colormap(mini_axes_comp.mini_ax,cmap);
colormap(axes_panel_comp.main_axes,cmap);

end