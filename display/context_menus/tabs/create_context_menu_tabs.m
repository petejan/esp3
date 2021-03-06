function tab_menu=create_context_menu_tabs(main_figure,tab_h,tab_name)

tab_menu = uicontextmenu(ancestor(tab_h,'figure'));
switch tab_name
    case 'echoint_tab'
        uimenu(tab_menu,'Label','Undock to External Window','Callback',{@undock_tab_callback,main_figure,tab_name,'new_fig'});
    otherwise
        uimenu(tab_menu,'Label','Undock to External Window','Callback',{@undock_tab_callback,main_figure,tab_name,'new_fig'});
        uimenu(tab_menu,'Label','Undock to Option panel','Callback',{@undock_tab_callback,main_figure,tab_name,'opt_tab'});
        uimenu(tab_menu,'Label','Undock to Echogram panel','Callback',{@undock_tab_callback,main_figure,tab_name,'echo_tab'});
end

end