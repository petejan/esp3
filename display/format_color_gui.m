function format_color_gui(fig)

set(fig,'Color','White');

panel_obj=findobj(fig,'Type','uipanel');
set(panel_obj,'BackgroundColor','White','bordertype','line');

tab_obj=findobj(fig,'Type','uitab');
set(tab_obj,'BackgroundColor','White');

control_obj=findobj(fig,'Type','uicontrol','-not',{'Style','PushButton','-or','Style','togglebutton'});
set(control_obj,'BackgroundColor','White');

end