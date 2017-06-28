function reset_mode(~,~,main_figure)

axes_panel_comp=getappdata(main_figure,'Axes_panel');

%  region_tab_comp=getappdata(main_figure,'Region_tab');
% set(region_tab_comp.create_button,'value',get(region_tab_comp.create_button,'Min'));

childs=[findall(main_figure,'type','uitoggletool');findall(main_figure,'type','uitogglesplittool')];
set(childs,'state','off');
initialize_interactions_v2(main_figure);
iptPointerManager(main_figure,'enable');
create_context_menu_main_echo(main_figure);
create_context_menu_bottom(main_figure,axes_panel_comp.bottom_plot);
end