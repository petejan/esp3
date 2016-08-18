function resize_mini_ax(src,~,main_figure)
load_mini_axes(main_figure,src,[0 0 1 1]);
update_mini_ax(main_figure,1);
update_cmap(main_figure);
end