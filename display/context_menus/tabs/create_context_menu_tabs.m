function tab_menu=create_context_menu_tabs(main_figure,tab_h,tab)

tab_menu = uicontextmenu(ancestor(tab_h,'figure'));
uimenu(tab_menu,'Label','Undock to External Window','Callback',{@undock_tab_callback,main_figure,tab,'new_fig'});
uimenu(tab_menu,'Label','Undock to Option panel','Callback',{@undock_tab_callback,main_figure,tab,'opt_tab'});
uimenu(tab_menu,'Label','Undock to Echogramm panel','Callback',{@undock_tab_callback,main_figure,tab,'echo_tab'});

end