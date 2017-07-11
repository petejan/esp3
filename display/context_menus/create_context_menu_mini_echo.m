function create_context_menu_mini_echo(main_figure)
mini_axes_comp=getappdata(main_figure,'Mini_axes');
 
parent=ancestor(mini_axes_comp.mini_ax,'figure');

delete(findall(parent,'Tag','miniechoCtxtMenu'));
context_menu=uicontextmenu(parent,'Tag','miniechoCtxtMenu');
mini_axes_comp.mini_echo_bt.UIContextMenu=context_menu;
mini_axes_comp.mini_axes.UIContextMenu=context_menu;
mini_axes_comp.patch_obj.UIContextMenu=context_menu;

if parent==main_figure
    uimenu(context_menu,'Label','Dock/Undock MiniAxes','Callback',{@undock_mini_axes_callback,main_figure,'out_figure'});
else
    uimenu(context_menu,'Label','Dock/Undock MiniAxes','Callback',{@undock_mini_axes_callback,main_figure,'main_figure'});
end

end