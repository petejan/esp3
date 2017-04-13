function load_map_tab(main_figure,tab_panel)

switch tab_panel.Type
    case 'uitabgroup'
        map_tab_comp.map_tab=uitab(tab_panel,'Title','Map','backgroundcolor','w');
        tab_menu = uicontextmenu(ancestor(tab_panel,'figure'));
        map_tab_comp.map_tab.UIContextMenu=tab_menu;
        uimenu(tab_menu,'Label','Undock map','Callback',{@undock_map_tab_callback,main_figure,'out_figure'});
    case 'figure'
        map_tab_comp.map_tab=tab_panel;
end

map_tab_comp.ax=[];
map_tab_comp.tracks=[];
map_tab_comp.boat_pos=[];
map_tab_comp.Proj=[];
map_tab_comp.LongLim=[];
map_tab_comp.LatLim=[];

setappdata(main_figure,'Map_tab',map_tab_comp);

update_map_tab(main_figure);
end
