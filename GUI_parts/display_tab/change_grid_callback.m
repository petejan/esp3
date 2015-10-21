function change_grid_callback(src,~,main_figure)
display_tab_comp=getappdata(main_figure,'Display_tab');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
val=str2double(get(src,'string'));

if val>0
    curr_disp.Grid_x=str2double(get(display_tab_comp.grid_x,'string'));
    curr_disp.Grid_y=str2double(get(display_tab_comp.grid_y,'string'));
else
    set(display_tab_comp.grid_x,'string',num2str(curr_disp.Grid_x,'%.0f'));
    set(display_tab_comp.grid_y,'string',num2str(curr_disp.Grid_y,'%.0f'));
end

xdata=get(axes_panel_comp.main_echo,'XData');
ydata=get(axes_panel_comp.main_echo,'YData');

switch curr_disp.Xaxes
    case 'Time'
        dx=curr_disp.Grid_x/(24*60*60);
    otherwise
        dx=curr_disp.Grid_x;
end

set(axes_panel_comp.main_axes,'Xtick',(xdata(1):dx:xdata(end)),'Ytick',(ydata(1):curr_disp.Grid_y:ydata(end)));
set(axes_panel_comp.haxes,'Xtick',(xdata(1):dx:xdata(end)));
set(axes_panel_comp.vaxes,'Ytick',(ydata(1):curr_disp.Grid_y:ydata(end)));

update_xtick_labels([],[],axes_panel_comp.haxes,curr_disp.Xaxes);
update_ytick_labels([],[],axes_panel_comp.vaxes);

end