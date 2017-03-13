function reset_mode(~,~,main_figure)

axes_panel_comp=getappdata(main_figure,'Axes_panel');

%  region_tab_comp=getappdata(main_figure,'Region_tab');
% set(region_tab_comp.create_button,'value',get(region_tab_comp.create_button,'Min'));

ah=axes_panel_comp.main_axes;
axes(ah);
childs=findall(main_figure,'type','uitoggletool');
set(childs,'state','off');
iptPointerManager(main_figure,'enable');
initialize_interactions(main_figure,0);
create_context_menu_main_echo(main_figure);
create_context_menu_bottom(main_figure,axes_panel_comp.bottom_plot);
end