function update_echo_int_cmap(main_figure)

curr_disp=getappdata(main_figure,'Curr_disp');
echo_int_tab_comp=getappdata(main_figure,'EchoInt_tab');

[cmap, col_ax, col_lab, col_grid, col_bot, col_txt]=init_cmap(curr_disp.Cmap);
colormap(echo_int_tab_comp.main_ax,cmap);
set(echo_int_tab_comp.main_ax,...
    'Color', col_ax,...
    'GridColor',col_grid);

end