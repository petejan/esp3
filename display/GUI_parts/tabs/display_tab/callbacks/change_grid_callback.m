function change_grid_callback(src,~,main_figure)

display_tab_comp=getappdata(main_figure,'Display_tab');
curr_disp=getappdata(main_figure,'Curr_disp');

val=str2double(get(src,'string'));

if val>0
    dx=str2double(get(display_tab_comp.grid_x,'string'));
    dy=str2double(get(display_tab_comp.grid_y,'string'));
    curr_disp.set_dx_dy(dx,dy,[]);
else
    [dx,dy]=curr_disp.get_dx_dy();
    set(display_tab_comp.grid_x,'string',num2str(dx,'%.0f'));
    set(display_tab_comp.grid_y,'string',num2str(dy,'%.0f'));
    return;
end


update_grid(main_figure);
update_grid_mini_ax(main_figure);

end