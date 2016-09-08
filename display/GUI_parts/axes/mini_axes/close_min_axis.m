function close_min_axis(src,~,main_figure)

display_tab_comp=getappdata(main_figure,'Display_tab');
load_mini_axes(main_figure,display_tab_comp.display_tab,[0.05 0.1 0.75 0.45]);
update_mini_ax(main_figure,1);
update_cmap(main_figure);
reverse_y_axis(main_figure);
display_bottom(main_figure);
delete(src);



end