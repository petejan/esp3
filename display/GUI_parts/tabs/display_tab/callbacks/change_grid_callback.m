function change_grid_callback(src,~,main_figure)

display_tab_comp=getappdata(main_figure,'Display_tab');
curr_disp=getappdata(main_figure,'Curr_disp');


val=str2double(get(src,'string'));
if val>0
    curr_disp.Grid_x=str2double(get(display_tab_comp.grid_x,'string'));
    curr_disp.Grid_y=str2double(get(display_tab_comp.grid_y,'string'));
else
    set(display_tab_comp.grid_x,'string',num2str(curr_disp.Grid_x,'%.0f'));
    set(display_tab_comp.grid_y,'string',num2str(curr_disp.Grid_y,'%.0f'));
    return;
end

update_grid(main_figure);
end