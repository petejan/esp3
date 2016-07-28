function update_cmap(main_figure)

axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
display_tab_comp=getappdata(main_figure,'Display_tab');


switch lower(curr_disp.Cmap)
    case 'esp2'
        
    case 'ek500'
        
    otherwise
        
end

switch lower(curr_disp.Cmap)
    case 'esp2'
        
    case 'ek500'
        
    otherwise
        
end

switch lower(curr_disp.Cmap)
    case 'jet'
        cmap=colormap('jet');
        col_ax='w';
        col_lab='k';
        col_grid=[0 0 0];
        col_bot='k';
    case 'hsv'
        cmap=colormap('hsv');
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

axes_panel_comp.main_axes.GridColor=col_grid;
set(axes_panel_comp.vaxes,'YColor',col_lab);
set(axes_panel_comp.haxes,'XColor',col_lab);
set(axes_panel_comp.main_axes,'Color',col_ax);
set(axes_panel_comp.bottom_plot,'Color',col_bot);
set(display_tab_comp.mini_ax,'Color',col_ax);

colormap(display_tab_comp.mini_ax,cmap);
colormap(axes_panel_comp.main_axes,cmap);

end