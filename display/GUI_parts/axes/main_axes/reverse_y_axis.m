function reverse_y_axis(main_figure)
main_menu=getappdata(main_figure,'main_menu');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
mini_axes_comp=getappdata(main_figure,'Mini_axes');


reverse_y_axis_state=get(main_menu.reverse_y_axis,'checked');

switch reverse_y_axis_state
    case 'off'
        set(axes_panel_comp.main_axes,'YDir','reverse');
        set(axes_panel_comp.vaxes,'YDir','reverse');
        set(mini_axes_comp.mini_ax,'YDir','reverse');
    case 'on'
        set(axes_panel_comp.main_axes,'YDir','normal');
        set(axes_panel_comp.vaxes,'YDir','normal');
        set(mini_axes_comp.mini_ax,'YDir','normal');
end
end
