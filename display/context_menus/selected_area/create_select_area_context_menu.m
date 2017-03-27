function create_select_area_context_menu(select_plot,main_figure)

context_menu=uicontextmenu(main_figure);
select_plot.UIContextMenu=context_menu;

uimenu(context_menu,'Label','Apply Bottom Detection V1 ','Callback',{@apply_bottom_detect_cback,select_plot,main_figure,'v1'});
uimenu(context_menu,'Label','Apply Bottom Detection V2 ','Callback',{@apply_bottom_detect_cback,select_plot,main_figure,'v2'});
uimenu(context_menu,'Label','Shift Bottom ','Callback',{@shift_bottom_callback,select_plot,main_figure});
uimenu(context_menu,'Label','Apply Single Target Detection ','Callback',{@apply_st_detect_cback,select_plot,main_figure});


end


