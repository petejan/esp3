function reset_mode(~,~,main_figure)

axes_panel_comp=getappdata(main_figure,'Axes_panel');
cursor_mode_tool_comp=getappdata(main_figure,'Cursor_mode_tool');

childs=[findall(main_figure,'type','uitoggletool');findall(main_figure,'type','uitogglesplittool')];
set(childs,'state','off');
set(cursor_mode_tool_comp.pointer,'state','on')
initialize_interactions_v2(main_figure);
iptPointerManager(main_figure,'enable');
create_context_menu_main_echo(main_figure);
create_context_menu_bottom(main_figure,axes_panel_comp.bottom_plot);
end