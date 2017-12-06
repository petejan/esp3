function reverse_y_axis(main_figure)
main_menu=getappdata(main_figure,'main_menu');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
mini_axes_comp=getappdata(main_figure,'Mini_axes');
curr_disp=getappdata(main_figure,'Curr_disp');

reverse_y_axis_state=get(main_menu.reverse_y_axis,'checked');

switch reverse_y_axis_state
    case 'off'
        set(axes_panel_comp.main_axes,'YDir','reverse');
    case 'on'
        set(axes_panel_comp.main_axes,'YDir','normal');
end

