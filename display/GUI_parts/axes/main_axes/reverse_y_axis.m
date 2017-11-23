function reverse_y_axis(main_figure)
main_menu=getappdata(main_figure,'main_menu');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
mini_axes_comp=getappdata(main_figure,'Mini_axes');
curr_disp=getappdata(main_figure,'Curr_disp');

reverse_y_axis_state=get(main_menu.reverse_y_axis,'checked');

switch reverse_y_axis_state
    case 'off'
        set(axes_panel_comp.main_axes,'YDir','reverse');
        set(axes_panel_comp.vaxes,'YDir','reverse');
        set(mini_axes_comp.mini_ax,'YDir','reverse');
        if isappdata(main_figure,'Secondary_freq')&&curr_disp.DispSecFreqs>0
            secondary_freq=getappdata(main_figure,'Secondary_freq');
            set(secondary_freq.axes,'YDir','reverse');
        end
    case 'on'
        set(axes_panel_comp.main_axes,'YDir','normal');
        set(axes_panel_comp.vaxes,'YDir','normal');
        set(mini_axes_comp.mini_ax,'YDir','normal');
        if isappdata(main_figure,'Secondary_freq')&&curr_disp.DispSecFreqs>0
            secondary_freq=getappdata(main_figure,'Secondary_freq');
            set(secondary_freq.axes,'YDir','normal');          
        end
end

